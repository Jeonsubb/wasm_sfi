# Snappy bench (wasm32-unknown-unknown + no_std)

목표
- 멀티메모리(mem1) 패스가 적용된 Rust↔C FFI 파이프라인 위에 Snappy를 올려 벤치/실험.
- 타깃 고정: `wasm32-unknown-unknown`, `no_std`, freestanding. libc를 직접 링크하지 않고 필요한 심벌만 shim 제공.

현재 구성/진행 사항
- Snappy 선택: C++ upstream 대신 `andikleen/snappy-c`(pure C) 사용해 C++ 런타임 의존 제거.
- 로컬 스텁 헤더: `support/`에 `endian.h`, `stdlib.h`(malloc/free no-op), `assert.h`, `errno.h`, `string.h`, `sys/types.h`, `sys/uio.h` 등 freestanding 빌드를 위한 최소 정의 제공.
- libc shim: `support/libc_shim.c`에서 `memcmp/memcpy/memmove/memset` 제공. 추가 동적 할당 shim 없음.
- Snappy 정적 라이브러리: `scripts/build_snappy_c.sh`로 `vendor/snappy/snappy.c`를 `libsnappy.a`로 빌드(`-ffreestanding -fno-builtin`, include는 `support/`와 `vendor/snappy/`).
- C 래퍼: `c_wrappers/snappy_ffi.c`에서 스택에 `snappy_env`/해시 테이블을 직접 할당해 `snappy_compress` 호출(동적 할당 경로 미사용). `snappy_uncompressed_length`로 길이 체크 후 `snappy_uncompress` 호출.
- Rust 엔트리: `rust/src/lib.rs`에 `no_std` 테스트/벤치 함수(`test_snappy_mem0`, `test_snappy_mem1`, `test_rust_alloc_rewritten_mem1`, `_start`)와 `mem1_region` 매크로 포함.
- 파이프라인: `scripts/build_full_pipeline_snappy.sh`가 LLVM 패스/런타임을 `/home/ubuntu/wasm-mem1`에서 재사용, 소스는 이 디렉터리를 사용. 기본으로 `libsnappy.a`를 링크하고 `support/`+`vendor/snappy/`를 include에 추가.
- 벤치: `bench/bench.sh`에서 wasmtime 반복 실행 루프 제공(`RUNS` 환경변수).

디렉터리 구조
- `c_wrappers/` : Snappy FFI 래퍼(동적 할당 없이 env 스택 할당).
- `rust/src/`   : `no_std` 엔트리/테스트, `mem1_region` 매크로.
- `vendor/snappy/` : snappy-c 소스 + 빌드 결과(`libsnappy.a`).
- `support/`    : freestanding 스텁 헤더/`libc_shim.c`.
- `scripts/`    : 전체 파이프라인(`build_full_pipeline_snappy.sh`), Snappy 전용 빌드(`build_snappy_c.sh`).
- `build/`      : 중간 bc/o/wasm 산출물.
- `bench/`      : wasmtime 루프, 입력 샘플용 폴더.
- `data/`, `results/` : 입력/결과 보관.

Snappy FFI 래핑 방식
- C 래퍼(`project_testing/c_ffi.c`): `snappy.h`를 직접 include하고, `snappy_compress`/`snappy_uncompress`/`snappy_max_compressed_length`를 `c_snappy_*`로 export. `snappy_env`와 해시 테이블(1<<14 u16 ≈ 32KiB)을 스택에 할당해 vmalloc/malloc 없이 압축을 수행한다. 압축 시 `snappy_compress`에 스택 env/테이블을 넘기고, 해제 시 입력 길이를 먼저 `snappy_uncompressed_length`로 확인해 버퍼 부족을 오류로 반환한다.
- Rust 래퍼(`project_testing/rust_ffi.rs`): `extern "C"`로 `c_snappy_*`를 선언한 뒤, 샘플 데이터(`"hello snappy ffi"`)를 mem0 버퍼에서 압축/해제하는 테스트(`test_snappy_mem0`)만 남겨 `_start`에서 호출한다. 결과 길이를 Rust 쪽에서 관리해 C 래퍼가 채워주는 out_len을 검증한다.
- 목적: freestanding/no_std 환경에서 Snappy를 zero-alloc 경로로 호출하고, 멀티메모리 패스를 거치지 않은 mem0 경로만 검증하기 위해 단순화.

사용 흐름(요약)
1) Snappy 정적 라이브러리 빌드: `./scripts/build_snappy_c.sh` (필요시 `NOSTDINC=1 BUILTIN_INC=...` 지정).
2) 파이프라인 빌드: `./scripts/build_full_pipeline_snappy.sh` (기본으로 `libsnappy.a` 링크, 필요시 `CFLAGS_SNAPPY`/`SNAPPY_LIBS` override).
3) 실행/벤치: `wasmtime final.wasm --invoke _start` 또는 `./bench/bench.sh` (RUNS 조절).

