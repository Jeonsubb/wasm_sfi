#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/project_testing/c_libpng_onefile_generated.c}"

LIBPNG_SRC_DIR="${LIBPNG_SRC_DIR:-$ROOT/vendor/libpng-src}"
ZLIB_SRC_DIR="${ZLIB_SRC_DIR:-$ROOT/vendor/zlib-src}"

ZLIB_CORE_SRCS=(
  adler32.c compress.c crc32.c deflate.c infback.c inffast.c
  inflate.c inftrees.c trees.c uncompr.c zutil.c
)
LIBPNG_CORE_SRCS=(
  png.c pngerror.c pngget.c pngmem.c pngpread.c pngread.c pngrio.c
  pngrtran.c pngrutil.c pngset.c pngtrans.c pngwio.c pngwrite.c
  pngwtran.c pngwutil.c
)

mkdir -p "$(dirname "$OUT")"

{
  echo "/*"
  echo " * AUTO-GENERATED EXPERIMENTAL FILE."
  echo " *"
  echo " * Purpose:"
  echo " *   Attempt a single-file style layout similar to snappy's c_snappy.c."
  echo " *"
  echo " * Important:"
  echo " *   This file is NOT wired into default build scripts."
  echo " *   Upstream libpng/zlib internals are not designed as one TU, so this"
  echo " *   generated file may fail to compile without additional refactoring."
  echo " */"
  echo
  echo "#include \"c_libpng.c\""
  echo
  echo "/* ---- zlib source bodies ---- */"
  for f in "${ZLIB_CORE_SRCS[@]}"; do
    echo
    echo "/* BEGIN zlib: $f */"
    cat "$ZLIB_SRC_DIR/$f"
    echo "/* END zlib: $f */"
  done

  echo
  echo "/* ---- libpng source bodies ---- */"
  for f in "${LIBPNG_CORE_SRCS[@]}"; do
    echo
    echo "/* BEGIN libpng: $f */"
    cat "$LIBPNG_SRC_DIR/$f"
    echo "/* END libpng: $f */"
  done
} > "$OUT"

echo "generated: $OUT"
