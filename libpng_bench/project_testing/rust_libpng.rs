#![no_std]
#![no_main]

use core::panic::PanicInfo;
use core::mem::MaybeUninit;

const BENCH_MAX_RAW: usize = 1 << 21; // 2 MiB
const BENCH_MAX_ENCODED: usize = BENCH_MAX_RAW + (BENCH_MAX_RAW / 8) + 8192;
const FIXED_WIDTH: usize = 256;
const PNG_IMAGE_VERSION: u32 = 1;
const PNG_FORMAT_RGBA: u32 = 0x0002 | 0x0001; // PNG_FORMAT_RGB | PNG_FORMAT_FLAG_ALPHA

static mut BENCH_RAW: [u8; BENCH_MAX_RAW] = [0; BENCH_MAX_RAW];
static mut BENCH_ENCODED: [u8; BENCH_MAX_ENCODED] = [0; BENCH_MAX_ENCODED];
static mut BENCH_DECODED: [u8; BENCH_MAX_RAW] = [0; BENCH_MAX_RAW];

static mut BENCH_READY: bool = false;
static mut BENCH_RAW_SIZE: usize = 0;
static mut BENCH_WIDTH: usize = 0;
static mut BENCH_HEIGHT: usize = 0;
static mut BENCH_ENCODED_LEN: usize = 0;
static mut LIBPNG_VERSION: i32 = 0;
static mut ZLIB_COMPRESS_BOUND: u32 = 0;
static mut BENCH_DECODED_WIDTH: usize = 0;
static mut BENCH_DECODED_HEIGHT: usize = 0;

#[repr(C)]
struct PngImage {
    opaque: *mut u8,
    version: u32,
    width: u32,
    height: u32,
    format: u32,
    flags: u32,
    colormap_entries: u32,
    warning_or_error: u32,
    message: [u8; 64],
}

extern "C" {
    fn bench_fill_target_from_pool(dst_mem0: *mut u8, size: usize) -> i32;
    fn png_access_version_number() -> u32;
    fn png_image_begin_read_from_memory(image: *mut PngImage, memory: *const u8, size: usize) -> i32;
    fn png_image_finish_read(
        image: *mut PngImage,
        background: *const u8,
        buffer: *mut u8,
        row_stride: i32,
        colormap: *mut u8,
    ) -> i32;
    fn png_image_write_to_memory(
        image: *mut PngImage,
        memory: *mut u8,
        memory_bytes: *mut usize,
        convert_to_8_bit: i32,
        buffer: *const u8,
        row_stride: i32,
        colormap: *const u8,
    ) -> i32;
    fn png_image_free(image: *mut PngImage);
    fn compressBound(source_len: u32) -> u32;
    fn memcmp(a: *const u8, b: *const u8, n: usize) -> i32;
}

#[inline]
fn aligned_rgba_size(size: usize) -> usize {
    (size + 3) & !3
}

#[inline]
fn derive_dims(raw_size: usize) -> (usize, usize, usize) {
    let width = FIXED_WIDTH;
    let row = width * 4;
    let height = if raw_size <= row {
        1
    } else {
        (raw_size + row - 1) / row
    };
    let total = row * height;
    (width, height, total)
}

#[no_mangle]
pub extern "C" fn bench_prepare(size: u32) -> i32 {
    let requested = size as usize;
    if requested == 0 {
        return -100;
    }
    if requested > BENCH_MAX_RAW {
        return -101;
    }

    let normalized = aligned_rgba_size(requested);
    let (width, height, total) = derive_dims(normalized);
    if total > BENCH_MAX_RAW {
        return -102;
    }

    let ret = unsafe { bench_fill_target_from_pool(BENCH_RAW.as_mut_ptr(), total) };
    if ret != 0 {
        return ret;
    }

    unsafe {
        LIBPNG_VERSION = png_access_version_number() as i32;
        ZLIB_COMPRESS_BOUND = compressBound(total as u32);
        BENCH_RAW_SIZE = total;
        BENCH_WIDTH = width;
        BENCH_HEIGHT = height;
        BENCH_ENCODED_LEN = 0;
        BENCH_READY = true;
    }

    0
}

#[no_mangle]
pub extern "C" fn bench_png_encode(size: u32) -> i32 {
    let size = size as usize;
    if size == 0 {
        return -110;
    }
    let ready = unsafe { BENCH_READY };
    if !ready {
        return -111;
    }

    let mut image = MaybeUninit::<PngImage>::zeroed();
    let image = unsafe { image.assume_init_mut() };
    image.version = PNG_IMAGE_VERSION;
    image.width = unsafe { BENCH_WIDTH as u32 };
    image.height = unsafe { BENCH_HEIGHT as u32 };
    image.format = PNG_FORMAT_RGBA;

    let mut needed = 0usize;
    let ok_probe = unsafe {
        png_image_write_to_memory(
            image as *mut PngImage,
            core::ptr::null_mut(),
            &mut needed as *mut usize,
            0,
            BENCH_RAW.as_ptr(),
            0,
            core::ptr::null(),
        )
    };
    if ok_probe == 0 {
        return -203;
    }
    if needed > BENCH_MAX_ENCODED {
        return -204;
    }

    let ok_write = unsafe {
        png_image_write_to_memory(
            image as *mut PngImage,
            BENCH_ENCODED.as_mut_ptr(),
            &mut needed as *mut usize,
            0,
            BENCH_RAW.as_ptr(),
            0,
            core::ptr::null(),
        )
    };
    if ok_write == 0 {
        return -205;
    }

    unsafe {
        BENCH_ENCODED_LEN = needed;
    }

    0
}

