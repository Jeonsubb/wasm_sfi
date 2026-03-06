#!/usr/bin/env python3
import argparse
import csv
import json
import os
import time
from pathlib import Path

try:
    import wasmtime
except ImportError:
    raise SystemExit("missing python module: wasmtime (activate venv with wasmtime)")

ROOT = Path(__file__).resolve().parent
PNGSUITE_DIR = Path(os.environ.get("PNGSUITE_DIR", ROOT / "data" / "pngsuite"))
RUNS = int(os.environ.get("BENCH_RUNS", "5"))
PNG_FILE_LIMIT = int(os.environ.get("PNG_FILE_LIMIT", "4"))
DUMP_DECODED = os.environ.get("DUMP_DECODED", "0") == "1"
DUMP_DIR = Path(os.environ.get("DUMP_DIR", ROOT / "bench_result" / "decoded"))


def list_png_files(base: Path):
    candidates = []
    if (base / "png").is_dir():
        candidates.extend(sorted((base / "png").glob("*.png")))
    candidates.extend(sorted(base.glob("*.png")))

    dedup = []
    seen = set()
    for p in candidates:
        rp = p.resolve()
        if rp in seen:
            continue
        seen.add(rp)
        dedup.append(p)
    return dedup


def make_engine():
    cfg = wasmtime.Config()
    if hasattr(cfg, "wasm_multi_memory"):
        cfg.wasm_multi_memory = True
    return wasmtime.Engine(cfg)


def write_memory(memory, store, offset, data: bytes):
    try:
        memory.write(store, data, offset)
    except TypeError:
        memory.write(store, offset, data)


def read_memory(memory, store, offset: int, size: int) -> bytes:
    try:
        data = memory.read(store, offset, offset + size)
    except TypeError:
        data = memory.read(store, offset, size)
    return bytes(data)


def dump_decoded_output(
    variant: str,
    file_name: str,
    run_idx: int,
    width: int,
    height: int,
    decoded_bytes: int,
    payload: bytes,
):
    stem = Path(file_name).stem
    out_dir = DUMP_DIR / variant
    out_dir.mkdir(parents=True, exist_ok=True)
    rgba_path = out_dir / f"{stem}.run{run_idx}.rgba"
    meta_path = out_dir / f"{stem}.run{run_idx}.json"
    rgba_path.write_bytes(payload)
    meta = {
        "file": file_name,
        "variant": variant,
        "run": run_idx,
        "width": width,
        "height": height,
        "decoded_bytes": decoded_bytes,
        "format": "rgba8",
        "rgba_path": str(rgba_path),
    }
    meta_path.write_text(json.dumps(meta, ensure_ascii=False, indent=2))


def err_text(exc: Exception) -> str:
    return " ".join(str(exc).splitlines())


