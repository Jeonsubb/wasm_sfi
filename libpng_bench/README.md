# libpng_bench (wasm32-unknown-unknown + no_std)

`snappy_bench`와 동일한 목적/구조로 `libpng`를 Rust->C FFI 경로에 올린 벤치 디렉터리입니다.

## 목표

- 동일한 함수 동작을 `mem0`, `mem1`, `sfi` 경로에서 실행해 오버헤드를 비교.
- Rust caller + C callee + wasm-mem1_sfi 패스 체인을 그대로 재사용.
- `libpng` 호출을 먼저 최소 기능(버전 조회, encode/decode roundtrip)으로 안정화.

## 현재 엔트리 포인트

- Rust (`project_testing/rust_libpng.rs`)
  - `bench_prepare(size)`
  - `bench_png_encode(size)`
  - `bench_png_decode(size)`
  - `bench_verify_decode(size)`
  - `bench_get_encoded_len()`
  - `bench_get_libpng_version()`

- C (`project_testing/c_libpng.c`)
  - `c_libpng_version_number()`
  - `c_png_encode_rgba(...)`
  - `c_png_decode_rgba(...)`
  - `bench_fill_target_from_pool(...)`

## 빌드 스크립트

- `build_mem0_libpng.sh`
- `build_mem1_libpng.sh`
- `build_sfi_libpng.sh`

기본 라이브러리 경로:

- `vendor/zlib/libz.a`
- `vendor/libpng/libpng.a`

필요하면 아래 환경변수로 덮어씁니다.

- `ZLIB_LIB=/abs/path/libz.a`
- `LIBPNG_LIB=/abs/path/libpng.a`
- `CFLAGS_LIBPNG='-I... -I...'`

## 데이터셋

- 생성 스크립트: `scripts/generate_dataset.py`
- 출력 매니페스트: `data/dataset_sizes.csv`
- 출력 샘플 PNG: `data/png_samples/*.png`

기본 범위는 `2^10 .. 2^21` 바이트(1KiB..2MiB)입니다.

## 벤치 실행

1. 데이터셋 생성(이미 생성되어 있지 않다면):
   - `python3 scripts/generate_dataset.py`
2. 빌드:
   - `./build_mem0_libpng.sh`
   - `./build_mem1_libpng.sh`
   - `./build_sfi_libpng.sh`
3. 벤치:
   - `./run_bench.sh`

결과는 `bench_result/*.csv` 와 `bench_result/*.svg`에 생성됩니다.

- 시간 결과: `*_encode.csv`, `*_decode.csv`, `bench_encode*.csv`, `bench_decode*.csv`
- 압축률 결과: `bench_encode_compression_ratio.csv`, `bench_decode_compression_ratio.csv`

각 run CSV에는 `compression_ratio = encoded_len / raw_size` 컬럼이 포함됩니다.
이는 libpng 벤치에서 시간(성능)과 압축효율(품질)을 함께 해석하기 위함입니다.

## 필수 의존성

- 빌드 툴: `clang-18`, `llvm-link-18`, `llc-18`, `opt-18`, `wasm-ld`, `wasm-opt`
- 벤치 런타임: Python `wasmtime` 모듈
- 정적 라이브러리: `vendor/libpng/libpng.a`, `vendor/zlib/libz.a`
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

## PngSuite 디코드 벤치 (mem0/sfi)

PngSuite 데이터셋을 로컬에 준비한 뒤 파일 기반 디코드 벤치를 실행할 수 있습니다.

```bash
# 예시: PngSuite mirror를 data/pngsuite 로 가져오기
git clone https://github.com/lunapaint/pngsuite.git /home/ehdgns/wasm_sfi/libpng_bench/data/pngsuite

cd /home/ehdgns/wasm_sfi/libpng_bench
./build_mem0_libpng.sh
./build_sfi_libpng.sh
./run_bench_pngsuite.sh
python3 ./bench_analysis_pngsuite.py
```

환경변수 `PNGSUITE_DIR`로 데이터셋 경로를 변경할 수 있습니다.
