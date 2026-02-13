# 디자인: libpng 벤치 (Rust/C FFI + Wasm 격리)

## 왜 이렇게 구성했나

- 기존 `snappy_bench` 파이프라인을 최대한 유지해야 mem0/mem1/sfi 오버헤드 비교가 공정함.
- 첫 단계에서 복잡한 파일 I/O를 제거하고, 메모리 기반 PNG encode/decode만 측정해야 원인 분리가 쉬움.
- Rust 쪽은 `no_std`를 유지해 현재 wasm_sfi 실험 조건(프리스탠딩, 커스텀 런타임)과 동일하게 맞춤.

## 측정 대상

- `bench_png_encode`: raw RGBA -> PNG
- `bench_png_decode`: PNG -> raw RGBA
- `bench_verify_decode`: decode 결과 정확성 검증(memcmp)

## 데이터셋 전략

- 벤치 실행 루프는 `data/dataset_sizes.csv`의 `raw_bytes`를 기준으로 size 스윕.
- 별도 PNG 샘플(`data/png_samples`)은 크기/압축성 확인용으로 생성.
- 기본 범위: 1KiB(2^10) ~ 2MiB(2^21)

## 제약/가정

- 정적 라이브러리 `libpng.a`, `libz.a`가 wasm 대상용으로 준비되어 있어야 함.
- 현재 단계는 파일 시스템 API가 아닌 메모리 API 중심.
- mem1/sfi 빌드는 기존 `wasm-mem1_sfi` 패스/런타임 가용성을 전제로 함.