def run_one(module, engine, png_path: Path, run_idx: int, variant: str):
    store = wasmtime.Store(engine)
    instance = wasmtime.Instance(store, module, [])
    exports = instance.exports(store)

    mem = exports.get("memory")
    get_staging_ptr = exports.get("bench_get_staging_ptr")
    get_staging_cap = exports.get("bench_get_staging_cap")
    set_staging_byte = exports.get("bench_set_staging_byte")
    set_c_staging_byte = exports.get("bench_set_c_staging_byte")
    get_c_staging_ptr = exports.get("c_get_staging_ptr")
    load_external = exports.get("bench_load_external_png")
    decode_external = exports.get("bench_png_decode_external")
    get_decoded_bytes = exports.get("bench_get_decoded_bytes")
    get_w = exports.get("bench_get_decoded_width")
    get_h = exports.get("bench_get_decoded_height")
    get_decoded_ptr = exports.get("c_get_decoded_ptr")
    mem1_load8 = exports.get("__mem1_load8")
    memcpy_1_to_0 = exports.get("__memcpy_1_to_0")

    for fn_name, fn in [
        ("bench_get_staging_ptr", get_staging_ptr),
        ("bench_get_staging_cap", get_staging_cap),
        ("bench_set_staging_byte", set_staging_byte if set_staging_byte is not None else set_c_staging_byte),
        ("bench_load_external_png", load_external),
        ("bench_png_decode_external", decode_external),
        ("bench_get_decoded_bytes", get_decoded_bytes),
        ("bench_get_decoded_width", get_w),
        ("bench_get_decoded_height", get_h),
    ]:
        if fn is None:
            raise RuntimeError(f"missing export: {fn_name}")

    png_bytes = png_path.read_bytes()
    staging_ptr = int(get_staging_ptr(store))
    staging_cap = int(get_staging_cap(store))
    if len(png_bytes) > staging_cap:
        return {
            "file": str(png_path.name),
            "variant": variant,
            "run": run_idx,
            "png_bytes": len(png_bytes),
            "decoded_bytes": "",
            "width": "",
            "height": "",
            "us": "ERR",
            "compression_ratio": "",
            "ret": f"too_large:{len(png_bytes)}>{staging_cap}",
        }

    # SFI needs both Rust staging and C staging to receive bytes.
    # If c_get_staging_ptr is available, bulk-write both regions.
    use_setter = (variant == "sfi")

    if variant == "sfi" and mem is not None and get_c_staging_ptr is not None:
        c_staging_ptr = int(get_c_staging_ptr(store))
        write_memory(mem, store, staging_ptr, png_bytes)
        write_memory(mem, store, c_staging_ptr, png_bytes)
    elif (not use_setter) and mem is not None:
        write_memory(mem, store, staging_ptr, png_bytes)
    elif set_staging_byte is not None or set_c_staging_byte is not None:
        for i, b in enumerate(png_bytes):
            for fn in (set_staging_byte, set_c_staging_byte):
                if fn is None:
                    continue
                ret = fn(store, i, b)
                if ret is None:
                    ret = 0
                if ret != 0:
                    return {
                        "file": str(png_path.name),
                        "variant": variant,
                        "run": run_idx,
                        "png_bytes": len(png_bytes),
                        "decoded_bytes": "",
                        "width": "",
                        "height": "",
                        "us": "ERR",
                        "compression_ratio": "",
                        "ret": f"set_byte:{ret}",
                    }
    else:
        raise RuntimeError("missing export: memory")

    try:
        ret = load_external(store, len(png_bytes))
    except Exception as exc:
        return {
            "file": str(png_path.name),
            "variant": variant,
            "run": run_idx,
            "png_bytes": len(png_bytes),
            "decoded_bytes": "",
            "width": "",
            "height": "",
            "us": "ERR",
            "compression_ratio": "",
            "ret": f"load_exc:{err_text(exc)}",
        }
    if ret is None:
        ret = 0
    if ret != 0:
        return {
            "file": str(png_path.name),
            "variant": variant,
            "run": run_idx,
            "png_bytes": len(png_bytes),
            "decoded_bytes": "",
            "width": "",
            "height": "",
            "us": "ERR",
            "compression_ratio": "",
            "ret": f"load:{ret}",
        }

    t0 = time.perf_counter()
    try:
        ret = decode_external(store)
    except Exception as exc:
        return {
            "file": str(png_path.name),
            "variant": variant,
            "run": run_idx,
            "png_bytes": len(png_bytes),
            "decoded_bytes": "",
            "width": "",
            "height": "",
            "us": "ERR",
            "compression_ratio": "",
            "ret": f"decode_exc:{err_text(exc)}",
        }
    elapsed_us = (time.perf_counter() - t0) * 1_000_000.0

    if ret is None:
        ret = 0
    if ret != 0:
        return {
            "file": str(png_path.name),
            "variant": variant,
            "run": run_idx,
            "png_bytes": len(png_bytes),
            "decoded_bytes": "",
            "width": "",
            "height": "",
            "us": "ERR",
            "compression_ratio": "",
            "ret": f"decode:{ret}",
        }

    decoded_bytes = int(get_decoded_bytes(store))
    width = int(get_w(store))
    height = int(get_h(store))
    ratio = ""
    if decoded_bytes > 0:
        ratio = f"{(len(png_bytes) / decoded_bytes):.6f}"

    if DUMP_DECODED and decoded_bytes > 0 and get_decoded_ptr is not None:
        decoded_ptr = int(get_decoded_ptr(store))
        payload = b""
        if variant == "mem1":
            if mem is not None and memcpy_1_to_0 is not None:
                dst_mem0 = staging_ptr
                chunk_cap = max(1, staging_cap)
                parts = []
                copied = 0
                while copied < decoded_bytes:
                    n = min(chunk_cap, decoded_bytes - copied)
                    memcpy_1_to_0(store, dst_mem0, decoded_ptr + copied, n)
                    parts.append(read_memory(mem, store, dst_mem0, n))
                    copied += n
                payload = b"".join(parts)
            elif mem1_load8 is not None:
                buf = bytearray(decoded_bytes)
                for i in range(decoded_bytes):
                    buf[i] = int(mem1_load8(store, decoded_ptr + i)) & 0xFF
                payload = bytes(buf)
            else:
                raise RuntimeError("missing exports for mem1 dump (__memcpy_1_to_0 or __mem1_load8)")
        else:
            if mem is None:
                raise RuntimeError("missing export: memory")
            payload = read_memory(mem, store, decoded_ptr, decoded_bytes)
        dump_decoded_output(
            variant=variant,
            file_name=png_path.name,
            run_idx=run_idx,
            width=width,
            height=height,
            decoded_bytes=decoded_bytes,
            payload=payload,
        )

    return {
        "file": str(png_path.name),
        "variant": variant,
        "run": run_idx,
        "png_bytes": len(png_bytes),
        "decoded_bytes": decoded_bytes,
        "width": width,
        "height": height,
        "us": f"{elapsed_us:.3f}",
        "compression_ratio": ratio,
        "ret": 0,
    }


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("variant", choices=["mem0", "mem1", "sfi"])
    p.add_argument("--limit", type=int, default=PNG_FILE_LIMIT, help="number of PNG files to run (0: all)")
    return p.parse_args()


def main():
    args = parse_args()
    variant = args.variant
    wasm_name = {
        "mem0": "final_mem0.wasm",
        "mem1": "final_mem1.wasm",
        "sfi": "final_sfi_libpng.wasm",
    }[variant]
    wasm = ROOT / "build" / variant / wasm_name
    result_csv = ROOT / "bench_result" / f"{variant}_pngsuite_decode.csv"

    if not wasm.exists():
        raise SystemExit(f"missing: {wasm}")

    png_files = list_png_files(PNGSUITE_DIR)
    if args.limit > 0:
        png_files = png_files[: args.limit]
    if not png_files:
        raise SystemExit(f"no png files found under: {PNGSUITE_DIR}")

    engine = make_engine()
    module = wasmtime.Module.from_file(engine, str(wasm))

    rows = []
    for p in png_files:
        for i in range(RUNS):
            rows.append(run_one(module, engine, p, i, variant))

    result_csv.parent.mkdir(parents=True, exist_ok=True)
    with result_csv.open("w", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "file",
                "variant",
                "run",
                "png_bytes",
                "decoded_bytes",
                "width",
                "height",
                "us",
                "compression_ratio",
                "ret",
            ],
        )
        w.writeheader()
        w.writerows(rows)
    print(f"wrote: {result_csv}")


if __name__ == "__main__":
    main()
