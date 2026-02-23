#!/usr/bin/env bash
set -euo pipefail

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

LIBPNG_SRC_DIR="${LIBPNG_SRC_DIR:-$ROOT/vendor/libpng-src}"
ZLIB_SRC_DIR="${ZLIB_SRC_DIR:-$ROOT/vendor/zlib-src}"
DEFAULT_CFLAGS_LIBPNG="-DNO_GZCOMPRESS -DNO_GZIP -DPNG_NO_STDIO_SUPPORTED -DPNG_NO_STDIO -I$ROOT/support -I$LIBPNG_SRC_DIR -I$ZLIB_SRC_DIR"
CFLAGS_LIBPNG_EFFECTIVE="${CFLAGS_LIBPNG:-$DEFAULT_CFLAGS_LIBPNG}"

C_FFI_SRC="$ROOT/project_testing/c_libpng.c"
RUST_FFI_SRC="$ROOT/project_testing/rust_libpng.rs"
LIBC_SHIM_SRC="$ROOT/support/libc_shim.c"

COMBINED_RAW_WASM="$OUT_DIR/combined_sfi_libpng_raw.wasm"
COMBINED_RAW_WAT="$OUT_DIR/combined_sfi_libpng_raw.wat"
FINAL_WASM="$OUT_DIR/final_sfi_libpng.wasm"
FINAL_WAT="$OUT_DIR/final_sfi_libpng.wat"
FINAL_DCMP="$DEBUG_DIR/final_sfi_libpng.dcmp"
LOG_FILE="$DEBUG_DIR/output_sfi_build.txt"

mkdir -p "$OUT_DIR" "$DEBUG_DIR" "$PASS_DIR/build"
exec > >(tee "$LOG_FILE") 2>&1

if [[ ! -f "$LIBPNG_SRC_DIR/png.h" ]] || [[ ! -f "$LIBPNG_SRC_DIR/png.c" ]]; then
  echo "error: missing libpng C sources under: $LIBPNG_SRC_DIR"
  exit 1
fi
if [[ ! -f "$ZLIB_SRC_DIR/zlib.h" ]] || [[ ! -f "$ZLIB_SRC_DIR/deflate.c" ]]; then
  echo "error: missing zlib C sources under: $ZLIB_SRC_DIR"
  exit 1
fi

SFI_C_BASE=${SFI_C_BASE:-$((2 * 65536))}
SFI_C_END=${SFI_C_END:-$((SFI_C_BASE + 256 * 65536))}
SFI_C_STACK_TOP=${SFI_C_STACK_TOP:-$SFI_C_END}
SFI_C_HEAP_BASE=${SFI_C_HEAP_BASE:-$((SFI_C_BASE + 4096))}
SFI_C_HEAP_END=${SFI_C_HEAP_END:-$SFI_C_END}
export SFI_C_BASE SFI_C_END SFI_C_STACK_TOP SFI_C_HEAP_BASE SFI_C_HEAP_END

C_FFI_BC="$OUT_DIR/sfi_c_libpng.bc"
LIBC_SHIM_BC="$OUT_DIR/sfi_libc_shim.bc"
C_FFI_MARKED_BC="$OUT_DIR/sfi_c_libpng.marked.bc"
RUST_FFI_BC="$OUT_DIR/sfi_rust_libpng.bc"
RUST_FFI_RO_BC="$OUT_DIR/sfi_rust_libpng.ro.bc"
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
  "$SFI_ROOT/build_passes.sh"
fi

if [[ ! -f "$SFI_RUNTIME_A" ]]; then
  "$SFI_DIR/build_sfi_runtime.sh"
fi

echo "[1] C code -> LLVM bc"
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_LIBPNG_EFFECTIVE} \
  -emit-llvm -c "$C_FFI_SRC" -o "$C_FFI_BC"
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding -fno-builtin \
  -emit-llvm -c "$LIBC_SHIM_SRC" -o "$LIBC_SHIM_BC"

echo "[1a] libpng/zlib sources -> LLVM bc"
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

MEM1FFI_LIST_OUT="$MEM1_FFI_LIST_TSV" \
  opt-18 -load-pass-plugin="$MARK_SO" -passes=mark-mem1-ffi "$C_FFI_BC" -o "$C_FFI_MARKED_BC"

