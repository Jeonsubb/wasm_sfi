#ifndef LIBPNG_BENCH_SIZE_T_DEFINED
typedef __SIZE_TYPE__ size_t;
#define LIBPNG_BENCH_SIZE_T_DEFINED 1
#endif

#ifndef LIBPNG_BENCH_SSIZE_T_DEFINED
typedef __PTRDIFF_TYPE__ ssize_t;
#define LIBPNG_BENCH_SSIZE_T_DEFINED 1
#endif

#ifndef __cplusplus
typedef _Bool bool;
#endif
#ifndef true
#define true 1
#endif
#ifndef false
#define false 0
#endif

#ifndef NULL
#define NULL ((void *)0)
#endif

#include "../support/stdlib.h"
#include "../support/string.h"

/*
 * libpng simple API only.
 * setjmp/longjmp handling is internal to libpng simple API.
 */
#include <png.h>

#define BENCH_MAX_RAW (1u << 21) /* 2 MiB */
#define BENCH_POOL_SIZE 8
#define BENCH_POOL_CHUNK (64 * 1024)

static unsigned char bench_input_pool[BENCH_POOL_SIZE][BENCH_POOL_CHUNK];
static bool bench_pool_ready;

static void bench_fill_input_pattern(unsigned char *dst, size_t size, unsigned tag)
{
    unsigned char mix = (unsigned char)(tag * 29u + 7u);
    for (size_t i = 0; i < size; i++) {
        dst[i] = (unsigned char)((i * 31u + 17u + mix) & 0xffu);
    }
}

static void bench_init_pool(void)
{
    if (bench_pool_ready)
        return;
    for (size_t p = 0; p < BENCH_POOL_SIZE; p++) {
        bench_fill_input_pattern(bench_input_pool[p], BENCH_POOL_CHUNK, (unsigned)p);
    }
    bench_pool_ready = true;
}

__attribute__((export_name("bench_fill_target_from_pool")))
int bench_fill_target_from_pool(void *dst_mem0, size_t size)
{
    if (size == 0)
        return -120;
    if (size > BENCH_MAX_RAW)
        return -121;

    bench_init_pool();

    size_t offset = 0;
    size_t pool_idx = 0;
    while (offset < size) {
        size_t remaining = size - offset;
        size_t copy_len = remaining < BENCH_POOL_CHUNK ? remaining : BENCH_POOL_CHUNK;
        memcpy((unsigned char *)dst_mem0 + offset, bench_input_pool[pool_idx], copy_len);
        offset += copy_len;
        pool_idx++;
        if (pool_idx == BENCH_POOL_SIZE)
            pool_idx = 0;
    }

    return 0;
}

__attribute__((export_name("c_libpng_version_number")))
int c_libpng_version_number(void)
{
    return (int)png_access_version_number();
}

__attribute__((export_name("c_png_encode_rgba")))
int c_png_encode_rgba(const unsigned char *rgba,
                      size_t width,
                      size_t height,
                      unsigned char *png_out,
                      size_t png_cap,
                      size_t *png_len)
{
    if (rgba == NULL || png_out == NULL || png_len == NULL)
        return -201;
    if (width == 0 || height == 0)
        return -202;

    png_image image;
    memset(&image, 0, sizeof(image));
    image.version = PNG_IMAGE_VERSION;
    image.width = (png_uint_32)width;
    image.height = (png_uint_32)height;
    image.format = PNG_FORMAT_RGBA;

    size_t needed = 0;
    if (!png_image_write_to_memory(&image, NULL, &needed, 0, rgba, 0, NULL))
        return -203;
    if (needed > png_cap)
        return -204;

    if (!png_image_write_to_memory(&image, png_out, &needed, 0, rgba, 0, NULL))
        return -205;

    *png_len = needed;
    return 0;
}

__attribute__((export_name("c_png_decode_rgba")))
int c_png_decode_rgba(const unsigned char *png_data,
                      size_t png_len,
                      unsigned char *rgba_out,
                      size_t rgba_cap,
                      size_t *out_width,
                      size_t *out_height)
{
    if (png_data == NULL || rgba_out == NULL || out_width == NULL || out_height == NULL)
        return -210;
    if (png_len == 0)
        return -211;

    png_image image;
    memset(&image, 0, sizeof(image));
    image.version = PNG_IMAGE_VERSION;

    if (!png_image_begin_read_from_memory(&image, png_data, png_len))
        return -212;

    image.format = PNG_FORMAT_RGBA;

    size_t need = PNG_IMAGE_SIZE(image);
    if (need > rgba_cap) {
        png_image_free(&image);
        return -213;
    }

    if (!png_image_finish_read(&image, NULL, rgba_out, 0, NULL)) {
        png_image_free(&image);
        return -214;
    }

    *out_width = (size_t)image.width;
    *out_height = (size_t)image.height;
    png_image_free(&image);
    return 0;
}
