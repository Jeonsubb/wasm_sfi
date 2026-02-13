#!/usr/bin/env bash
set -euo pipefail

# Build snappy benchmark with SFI protection in single-memory mode.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SFI_ROOT="${SFI_ROOT:-$ROOT/../wasm-mem1_sfi}"

PASS_DIR="$SFI_ROOT/passes"
SFI_DIR="$SFI_ROOT/sfi"
OUT_DIR="$ROOT/build/sfi"
DEBUG_DIR="$OUT_DIR/debug"

REWRITE_SO="$PASS_DIR/build/libRewriteWasmFFI.so"
MARK_SO="$PASS_DIR/build/libMarkMem1FFI.so"
INJECT_SO="$PASS_DIR/build/libInjectMem1Markers.so"
SFI_BOUNDS_SO="$PASS_DIR/build/libSfiBoundsCheck.so"
SFI_RUNTIME_A="$SFI_DIR/build/sfi_runtime.a"

C_FFI_SRC="$ROOT/project_testing/c_snappy.c"
RUST_FFI_SRC="$ROOT/project_testing/rust_snappy.rs"
LIBC_SHIM_SRC="$ROOT/support/libc_shim.c"

COMBINED_RAW_WASM="$OUT_DIR/combined_sfi_snappy_raw.wasm"
COMBINED_RAW_WAT="$OUT_DIR/combined_sfi_snappy_raw.wat"
FINAL_WASM="$OUT_DIR/final_sfi_snappy.wasm"
FINAL_WAT="$OUT_DIR/final_sfi_snappy.wat"
FINAL_DCMP="$DEBUG_DIR/final_sfi_snappy.dcmp"
LOG_FILE="$DEBUG_DIR/output_sfi_build.txt"

mkdir -p "$OUT_DIR" "$DEBUG_DIR" "$PASS_DIR/build"
exec > >(tee "$LOG_FILE") 2>&1

# SFI region defaults (same as build_sfi_ffi.sh).
SFI_C_BASE=${SFI_C_BASE:-$((2 * 65536))}
SFI_C_END=${SFI_C_END:-$((SFI_C_BASE + 256 * 65536))}
SFI_C_STACK_TOP=${SFI_C_STACK_TOP:-$SFI_C_END}
SFI_C_HEAP_BASE=${SFI_C_HEAP_BASE:-$((SFI_C_BASE + 4096))}
SFI_C_HEAP_END=${SFI_C_HEAP_END:-$SFI_C_END}
export SFI_C_BASE SFI_C_END SFI_C_STACK_TOP SFI_C_HEAP_BASE SFI_C_HEAP_END

DEFAULT_CFLAGS_SNAPPY="-I$ROOT/support -I$ROOT/vendor/snappy"
CFLAGS_SNAPPY_EFFECTIVE="${CFLAGS_SNAPPY:-$DEFAULT_CFLAGS_SNAPPY}"

C_FFI_BC="$OUT_DIR/sfi_c_snappy.bc"
LIBC_SHIM_BC="$OUT_DIR/sfi_libc_shim.bc"
C_FFI_MARKED_BC="$OUT_DIR/sfi_c_snappy.marked.bc"
RUST_FFI_BC="$OUT_DIR/sfi_rust_snappy.bc"
RUST_FFI_RO_BC="$OUT_DIR/sfi_rust_snappy.ro.bc"
MEM1_RO_LIST_TSV="$OUT_DIR/mem1_ro_list.tsv"
MEM1_FFI_LIST_TSV="$OUT_DIR/mem1_ffi_list.tsv"
COMBINED_BC="$OUT_DIR/sfi_combined.bc"
COMBINED_SFI_BC="$OUT_DIR/sfi_combined.rewritten.bc"
COMBINED_O="$OUT_DIR/sfi_combined.o"

echo "[0] build passes/runtime"
missing_passes=()
for so in "$REWRITE_SO" "$MARK_SO" "$INJECT_SO" "$SFI_BOUNDS_SO"; do
  if [[ ! -f "$so" ]]; then
    missing_passes+=("$so")
  fi
done

