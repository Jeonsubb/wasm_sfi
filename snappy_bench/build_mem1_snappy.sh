#!/usr/bin/env bash
set -euo pipefail

# 원본 wasm-mem1 패스/런타임을 그대로 사용하면서,
# 소스와 결과물만 snappy_bench 디렉토리를 바라보는 파이프라인 스크립트입니다.
# mem1 테스트 파이프라인(build_mem1_ffi.sh)와 동일하게:
# - mem1-rustc 래퍼 사용 (RO/FFI 리스트 TSV 생성)
# - inject-mem1-markers, rewrite-rust-alloc-to-mem1 패스 추가

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEM1_ROOT="${MEM1_ROOT:-$ROOT/../wasm-mem1_sfi}"
SNAPPY_ROOT="${SNAPPY_ROOT:-$ROOT}"
SNAPPY_SRC_DIR="$SNAPPY_ROOT/vendor/snappy"

SNAPPY_LIB_DEFAULT="$SNAPPY_SRC_DIR/libsnappy.a"
DEFAULT_CFLAGS_SNAPPY="-I$SNAPPY_ROOT/support -I$SNAPPY_SRC_DIR"

PASS_DIR="$MEM1_ROOT/passes"
OUT_DIR="$SNAPPY_ROOT/build/mem1"
DEBUG_DIR="$OUT_DIR/debug"

REWRITE_SO="$PASS_DIR/build/libRewriteWasmFFI.so"
RUST_ALLOC_SO="$PASS_DIR/build/libRewriteRustAllocToMem1.so"
PASS_MARK_SO="$PASS_DIR/build/libMarkMem1FFI.so"
PASS_NOP_NORMAL_SO="$PASS_DIR/build/libInsertNopGrow.so" 
INJECT_SO="$PASS_DIR/build/libInjectMem1Markers.so"
RUNTIME_A="$MEM1_ROOT/build/mem1_runtime.a"
if [[ -z "${WASM_OPT_BIN:-}" ]]; then
  if [[ -x "$ROOT/../binaryen/build/bin/wasm-opt" ]]; then
    WASM_OPT_BIN="$ROOT/../binaryen/build/bin/wasm-opt"
  else
    WASM_OPT_BIN="wasm-opt"
  fi
fi

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
MEM1_REWRITE_WASM="$OUT_DIR/final_mem1.rewrite.wasm"

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
  "$MEM1_REWRITE_WASM"
  # "$DEBUG_DCMP"
  # "$LOG_FILE"
)

cleanup_intermediates() {
  rm -f "${INTERMEDIATE_FILES[@]}"
}
trap cleanup_intermediates EXIT

exec > >(tee "$LOG_FILE") 2>&1 # 출력 리다이렉트

echo "[0] pass, allocator 빌드"
echo "[0a] 패스들 빌드"
missing_passes=()
for so in "$REWRITE_SO" "$RUST_ALLOC_SO" "$PASS_NOP_NORMAL_SO" "$PASS_MARK_SO" "$INJECT_SO"; do
  if [[ ! -f "$so" ]]; then
    missing_passes+=("$so")
  fi
done

