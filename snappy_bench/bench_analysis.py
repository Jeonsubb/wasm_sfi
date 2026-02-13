#!/usr/bin/env python3
import csv
import math
import os
from statistics import median

ROOT = os.path.dirname(os.path.abspath(__file__))
RESULT_DIR = os.path.join(ROOT, "bench_result")

MIN_POW = int(os.environ.get("BENCH_MIN_POW", "0"))
MAX_POW = int(os.environ.get("BENCH_MAX_POW", "21"))
SIZES = [1 << i for i in range(MIN_POW, MAX_POW + 1)]

TIME_UNIT = "us"
VARIANTS = ("mem0", "mem1", "sfi")


def format_bytes(size):
    if size < 0:
        return str(size)
    units = ["B", "KB", "MB", "GB", "TB"]
    value = float(size)
    unit_idx = 0
    while value >= 1024.0 and unit_idx < len(units) - 1:
        value /= 1024.0
        unit_idx += 1
    if value >= 10 or value.is_integer():
        value_str = f"{int(value)}"
    else:
        value_str = f"{value:.1f}"
    return f"{value_str}{units[unit_idx]}"


def size_label_parts(size):
    if size <= 0:
        return str(size), str(size)
    pow2 = size.bit_length() - 1
    return str(pow2), format_bytes(size)


def read_rows(path):
    with open(path, "r", newline="") as f:
        reader = csv.DictReader(f)
        return list(reader)


