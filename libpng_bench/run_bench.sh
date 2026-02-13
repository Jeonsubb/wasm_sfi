#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

: "${BENCH_MIN_POW:=10}"
: "${BENCH_MAX_POW:=21}"
: "${BENCH_RUNS:=5}"

export BENCH_MIN_POW BENCH_MAX_POW BENCH_RUNS

python3 "$ROOT/run_bench_mem0.py"
python3 "$ROOT/run_bench_mem1.py"
python3 "$ROOT/run_bench_sfi.py"
python3 "$ROOT/bench_analysis.py"