if (( ${#missing_passes[@]} > 0 )); then
  echo "[0a] 누락된 패스 발견 → build_passes.sh 실행"
  printf '  - %s\n' "${missing_passes[@]}"
  if [[ -x "$MEM1_ROOT/build_passes.sh" ]]; then
    "$MEM1_ROOT/build_passes.sh"
  else
    echo "오류: $MEM1_ROOT/build_passes.sh 를 찾을 수 없습니다."
    exit 1
  fi
else
  echo "[0a] 패스들 빌드 생략 (모두 존재)"
fi

echo "[0b] build_allocator.sh 커스텀 할당자 빌드 ( mem0_load, __mem1_alloc... etc) "
if [[ ! -f "$RUNTIME_A" ]]; then
  if [[ -x "$MEM1_ROOT/build_allocator.sh" ]]; then
    echo "[0b] mem1_runtime.a 없음 → build_allocator.sh 실행"
    "$MEM1_ROOT/build_allocator.sh"
  else
    echo "오류: $MEM1_ROOT/build_allocator.sh 를 찾을 수 없습니다."
    exit 1
  fi
else
  NM=""
  command -v llvm-nm-18 >/dev/null 2>&1 && NM="llvm-nm-18"
  command -v llvm-nm >/dev/null 2>&1 && [[ -z "$NM" ]] && NM="llvm-nm"
  if [[ -n "$NM" ]] && ! "$NM" "$RUNTIME_A" 2>/dev/null | grep -q "__mem1_ro_ptr"; then
    echo "[0b] mem1_runtime.a 에 마커 심볼 누락 → build_allocator.sh 재실행"
    "$MEM1_ROOT/build_allocator.sh"
  else
    echo "[0b] allocator 빌드 생략 (mem1_runtime.a 존재)"
  fi
fi

C_FFI_SRC="$SNAPPY_ROOT/project_testing/c_snappy.c"
RUST_FFI_SRC="$SNAPPY_ROOT/project_testing/rust_snappy.rs"
LIBC_SHIM_SRC="$SNAPPY_ROOT/support/libc_shim_mem1.c"
CFLAGS_SNAPPY_EFFECTIVE="${CFLAGS_SNAPPY:-$DEFAULT_CFLAGS_SNAPPY}"

echo "=== [01] C callee -> LLVM bc ==="
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_SNAPPY_EFFECTIVE} -emit-llvm -c "$C_FFI_SRC" -o "$C_FFI_BC"
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding -fno-builtin -emit-llvm \
  -c "$LIBC_SHIM_SRC" -o "$LIBC_SHIM_BC"

echo "=== [02] LLVM passes: insert-nop + MarkMem1FFI ==="
echo "=== [02a] Pass: insert-nop-grow ==="
opt-18 -load-pass-plugin="$PASS_NOP_NORMAL_SO" -passes='function(insert-nop-grow)' "$C_FFI_BC" -o "$C_FFI_NOP_BC"
# llvm-dis-18 "$C_FFI_NOP_BC" -o "${C_FFI_NOP_BC%.*}.ll"

echo "=== [02a-2] Pass: insert-nop-grow (libc_shim) ==="
opt-18 -load-pass-plugin="$PASS_NOP_NORMAL_SO" -passes='function(insert-nop-grow)' "$LIBC_SHIM_BC" -o "$LIBC_SHIM_NOP_BC"

echo "=== [02b] Pass: mark-mem1-ffi ==="
MEM1FFI_LIST_OUT="$MEM1_FFI_LIST_TSV" \
  opt-18 -load-pass-plugin="$PASS_MARK_SO" -passes=mark-mem1-ffi "$C_FFI_NOP_BC" -o "$C_FFI_MARKED_BC"

echo "=== [03] Rust caller -> LLVM bc ==="
MEM1_RO_LIST_OUT="$MEM1_RO_LIST_TSV" \
MEM1_FFI_LIST="$MEM1_FFI_LIST_TSV" \
  bash "$MEM1_ROOT/tools/mem1-rustc/mem1-rustc.sh" \
    --target=wasm32-unknown-unknown -C opt-level=2 \
    --emit=llvm-bc -o "$RUST_FFI_BC" "$RUST_FFI_SRC"

echo "=== [03b] Pass: inject-mem1-markers (Rust bc) ==="
MEM1_RO_LIST="$MEM1_RO_LIST_TSV" \
  opt-18 -load-pass-plugin="$INJECT_SO" -passes=inject-mem1-markers \
    "$RUST_FFI_BC" -o "$RUST_FFI_RO_BC"
# llvm-dis-18 "$RUST_FFI_BC" -o "${RUST_FFI_BC%.*}.ll"
# llvm-dis-18 "$RUST_FFI_RO_BC" -o "${RUST_FFI_RO_BC%.*}.ll"



echo "=== [04] Link: Rust + C + libc_shim ==="
llvm-link-18 "$RUST_FFI_RO_BC" "$C_FFI_MARKED_BC" "$LIBC_SHIM_NOP_BC" -o "$COMBINED_BC"

echo "=== [04a] Pass: rewrite-wasm-ffi ==="
opt-18  -load-pass-plugin="$RUST_ALLOC_SO" -load-pass-plugin="$REWRITE_SO" \
  -passes=rewrite-wasm-ffi "$COMBINED_BC" -o "$COMBINED_REWRITTEN_BC"
llvm-dis-18 "$COMBINED_REWRITTEN_BC" -o "${COMBINED_REWRITTEN_BC%.*}.ll"

echo "=== [05] Codegen + link ==="
echo "=== [05a] llc: combined.bc -> combined.o ==="
llc-18 -filetype=obj -march=wasm32 "$COMBINED_REWRITTEN_BC" -o "$COMBINED_O"

echo "=== [05b] wasm-ld: add mem1 runtime ==="
wasm-ld --no-entry --export-all --no-gc-sections \
  "$COMBINED_O" "$RUNTIME_A" -o "$COMBINED_RAW_WASM" \


echo "=== [05c] wasm2wat: combined_raw.wat (optional) ==="
command -v wasm2wat >/dev/null 2>&1 && wasm2wat --enable-multi-memory "$COMBINED_RAW_WASM" -o "$COMBINED_RAW_WAT"

echo "=== [06] Binaryen: mem1-rewrite + mem1-inline-memcpy ==="
"$WASM_OPT_BIN" "$COMBINED_RAW_WASM" --enable-multimemory --enable-bulk-memory \
  --mem1-rewrite \
  -o "$MEM1_REWRITE_WASM"
"$WASM_OPT_BIN" "$MEM1_REWRITE_WASM" --enable-multimemory --enable-bulk-memory \
  --mem1-inline-memcpy \
  -o "$FINAL_WASM"

if command -v wasm2wat >/dev/null 2>&1 && command -v wat2wasm >/dev/null 2>&1 && [[ -f "$MEM1_ROOT/tools/fix_mem1_default_loads.py" ]]; then
  echo "=== [06a] post-fix: normalize implicit default load ops to memory index 1 (mem1-heavy funcs) ==="
  python3 "$MEM1_ROOT/tools/fix_mem1_default_loads.py" --wasm "$FINAL_WASM"
fi

command -v wasm2wat >/dev/null 2>&1 && wasm2wat --enable-multi-memory "$FINAL_WASM" -o "$FINAL_WAT"

echo "=== done: $FINAL_WASM ==="
echo ""


echo "=== [07] Debug artifacts ==="
mkdir -p "$DEBUG_DIR"

echo "=== [07a] wasm-decompile -> $DEBUG_DCMP ==="
wasm-decompile --enable-all "$FINAL_WASM" -o "$DEBUG_DCMP"
echo ""

echo "=== [08] wasmtime sanity check ==="
if command -v wasmtime >/dev/null 2>&1 && [[ -f "$FINAL_WASM" ]]; then
  wasmtime "$FINAL_WASM" --invoke test_snappy_roundtrip || true
else
  echo "wasmtime이 없거나 $FINAL_WASM이 없습니다."
fi

echo "=== end ==="
