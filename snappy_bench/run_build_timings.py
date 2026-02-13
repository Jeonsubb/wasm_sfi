#!/usr/bin/env python3
import csv
import os
import subprocess
import time
from dataclasses import dataclass
from typing import Dict, Iterable, List

# Measure per-stage build times for mem1 and mem0 snappy builds.
# Debug-only steps from the shell scripts (llvm-dis, wasm2wat, wasm-decompile, cleanup) are omitted.

ROOT = os.path.expanduser("~/wasm-mem1-copy-out-remove")
MEM1_ROOT = os.path.join(ROOT, "wasm-mem1")
SNAPPY_ROOT = os.path.join(ROOT, "snappy_bench")
BENCH_RESULT = os.path.join(SNAPPY_ROOT, "bench_result")

OUT_MEM1 = os.path.join(SNAPPY_ROOT, "build", "mem1")
OUT_MEM0 = os.path.join(SNAPPY_ROOT, "build", "mem0")
RUNS = int(os.environ.get("BUILD_TIME_RUNS", "20"))

# Time unit handling
TIME_UNIT = os.environ.get("BUILD_TIME_UNIT", "ms").lower()  # s | ms | us
if TIME_UNIT == "us":
    TIME_SCALE = 1_000_000.0
elif TIME_UNIT == "ms":
    TIME_SCALE = 1_000.0
else:
    TIME_UNIT = "s"
    TIME_SCALE = 1.0
TIME_COL = f"duration_{TIME_UNIT}"


@dataclass
class Stage:
    name: str
    cmd: List[str]
    cwd: str = SNAPPY_ROOT
    env: Dict[str, str] | None = None


