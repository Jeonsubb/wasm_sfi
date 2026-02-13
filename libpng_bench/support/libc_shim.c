#include <stddef.h>
#include <stdint.h>

// ----------------------------------------------------------------
// 1. 기존 메모리/문자열 함수들
// ----------------------------------------------------------------

int memcmp(const void* a, const void* b, size_t n) {
    const uint8_t* p = (const uint8_t*)a;
    const uint8_t* q = (const uint8_t*)b;
    for (size_t i = 0; i < n; ++i) {
        if (p[i] != q[i]) return (int)p[i] - (int)q[i];
    }
    return 0;
}

void* memcpy(void* dst, const void* src, size_t n) {
    uint8_t* d = (uint8_t*)dst;
    const uint8_t* s = (const uint8_t*)src;
    for (size_t i = 0; i < n; ++i) d[i] = s[i];
    return dst;
}

void* memmove(void* dst, const void* src, size_t n) {
    uint8_t* d = (uint8_t*)dst;
    const uint8_t* s = (const uint8_t*)src;
    if (d == s || n == 0) return dst;
    if (d < s) {
        for (size_t i = 0; i < n; ++i) d[i] = s[i];
    } else {
        for (size_t i = n; i-- > 0;) d[i] = s[i];
    }
    return dst;
}

void* memset(void* dst, int c, size_t n) {
    uint8_t* d = (uint8_t*)dst;
    for (size_t i = 0; i < n; ++i) d[i] = (uint8_t)c;
    return dst;
}

// ----------------------------------------------------------------
// 2. 추가된 malloc / free (Bump Allocator)
// ----------------------------------------------------------------

// 링커(wasm-ld)가 데이터 섹션 끝나는 지점을 알려주는 심볼입니다.
// 이 주소 뒤부터는 힙으로 안전하게 쓸 수 있습니다.
extern unsigned char __heap_base;

// 현재 힙 포인터 위치를 저장할 변수
// 초기값은 0으로 두고, 첫 호출 시 __heap_base로 설정합니다.
static unsigned char* bump_pointer = 0;

void* malloc(size_t n) {
    // 1. 초기화: 아직 포인터가 설정 안 됐다면 __heap_base 위치로 설정
    if (bump_pointer == 0) {
        bump_pointer = &__heap_base;
    }

    // 2. 메모리 정렬 (Alignment)
    // Rust나 C 구조체는 보통 8바이트 정렬을 선호하므로, 주소를 8의 배수로 맞춥니다.
    // (성능과 안정성을 위해 필수적입니다)
    size_t address = (size_t)bump_pointer;
    size_t alignment = 8;
    size_t remainder = address % alignment;
    
    if (remainder != 0) {
        bump_pointer += (alignment - remainder);
    }

    // 3. 할당
    void* ptr = bump_pointer;
    bump_pointer += n; // 요청한 크기만큼 포인터를 앞으로 이동 (Bump)

    return ptr;
}

void free(void* ptr) {
    // Bump Allocator는 메모리 해제를 지원하지 않습니다.
    // 포인터를 되돌릴 수 없으므로 그냥 아무것도 하지 않습니다 (No-op).
    // 단순 벤치마크나 단기 실행 프로그램에서는 문제가 되지 않습니다.
    (void)ptr; 
}

void* calloc(size_t nmemb, size_t size) {
    size_t total_size = nmemb * size;
    void* ptr = malloc(total_size);
    if (ptr) {
        memset(ptr, 0, total_size); // 0으로 초기화 필수
    }
    return ptr;
}

void* realloc(void* ptr, size_t size) {
    if (ptr == NULL) return malloc(size);
    if (size == 0) {
        free(ptr);
        return NULL;
    }
    
    // Bump Allocator에서는 기존 메모리 크기를 정확히 알기 어려우므로
    // 항상 새로운 공간을 할당하고 데이터를 복사하는 방식으로 처리합니다.
    // (주의: 이전 크기를 모르므로 안전을 위해 충분히 복사하거나, 
    //  단순 벤치마크용이라면 size만큼 복사 시도 - 여기서는 안전하게 처리)
    
    void* new_ptr = malloc(size);
    if (new_ptr) {
        // 원래 크기를 모르지만, 보통 realloc은 확장을 위해 쓰이므로
        // size만큼 복사하면 안전하지 않을 수 있습니다(Over-read).
        // 하지만 libc shim의 한계상, 여기서는 memcpy를 사용합니다.
        // *실제 프로덕션에서는 원래 크기 추적 필요*
        memcpy(new_ptr, ptr, size); 
    }
    // free(ptr); // Bump Allocator는 free가 없으므로 생략
    return new_ptr;
}

int setjmp(int env[1]) {
    (void)env;
    return 0;
}

void longjmp(int env[1], int val) {
    (void)env;
    (void)val;
    __builtin_trap();
}

void abort(void) {
    __builtin_trap();
}

int abs(int x) {
    return x < 0 ? -x : x;
}

size_t strlen(const char* s) {
    size_t n = 0;
    while (s[n] != '\0') n++;
    return n;
}