# Fix known ptr-size metadata mismatch for scalar out-params.
# MarkMem1FFI may attach len_arg=<buffer-cap> to size_t* out params in libpng wrappers,
# which makes rewrite-wasm-ffi copy huge ranges and triggers SFI traps.
if command -v llvm-dis-18 >/dev/null 2>&1 && command -v llvm-as-18 >/dev/null 2>&1; then
  C_FFI_MARKED_LL="$OUT_DIR/sfi_c_libpng.marked.ll"
  llvm-dis-18 "$C_FFI_MARKED_BC" -o "$C_FFI_MARKED_LL"
  sed -i \
    -e 's/mem1-arg5"="ptrlike=1;dir=inout;len_arg=4"/mem1-arg5"="ptrlike=1;dir=inout;size=4"/g' \
    -e 's/mem1-arg4"="ptrlike=1;dir=inout;len_arg=3"/mem1-arg4"="ptrlike=1;dir=inout;size=4"/g' \
    -e 's/mem1-arg5"="ptrlike=1;dir=inout;len_arg=3"/mem1-arg5"="ptrlike=1;dir=inout;size=4"/g' \
    "$C_FFI_MARKED_LL"
  llvm-as-18 "$C_FFI_MARKED_LL" -o "$C_FFI_MARKED_BC"
  rm -f "$C_FFI_MARKED_LL"
fi

if [[ -f "$MEM1_FFI_LIST_TSV" ]]; then
  sed -i \
    -e 's/mem1-arg5=ptrlike=1;dir=inout;len_arg=4/mem1-arg5=ptrlike=1;dir=inout;size=4/g' \
    -e 's/mem1-arg4=ptrlike=1;dir=inout;len_arg=3/mem1-arg4=ptrlike=1;dir=inout;size=4/g' \
    -e 's/mem1-arg5=ptrlike=1;dir=inout;len_arg=3/mem1-arg5=ptrlike=1;dir=inout;size=4/g' \
    "$MEM1_FFI_LIST_TSV"
fi

echo "[2] Rust code -> LLVM bc"
MEM1_RO_LIST_OUT="$MEM1_RO_LIST_TSV" \
MEM1_FFI_LIST="$MEM1_FFI_LIST_TSV" \
  bash "$SFI_ROOT/tools/mem1-rustc/mem1-rustc.sh" \
    --target=wasm32-unknown-unknown -C opt-level=2 \
    --emit=llvm-bc -o "$RUST_FFI_BC" "$RUST_FFI_SRC"

MEM1_RO_LIST="$MEM1_RO_LIST_TSV" \
  opt-18 -load-pass-plugin="$INJECT_SO" -passes=inject-mem1-markers \
    "$RUST_FFI_BC" -o "$RUST_FFI_RO_BC"

echo "[3] link + rewrite-wasm-ffi + sfi-bounds-check"
llvm-link-18 "$RUST_FFI_RO_BC" "$C_FFI_MARKED_BC" "$LIBC_SHIM_BC" "${LIB_BCS[@]}" -o "$COMBINED_BC"

opt-18 -load-pass-plugin="$REWRITE_SO" -load-pass-plugin="$SFI_BOUNDS_SO" \
  -passes=rewrite-wasm-ffi,sfi-bounds-check \
  "$COMBINED_BC" -o "$COMBINED_SFI_BC"

echo "[4] codegen + wasm link"
llc-18 -filetype=obj -march=wasm32 "$COMBINED_SFI_BC" -o "$COMBINED_O"

wasm-ld --no-entry --export-all --no-gc-sections \
  --initial-memory="$SFI_C_END" --max-memory="$SFI_C_END" \
  "$COMBINED_O" "$SFI_RUNTIME_A" -o "$COMBINED_RAW_WASM"

command -v wasm2wat >/dev/null 2>&1 && wasm2wat "$COMBINED_RAW_WASM" -o "$COMBINED_RAW_WAT"

echo "[5] wasm post-process"
if command -v wasm2wat >/dev/null 2>&1 && command -v wat2wasm >/dev/null 2>&1; then
  python3 "$SFI_ROOT/sfi/tools/sfi_wat_sandbox.py" \
    --in-wasm "$COMBINED_RAW_WASM" \
    --out-wasm "$FINAL_WASM" \
    --c-stack-top "$SFI_C_STACK_TOP"
  wasm2wat "$FINAL_WASM" -o "$FINAL_WAT"
else
  cp -f "$COMBINED_RAW_WASM" "$FINAL_WASM"
  command -v wasm2wat >/dev/null 2>&1 && wasm2wat "$FINAL_WASM" -o "$FINAL_WAT"
fi

if command -v wasm-decompile >/dev/null 2>&1; then
  wasm-decompile --enable-all "$FINAL_WASM" -o "$FINAL_DCMP"
fi

rm -f \
  "$C_FFI_BC" "$LIBC_SHIM_BC" "$C_FFI_MARKED_BC" \
  "$RUST_FFI_BC" "$RUST_FFI_RO_BC" "$COMBINED_BC" \
  "$COMBINED_SFI_BC" "$COMBINED_O" \
  "$OUT_DIR"/zlib_*.bc "$OUT_DIR"/libpng_*.bc

echo "done: $FINAL_WASM"
