#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 벤치가 "실행 실패"보다 "사전 점검 실패"로 빠르게 끝나게 하려는 체크 스크립트.
# libpng 벤치는 시간이랑 압축률을 같이 측정하므로 빌드/런타임 의존성이 모두 필요하다.
REQUIRED_CMDS=(clang-18 llvm-link-18 llc-18 opt-18 wasm-ld wasm-opt)
missing=()
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    missing+=("$cmd")
  fi
done

if ((${#missing[@]} > 0)); then
  echo "[missing tools] ${missing[*]}"
else
  echo "[ok] llvm/wasm toolchain found"
fi

LIBPNG_LIB="${LIBPNG_LIB:-$ROOT/vendor/libpng/libpng.a}"
ZLIB_LIB="${ZLIB_LIB:-$ROOT/vendor/zlib/libz.a}"
if [[ ! -f "$LIBPNG_LIB" ]]; then
  echo "[missing lib] $LIBPNG_LIB"
fi
if [[ ! -f "$ZLIB_LIB" ]]; then
  echo "[missing lib] $ZLIB_LIB"
fi

if python3 - <<'PY' >/dev/null 2>&1
import wasmtime
PY
then
  echo "[ok] python wasmtime module found"
else
  echo "[missing py module] wasmtime"
  if python3 -m pip --version >/dev/null 2>&1; then
    echo "[install] python3 -m pip install --user wasmtime"
    python3 -m pip install --user wasmtime || true
  else
    echo "[hint] pip unavailable. install pip first, then: python3 -m pip install --user wasmtime"
  fi
fi

echo "done"
