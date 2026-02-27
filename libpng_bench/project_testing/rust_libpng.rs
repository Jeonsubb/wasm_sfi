#![no_std]
#![no_main]

use core::panic::PanicInfo;

const BENCH_MAX_RAW: usize = 1 << 21; // 2 MiB
const BENCH_MAX_ENCODED: usize = BENCH_MAX_RAW + (BENCH_MAX_RAW / 8) + 8192;

static mut BENCH_READY: bool = false;
static mut BENCH_ENCODED_LEN: usize = 0;
static mut BENCH_DECODED_BYTES: usize = 0;
static mut BENCH_DECODED_WIDTH: usize = 0;
static mut BENCH_DECODED_HEIGHT: usize = 0;
static mut BENCH_ENCODED_BUF: [u8; BENCH_MAX_ENCODED] = [0; BENCH_MAX_ENCODED];

extern "C" {
    fn c_png_decode_from_mem0(src_mem0: *const u8, png_len: usize) -> i32;
    fn c_get_decoded_bytes() -> usize;
    fn c_get_decoded_width() -> usize;
    fn c_get_decoded_height() -> usize;
}

#[no_mangle]
pub extern "C" fn bench_get_staging_ptr() -> usize {
    unsafe { BENCH_ENCODED_BUF.as_ptr() as usize }
}

#[no_mangle]
pub extern "C" fn bench_get_staging_cap() -> usize {
    BENCH_MAX_ENCODED
}

#[no_mangle]
pub extern "C" fn bench_set_staging_byte(offset: u32, value: u32) -> i32 {
    let idx = offset as usize;
    if idx >= BENCH_MAX_ENCODED {
        return -180;
    }
    unsafe {
        BENCH_ENCODED_BUF[idx] = (value & 0xff) as u8;
    }
    0
}

#[no_mangle]
pub extern "C" fn bench_get_staging_byte(offset: u32) -> u32 {
    let idx = offset as usize;
    if idx >= BENCH_MAX_ENCODED {
        return 0;
    }
    unsafe { BENCH_ENCODED_BUF[idx] as u32 }
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
        BENCH_DECODED_BYTES = 0;
        BENCH_DECODED_WIDTH = 0;
        BENCH_DECODED_HEIGHT = 0;
    }
    0
}

#[no_mangle]
pub extern "C" fn bench_png_decode_external() -> i32 {
    if unsafe { !BENCH_READY } {
        return -171;
    }

    let encoded_len = unsafe { BENCH_ENCODED_LEN };
    if encoded_len == 0 {
        return -171;
    }

    let ret = unsafe { c_png_decode_from_mem0(BENCH_ENCODED_BUF.as_ptr(), encoded_len) };
    if ret != 0 {
        return ret;
    }

    unsafe {
        BENCH_DECODED_BYTES = c_get_decoded_bytes();
        BENCH_DECODED_WIDTH = c_get_decoded_width();
        BENCH_DECODED_HEIGHT = c_get_decoded_height();
    }
    0
}

#[no_mangle]
pub extern "C" fn bench_get_decoded_bytes() -> usize {
    unsafe { BENCH_DECODED_BYTES }
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
pub extern "C" fn _start() {}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}
