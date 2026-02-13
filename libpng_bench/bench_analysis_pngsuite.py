#!/usr/bin/env python3
import csv
import os
from statistics import median

ROOT = os.path.dirname(os.path.abspath(__file__))
RESULT = os.path.join(ROOT, "bench_result")
MEM0_CSV = os.path.join(RESULT, "mem0_pngsuite_decode.csv")
SFI_CSV = os.path.join(RESULT, "sfi_pngsuite_decode.csv")
OUT_CSV = os.path.join(RESULT, "pngsuite_decode_compare.csv")


def read_rows(path):
    with open(path, "r", newline="") as f:
        return list(csv.DictReader(f))


def median_by_file(rows):
    by_file = {}
    for r in rows:
        if str(r.get("ret")) != "0":
            continue
        f = r.get("file", "")
        by_file.setdefault(f, []).append(float(r["us"]))

    out = {}
    for k, vals in by_file.items():
        out[k] = median(vals)
    return out


def first_meta(rows):
    meta = {}
    for r in rows:
        f = r.get("file", "")
        if f in meta:
            continue
        meta[f] = {
            "png_bytes": r.get("png_bytes", ""),
            "decoded_bytes": r.get("decoded_bytes", ""),
            "width": r.get("width", ""),
            "height": r.get("height", ""),
            "compression_ratio": r.get("compression_ratio", ""),
        }
    return meta


def main():
    if not os.path.exists(MEM0_CSV):
        raise SystemExit(f"missing: {MEM0_CSV}")
    if not os.path.exists(SFI_CSV):
        raise SystemExit(f"missing: {SFI_CSV}")

    mem0_rows = read_rows(MEM0_CSV)
    sfi_rows = read_rows(SFI_CSV)

    m0 = median_by_file(mem0_rows)
    sf = median_by_file(sfi_rows)
    meta = first_meta(mem0_rows + sfi_rows)

    files = sorted(set(m0.keys()) | set(sf.keys()))
    out = []
    for f in files:
        m0_us = m0.get(f)
        sf_us = sf.get(f)
        ratio = ""
        if m0_us and sf_us and m0_us > 0:
            ratio = f"{(sf_us / m0_us):.6f}"
        info = meta.get(f, {})
        out.append({
            "file": f,
            "png_bytes": info.get("png_bytes", ""),
            "decoded_bytes": info.get("decoded_bytes", ""),
            "width": info.get("width", ""),
            "height": info.get("height", ""),
            "compression_ratio": info.get("compression_ratio", ""),
            "mem0_us_median": "" if m0_us is None else f"{m0_us:.3f}",
            "sfi_us_median": "" if sf_us is None else f"{sf_us:.3f}",
            "sfi_over_mem0": ratio,
        })

    with open(OUT_CSV, "w", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "file",
                "png_bytes",
                "decoded_bytes",
                "width",
                "height",
                "compression_ratio",
                "mem0_us_median",
                "sfi_us_median",
                "sfi_over_mem0",
            ],
        )
        w.writeheader()
        w.writerows(out)

    print(f"wrote: {OUT_CSV}")


if __name__ == "__main__":
    main()