**Rust/C WASM 멀티메모리 파이프라인**

- 핵심 흐름은 wasm-mem1/build_full_pipeline_rust_c.sh가 C FFI 피호출부(project_testing/c_ffi.c)와 Rust 호출부(project_testing/rust_ffi.rs)를 wasm32용 LLVM IR로 만든 뒤, 커스텀 LLVM 패스를 적용해 멀티 메모리(mem0/mem1) 친화적으로 재작성하고, Binaryen로 mem1 리라이트까지 거쳐 최종 final.wasm을 생성·검증한다.
- **런타임 헬퍼 빌드**: 0단계에서 wasm-mem1/build_runtime.sh 실행. c_alloc/mem0_primitives.c(mem0 전용), mem1_primitives.c, mem1_sbrk.c, copy_shuttle.c를 wasm32 오브젝트로 만든 뒤 정적 라이브러리 build/mem1_runtime.a로 묶는다. mem1_primitives/mem1_sbrk에는 함수 패스 InsertNop를 적용해 mem1 영역의 메모리 op를 마킹해 둔다.
- **LLVM 패스 빌드** (passes/src/*.cpp):
    - RewriteWasmFFI.cpp → libRewriteFFI.so: mem1-ffi로 마킹된 피호출 함수 호출지점에 대해 mem0↔mem1 셔틀(__mem1_alloc, __memcpy_0_to_1, __memcpy_1_to_0, __mem1_free)을 삽입하고 포인터/길이 인자를 mem1 주소로 교체, deep-copy 스펙도 처리.
    - RewriteRustAllocToMem1.cpp → libRewriteRustAllocToMem1.so: mem1_region 구간 내 __rust_alloc/malloc→__mem1_alloc, __rust_dealloc/free→__mem1_free로 치환하고 mem1 레지던스 메타데이터를 부여.
    - InsertNopPass.cpp → libInsertNopPass.so: __mem1_region_begin~__mem1_region_end 사이 load/store/memory.grow/size 뒤에 inline asm nop을 꽂아 Binaryen 리라이트용 힌트를 남김.
    - MarkMem1FFI.cpp → libMarkMem1FFI.so: wasm-export된 C 함수 중 포인터 인자가 있는 것에 mem1-ffi/arg 속성을 자동 부여(환경변수 MEM1FFI_SKIP로 스킵 가능). c_deep_update에는 deep-copy 속성도 부여. 빌드 실패 시 c_ffi.ll을 sed로 손봐 대체.
- **IR 생성·마킹**:
    - C 쪽을 clang-18 --target=wasm32-unknown-unknown -Oz -emit-llvm으로 build/c_ffi.bc 생성 후 Mark 패스로 FFI 속성 마킹(실패 시 수동 속성 주입 경로).
    - Rust 쪽을 rustc +1.78.0 --target=wasm32-unknown-unknown --emit=llvm-bc로 build/rust_ffi.bc 생성. Rust 코드(project_testing/rust_ffi.rs)는 mem1_region! 매크로(project_testing/mem1_region.rs)로 mem1 구역을 감싸고, 여러 테스트 함수와 _start 진입점을 노출.
- **패스 적용 파이프라인**:
    - llvm-link-18로 Rust/C IR을 build/combined.bc로 합침.
    - 4a) 함수 패스: opt-18 -passes='function(insert-nop)'로 mem1 영역 메모리 op 뒤에 nop 삽입.
    - 4b) 모듈 패스: opt-18에 rewrite-rust-alloc-to-mem1,rewrite-wasm-ffi 순서 적용, mem1 할당 치환 및 FFI 호출 셔틀 삽입.
- **코드 생성·링크**: llc-18 -march=wasm32로 오브젝트 생성 후, wasm-ld --no-entry --export-all --no-gc-sections로 런타임 라이브러리(build/mem1_runtime.a)와 함께 combined_raw.wasm 작성, 테스트 엔트리(_start, test_*)를 export. wasm2wat가 있으면 combined_raw.wat 덤프.
- **Binaryen 멀티메모리 리라이트**: wasm-opt --enable-multimemory --Mem1RewritePass로 mem1 관련 load/store/grow/size를 메모리 인덱스 1로 재작성, 결과를 final.wasm/final.wat로 저장.
- **결과 검증**: final.wat에서 각 테스트 함수의 mem1 셔틀 호출/메모리 op를 sed|grep으로 스팟 체크, mem1 allocator의 memory.grow 1/memory.size 1 존재 여부 확인. wasmtime가 있으면 모든 테스트 엔트리 포인트를 순차 실행해 동작을 확인.

필요한 산출물은 build/mem1_runtime.a, 중간 IR/오브젝트(build/*.bc, combined*.bc/.o), 그리고 최종 combined_raw.wasm/final.wasm(+wat)이며, 문제 발생 시 Mark 패스 실패 대비 수동 속성 주입 루틴까지 포함된 일련의 end-to-end Rust↔C FFI 멀티메모리 빌드 파이프라인이다.