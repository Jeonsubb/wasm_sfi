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

static unsigned char bench_png_staging[BENCH_MAX_ENCODED];
static unsigned char bench_decoded_rgba[BENCH_MAX_RAW];
static size_t bench_decoded_bytes;
static size_t bench_decoded_width;
static size_t bench_decoded_height;
static int bench_last_error_stage;
static unsigned bench_last_png_warnerr;
static char bench_last_png_message[64];

typedef struct {
    size_t png_len;
    size_t cursor;
} bench_png_reader_state;

static void bench_png_read_cb(png_structp png_ptr, png_bytep out, png_size_t len)
{
    bench_png_reader_state *st = (bench_png_reader_state *)png_get_io_ptr(png_ptr);
    if (st == NULL)
        png_error(png_ptr, "null io state");

    size_t need = (size_t)len;
    if (st->cursor > st->png_len || need > (st->png_len - st->cursor))
        png_error(png_ptr, "short read");

    memcpy(out, bench_png_staging + st->cursor, need);
    st->cursor += need;
}

__attribute__((export_name("bench_set_c_staging_byte")))
int bench_set_c_staging_byte(size_t offset, unsigned value)
{
    if (offset >= BENCH_MAX_ENCODED)
        return -180;
    bench_png_staging[offset] = (unsigned char)(value & 0xffu);
    return 0;
}

__attribute__((export_name("c_get_staging_ptr")))
size_t c_get_staging_ptr(void)
{
    return (size_t)(bench_png_staging);
}

__attribute__((export_name("c_get_decoded_ptr")))
size_t c_get_decoded_ptr(void)
{
    return (size_t)(bench_decoded_rgba);
}

__attribute__((export_name("c_libpng_version_number")))
int c_libpng_version_number(void)
{
    return (int)png_access_version_number();
}

__attribute__((export_name("c_png_decode_staged")))
int c_png_decode_staged(size_t png_len)
{
    bench_last_error_stage = 0;
    bench_last_png_warnerr = 0;
    memset(bench_last_png_message, 0, sizeof(bench_last_png_message));

    if (png_len < 24)
        return -211;

    unsigned char sig[8];
    for (size_t i = 0; i < 8; i++) {
        sig[i] = bench_png_staging[i];
    }
    if (png_sig_cmp((png_const_bytep)sig, 0, 8) != 0)
        return -215;

    char version[] = "1.8.0.git";
    png_structp png_ptr = png_create_read_struct(version, NULL, NULL, NULL);
    if (png_ptr == NULL) {
        bench_last_error_stage = 1;
        return -220;
    }
    png_infop info_ptr = png_create_info_struct(png_ptr);
    if (info_ptr == NULL) {
        bench_last_error_stage = 2;
        png_destroy_read_struct(&png_ptr, NULL, NULL);
        return -221;
    }

    if (setjmp(png_jmpbuf(png_ptr)) != 0) {
        bench_last_error_stage = 3;
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        return -222;
    }

    bench_png_reader_state st;
    st.png_len = png_len;
    st.cursor = 0;
    png_set_read_fn(png_ptr, &st, bench_png_read_cb);

    png_read_info(png_ptr, info_ptr);
    png_uint_32 out_w = 0;
    png_uint_32 out_h = 0;
    int bit_depth = 0;
    int color_type = 0;
    int interlace = 0;
    int compression = 0;
    int filter = 0;
    if (png_get_IHDR(png_ptr, info_ptr, &out_w, &out_h, &bit_depth, &color_type,
                     &interlace, &compression, &filter) == 0) {
        bench_last_error_stage = 4;
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        return -217;
    }
    if (out_w == 0 || out_h == 0) {
        bench_last_error_stage = 5;
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        return -218;
    }

    if (bit_depth == 16)
        png_set_strip_16(png_ptr);
    if (color_type == PNG_COLOR_TYPE_PALETTE)
        png_set_palette_to_rgb(png_ptr);
    if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
        png_set_expand_gray_1_2_4_to_8(png_ptr);
    if (png_get_valid(png_ptr, info_ptr, PNG_INFO_tRNS) != 0)
        png_set_tRNS_to_alpha(png_ptr);
    if (color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
        png_set_gray_to_rgb(png_ptr);
    if ((color_type & PNG_COLOR_MASK_ALPHA) == 0)
        png_set_filler(png_ptr, 0xff, PNG_FILLER_AFTER);

    (void)png_set_interlace_handling(png_ptr);
    png_read_update_info(png_ptr, info_ptr);

    png_size_t rowbytes = png_get_rowbytes(png_ptr, info_ptr);
    size_t bytes = (size_t)rowbytes * (size_t)out_h;
    if (bytes > BENCH_MAX_RAW) {
        bench_last_error_stage = 6;
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        return -172;
    }

    png_bytep rows[4096];
    if (out_h > 4096u) {
        bench_last_error_stage = 7;
        png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
        return -223;
    }
    for (png_uint_32 y = 0; y < out_h; y++) {
        rows[y] = bench_decoded_rgba + ((size_t)y * (size_t)rowbytes);
    }
    png_read_image(png_ptr, rows);
    png_read_end(png_ptr, NULL);
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);

    bench_decoded_width = (size_t)out_w;
    bench_decoded_height = (size_t)out_h;
    bench_decoded_bytes = bytes;
    return 0;
}

__attribute__((export_name("c_get_last_error_stage")))
int c_get_last_error_stage(void)
{
    return bench_last_error_stage;
}

__attribute__((export_name("c_get_last_png_warnerr")))
unsigned c_get_last_png_warnerr(void)
{
    return bench_last_png_warnerr;
}

__attribute__((export_name("c_get_last_png_message_byte")))
unsigned c_get_last_png_message_byte(unsigned idx)
{
    if (idx >= sizeof(bench_last_png_message))
        return 0;
    return (unsigned)(unsigned char)bench_last_png_message[idx];
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
