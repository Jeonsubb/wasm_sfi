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
if [[ -z "${WASM_OPT_BIN:-}" ]]; then
  if [[ -x "$ROOT/../binaryen/build/bin/wasm-opt" ]]; then
    WASM_OPT_BIN="$ROOT/../binaryen/build/bin/wasm-opt"
  else
    WASM_OPT_BIN="wasm-opt"
  fi
fi

LIBPNG_SRC_DIR="${LIBPNG_SRC_DIR:-$ROOT/vendor/libpng-src}"
ZLIB_SRC_DIR="${ZLIB_SRC_DIR:-$ROOT/vendor/zlib-src}"
DEFAULT_CFLAGS_LIBPNG="-DNO_GZCOMPRESS -DNO_GZIP -DPNG_NO_STDIO_SUPPORTED -DPNG_NO_STDIO -I$ROOT/support -I$LIBPNG_SRC_DIR -I$ZLIB_SRC_DIR"
CFLAGS_LIBPNG_EFFECTIVE="${CFLAGS_LIBPNG:-$DEFAULT_CFLAGS_LIBPNG}"
MEM1_LINEAR_MEMORY_BYTES="${MEM1_LINEAR_MEMORY_BYTES:-268435456}"
MEM1_SECONDARY_PAGES="${MEM1_SECONDARY_PAGES:-4096}"

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
  rm -f "$OUT_DIR"/zlib_*.bc "$OUT_DIR"/libpng_*.bc
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

if [[ ! -f "$LIBPNG_SRC_DIR/png.h" ]] || [[ ! -f "$LIBPNG_SRC_DIR/png.c" ]]; then
  echo "error: missing libpng C sources under: $LIBPNG_SRC_DIR"
  exit 1
fi
if [[ ! -f "$ZLIB_SRC_DIR/zlib.h" ]] || [[ ! -f "$ZLIB_SRC_DIR/deflate.c" ]]; then
  echo "error: missing zlib C sources under: $ZLIB_SRC_DIR"
  exit 1
fi

C_FFI_SRC="$ROOT/project_testing/c_libpng.c"
RUST_FFI_SRC="$ROOT/project_testing/rust_libpng.rs"
LIBC_SHIM_SRC="$ROOT/support/libc_shim_mem1.c"

echo "=== [01] C callee -> LLVM bc ==="
clang-18 --target=wasm32-unknown-unknown -Oz -ffreestanding ${CFLAGS_LIBPNG_EFFECTIVE} -emit-llvm -c "$C_FFI_SRC" -o "$C_FFI_BC"
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

echo "=== [02] LLVM passes: insert-nop + MarkMem1FFI ==="
opt-18 -load-pass-plugin="$PASS_NOP_NORMAL_SO" -passes='function(insert-nop-grow)' "$C_FFI_BC" -o "$C_FFI_NOP_BC"
opt-18 -load-pass-plugin="$PASS_NOP_NORMAL_SO" -passes='function(insert-nop-grow)' "$LIBC_SHIM_BC" -o "$LIBC_SHIM_NOP_BC"

# Ensure all C-side memory ops (including libpng/zlib internals and RO-data accesses)
# are rewritten to mem1 by Mem1RewritePass.
LIB_BCS_NOP=()
for bc in "${LIB_BCS[@]}"; do
  bc_nop="${bc%.bc}.nop.bc"
  opt-18 -load-pass-plugin="$PASS_NOP_NORMAL_SO" -passes='function(insert-nop-grow)' "$bc" -o "$bc_nop"
  LIB_BCS_NOP+=("$bc_nop")
done

MEM1FFI_LIST_OUT="$MEM1_FFI_LIST_TSV" \
  opt-18 -load-pass-plugin="$PASS_MARK_SO" -passes=mark-mem1-ffi "$C_FFI_NOP_BC" -o "$C_FFI_MARKED_BC"

# Fix known ptr-size metadata mismatch for scalar out-params.
# Without this correction, rewrite-wasm-ffi may copy huge ranges for size_t* outputs.
if command -v llvm-dis-18 >/dev/null 2>&1 && command -v llvm-as-18 >/dev/null 2>&1; then
  C_FFI_MARKED_LL="$OUT_DIR/mem1_c_ffi_marked.ll"
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
llvm-link-18 "$RUST_FFI_RO_BC" "$C_FFI_MARKED_BC" "$LIBC_SHIM_NOP_BC" "${LIB_BCS_NOP[@]}" -o "$COMBINED_BC"

opt-18 -load-pass-plugin="$RUST_ALLOC_SO" -load-pass-plugin="$REWRITE_SO" \
  -passes=rewrite-wasm-ffi "$COMBINED_BC" -o "$COMBINED_REWRITTEN_BC"

echo "=== [05] Codegen + link ==="
llc-18 -filetype=obj -march=wasm32 "$COMBINED_REWRITTEN_BC" -o "$COMBINED_O"

wasm-ld --no-entry --export-all --no-gc-sections \
  --initial-memory="$MEM1_LINEAR_MEMORY_BYTES" --max-memory="$MEM1_LINEAR_MEMORY_BYTES" \
  "$COMBINED_O" "$RUNTIME_A" -o "$COMBINED_RAW_WASM"

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

