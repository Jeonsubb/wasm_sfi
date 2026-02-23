# libpng_bench (decode-lite, wasm32-unknown-unknown + no_std)

`mem0`, `mem1`, `sfi` 경로에서 libpng 기반 PNG header decode-lite(IHDR 파싱) 동작을 비교하는 벤치입니다.

## 빌드 스크립트

- `build_mem0_libpng.sh`
- `build_mem1_libpng.sh`
- `build_sfi_libpng.sh`

## 벤치 실행

1. 빌드:
   - `./build_mem0_libpng.sh`
   - `./build_mem1_libpng.sh`
   - `./build_sfi_libpng.sh`
2. 벤치:
   - `./run_bench.sh`
   - 또는 단일 실행: `python3 run_bench_pngsuite.py mem0|mem1|sfi`

결과:
- raw run CSV:
  - `bench_result/mem0_pngsuite_decode.csv`
  - `bench_result/mem1_pngsuite_decode.csv`
  - `bench_result/sfi_pngsuite_decode.csv`
- 요약 테이블:
  - `bench_result/decode_only_summary.md`

## 필수 의존성

- 빌드 툴: `clang-18`, `llvm-link-18`, `llc-18`, `opt-18`, `wasm-ld`, `wasm-opt`
- 벤치 런타임: Python `wasmtime` 모듈
- 정적 라이브러리: (없음, source compile)
- Rust:
  - mem0만 필요: `rustc` + `wasm32-unknown-unknown`
  - mem1/sfi 필요: `rustup` + `nightly-2024-05-05` + `rustc-dev` + `wasm32-unknown-unknown`

### Rust 설치 예시

```bash
# rustup 설치 (이미 있으면 생략)
curl https://sh.rustup.rs -sSf | sh -s -- -y
source "$HOME/.cargo/env"

# mem0 용 pinned toolchain
rustup toolchain install 1.78.0
rustup target add wasm32-unknown-unknown --toolchain 1.78.0

# mem1/sfi 용 mem1-rustc 요구사항
rustup toolchain install nightly-2024-05-05
rustup component add rustc-dev --toolchain nightly-2024-05-05
rustup target add wasm32-unknown-unknown --toolchain nightly-2024-05-05
```

## PngSuite 디코드 벤치

PngSuite 데이터셋을 로컬에 준비한 뒤 파일 기반 디코드 벤치를 실행할 수 있습니다.

```bash
# 예시: PngSuite mirror를 data/pngsuite 로 가져오기
git clone https://github.com/lunapaint/pngsuite.git /home/ehdgns/wasm_sfi/libpng_bench/data/pngsuite

cd /home/ehdgns/wasm_sfi/libpng_bench
./build_mem0_libpng.sh
./build_mem1_libpng.sh
./build_sfi_libpng.sh
./run_bench.sh
```

환경변수 `PNGSUITE_DIR`로 데이터셋 경로를 변경할 수 있습니다.
