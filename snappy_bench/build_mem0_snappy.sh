#!/usr/bin/env bash
set -euo pipefail

# mem0 전용 빌드: 모든 패스/멀티메모리 리라이트 없이 순수 wasm을 생성한다.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SNAPPY_ROOT="${SNAPPY_ROOT:-$ROOT}"
OUT_DIR="$SNAPPY_ROOT/build/mem0"
DEBUG_DIR="$OUT_DIR/debug"

C_FFI_SRC="$SNAPPY_ROOT/project_testing/c_snappy.c"
RUST_FFI_SRC="$SNAPPY_ROOT/project_testing/rust_snappy.rs"
LIBC_SHIM_SRC="$SNAPPY_ROOT/support/libc_shim.c"

DEFAULT_CFLAGS_SNAPPY="-I$SNAPPY_ROOT/support"
CFLAGS_SNAPPY_EFFECTIVE="${CFLAGS_SNAPPY:-$DEFAULT_CFLAGS_SNAPPY}"
MEM0_LINEAR_MEMORY_BYTES="${MEM0_LINEAR_MEMORY_BYTES:-20971520}" # 320 pages (64KiB each)

mkdir -p "$OUT_DIR" "$DEBUG_DIR"

LOG_FILE="$DEBUG_DIR/output_mem0_build.txt"
C_FFI_BC="$OUT_DIR/mem0_c_ffi.bc"
LIBC_SHIM_BC="$OUT_DIR/mem0_libc_shim.bc"
RUST_FFI_BC="$OUT_DIR/mem0_rust_ffi.bc"
COMBINED_BC="$OUT_DIR/mem0_combined.bc"
COMBINED_O="$OUT_DIR/mem0_combined.o"
FINAL_WASM="$OUT_DIR/final_mem0.wasm"
FINAL_WAT="$OUT_DIR/final_mem0.wat"
DEBUG_DCMP="$DEBUG_DIR/final_mem0.dcmp"

INTERMEDIATE_FILES=(
  "$C_FFI_BC"
  "$LIBC_SHIM_BC"
  "$RUST_FFI_BC"
  "$COMBINED_BC"
  "$COMBINED_O"
  "$DEBUG_DCMP"
  "$LOG_FILE"
)

cleanup_intermediates() {
  rm -f "${INTERMEDIATE_FILES[@]}"
}
trap cleanup_intermediates EXIT

exec > >(tee "$LOG_FILE") 2>&1

echo "=== [00] mem0-only build start ==="
echo "=== [01] C callee -> LLVM bc ==="
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_SNAPPY_EFFECTIVE} \
  -emit-llvm -c "$C_FFI_SRC" -o "$C_FFI_BC"
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding -fno-builtin -emit-llvm \
  -c "$LIBC_SHIM_SRC" -o "$LIBC_SHIM_BC"

echo "=== [02] Rust caller -> LLVM bc ==="
rustc +1.78.0 --target=wasm32-unknown-unknown -C opt-level=2 \
  --emit=llvm-bc -o "$RUST_FFI_BC" "$RUST_FFI_SRC"

echo "=== [03] Link: Rust + C + libc_shim ==="
llvm-link-18 "$RUST_FFI_BC" "$C_FFI_BC" "$LIBC_SHIM_BC" -o "$COMBINED_BC"

echo "=== [04] Codegen: combined.bc -> combined.o ==="
llc-18 -filetype=obj -march=wasm32 "$COMBINED_BC" -o "$COMBINED_O"

echo "=== [05] wasm-ld: mem0-only link ==="
wasm-ld --no-entry --export-all --no-gc-sections \
  --initial-memory="$MEM0_LINEAR_MEMORY_BYTES" --max-memory="$MEM0_LINEAR_MEMORY_BYTES" \
  "$COMBINED_O" -o "$FINAL_WASM" \


echo "=== [06] wasm2wat: final_mem0.wat (optional) ==="
command -v wasm2wat >/dev/null 2>&1 && wasm2wat "$FINAL_WASM" -o "$FINAL_WAT"

echo "=== [07] wasm-decompile: final_mem0.dcmp (optional) ==="
command -v wasm-decompile >/dev/null 2>&1 && wasm-decompile --enable-all "$FINAL_WASM" -o "$DEBUG_DCMP"

echo "=== done: $FINAL_WASM ==="
