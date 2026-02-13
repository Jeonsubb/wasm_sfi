#include <stddef.h>
#include <stdint.h>

// mem1 런타임 심볼( mem1 전용 빌드에서만 제공됨 )
extern void* __mem1_alloc(uint32_t size);
extern void __mem1_free(void* p);

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
// 2. mem1 전용 malloc / free
// ----------------------------------------------------------------

void* malloc(size_t n) {
    return __mem1_alloc((uint32_t)n);
}

void free(void* ptr) {
    __mem1_free(ptr);
}

void* calloc(size_t nmemb, size_t size) {
    size_t total_size = nmemb * size;
    void* ptr = malloc(total_size);
    if (ptr) {
        memset(ptr, 0, total_size);
    }
    return ptr;
}

void* realloc(void* ptr, size_t size) {
    if (ptr == NULL) return malloc(size);
    if (size == 0) {
        free(ptr);
        return NULL;
    }

    void* new_ptr = malloc(size);
    if (new_ptr) {
        memcpy(new_ptr, ptr, size);
    }
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
