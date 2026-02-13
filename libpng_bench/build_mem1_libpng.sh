#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEM1_ROOT="${MEM1_ROOT:-$ROOT/../wasm-mem1_sfi}"

PASS_DIR="$MEM1_ROOT/passes"
OUT_DIR="$ROOT/build/mem1"
DEBUG_DIR="$OUT_DIR/debug"

REWRITE_SO="$PASS_DIR/build/libRewriteWasmFFI.so"
RUST_ALLOC_SO="$PASS_DIR/build/libRewriteRustAllocToMem1.so"
PASS_MARK_SO="$PASS_DIR/build/libMarkMem1FFI.so"
PASS_NOP_NORMAL_SO="$PASS_DIR/build/libInsertNopGrow.so"
INJECT_SO="$PASS_DIR/build/libInjectMem1Markers.so"
RUNTIME_A="$MEM1_ROOT/build/mem1_runtime.a"
WASM_OPT_BIN="${WASM_OPT_BIN:-wasm-opt}"

LIBPNG_SRC_DIR="${LIBPNG_SRC_DIR:-$ROOT/vendor/libpng}"
ZLIB_SRC_DIR="${ZLIB_SRC_DIR:-$ROOT/vendor/zlib}"
LIBPNG_LIB="${LIBPNG_LIB:-$LIBPNG_SRC_DIR/libpng.a}"
ZLIB_LIB="${ZLIB_LIB:-$ZLIB_SRC_DIR/libz.a}"
DEFAULT_CFLAGS_LIBPNG="-I$ROOT/support -I$LIBPNG_SRC_DIR -I$ZLIB_SRC_DIR"
CFLAGS_LIBPNG_EFFECTIVE="${CFLAGS_LIBPNG:-$DEFAULT_CFLAGS_LIBPNG}"

mkdir -p "$OUT_DIR" "$PASS_DIR/build" "$DEBUG_DIR"

LOG_FILE="$DEBUG_DIR/output_mem1_build.txt"
C_FFI_BC="$OUT_DIR/mem1_c_ffi.bc"
LIBC_SHIM_BC="$OUT_DIR/mem1_libc_shim.bc"
LIBC_SHIM_NOP_BC="$OUT_DIR/mem1_libc_shim_nop.bc"
C_FFI_NOP_BC="$OUT_DIR/mem1_c_ffi_nop.bc"
C_FFI_MARKED_BC="$OUT_DIR/mem1_c_ffi_marked.bc"
RUST_FFI_BC="$OUT_DIR/mem1_rust_ffi.bc"
RUST_FFI_RO_BC="$OUT_DIR/mem1_rust_ffi.ro.bc"
MEM1_RO_LIST_TSV="$OUT_DIR/mem1_ro_list.tsv"
MEM1_FFI_LIST_TSV="$OUT_DIR/mem1_ffi_list.tsv"
COMBINED_BC="$OUT_DIR/mem1_combined.bc"
COMBINED_REWRITTEN_BC="$OUT_DIR/mem1_combined.rewritten.bc"
COMBINED_O="$OUT_DIR/mem1_combined.o"
COMBINED_RAW_WASM="$OUT_DIR/combined_mem1_raw.wasm"
COMBINED_RAW_WAT="$OUT_DIR/combined_mem1_raw.wat"
FINAL_WASM="$OUT_DIR/final_mem1.wasm"
FINAL_WAT="$OUT_DIR/final_mem1.wat"
DEBUG_DCMP="$DEBUG_DIR/final_mem1.dcmp"

INTERMEDIATE_FILES=(
  "$C_FFI_BC"
  "$LIBC_SHIM_BC"
  "$LIBC_SHIM_NOP_BC"
  "$C_FFI_NOP_BC"
  "$C_FFI_MARKED_BC"
  "$RUST_FFI_BC"
  "$RUST_FFI_RO_BC"
  "$COMBINED_BC"
  "$COMBINED_REWRITTEN_BC"
  "$COMBINED_O"
  "$COMBINED_RAW_WASM"
  "$COMBINED_RAW_WAT"
)

cleanup_intermediates() {
  rm -f "${INTERMEDIATE_FILES[@]}"
}
trap cleanup_intermediates EXIT

exec > >(tee "$LOG_FILE") 2>&1

echo "[0] pass, allocator 빌드"
missing_passes=()
for so in "$REWRITE_SO" "$RUST_ALLOC_SO" "$PASS_NOP_NORMAL_SO" "$PASS_MARK_SO" "$INJECT_SO"; do
  if [[ ! -f "$so" ]]; then
    missing_passes+=("$so")
  fi
done

