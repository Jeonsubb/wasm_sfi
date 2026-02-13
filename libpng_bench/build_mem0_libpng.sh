#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$ROOT/build/mem0"
DEBUG_DIR="$OUT_DIR/debug"

C_FFI_SRC="$ROOT/project_testing/c_libpng.c"
RUST_FFI_SRC="$ROOT/project_testing/rust_libpng.rs"
LIBC_SHIM_SRC="$ROOT/support/libc_shim.c"

LIBPNG_SRC_DIR="${LIBPNG_SRC_DIR:-$ROOT/vendor/libpng}"
ZLIB_SRC_DIR="${ZLIB_SRC_DIR:-$ROOT/vendor/zlib}"
LIBPNG_LIB="${LIBPNG_LIB:-$LIBPNG_SRC_DIR/libpng.a}"
ZLIB_LIB="${ZLIB_LIB:-$ZLIB_SRC_DIR/libz.a}"

DEFAULT_CFLAGS_LIBPNG="-I$ROOT/support -I$LIBPNG_SRC_DIR -I$ZLIB_SRC_DIR"
CFLAGS_LIBPNG_EFFECTIVE="${CFLAGS_LIBPNG:-$DEFAULT_CFLAGS_LIBPNG}"
MEM0_LINEAR_MEMORY_BYTES="${MEM0_LINEAR_MEMORY_BYTES:-33554432}"

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

echo "=== [00] mem0-only libpng build start ==="
if [[ ! -f "$LIBPNG_LIB" ]]; then
  echo "error: missing libpng static library: $LIBPNG_LIB"
  echo "hint: place libpng.a under vendor/libpng or set LIBPNG_LIB"
  exit 1
fi
if [[ ! -f "$ZLIB_LIB" ]]; then
  echo "error: missing zlib static library: $ZLIB_LIB"
  echo "hint: place libz.a under vendor/zlib or set ZLIB_LIB"
  exit 1
fi

echo "=== [01] C callee -> LLVM bc ==="
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_LIBPNG_EFFECTIVE} \
  -emit-llvm -c "$C_FFI_SRC" -o "$C_FFI_BC"
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding -fno-builtin -emit-llvm \
  -c "$LIBC_SHIM_SRC" -o "$LIBC_SHIM_BC"

echo "=== [02] Rust caller -> LLVM bc ==="
# Prefer pinned toolchain for reproducibility, but allow fallback to plain rustc
# when rustup/toolchain pinning is unavailable in local environments.
RUSTC_BIN="${RUSTC_BIN:-rustc}"
RUSTC_PIN="${RUSTC_PIN:-+1.78.0}"
if command -v rustup >/dev/null 2>&1; then
  "$RUSTC_BIN" "$RUSTC_PIN" --target=wasm32-unknown-unknown -C opt-level=2 \
    --emit=llvm-bc -o "$RUST_FFI_BC" "$RUST_FFI_SRC"
else
  echo "warn: rustup not found; using unpinned rustc ($RUSTC_BIN)"
  "$RUSTC_BIN" --target=wasm32-unknown-unknown -C opt-level=2 \
    --emit=llvm-bc -o "$RUST_FFI_BC" "$RUST_FFI_SRC"
fi

echo "=== [03] Link: Rust + C + libc_shim ==="
llvm-link-18 "$RUST_FFI_BC" "$C_FFI_BC" "$LIBC_SHIM_BC" -o "$COMBINED_BC"

echo "=== [04] Codegen: combined.bc -> combined.o ==="
llc-18 -filetype=obj -march=wasm32 "$COMBINED_BC" -o "$COMBINED_O"

echo "=== [05] wasm-ld: mem0-only link (+ libpng + zlib) ==="
wasm-ld --no-entry --export-all --no-gc-sections \
  --initial-memory="$MEM0_LINEAR_MEMORY_BYTES" --max-memory="$MEM0_LINEAR_MEMORY_BYTES" \
  "$COMBINED_O" "$LIBPNG_LIB" "$ZLIB_LIB" -o "$FINAL_WASM"

echo "=== [06] wasm2wat: final_mem0.wat (optional) ==="
command -v wasm2wat >/dev/null 2>&1 && wasm2wat "$FINAL_WASM" -o "$FINAL_WAT"

echo "=== [07] wasm-decompile: final_mem0.dcmp (optional) ==="
command -v wasm-decompile >/dev/null 2>&1 && wasm-decompile --enable-all "$FINAL_WASM" -o "$DEBUG_DCMP"

echo "=== done: $FINAL_WASM ==="
