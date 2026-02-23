#!/usr/bin/env python3
import argparse
import csv
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
    load_external = exports.get("bench_load_external_png")
    decode_external = exports.get("bench_png_decode_external")
    get_decoded_bytes = exports.get("bench_get_decoded_bytes")
    get_w = exports.get("bench_get_decoded_width")
    get_h = exports.get("bench_get_decoded_height")

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

    if set_staging_byte is not None or set_c_staging_byte is not None:
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
        if mem is None:
            raise RuntimeError("missing export: memory")
        write_memory(mem, store, staging_ptr, png_bytes)

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