def run_stage(stage: Stage) -> tuple[str, float, int, str]:
    env = os.environ.copy()
    if stage.env:
        env.update(stage.env)
    t0 = time.perf_counter()
    proc = subprocess.run(
        stage.cmd,
        cwd=stage.cwd,
        env=env,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    t1 = time.perf_counter()
    return stage.name, t1 - t0, proc.returncode, proc.stdout


def run_variant(variant: str, stages: Iterable[Stage], csv_path: str, runs: int) -> None:
    rows: list[list[str]] = []
    os.makedirs(os.path.dirname(csv_path), exist_ok=True)

    total_start = time.perf_counter()
    overall_rc = 0
    for stage in stages:
        sum_elapsed = 0.0
        rc = 0
        out = ""
        runs_done = 0
        for i in range(runs):
            _, elapsed, rc, out = run_stage(stage)
            sum_elapsed += elapsed
            runs_done += 1
            if rc != 0:
                overall_rc = rc
                print(f"[{variant}] {stage.name} failed on run {i + 1}/{runs}")
                print(f"[{variant}] output:\n{out}")
                break

        avg_elapsed = sum_elapsed / runs_done if runs_done else 0.0
        scaled_avg = avg_elapsed * TIME_SCALE
        rows.append([variant, stage.name, f"{scaled_avg:.6f}", rc, runs_done])
        print(f"[{variant}] {stage.name}: avg={scaled_avg:.3f}{TIME_UNIT} over {runs_done} runs rc={rc}")
        if rc != 0:
            break

    total_elapsed = time.perf_counter() - total_start
    rows.append([variant, "TOTAL", f"{(total_elapsed * TIME_SCALE) / 20:.6f}", overall_rc, ""])

    with open(csv_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["variant", "stage", TIME_COL, "returncode", "runs"])
        w.writerows(rows)
    print(f"wrote {csv_path}")


def render_table_image(csv_path: str, png_path: str, title: str | None = None) -> None:
    try:
        import pandas as pd
        import matplotlib.pyplot as plt
        from matplotlib import font_manager
    except ImportError as exc:
        raise SystemExit(f"missing module for rendering table image: {exc}")

    if not os.path.exists(csv_path):
        raise SystemExit(f"csv not found: {csv_path}")

    df = pd.read_csv(csv_path)

    # Pick a font with Hangul support if available to avoid missing glyph warnings.
    preferred_fonts = [
        "Noto Sans CJK KR",
        "NanumGothic",
        "Apple SD Gothic Neo",
        "Malgun Gothic",
        "Noto Sans CJK JP",
        "Noto Sans",
    ]
    chosen_font = None
    for fname in preferred_fonts:
        try:
            path = font_manager.findfont(fname, fallback_to_default=False)
            if path and os.path.exists(path):
                chosen_font = fname
                break
        except Exception:
            continue
    if chosen_font:
        plt.rcParams["font.family"] = chosen_font

    max_stage_len = 0
    if "stage" in df.columns:
        max_stage_len = df["stage"].astype(str).map(len).max()
    fig_w = max(8, len(df.columns) * 1.6, max_stage_len * 0.2)
    fig, ax = plt.subplots(figsize=(fig_w, max(2, len(df) * 0.4)))
    ax.axis("off")
    table = ax.table(cellText=df.values, colLabels=df.columns, loc="center")
    table.auto_set_font_size(False)
    table.set_fontsize(8)
    table.scale(1.2, 1.2)
    if "stage" in df.columns:
        stage_idx = df.columns.get_loc("stage")
        for (row, col), cell in table.get_celld().items():
            if col == stage_idx:
                cell.set_width(cell.get_width() * 2.2)
    if title:
        ax.set_title(title, pad=10, fontsize=10)
    fig.tight_layout()
    os.makedirs(os.path.dirname(png_path), exist_ok=True)
    fig.savefig(png_path, dpi=200)
    plt.close(fig)
    print(f"wrote {png_path}")


def stages_mem1() -> List[Stage]:
    c_src = os.path.join(SNAPPY_ROOT, "project_testing", "c_snappy.c")
    rust_src = os.path.join(SNAPPY_ROOT, "project_testing", "rust_snappy.rs")
    libc_shim = os.path.join(SNAPPY_ROOT, "support", "libc_shim_mem1.c")

    vendor_dir = os.path.join(SNAPPY_ROOT, "vendor", "snappy")
    cflags_snappy = [
        f"-I{os.path.join(SNAPPY_ROOT, 'support')}",
        f"-I{vendor_dir}",
    ]

    pass_dir = os.path.join(MEM1_ROOT, "passes", "build")
    runtime_a = os.path.join(MEM1_ROOT, "build", "mem1_runtime.a")

    c_bc = os.path.join(OUT_MEM1, "mem1_c_ffi.bc")
    libc_bc = os.path.join(OUT_MEM1, "mem1_libc_shim.bc")
    c_nop = os.path.join(OUT_MEM1, "mem1_c_ffi_nop.bc")
    libc_nop = os.path.join(OUT_MEM1, "mem1_libc_shim_nop.bc")
    c_marked = os.path.join(OUT_MEM1, "mem1_c_ffi_marked.bc")
    rust_bc = os.path.join(OUT_MEM1, "mem1_rust_ffi.bc")
    rust_ro = os.path.join(OUT_MEM1, "mem1_rust_ffi.ro.bc")
    ro_list = os.path.join(OUT_MEM1, "mem1_ro_list.tsv")
    ffi_list = os.path.join(OUT_MEM1, "mem1_ffi_list.tsv")
    combined_bc = os.path.join(OUT_MEM1, "mem1_combined.bc")
    combined_rw = os.path.join(OUT_MEM1, "mem1_combined.rewritten.bc")
    obj = os.path.join(OUT_MEM1, "mem1_combined.o")
    raw_wasm = os.path.join(OUT_MEM1, "combined_mem1_raw.wasm")
    final_wasm = os.path.join(OUT_MEM1, "final_mem1.wasm")

    return [
        Stage(
            "C FFI clang (wasm32 bc)",
            ["clang-18", "--target=wasm32-unknown-unknown", "-Oz", "-ffreestanding"]
            + cflags_snappy
            + ["-emit-llvm", "-c", c_src, "-o", c_bc],
        ),
        Stage(
            "libc_shim clang (wasm32 bc)",
            [
                "clang-18",
                "--target=wasm32-unknown-unknown",
                "-Oz",
                "-ffreestanding",
                "-fno-builtin",
                "-emit-llvm",
                "-c",
                libc_shim,
                "-o",
                libc_bc,
            ],
        ),
        Stage(
            "Pass: insert-nop-grow (C)",
            [
                "opt-18",
                f"-load-pass-plugin={os.path.join(pass_dir, 'libInsertNopGrow.so')}",
                "-passes=function(insert-nop-grow)",
                c_bc,
                "-o",
                c_nop,
            ],
        ),
        Stage(
            "Pass: insert-nop-grow (libc_shim)",
            [
                "opt-18",
                f"-load-pass-plugin={os.path.join(pass_dir, 'libInsertNopGrow.so')}",
                "-passes=function(insert-nop-grow)",
                libc_bc,
                "-o",
                libc_nop,
            ],
        ),
        Stage(
            "Pass: mark-mem1-ffi (C)",
            [
                "opt-18",
                f"-load-pass-plugin={os.path.join(pass_dir, 'libMarkMem1FFI.so')}",
                "-passes=mark-mem1-ffi",
                c_nop,
                "-o",
                c_marked,
            ],
            env={"MEM1FFI_LIST_OUT": ffi_list},
        ),
        Stage(
            "Rust bc (mem1-rustc, wasm32)",
            [
                "bash",
                os.path.join(MEM1_ROOT, "tools", "mem1-rustc", "mem1-rustc.sh"),
                "--target=wasm32-unknown-unknown",
                "-C",
                "opt-level=2",
                "--emit=llvm-bc",
                "-o",
                rust_bc,
                rust_src,
            ],
            env={"MEM1_RO_LIST_OUT": ro_list, "MEM1_FFI_LIST": ffi_list},
        ),
        Stage(
            "Pass: inject-mem1-markers (Rust)",
            [
                "opt-18",
                f"-load-pass-plugin={os.path.join(pass_dir, 'libInjectMem1Markers.so')}",
                "-passes=inject-mem1-markers",
                rust_bc,
                "-o",
                rust_ro,
            ],
            env={"MEM1_RO_LIST": ro_list},
        ),
        Stage("llvm-link (Rust+C+libc_shim)", ["llvm-link-18", rust_ro, c_marked, libc_nop, "-o", combined_bc]),
        Stage(
            "Pass: rewrite-rust-alloc + rewrite-wasm-ffi",
            [
                "opt-18",
                f"-load-pass-plugin={os.path.join(pass_dir, 'libRewriteRustAllocToMem1.so')}",
                f"-load-pass-plugin={os.path.join(pass_dir, 'libRewriteWasmFFI.so')}",
                "-passes=rewrite-wasm-ffi",
                combined_bc,
                "-o",
                combined_rw,
            ],
        ),
        Stage("llc (wasm32 obj)", ["llc-18", "-filetype=obj", "-march=wasm32", combined_rw, "-o", obj]),
        Stage(
            "wasm-ld (+mem1_runtime)",
            [
                "wasm-ld",
                "--no-entry",
                "--export-all",
                "--no-gc-sections",
                obj,
                runtime_a,
                "-o",
                raw_wasm,
            ],
        ),
        Stage(
            "Binaryen Mem1RewritePass",
            ["wasm-opt", raw_wasm, "--enable-multimemory", "--Mem1RewritePass", "-o", final_wasm],
        ),
    ]


def stages_mem0() -> List[Stage]:
    c_src = os.path.join(SNAPPY_ROOT, "project_testing", "c_snappy.c")
    rust_src = os.path.join(SNAPPY_ROOT, "project_testing", "rust_snappy.rs")
    libc_shim = os.path.join(SNAPPY_ROOT, "support", "libc_shim.c")

    cflags_snappy = [f"-I{os.path.join(SNAPPY_ROOT, 'support')}"]

    c_bc = os.path.join(OUT_MEM0, "mem0_c_ffi.bc")
    libc_bc = os.path.join(OUT_MEM0, "mem0_libc_shim.bc")
    rust_bc = os.path.join(OUT_MEM0, "mem0_rust_ffi.bc")
    combined_bc = os.path.join(OUT_MEM0, "mem0_combined.bc")
    obj = os.path.join(OUT_MEM0, "mem0_combined.o")
    final_wasm = os.path.join(OUT_MEM0, "final_mem0.wasm")

    return [
        Stage(
            "C FFI clang (mem0 wasm32 bc)",
            ["clang-18", "--target=wasm32-unknown-unknown", "-Oz", "-ffreestanding"]
            + cflags_snappy
            + ["-emit-llvm", "-c", c_src, "-o", c_bc],
        ),
        Stage(
            "libc_shim clang (mem0)",
            [
                "clang-18",
                "--target=wasm32-unknown-unknown",
                "-Oz",
                "-ffreestanding",
                "-fno-builtin",
                "-emit-llvm",
                "-c",
                libc_shim,
                "-o",
                libc_bc,
            ],
        ),
        Stage(
            "Rust bc (rustc wasm32)",
            [
                "rustc",
                "+1.78.0",
                "--target=wasm32-unknown-unknown",
                "-C",
                "opt-level=2",
                "--emit=llvm-bc",
                "-o",
                rust_bc,
                rust_src,
            ],
        ),
        Stage("llvm-link (mem0)", ["llvm-link-18", rust_bc, c_bc, libc_bc, "-o", combined_bc]),
        Stage("llc (mem0 obj)", ["llc-18", "-filetype=obj", "-march=wasm32", combined_bc, "-o", obj]),
        Stage(
            "wasm-ld (mem0 final wasm)",
            ["wasm-ld", "--no-entry", "--export-all", "--no-gc-sections", obj, "-o", final_wasm],
        ),
    ]


def main() -> None:
    # Ensure output dirs exist (creation time not measured).
    os.makedirs(OUT_MEM1, exist_ok=True)
    os.makedirs(OUT_MEM0, exist_ok=True)

    mem1_csv = os.path.join(BENCH_RESULT, "build_mem1_times.csv")
    mem0_csv = os.path.join(BENCH_RESULT, "build_mem0_times.csv")
    run_variant("mem1", stages_mem1(), mem1_csv, RUNS)
    run_variant("mem0", stages_mem0(), mem0_csv, RUNS)

    # Render tables as images (requires pandas, matplotlib).
    render_table_image(mem1_csv, os.path.join(BENCH_RESULT, "build_mem1_times.png"), title="mem1 build timings")
    render_table_image(mem0_csv, os.path.join(BENCH_RESULT, "build_mem0_times.png"), title="mem0 build timings")


if __name__ == "__main__":
    main()