#[no_mangle]
pub extern "C" fn bench_png_decode(size: u32) -> i32 {
    let size = size as usize;
    if size == 0 {
        return -120;
    }
    let ready = unsafe { BENCH_READY };
    if !ready {
        return -121;
    }

    let encoded_len = unsafe { BENCH_ENCODED_LEN };
    if encoded_len == 0 {
        return -122;
    }

    let mut image = MaybeUninit::<PngImage>::zeroed();
    let image = unsafe { image.assume_init_mut() };
    image.version = PNG_IMAGE_VERSION;

    let ok_begin = unsafe {
        png_image_begin_read_from_memory(
            image as *mut PngImage,
            BENCH_ENCODED.as_ptr(),
            encoded_len,
        )
    };
    if ok_begin == 0 {
        return -212;
    }

    image.format = PNG_FORMAT_RGBA;
    let need = (image.width as usize)
        .saturating_mul(image.height as usize)
        .saturating_mul(4);
    if need > BENCH_MAX_RAW {
        unsafe { png_image_free(image as *mut PngImage) };
        return -213;
    }

    let ok_finish = unsafe {
        png_image_finish_read(
            image as *mut PngImage,
            core::ptr::null(),
            BENCH_DECODED.as_mut_ptr(),
            0,
            core::ptr::null_mut(),
        )
    };
    if ok_finish == 0 {
        unsafe { png_image_free(image as *mut PngImage) };
        return -214;
    }

    let w = image.width as usize;
    let h = image.height as usize;
    unsafe { png_image_free(image as *mut PngImage) };

    let expected_w = unsafe { BENCH_WIDTH };
    let expected_h = unsafe { BENCH_HEIGHT };
    if w != expected_w || h != expected_h {
        return -123;
    }

    0
}

#[no_mangle]
pub extern "C" fn bench_get_encoded_len() -> usize {
    unsafe { BENCH_ENCODED_LEN }
}

#[no_mangle]
pub extern "C" fn bench_get_staging_ptr() -> usize {
    unsafe { BENCH_ENCODED.as_mut_ptr() as usize }
}

#[no_mangle]
pub extern "C" fn bench_get_staging_cap() -> usize {
    BENCH_MAX_ENCODED
}

#[no_mangle]
pub extern "C" fn bench_load_external_png(len: u32) -> i32 {
    let len = len as usize;
    if len == 0 || len > BENCH_MAX_ENCODED {
        return -170;
    }
    unsafe {
        BENCH_ENCODED_LEN = len;
        BENCH_READY = true;
        BENCH_DECODED_WIDTH = 0;
        BENCH_DECODED_HEIGHT = 0;
        BENCH_RAW_SIZE = 0;
    }
    0
}

#[no_mangle]
pub extern "C" fn bench_png_decode_external() -> i32 {
    let encoded_len = unsafe { BENCH_ENCODED_LEN };
    if encoded_len == 0 {
        return -171;
    }
    let mut image = MaybeUninit::<PngImage>::zeroed();
    let image = unsafe { image.assume_init_mut() };
    image.version = PNG_IMAGE_VERSION;

    let ok_begin = unsafe {
        png_image_begin_read_from_memory(
            image as *mut PngImage,
            BENCH_ENCODED.as_ptr(),
            encoded_len,
        )
    };
    if ok_begin == 0 {
        return -212;
    }

    image.format = PNG_FORMAT_RGBA;
    let need = (image.width as usize)
        .saturating_mul(image.height as usize)
        .saturating_mul(4);
    if need > BENCH_MAX_RAW {
        unsafe { png_image_free(image as *mut PngImage) };
        return -213;
    }

    let ok_finish = unsafe {
        png_image_finish_read(
            image as *mut PngImage,
            core::ptr::null(),
            BENCH_DECODED.as_mut_ptr(),
            0,
            core::ptr::null_mut(),
        )
    };
    if ok_finish == 0 {
        unsafe { png_image_free(image as *mut PngImage) };
        return -214;
    }

    let w = image.width as usize;
    let h = image.height as usize;
    unsafe { png_image_free(image as *mut PngImage) };

    let raw = need;
    if raw > BENCH_MAX_RAW {
        return -172;
    }
    unsafe {
        BENCH_DECODED_WIDTH = w;
        BENCH_DECODED_HEIGHT = h;
        BENCH_RAW_SIZE = raw;
    }
    0
}

#[no_mangle]
pub extern "C" fn bench_get_decoded_bytes() -> usize {
    unsafe { BENCH_RAW_SIZE }
}

#[no_mangle]
pub extern "C" fn bench_get_decoded_width() -> usize {
    unsafe { BENCH_DECODED_WIDTH }
}

#[no_mangle]
pub extern "C" fn bench_get_decoded_height() -> usize {
    unsafe { BENCH_DECODED_HEIGHT }
}

#[no_mangle]
pub extern "C" fn bench_get_libpng_version() -> i32 {
    unsafe { LIBPNG_VERSION }
}

#[no_mangle]
pub extern "C" fn bench_get_zlib_compress_bound() -> u32 {
    unsafe { ZLIB_COMPRESS_BOUND }
}

#[no_mangle]
pub extern "C" fn bench_verify_decode(_size: u32) -> i32 {
    let ready = unsafe { BENCH_READY };
    if !ready {
        return -130;
    }
    let raw_size = unsafe { BENCH_RAW_SIZE };
    if raw_size == 0 {
        return -131;
    }

    let cmp = unsafe { memcmp(BENCH_RAW.as_ptr(), BENCH_DECODED.as_ptr(), raw_size) };
    if cmp != 0 {
        return -132;
    }

    0
}

#[no_mangle]
pub extern "C" fn _start() {
    let _ = bench_prepare(1024);
    let _ = bench_png_encode(1024);
    let _ = bench_png_decode(1024);
    let _ = bench_verify_decode(1024);
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
