#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$ROOT/build/mem0"
DEBUG_DIR="$OUT_DIR/debug"

C_FFI_SRC="$ROOT/project_testing/c_libpng.c"
RUST_FFI_SRC="$ROOT/project_testing/rust_libpng.rs"
LIBC_SHIM_SRC="$ROOT/support/libc_shim.c"

LIBPNG_SRC_DIR="${LIBPNG_SRC_DIR:-$ROOT/vendor/libpng-src}"
ZLIB_SRC_DIR="${ZLIB_SRC_DIR:-$ROOT/vendor/zlib-src}"

DEFAULT_CFLAGS_LIBPNG="-DNO_GZCOMPRESS -DNO_GZIP -DPNG_NO_STDIO_SUPPORTED -DPNG_NO_STDIO -I$ROOT/support -I$LIBPNG_SRC_DIR -I$ZLIB_SRC_DIR"
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
  rm -f "$OUT_DIR"/zlib_*.bc "$OUT_DIR"/libpng_*.bc
}
trap cleanup_intermediates EXIT

exec > >(tee "$LOG_FILE") 2>&1

echo "=== [00] mem0-only libpng build start ==="
if [[ ! -f "$LIBPNG_SRC_DIR/png.h" ]] || [[ ! -f "$LIBPNG_SRC_DIR/png.c" ]]; then
  echo "error: missing libpng C sources under: $LIBPNG_SRC_DIR"
  echo "hint: place libpng .c/.h files under vendor/libpng-src or set LIBPNG_SRC_DIR"
  exit 1
fi
if [[ ! -f "$ZLIB_SRC_DIR/zlib.h" ]] || [[ ! -f "$ZLIB_SRC_DIR/deflate.c" ]]; then
  echo "error: missing zlib C sources under: $ZLIB_SRC_DIR"
  echo "hint: place zlib .c/.h files under vendor/zlib-src or set ZLIB_SRC_DIR"
  exit 1
fi

echo "=== [01] C callee -> LLVM bc ==="
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_LIBPNG_EFFECTIVE} \
  -emit-llvm -c "$C_FFI_SRC" -o "$C_FFI_BC"
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding -fno-builtin -emit-llvm \
  -c "$LIBC_SHIM_SRC" -o "$LIBC_SHIM_BC"

echo "=== [01a] libpng/zlib sources -> LLVM bc ==="
ZLIB_CORE_SRCS=(
  adler32.c compress.c crc32.c deflate.c infback.c inffast.c
  inflate.c inftrees.c trees.c uncompr.c zutil.c
)
LIBPNG_CORE_SRCS=(
  png.c pngerror.c pngget.c pngmem.c pngpread.c pngread.c pngrio.c
  pngrtran.c pngrutil.c pngset.c pngtrans.c pngwio.c pngwrite.c
  pngwtran.c pngwutil.c
)
LIB_BCS=()
for src in "${ZLIB_CORE_SRCS[@]}"; do
  bc="$OUT_DIR/zlib_${src%.c}.bc"
  clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_LIBPNG_EFFECTIVE} \
    -emit-llvm -c "$ZLIB_SRC_DIR/$src" -o "$bc"
  LIB_BCS+=("$bc")
done
for src in "${LIBPNG_CORE_SRCS[@]}"; do
  bc="$OUT_DIR/libpng_${src%.c}.bc"
  clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_LIBPNG_EFFECTIVE} \
    -emit-llvm -c "$LIBPNG_SRC_DIR/$src" -o "$bc"
  LIB_BCS+=("$bc")
done

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
llvm-link-18 "$RUST_FFI_BC" "$C_FFI_BC" "$LIBC_SHIM_BC" "${LIB_BCS[@]}" -o "$COMBINED_BC"

echo "=== [04] Codegen: combined.bc -> combined.o ==="
llc-18 -filetype=obj -march=wasm32 "$COMBINED_BC" -o "$COMBINED_O"

echo "=== [05] wasm-ld: mem0-only link ==="
wasm-ld --no-entry --export-all --no-gc-sections \
  --initial-memory="$MEM0_LINEAR_MEMORY_BYTES" --max-memory="$MEM0_LINEAR_MEMORY_BYTES" \
  "$COMBINED_O" -o "$FINAL_WASM"

echo "=== [06] wasm2wat: final_mem0.wat (optional) ==="
command -v wasm2wat >/dev/null 2>&1 && wasm2wat "$FINAL_WASM" -o "$FINAL_WAT"

echo "=== [07] wasm-decompile: final_mem0.dcmp (optional) ==="
command -v wasm-decompile >/dev/null 2>&1 && wasm-decompile --enable-all "$FINAL_WASM" -o "$DEBUG_DCMP"

echo "=== done: $FINAL_WASM ==="
