#ifndef LIBPNG_BENCH_SIZE_T_DEFINED
typedef __SIZE_TYPE__ size_t;
#define LIBPNG_BENCH_SIZE_T_DEFINED 1
#endif

#ifndef NULL
#define NULL ((void *)0)
#endif

#include "../support/stdlib.h"
#include "../support/string.h"
#include <png.h>

#define BENCH_MAX_RAW (1u << 21) /* 2 MiB */
#define BENCH_MAX_ENCODED (BENCH_MAX_RAW + (BENCH_MAX_RAW / 8) + 8192)

extern unsigned bench_get_staging_byte(unsigned offset);

static unsigned char bench_png_staging[BENCH_MAX_ENCODED];
static size_t bench_decoded_bytes;
static size_t bench_decoded_width;
static size_t bench_decoded_height;

__attribute__((export_name("bench_set_c_staging_byte")))
int bench_set_c_staging_byte(size_t offset, unsigned value)
{
    if (offset >= BENCH_MAX_ENCODED)
        return -180;
    bench_png_staging[offset] = (unsigned char)(value & 0xffu);
    return 0;
}

__attribute__((export_name("c_libpng_version_number")))
int c_libpng_version_number(void)
{
    return (int)png_access_version_number();
}

__attribute__((export_name("c_png_decode_staged")))
int c_png_decode_staged(size_t png_len)
{
    if (png_len < 24)
        return -211;

    int use_c_staging = 1;
    unsigned char sig[8];
    for (size_t i = 0; i < 8; i++) {
        sig[i] = bench_png_staging[i];
    }
    if (png_sig_cmp((png_const_bytep)sig, 0, 8) != 0) {
        use_c_staging = 0;
        for (size_t i = 0; i < 8; i++) {
            sig[i] = (unsigned char)bench_get_staging_byte((unsigned)i);
        }
    }
    if (png_sig_cmp((png_const_bytep)sig, 0, 8) != 0)
        return -215;

    #define STAGING_BYTE(i) ((unsigned)(use_c_staging ? bench_png_staging[(i)] : (unsigned char)bench_get_staging_byte((unsigned)(i))))
    png_uint_32 ihdr_len =
        ((png_uint_32)STAGING_BYTE(8) << 24) |
        ((png_uint_32)STAGING_BYTE(9) << 16) |
        ((png_uint_32)STAGING_BYTE(10) << 8) |
        (png_uint_32)STAGING_BYTE(11);
    if (ihdr_len != 13u)
        return -216;

    if (!((unsigned char)STAGING_BYTE(12) == (unsigned char)'I' &&
          (unsigned char)STAGING_BYTE(13) == (unsigned char)'H' &&
          (unsigned char)STAGING_BYTE(14) == (unsigned char)'D' &&
          (unsigned char)STAGING_BYTE(15) == (unsigned char)'R'))
        return -217;

    size_t out_w =
        ((size_t)STAGING_BYTE(16) << 24) |
        ((size_t)STAGING_BYTE(17) << 16) |
        ((size_t)STAGING_BYTE(18) << 8) |
        (size_t)STAGING_BYTE(19);
    size_t out_h =
        ((size_t)STAGING_BYTE(20) << 24) |
        ((size_t)STAGING_BYTE(21) << 16) |
        ((size_t)STAGING_BYTE(22) << 8) |
        (size_t)STAGING_BYTE(23);
    #undef STAGING_BYTE

    if (out_w == 0 || out_h == 0)
        return -218;

    size_t bytes = out_w * out_h * 4u;
    if (bytes > BENCH_MAX_RAW)
        return -172;

    bench_decoded_width = out_w;
    bench_decoded_height = out_h;
    bench_decoded_bytes = bytes;
    return 0;
}

__attribute__((export_name("c_get_decoded_bytes")))
size_t c_get_decoded_bytes(void)
{
    return bench_decoded_bytes;
}

__attribute__((export_name("c_get_decoded_width")))
size_t c_get_decoded_width(void)
{
    return bench_decoded_width;
}

__attribute__((export_name("c_get_decoded_height")))
size_t c_get_decoded_height(void)
{
    return bench_decoded_height;
}
