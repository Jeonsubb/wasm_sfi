#pragma once

#ifndef SNAPPY_BENCH_SIZE_T_DEFINED
typedef __SIZE_TYPE__ size_t;
#define SNAPPY_BENCH_SIZE_T_DEFINED 1
#endif

// Prototypes matching libc_shim.c implementations
int memcmp(const void* a, const void* b, size_t n);
void* memcpy(void* dst, const void* src, size_t n);
void* memmove(void* dst, const void* src, size_t n);
void* memset(void* dst, int c, size_t n);
size_t strlen(const char* s);