def write_rows(path, rows):
    if not rows:
        return
    with open(path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(rows[0].keys())
        for row in rows:
            w.writerow(row.values())
    print(f"wrote: {path}")


def build_series(rows, bench_name):
    series = {variant: [] for variant in VARIANTS}
    for variant in series:
        for size in SIZES:
            values = []
            for row in rows:
                if row.get("bench") != bench_name:
                    continue
                if row.get("variant") != variant:
                    continue
                if int(row.get("size", "0")) != size:
                    continue
                if row.get("ret") != "0":
                    continue
                try:
                    values.append(float(row.get(TIME_UNIT, "")))
                except ValueError:
                    continue
            series[variant].append(median(values) if values else None)
    return series


def geometric_mean(values):
    if not values:
        return None
    log_sum = 0.0
    count = 0
    for v in values:
        if v <= 0:
            continue
        log_sum += math.log(v)
        count += 1
    if count == 0:
        return None
    return math.exp(log_sum / count)


def compute_ratio(mem0_series, mem1_series):
    ratios = []
    for mem0, mem1 in zip(mem0_series, mem1_series):
        if mem0 is None or mem1 is None or mem0 <= 0:
            ratios.append(None)
        else:
            ratios.append(mem1 / mem0)
    values = [v for v in ratios if v is not None and v > 0]
    geomean_ratio = geometric_mean(values)
    return ratios, geomean_ratio


def compute_pair_ratio(num_series, den_series):
    ratios = []
    for num, den in zip(num_series, den_series):
        if num is None or den is None or den <= 0:
            ratios.append(None)
        else:
            ratios.append(num / den)
    values = [v for v in ratios if v is not None and v > 0]
    geomean_ratio = geometric_mean(values)
    return ratios, geomean_ratio


def write_overhead_csv(out_csv, den_name, num_name, den_series, num_series, ratios, geomean_ratio):
    rows = []
    for size, den_val, num_val, ratio in zip(SIZES, den_series, num_series, ratios):
        rows.append([size, den_val, num_val, ratio])

    with open(out_csv, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["size", f"{den_name}_{TIME_UNIT}", f"{num_name}_{TIME_UNIT}", f"{num_name}_over_{den_name}"])
        w.writerow(["geomean_ratio", "", "", geomean_ratio])
        w.writerows(rows)
    print(f"wrote: {out_csv}")


def write_overhead_svg(ratios, out_svg, title, geomean_ratio):
    values = [v for v in ratios if v is not None and v > 0]
    if not values:
        print("no data for overhead chart")
        return

    width = 900
    height = 540
    margin = 60
    plot_w = width - margin * 2
    plot_h = height - margin * 2

    min_y = min(values)
    max_y = max(values)
    if min_y == max_y:
        min_y = min_y / 2
        max_y = max_y * 2

    min_x = min(SIZES)
    max_x = max(SIZES)
    log_min_x = math.log2(min_x)
    log_max_x = math.log2(max_x)
    log_min_y = math.log10(min_y)
    log_max_y = math.log10(max_y)

    def x_pos(size):
        if log_max_x == log_min_x:
            return margin + plot_w / 2
        x = (math.log2(size) - log_min_x) / (log_max_x - log_min_x)
        return margin + x * plot_w

    def y_pos(val):
        if log_max_y == log_min_y:
            return margin + plot_h / 2
        y = (math.log10(val) - log_min_y) / (log_max_y - log_min_y)
        return margin + plot_h * (1.0 - y)

    lines = []
    lines.append('<?xml version="1.0" encoding="UTF-8"?>')
    lines.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">')
    lines.append('<rect width="100%" height="100%" fill="#ffffff"/>')
    lines.append(f'<rect x="{margin}" y="{margin}" width="{plot_w}" height="{plot_h}" fill="#fafafa" stroke="#d0d0d0"/>')
    lines.append(f'<text x="{margin}" y="{margin - 20}" font-family="sans-serif" font-size="16" fill="#222">{title}</text>')
    if geomean_ratio is not None:
        overhead_pct = (geomean_ratio - 1.0) * 100.0
        lines.append(f'<text x="{margin}" y="{margin - 4}" font-family="sans-serif" font-size="12" fill="#444">geomean ratio: {geomean_ratio:.3f} ({overhead_pct:+.2f}%)</text>')

    ticks = 6
    for i in range(ticks + 1):
        value = min_y * ((max_y / min_y) ** (i / ticks))
        y = y_pos(value)
        lines.append(f'<line x1="{margin}" y1="{y:.2f}" x2="{margin + plot_w}" y2="{y:.2f}" stroke="#e6e6e6"/>')
        lines.append(f'<text x="{margin - 10}" y="{y + 4:.2f}" font-family="sans-serif" font-size="11" fill="#555" text-anchor="end">{value:.3f}</text>')

    for idx, size in enumerate(SIZES):
        x = x_pos(size)
        pow_str, size_str = size_label_parts(size)
        ratio = ratios[idx] if idx < len(ratios) else None
        overhead_str = "-" if ratio is None or ratio <= 0 else f"{(ratio - 1.0) * 100:+.1f}%"
        lines.append(f'<line x1="{x:.2f}" y1="{margin}" x2="{x:.2f}" y2="{margin + plot_h}" stroke="#f0f0f0"/>')
        lines.append(
            f'<text x="{x:.2f}" y="{margin + plot_h + 18}" font-family="sans-serif" font-size="11" fill="#555" text-anchor="middle">'
            f'2<tspan baseline-shift="super" font-size="8">{pow_str}</tspan>'
            f'<tspan x="{x:.2f}" dy="12" font-size="10">{size_str}</tspan>'
            f'<tspan x="{x:.2f}" dy="12" font-size="10" fill="#777">{overhead_str}</tspan>'
            f'</text>'
        )

    points = []
    for size, ratio in zip(SIZES, ratios):
        if ratio is None or ratio <= 0:
            if points:
                lines.append(f'<polyline fill="none" stroke="#1b7f5a" stroke-width="2" points="{" ".join(points)}"/>')
                points = []
            continue
        x = x_pos(size)
        y = y_pos(ratio)
        points.append(f"{x:.2f},{y:.2f}")
        lines.append(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="3" fill="#1b7f5a"/>')
    if points:
        lines.append(f'<polyline fill="none" stroke="#1b7f5a" stroke-width="2" points="{" ".join(points)}"/>')

    lines.append(f'<text x="{margin}" y="{height - 10}" font-family="sans-serif" font-size="11" fill="#666">x: input size (2^n, bytes), y: mem1/mem0 (log10)</text>')
    lines.append('</svg>')

    with open(out_svg, "w", encoding="utf-8") as f:
        f.write("\\n".join(lines))
    print(f"wrote: {out_svg}")


def write_svg(series, out_svg, title, avg_overhead, ratios=None):
    width = 900
    height = 540
    margin = 60
    plot_w = width - margin * 2
    plot_h = height - margin * 2

    all_vals = [v for vals in series.values() for v in vals if v is not None]
    if not all_vals:
        print("no data for chart")
        return
    max_y = max(all_vals) * 1.1
    if max_y <= 0:
        max_y = 1.0

    def x_pos(idx):
        if len(SIZES) == 1:
            return margin + plot_w / 2
        return margin + (idx / (len(SIZES) - 1)) * plot_w

    def y_pos(val):
        return margin + plot_h * (1.0 - (val / max_y))

    colors = {
        "mem0": "#1b7f5a",
        "mem1": "#c65b2b",
        "sfi": "#2a62c6",
    }

    lines = []
    lines.append('<?xml version="1.0" encoding="UTF-8"?>')
    lines.append(f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">')
    lines.append('<rect width="100%" height="100%" fill="#ffffff"/>')
    lines.append(f'<rect x="{margin}" y="{margin}" width="{plot_w}" height="{plot_h}" fill="#fafafa" stroke="#d0d0d0"/>')
    lines.append(f'<text x="{margin}" y="{margin - 20}" font-family="sans-serif" font-size="16" fill="#222">{title}</text>')
    if avg_overhead is not None:
        lines.append(f'<text x="{margin}" y="{margin - 4}" font-family="sans-serif" font-size="12" fill="#444">avg mem1 over mem0: {avg_overhead * 100:+.2f}%</text>')

    ticks = 100
    label_every = 10
    for i in range(ticks + 1):
        y = margin + (plot_h / ticks) * i
        value = max_y * (1 - i / ticks)
        is_major = (i % label_every) == 0
        stroke = "#e6e6e6" if is_major else "#f3f3f3"
        lines.append(f'<line x1="{margin}" y1="{y:.2f}" x2="{margin + plot_w}" y2="{y:.2f}" stroke="{stroke}"/>')
        if is_major:
            lines.append(f'<text x="{margin - 10}" y="{y + 4:.2f}" font-family="sans-serif" font-size="11" fill="#555" text-anchor="end">{value:.2f}</text>')

    for i, size in enumerate(SIZES):
        x = x_pos(i)
        pow_str, size_str = size_label_parts(size)
        overhead_str = "-"
        if ratios is not None and i < len(ratios):
            r = ratios[i]
            if r is not None and r > 0:
                overhead_str = f"{(r - 1.0) * 100:+.1f}%"
        lines.append(f'<line x1="{x:.2f}" y1="{margin}" x2="{x:.2f}" y2="{margin + plot_h}" stroke="#f0f0f0"/>')
        lines.append(
            f'<text x="{x:.2f}" y="{margin + plot_h + 18}" font-family="sans-serif" font-size="11" fill="#555" text-anchor="middle">'
            f'2<tspan baseline-shift="super" font-size="8">{pow_str}</tspan>'
            f'<tspan x="{x:.2f}" dy="12" font-size="10">{size_str}</tspan>'
            f'<tspan x="{x:.2f}" dy="12" font-size="10" fill="#777">{overhead_str}</tspan>'
            f'</text>'
        )

    legend_y = margin - 35
    legend_x = margin + plot_w - 220
    legend_idx = 0
    for name, values in series.items():
        color = colors.get(name, "#3366cc")
        points = []
        for i, val in enumerate(values):
            if val is None:
                if points:
                    lines.append(f'<polyline fill="none" stroke="{color}" stroke-width="2" points="{" ".join(points)}"/>')
                    points = []
                continue
            x = x_pos(i)
            y = y_pos(val)
            points.append(f"{x:.2f},{y:.2f}")
            lines.append(f'<circle cx="{x:.2f}" cy="{y:.2f}" r="3" fill="{color}"/>')
        if points:
            lines.append(f'<polyline fill="none" stroke="{color}" stroke-width="2" points="{" ".join(points)}"/>')

        lines.append(f'<rect x="{legend_x}" y="{legend_y + legend_idx * 18}" width="12" height="12" fill="{color}"/>')
        lines.append(f'<text x="{legend_x + 18}" y="{legend_y + legend_idx * 18 + 10}" font-family="sans-serif" font-size="12" fill="#222">{name}</text>')
        legend_idx += 1

    lines.append(f'<text x="{margin}" y="{height - 10}" font-family="sans-serif" font-size="11" fill="#666">x: input size (2^n, bytes), y: {TIME_UNIT} per run</text>')
    lines.append('</svg>')

    with open(out_svg, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))
    print(f"wrote: {out_svg}")


def merge_bench(bench_name, mem0_csv, mem1_csv, out_prefix, title_prefix):
    mem0_rows = read_rows(mem0_csv)
    mem1_rows = read_rows(mem1_csv)
    sfi_csv = os.path.join(RESULT_DIR, f"sfi_{out_prefix.split('_')[-1]}.csv")
    sfi_rows = read_rows(sfi_csv)
    all_rows = mem0_rows + mem1_rows + sfi_rows

    combined_csv = os.path.join(RESULT_DIR, f"{out_prefix}.csv")
    write_rows(combined_csv, all_rows)

    series = build_series(all_rows, bench_name)
    ratios_mem1_mem0, geomean_mem1_mem0 = compute_pair_ratio(series["mem1"], series["mem0"])
    ratios_sfi_mem0, geomean_sfi_mem0 = compute_pair_ratio(series["sfi"], series["mem0"])
    ratios_sfi_mem1, geomean_sfi_mem1 = compute_pair_ratio(series["sfi"], series["mem1"])

    # Backward-compatible output name: mem1/mem0.
    overhead_csv = os.path.join(RESULT_DIR, f"{out_prefix}_overhead.csv")
    write_overhead_csv(
        overhead_csv,
        "mem0",
        "mem1",
        series["mem0"],
        series["mem1"],
        ratios_mem1_mem0,
        geomean_mem1_mem0,
    )

    # New pairwise overhead outputs.
    overhead_csv_mem1_mem0 = os.path.join(RESULT_DIR, f"{out_prefix}_overhead_mem1_over_mem0.csv")
    write_overhead_csv(
        overhead_csv_mem1_mem0,
        "mem0",
        "mem1",
        series["mem0"],
        series["mem1"],
        ratios_mem1_mem0,
        geomean_mem1_mem0,
    )
    overhead_csv_sfi_mem0 = os.path.join(RESULT_DIR, f"{out_prefix}_overhead_sfi_over_mem0.csv")
    write_overhead_csv(
        overhead_csv_sfi_mem0,
        "mem0",
        "sfi",
        series["mem0"],
        series["sfi"],
        ratios_sfi_mem0,
        geomean_sfi_mem0,
    )
    overhead_csv_sfi_mem1 = os.path.join(RESULT_DIR, f"{out_prefix}_overhead_sfi_over_mem1.csv")
    write_overhead_csv(
        overhead_csv_sfi_mem1,
        "mem1",
        "sfi",
        series["mem1"],
        series["sfi"],
        ratios_sfi_mem1,
        geomean_sfi_mem1,
    )

    svg_path = os.path.join(RESULT_DIR, f"{out_prefix}.svg")
    # 기존 표기 유지: headline overhead는 mem1/mem0 기준.
    avg_overhead = (geomean_mem1_mem0 - 1.0) if geomean_mem1_mem0 is not None else None
    write_svg(series, svg_path, f"{title_prefix} (median {TIME_UNIT} per run)", avg_overhead, ratios_mem1_mem0)

    overhead_svg = os.path.join(RESULT_DIR, f"{out_prefix}_overhead.svg")
    write_overhead_svg(ratios_mem1_mem0, overhead_svg, f"{title_prefix} Overhead mem1/mem0 (log-log)", geomean_mem1_mem0)
    overhead_svg_mem1_mem0 = os.path.join(RESULT_DIR, f"{out_prefix}_overhead_mem1_over_mem0.svg")
    write_overhead_svg(
        ratios_mem1_mem0,
        overhead_svg_mem1_mem0,
        f"{title_prefix} Overhead mem1/mem0 (log-log)",
        geomean_mem1_mem0,
    )
    overhead_svg_sfi_mem0 = os.path.join(RESULT_DIR, f"{out_prefix}_overhead_sfi_over_mem0.svg")
    write_overhead_svg(
        ratios_sfi_mem0,
        overhead_svg_sfi_mem0,
        f"{title_prefix} Overhead sfi/mem0 (log-log)",
        geomean_sfi_mem0,
    )
    overhead_svg_sfi_mem1 = os.path.join(RESULT_DIR, f"{out_prefix}_overhead_sfi_over_mem1.svg")
    write_overhead_svg(
        ratios_sfi_mem1,
        overhead_svg_sfi_mem1,
        f"{title_prefix} Overhead sfi/mem1 (log-log)",
        geomean_sfi_mem1,
    )


def main():
    mem0_compress = os.path.join(RESULT_DIR, "mem0_compress.csv")
    mem1_compress = os.path.join(RESULT_DIR, "mem1_compress.csv")
    sfi_compress = os.path.join(RESULT_DIR, "sfi_compress.csv")
    mem0_uncompress = os.path.join(RESULT_DIR, "mem0_uncompress.csv")
    mem1_uncompress = os.path.join(RESULT_DIR, "mem1_uncompress.csv")
    sfi_uncompress = os.path.join(RESULT_DIR, "sfi_uncompress.csv")

    for path in (mem0_compress, mem1_compress, sfi_compress, mem0_uncompress, mem1_uncompress, sfi_uncompress):
        if not os.path.exists(path):
            raise SystemExit(f"missing: {path}")

    merge_bench(
        "bench_snappy_compress",
        mem0_compress,
        mem1_compress,
        "bench_compress",
        "Snappy Compress",
    )
    merge_bench(
        "bench_snappy_uncompress",
        mem0_uncompress,
        mem1_uncompress,
        "bench_uncompress",
        "Snappy Uncompress",
    )


if __name__ == "__main__":
    main()
