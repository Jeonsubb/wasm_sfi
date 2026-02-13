#pragma once

#ifndef SNAPPY_BENCH_SIZE_T_DEFINED
typedef __SIZE_TYPE__ size_t;
#define SNAPPY_BENCH_SIZE_T_DEFINED 1
#endif

#ifndef SNAPPY_BENCH_SSIZE_T_DEFINED
typedef __PTRDIFF_TYPE__ ssize_t;
#define SNAPPY_BENCH_SSIZE_T_DEFINED 1
#endif

void* malloc(size_t size);
void free(void* ptr);
void* calloc(size_t nmemb, size_t size);
void* realloc(void* ptr, size_t size);
void abort(void);
int abs(int x);
