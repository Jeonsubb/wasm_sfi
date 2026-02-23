#!/usr/bin/env python3
import csv
import math
import os
from statistics import median

ROOT = os.path.dirname(os.path.abspath(__file__))
RESULT = os.path.join(ROOT, "bench_result")

MEM0_CSV = os.path.join(RESULT, "mem0_pngsuite_decode.csv")
MEM1_CSV = os.path.join(RESULT, "mem1_pngsuite_decode.csv")
SFI_CSV = os.path.join(RESULT, "sfi_pngsuite_decode.csv")

OUT_CSV = os.path.join(RESULT, "decode_only_summary.csv")
OUT_MD = os.path.join(RESULT, "decode_only_summary.md")


def read_rows(path):
    with open(path, "r", newline="") as f:
        return list(csv.DictReader(f))


def safe_float(text):
    try:
        return float(text)
    except (TypeError, ValueError):
        return None


def variant_stats(rows, variant):
    selected = [r for r in rows if r.get("variant") == variant]
    total = len(selected)
    ok_rows = [r for r in selected if str(r.get("ret")) == "0"]
    ok = len(ok_rows)
    err = total - ok

    us_vals = []
    for r in ok_rows:
        v = safe_float(r.get("us"))
        if v is not None and v >= 0:
            us_vals.append(v)

    mean_us = sum(us_vals) / len(us_vals) if us_vals else None
    p50_us = median(us_vals) if us_vals else None
    success_rate = (100.0 * ok / total) if total else 0.0

    return {
        "variant": variant,
        "total_runs": total,
        "success_runs": ok,
        "error_runs": err,
        "success_rate_percent": success_rate,
        "mean_us": mean_us,
        "p50_us": p50_us,
    }


def median_by_file(rows, variant):
    by_file = {}
    for r in rows:
        if r.get("variant") != variant:
            continue
        if str(r.get("ret")) != "0":
            continue
        fn = r.get("file", "")
        v = safe_float(r.get("us"))
        if v is None or v < 0:
            continue
        by_file.setdefault(fn, []).append(v)

    out = {}
    for fn, vals in by_file.items():
        out[fn] = median(vals)
    return out


def geomean(values):
    vals = [v for v in values if v is not None and v > 0]
    if not vals:
        return None
    return math.exp(sum(math.log(v) for v in vals) / len(vals))


def format_num(v, digits=3):
    if v is None:
        return ""
    return f"{v:.{digits}f}"


def main():
    if not os.path.exists(MEM0_CSV):
        raise SystemExit(f"missing: {MEM0_CSV}")
    if not os.path.exists(MEM1_CSV):
        raise SystemExit(f"missing: {MEM1_CSV}")
    if not os.path.exists(SFI_CSV):
        raise SystemExit(f"missing: {SFI_CSV}")

    mem0_rows = read_rows(MEM0_CSV)
    mem1_rows = read_rows(MEM1_CSV)
    sfi_rows = read_rows(SFI_CSV)
    all_rows = mem0_rows + mem1_rows + sfi_rows

    mem0_stat = variant_stats(all_rows, "mem0")
    mem1_stat = variant_stats(all_rows, "mem1")
    sfi_stat = variant_stats(all_rows, "sfi")

    mem0_file_med = median_by_file(all_rows, "mem0")
    mem1_file_med = median_by_file(all_rows, "mem1")
    sfi_file_med = median_by_file(all_rows, "sfi")

    mem1_ratios = []
    for fn in sorted(set(mem0_file_med.keys()) & set(mem1_file_med.keys())):
        m0 = mem0_file_med[fn]
        m1 = mem1_file_med[fn]
        if m0 > 0:
            mem1_ratios.append(m1 / m0)

    sfi_ratios = []
    for fn in sorted(set(mem0_file_med.keys()) & set(sfi_file_med.keys())):
        m0 = mem0_file_med[fn]
        sf = sfi_file_med[fn]
        if m0 > 0:
            sfi_ratios.append(sf / m0)

    mem1_over_mem0_geomean = geomean(mem1_ratios)
    sfi_over_mem0_geomean = geomean(sfi_ratios)

    rows = [
        {
            "variant": "mem0",
            "total_runs": mem0_stat["total_runs"],
            "success_runs": mem0_stat["success_runs"],
            "error_runs": mem0_stat["error_runs"],
            "success_rate_percent": f"{mem0_stat['success_rate_percent']:.2f}",
            "mean_us": format_num(mem0_stat["mean_us"]),
            "p50_us": format_num(mem0_stat["p50_us"]),
            "mem1_over_mem0_geomean": "",
            "sfi_over_mem0_geomean": "1.000000",
        },
        {
            "variant": "mem1",
            "total_runs": mem1_stat["total_runs"],
            "success_runs": mem1_stat["success_runs"],
            "error_runs": mem1_stat["error_runs"],
            "success_rate_percent": f"{mem1_stat['success_rate_percent']:.2f}",
            "mean_us": format_num(mem1_stat["mean_us"]),
            "p50_us": format_num(mem1_stat["p50_us"]),
            "mem1_over_mem0_geomean": "" if mem1_over_mem0_geomean is None else f"{mem1_over_mem0_geomean:.6f}",
            "sfi_over_mem0_geomean": "",
        },
        {
            "variant": "sfi",
            "total_runs": sfi_stat["total_runs"],
            "success_runs": sfi_stat["success_runs"],
            "error_runs": sfi_stat["error_runs"],
            "success_rate_percent": f"{sfi_stat['success_rate_percent']:.2f}",
            "mean_us": format_num(sfi_stat["mean_us"]),
            "p50_us": format_num(sfi_stat["p50_us"]),
            "mem1_over_mem0_geomean": "",
            "sfi_over_mem0_geomean": "" if sfi_over_mem0_geomean is None else f"{sfi_over_mem0_geomean:.6f}",
        },
    ]

    os.makedirs(RESULT, exist_ok=True)
    with open(OUT_CSV, "w", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "variant",
                "total_runs",
                "success_runs",
                "error_runs",
                "success_rate_percent",
                "mean_us",
                "p50_us",
                "mem1_over_mem0_geomean",
                "sfi_over_mem0_geomean",
            ],
        )
        w.writeheader()
        w.writerows(rows)

    with open(OUT_MD, "w", encoding="utf-8") as f:
        f.write("| variant | total_runs | success_runs | error_runs | success_rate(%) | mean_us | p50_us | mem1_over_mem0_geomean | sfi_over_mem0_geomean |\n")
        f.write("|---|---:|---:|---:|---:|---:|---:|---:|---:|\n")
        for r in rows:
            f.write(
                f"| {r['variant']} | {r['total_runs']} | {r['success_runs']} | {r['error_runs']} | {r['success_rate_percent']} | {r['mean_us']} | {r['p50_us']} | {r['mem1_over_mem0_geomean']} | {r['sfi_over_mem0_geomean']} |\n"
            )

    print(f"wrote: {OUT_CSV}")
    print(f"wrote: {OUT_MD}")


if __name__ == "__main__":
    main()