if [[ "${SKIP_FIX_MEM1_DEFAULT_LOADS:-0}" != "1" ]] && \
   command -v wasm2wat >/dev/null 2>&1 && command -v wat2wasm >/dev/null 2>&1 && \
   [[ -f "$MEM1_ROOT/tools/fix_mem1_default_loads.py" ]]; then
  python3 "$MEM1_ROOT/tools/fix_mem1_default_loads.py" \
    --wasm "$FINAL_WASM" \
    --min-explicit1 "${FIX_MEM1_MIN_EXPLICIT1:-1}" \
    --min-ratio "${FIX_MEM1_MIN_RATIO:-0.0}"
fi

# Workaround for known mem1 misses:
# 1) c_png_decode_staged stack init stores
# 2) remaining non-helper C funcs that still emit default-memory ops
if command -v wasm2wat >/dev/null 2>&1 && command -v wat2wasm >/dev/null 2>&1; then
  TMP_WAT="$OUT_DIR/final_mem1.autofix.wat"
  wasm2wat --enable-multi-memory "$FINAL_WASM" -o "$TMP_WAT"
  python3 - "$TMP_WAT" "$MEM1_SECONDARY_PAGES" <<'PY'
import sys
import re
from pathlib import Path

wat = Path(sys.argv[1])
mem1_pages = int(sys.argv[2])
lines = wat.read_text().splitlines()

patched = 0
# Keep memory 1 large enough for bigger libpng staging/decoded buffers.
for i, s in enumerate(lines):
    st = s.strip()
    if st.startswith("(memory") and "(;1;)" in st:
        lines[i] = re.sub(r"\(memory.*\)", f"(memory (;1;) {mem1_pages} {mem1_pages})", st)
        lines[i] = "  " + lines[i]
        patched += 1
        break

# Build func index -> [start, end) line ranges.
func_ranges = {}
func_order = []
for i, line in enumerate(lines):
    m = re.match(r"^\s*\(func \(;(\d+);\)", line)
    if m:
        idx = int(m.group(1))
        func_order.append((idx, i))
for j, (idx, start) in enumerate(func_order):
    end = func_order[j + 1][1] if j + 1 < len(func_order) else len(lines)
    func_ranges[idx] = (start, end)

# Build export name -> func index map.
export_to_idx = {}
for line in lines:
    m = re.match(r'^\s*\(export "([^"]+)" \(func (\d+)\)\)', line)
    if m:
        export_to_idx[m.group(1)] = int(m.group(2))

# Known non-helper mem0 leak candidates from static scan.
target_exports = {
    "c_png_decode_staged",
    "deflate",
    "deflateReset",
    "deflateParams",
    "inflateBack",
    "inflate",
    "png_convert_to_rfc1123_buffer",
    "png_ascii_from_fixed",
    "png_reciprocal2",
    "png_image_free",
    "png_warning_parameter_unsigned",
    "png_warning_parameter_signed",
    "png_get_bKGD",
    "png_get_sBIT",
    "png_get_tIME",
    "png_read_transform_info",
    "png_set_shift",
    "png_set_background_fixed",
    "png_set_quantize",
    "png_init_read_transformations",
    "png_set_bKGD",
    "png_set_sBIT",
    "png_set_tRNS",
    "png_set_cHRM_XYZ_fixed",
    "png_write_finish_row",
    "_tr_tally",
}

target_func_idxs = set()
missing_exports = []
for name in sorted(target_exports):
    idx = export_to_idx.get(name)
    if idx is None:
        missing_exports.append(name)
    else:
        target_func_idxs.add(idx)

memop_re = re.compile(r"^(i(?:32|64)\.(?:load|store)[0-9A-Za-z_]*)(\b.*)$")

def patch_func_memops(start: int, end: int) -> int:
    local_patched = 0
    for i in range(start, end):
        s = lines[i]
        st = s.strip()
        if not st or "(memory " in st:
            continue
        m = memop_re.match(st)
        if not m:
            continue
        op = m.group(1)
        rest = m.group(2)
        rest_l = rest.lstrip()
        # Skip if memory immediate already exists in numeric or named form.
        if re.match(r"^(?:\d+|\$[A-Za-z0-9_.-]+)\b", rest_l):
            continue
        indent = s[:len(s) - len(s.lstrip())]
        lines[i] = f"{indent}{op} (memory 1){rest}"
        local_patched += 1
    return local_patched

for idx in sorted(target_func_idxs):
    rng = func_ranges.get(idx)
    if rng is None:
        continue
    patched += patch_func_memops(rng[0], rng[1])

if patched:
    wat.write_text("\n".join(lines) + "\n")
print(f"[mem1-autofix] patched={patched} target_funcs={len(target_func_idxs)} missing_exports={len(missing_exports)}")
if missing_exports:
    print("[mem1-autofix] missing: " + ", ".join(sorted(missing_exports)))
PY
  wat2wasm --enable-multi-memory "$TMP_WAT" -o "$FINAL_WASM"
  rm -f "$TMP_WAT"
fi

command -v wasm2wat >/dev/null 2>&1 && wasm2wat --enable-multi-memory "$FINAL_WASM" -o "$FINAL_WAT"
command -v wasm-decompile >/dev/null 2>&1 && wasm-decompile --enable-all "$FINAL_WASM" -o "$DEBUG_DCMP"

echo "=== done: $FINAL_WASM ==="