if (( ${#missing_passes[@]} > 0 )); then
  echo "[0a] 누락된 패스 발견 -> build_passes.sh 실행"
  printf '  - %s\n' "${missing_passes[@]}"
  "$MEM1_ROOT/build_passes.sh"
else
  echo "[0a] 패스들 빌드 생략 (모두 존재)"
fi

if [[ ! -f "$RUNTIME_A" ]]; then
  echo "[0b] mem1_runtime.a 없음 -> build_allocator.sh 실행"
  "$MEM1_ROOT/build_allocator.sh"
else
  echo "[0b] allocator 빌드 생략 (mem1_runtime.a 존재)"
fi

if [[ ! -f "$LIBPNG_LIB" ]]; then
  echo "error: missing libpng static library: $LIBPNG_LIB"
  exit 1
fi
if [[ ! -f "$ZLIB_LIB" ]]; then
  echo "error: missing zlib static library: $ZLIB_LIB"
  exit 1
fi

C_FFI_SRC="$ROOT/project_testing/c_libpng.c"
RUST_FFI_SRC="$ROOT/project_testing/rust_libpng.rs"
LIBC_SHIM_SRC="$ROOT/support/libc_shim_mem1.c"

echo "=== [01] C callee -> LLVM bc ==="
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_LIBPNG_EFFECTIVE} -emit-llvm -c "$C_FFI_SRC" -o "$C_FFI_BC"
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding -fno-builtin -emit-llvm \
  -c "$LIBC_SHIM_SRC" -o "$LIBC_SHIM_BC"

echo "=== [02] LLVM passes: insert-nop + MarkMem1FFI ==="
opt-18 -load-pass-plugin="$PASS_NOP_NORMAL_SO" -passes='function(insert-nop-grow)' "$C_FFI_BC" -o "$C_FFI_NOP_BC"
opt-18 -load-pass-plugin="$PASS_NOP_NORMAL_SO" -passes='function(insert-nop-grow)' "$LIBC_SHIM_BC" -o "$LIBC_SHIM_NOP_BC"

MEM1FFI_LIST_OUT="$MEM1_FFI_LIST_TSV" \
  opt-18 -load-pass-plugin="$PASS_MARK_SO" -passes=mark-mem1-ffi "$C_FFI_NOP_BC" -o "$C_FFI_MARKED_BC"

echo "=== [03] Rust caller -> LLVM bc ==="
MEM1_RO_LIST_OUT="$MEM1_RO_LIST_TSV" \
MEM1_FFI_LIST="$MEM1_FFI_LIST_TSV" \
  bash "$MEM1_ROOT/tools/mem1-rustc/mem1-rustc.sh" \
    --target=wasm32-unknown-unknown -C opt-level=2 \
    --emit=llvm-bc -o "$RUST_FFI_BC" "$RUST_FFI_SRC"

MEM1_RO_LIST="$MEM1_RO_LIST_TSV" \
  opt-18 -load-pass-plugin="$INJECT_SO" -passes=inject-mem1-markers \
    "$RUST_FFI_BC" -o "$RUST_FFI_RO_BC"

echo "=== [04] Link + rewrite ==="
llvm-link-18 "$RUST_FFI_RO_BC" "$C_FFI_MARKED_BC" "$LIBC_SHIM_NOP_BC" -o "$COMBINED_BC"

opt-18 -load-pass-plugin="$RUST_ALLOC_SO" -load-pass-plugin="$REWRITE_SO" \
  -passes=rewrite-wasm-ffi "$COMBINED_BC" -o "$COMBINED_REWRITTEN_BC"

echo "=== [05] Codegen + link ==="
llc-18 -filetype=obj -march=wasm32 "$COMBINED_REWRITTEN_BC" -o "$COMBINED_O"

wasm-ld --no-entry --export-all --no-gc-sections \
  "$COMBINED_O" "$RUNTIME_A" "$LIBPNG_LIB" "$ZLIB_LIB" -o "$COMBINED_RAW_WASM"

command -v wasm2wat >/dev/null 2>&1 && wasm2wat --enable-multi-memory "$COMBINED_RAW_WASM" -o "$COMBINED_RAW_WAT"

echo "=== [06] Binaryen: Mem1RewritePass ==="
if ! "$WASM_OPT_BIN" --help 2>/dev/null | grep -q -- "--Mem1RewritePass"; then
  echo "error: $WASM_OPT_BIN does not provide --Mem1RewritePass"
  echo "hint: use the exact custom wasm-opt binary used by your snappy mem1 build"
  exit 1
fi

if "$WASM_OPT_BIN" "$COMBINED_RAW_WASM" --enable-multimemory --Mem1RewritePass -o "$FINAL_WASM" 2>/dev/null; then
  :
elif "$WASM_OPT_BIN" "$COMBINED_RAW_WASM" --enable-multi-memory --Mem1RewritePass -o "$FINAL_WASM" 2>/dev/null; then
  :
else
  echo "error: $WASM_OPT_BIN failed with both --enable-multimemory and --enable-multi-memory"
  echo "hint: check binaryen version/flags for the custom wasm-opt used in snappy mem1"
  exit 1
fi

if command -v wasm2wat >/dev/null 2>&1 && command -v wat2wasm >/dev/null 2>&1 && [[ -f "$MEM1_ROOT/tools/fix_mem1_default_loads.py" ]]; then
  python3 "$MEM1_ROOT/tools/fix_mem1_default_loads.py" --wasm "$FINAL_WASM"
fi

command -v wasm2wat >/dev/null 2>&1 && wasm2wat --enable-multi-memory "$FINAL_WASM" -o "$FINAL_WAT"
command -v wasm-decompile >/dev/null 2>&1 && wasm-decompile --enable-all "$FINAL_WASM" -o "$DEBUG_DCMP"

echo "=== [07] wasmtime sanity check ==="
if command -v wasmtime >/dev/null 2>&1 && [[ -f "$FINAL_WASM" ]]; then
  wasmtime "$FINAL_WASM" --invoke bench_prepare 1024 || true
  wasmtime "$FINAL_WASM" --invoke bench_png_encode 1024 || true
  wasmtime "$FINAL_WASM" --invoke bench_png_decode 1024 || true
else
  echo "wasmtime missing or output wasm not found: $FINAL_WASM"
fi

echo "=== done: $FINAL_WASM ==="
