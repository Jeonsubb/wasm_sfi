#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

: "${BENCH_RUNS:=5}"
: "${PNG_FILE_LIMIT:=4}"

export BENCH_RUNS
export PNG_FILE_LIMIT

PYTHON_BIN="${PYTHON_BIN:-python3}"
if [[ -x "$ROOT/.venv/bin/python" ]]; then
  PYTHON_BIN="$ROOT/.venv/bin/python"
fi

"$PYTHON_BIN" "$ROOT/run_bench_pngsuite.py" mem0
"$PYTHON_BIN" "$ROOT/run_bench_pngsuite.py" mem1
"$PYTHON_BIN" "$ROOT/run_bench_pngsuite.py" sfi
"$PYTHON_BIN" "$ROOT/bench_analysis_decode_only.py"
