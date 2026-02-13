#!/usr/bin/env python3
import csv
import os
import subprocess
import time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "bench_result")
RUNS = int(os.environ.get("BUILD_TIME_RUNS", "5"))

TARGETS = [
    ("mem0", ["bash", os.path.join(ROOT, "build_mem0_libpng.sh")]),
    ("mem1", ["bash", os.path.join(ROOT, "build_mem1_libpng.sh")]),
    ("sfi", ["bash", os.path.join(ROOT, "build_sfi_libpng.sh")]),
]


def run_once(cmd):
    t0 = time.perf_counter()
    proc = subprocess.run(cmd, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    t1 = time.perf_counter()
    return t1 - t0, proc.returncode, proc.stdout


def main():
    os.makedirs(OUT, exist_ok=True)
    rows = []
    for variant, cmd in TARGETS:
        for i in range(RUNS):
            elapsed, rc, out = run_once(cmd)
            rows.append(
                {
                    "variant": variant,
                    "run": i,
                    "seconds": f"{elapsed:.6f}",
                    "returncode": rc,
                }
            )
            print(f"[{variant}] run={i} sec={elapsed:.3f} rc={rc}")
            if rc != 0:
                print(out)
                break

    out_csv = os.path.join(OUT, "build_times.csv")
    with open(out_csv, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["variant", "run", "seconds", "returncode"])
        w.writeheader()
        w.writerows(rows)
    print(f"wrote: {out_csv}")


if __name__ == "__main__":
    main()