if (( ${#missing_passes[@]} > 0 )); then
  echo "[0a] missing passes -> build_passes.sh"
  printf '  - %s\n' "${missing_passes[@]}"
  if [[ -x "$SFI_ROOT/build_passes.sh" ]]; then
    "$SFI_ROOT/build_passes.sh"
  else
    echo "error: missing $SFI_ROOT/build_passes.sh"
    exit 1
  fi
else
  echo "[0a] pass build skipped (already built)"
fi

echo "[0b] build SFI runtime"
if [[ ! -f "$SFI_RUNTIME_A" ]]; then
  if [[ -x "$SFI_DIR/build_sfi_runtime.sh" ]]; then
    "$SFI_DIR/build_sfi_runtime.sh"
  else
    echo "error: missing $SFI_DIR/build_sfi_runtime.sh"
    exit 1
  fi
else
  echo "[0b] runtime build skipped (sfi_runtime.a exists)"
fi

echo "[1] C code -> LLVM bc"
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_SNAPPY_EFFECTIVE} \
  -emit-llvm -c "$C_FFI_SRC" -o "$C_FFI_BC"
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding -fno-builtin \
  -emit-llvm -c "$LIBC_SHIM_SRC" -o "$LIBC_SHIM_BC"

echo "[1a] mark-mem1-ffi pass"
MEM1FFI_LIST_OUT="$MEM1_FFI_LIST_TSV" \
  opt-18 -load-pass-plugin="$MARK_SO" -passes=mark-mem1-ffi "$C_FFI_BC" -o "$C_FFI_MARKED_BC"

echo "[2] Rust code -> LLVM bc"
MEM1_RO_LIST_OUT="$MEM1_RO_LIST_TSV" \
MEM1_FFI_LIST="$MEM1_FFI_LIST_TSV" \
  bash "$SFI_ROOT/tools/mem1-rustc/mem1-rustc.sh" \
    --target=wasm32-unknown-unknown -C opt-level=2 \
    --emit=llvm-bc -o "$RUST_FFI_BC" "$RUST_FFI_SRC"

echo "[2a] inject-mem1-markers pass"
MEM1_RO_LIST="$MEM1_RO_LIST_TSV" \
  opt-18 -load-pass-plugin="$INJECT_SO" -passes=inject-mem1-markers \
    "$RUST_FFI_BC" -o "$RUST_FFI_RO_BC"

echo "[3] link + rewrite-wasm-ffi + sfi-bounds-check"
llvm-link-18 "$RUST_FFI_RO_BC" "$C_FFI_MARKED_BC" "$LIBC_SHIM_BC" -o "$COMBINED_BC"

opt-18 -load-pass-plugin="$REWRITE_SO" -load-pass-plugin="$SFI_BOUNDS_SO" \
  -passes=rewrite-wasm-ffi,sfi-bounds-check \
  "$COMBINED_BC" -o "$COMBINED_SFI_BC"

echo "[4] codegen + wasm link"
llc-18 -filetype=obj -march=wasm32 "$COMBINED_SFI_BC" -o "$COMBINED_O"

wasm-ld --no-entry --export-all --no-gc-sections \
  --initial-memory="$SFI_C_END" --max-memory="$SFI_C_END" \
  "$COMBINED_O" "$SFI_RUNTIME_A" -o "$COMBINED_RAW_WASM"

command -v wasm2wat >/dev/null 2>&1 && wasm2wat "$COMBINED_RAW_WASM" -o "$COMBINED_RAW_WAT"

echo "[5] wasm post-process (C stack split + __sfi_check instrumentation)"
if command -v wasm2wat >/dev/null 2>&1 && command -v wat2wasm >/dev/null 2>&1; then
  python3 "$SFI_ROOT/sfi/tools/sfi_wat_sandbox.py" \
    --in-wasm "$COMBINED_RAW_WASM" \
    --out-wasm "$FINAL_WASM" \
    --c-stack-top "$SFI_C_STACK_TOP"
  command -v wasm2wat >/dev/null 2>&1 && wasm2wat "$FINAL_WASM" -o "$FINAL_WAT"
else
  echo "warn: wasm2wat/wat2wasm missing, skip post-process and copy raw wasm"
  cp -f "$COMBINED_RAW_WASM" "$FINAL_WASM"
  command -v wasm2wat >/dev/null 2>&1 && wasm2wat "$FINAL_WASM" -o "$FINAL_WAT"
fi

echo "[6] debug/decompile"
if command -v wasm-decompile >/dev/null 2>&1; then
  wasm-decompile --enable-all "$FINAL_WASM" -o "$FINAL_DCMP"
fi

echo "[7] wasmtime smoke test"
if command -v wasmtime >/dev/null 2>&1 && [[ -f "$FINAL_WASM" ]]; then
  wasmtime "$FINAL_WASM" --invoke bench_prepare 1024 || true
  wasmtime "$FINAL_WASM" --invoke bench_snappy_compress 1024 || true
  wasmtime "$FINAL_WASM" --invoke bench_snappy_uncompress 1024 || true
else
  echo "wasmtime missing or output wasm not found: $FINAL_WASM"
fi

echo "[8] cleanup intermediates"
rm -f \
  "$C_FFI_BC" \
  "$LIBC_SHIM_BC" \
  "$C_FFI_MARKED_BC" \
  "$RUST_FFI_BC" \
  "$RUST_FFI_RO_BC" \
  "$COMBINED_BC" \
  "$COMBINED_SFI_BC" \
  "$COMBINED_O"

echo "done: $FINAL_WASM"

