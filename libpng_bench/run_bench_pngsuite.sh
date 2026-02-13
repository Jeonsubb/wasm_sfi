#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

python3 "$ROOT/run_bench_pngsuite_mem0.py"
python3 "$ROOT/run_bench_pngsuite_sfi.py"
