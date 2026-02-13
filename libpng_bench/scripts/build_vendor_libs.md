# Vendor libs 준비

`libpng_bench`는 다음 정적 라이브러리가 필요합니다.

- `vendor/zlib/libz.a`
- `vendor/libpng/libpng.a`

빌드 스크립트는 기본적으로 위 경로를 사용하며, 필요하면 환경변수로 덮어쓸 수 있습니다.

- `ZLIB_LIB=/path/to/libz.a`
- `LIBPNG_LIB=/path/to/libpng.a`

또한 C include 경로는 기본적으로 아래를 사용합니다.

- `-Ilibpng_bench/support`
- `-Ilibpng_bench/vendor/libpng`
- `-Ilibpng_bench/vendor/zlib`

필요하면 `CFLAGS_LIBPNG`로 재정의하세요.
