#![no_std]
#![no_main]

use core::ptr::addr_of_mut;

#[repr(C)]
struct SnappyEnv {
    hash_table: *mut u16,
    scratch: *mut core::ffi::c_void,
    scratch_output: *mut core::ffi::c_void,
}

const BENCH_MAX_INPUT: usize = 1 << 22;
const BENCH_MAX_COMPRESSED: usize = 32 + BENCH_MAX_INPUT + BENCH_MAX_INPUT / 6;

static mut BENCH_TARGET: [u8; BENCH_MAX_INPUT] = [0; BENCH_MAX_INPUT];
static mut BENCH_COMPRESSED: [u8; BENCH_MAX_COMPRESSED] = [0; BENCH_MAX_COMPRESSED];
static mut BENCH_UNCOMPRESSED: [u8; BENCH_MAX_INPUT] = [0; BENCH_MAX_INPUT];
static mut BENCH_COMPRESSED_LEN: usize = 0;
static mut BENCH_COMPRESSED_SIZE: usize = 0;
static mut BENCH_TARGET_READY: bool = false;
static mut BENCH_TARGET_SIZE: usize = 0;
static mut SNAPPY_ENV: SnappyEnv = SnappyEnv {
    hash_table: core::ptr::null_mut(),
    scratch: core::ptr::null_mut(),
    scratch_output: core::ptr::null_mut(),
};
static mut SNAPPY_ENV_READY: bool = false;
static mut DBG_UNCOMP_CALL_COMPRESSED_PTR: usize = 0;
static mut DBG_UNCOMP_CALL_COMPRESSED_LEN: usize = 0;
static mut DBG_UNCOMP_CALL_DST_PTR: usize = 0;
static mut DBG_UNCOMP_CALL_DST_LEN: usize = 0;
static mut DBG_UNCOMP_CALL_LAST_RET: i32 = 0;

extern "C" {
    /// C 측 데이터 풀에서 주어진 mem0 버퍼로 size 바이트를 채운다.
    /// 성공 시 0, 실패 시 음수 에러 코드.
    fn bench_fill_target_from_pool(dst_mem0: *mut u8, size: usize) -> i32;
}

#[no_mangle]
pub extern "C" fn bench_prepare(size: u32) -> i32 {
    let size = size as usize;
    if size == 0 {
        return -120;
    }
    if size > BENCH_MAX_INPUT {
        return -121;
    }

    unsafe {
        let fill_ret = bench_fill_target_from_pool(BENCH_TARGET.as_mut_ptr(), size);
        if fill_ret != 0 {
            return fill_ret;
        }
        BENCH_TARGET_READY = true;
        BENCH_TARGET_SIZE = size;
        BENCH_COMPRESSED_LEN = 0;
        BENCH_COMPRESSED_SIZE = 0;
    }

    0
}

extern "C" {
    fn snappy_init_env_with_len(env: *mut SnappyEnv, env_len: usize) -> i32;
    fn snappy_max_compressed_length(source_len: usize) -> usize;
    fn snappy_compress_with_len(
        env: *mut SnappyEnv,
        env_len: usize,
        input: *const u8,
        input_length: usize,
        compressed: *mut u8,
        compressed_capacity: usize,
        compressed_length: *mut usize,
        compressed_length_len: usize,
    ) -> i32;
    fn snappy_uncompress_with_len(
        compressed: *const u8,
        n: usize,
        uncompressed: *mut u8,
        uncompressed_len: usize,
    ) -> i32;
    fn memcmp(a: *const u8, b: *const u8, n: usize) -> i32;
}

unsafe fn ensure_snappy_env() -> i32 {
    if SNAPPY_ENV_READY {
        return 0;
    }
    let env_len = core::mem::size_of::<SnappyEnv>();
    if snappy_init_env_with_len(addr_of_mut!(SNAPPY_ENV), env_len) != 0 {
        return -92;
    }
    SNAPPY_ENV_READY = true;
    0
}

#[no_mangle]
pub extern "C" fn bench_snappy_compress(size: u32) -> i32 {
    bench_snappy_compress_impl(size)
}

#[no_mangle]
pub extern "C" fn bench_snappy_uncompress(size: u32) -> i32 {
    bench_snappy_uncompress_impl(size)
}

fn bench_snappy_compress_impl(size: u32) -> i32 {
    let size = size as usize;
    if size == 0 {
        return -90;
    }
    if size > BENCH_MAX_INPUT {
        return -91;
    }
    let target_ready = unsafe { BENCH_TARGET_READY };
    let target_size = unsafe { BENCH_TARGET_SIZE };
    if !target_ready || target_size != size {
        return -92;
    }

    let init_ret = unsafe { ensure_snappy_env() };
    if init_ret != 0 {
        return init_ret;
    }

    let max_len = unsafe { snappy_max_compressed_length(size) };
    if max_len > BENCH_MAX_COMPRESSED {
        return -93;
    }

    unsafe {
        BENCH_COMPRESSED_LEN = 0;
        BENCH_COMPRESSED_SIZE = 0;
    }

    let mut result = 0;
    let mut compressed_len = max_len;
    let env_len = core::mem::size_of::<SnappyEnv>();
    let compressed_len_size = core::mem::size_of::<usize>();
    if unsafe {
        snappy_compress_with_len(
            addr_of_mut!(SNAPPY_ENV),
            env_len,
            BENCH_TARGET.as_ptr(),
            size,
            BENCH_COMPRESSED.as_mut_ptr(),
            max_len,
            &mut compressed_len as *mut usize,
            compressed_len_size,
        )
    } != 0
    {
        result = -94;
    }

    if result == 0 {
        unsafe {
            BENCH_COMPRESSED_LEN = compressed_len;
            BENCH_COMPRESSED_SIZE = size;
        }
    }

    result
}

fn bench_snappy_uncompress_impl(size: u32) -> i32 {
    let size = size as usize;
    if size == 0 {
        return -100;
    }
    if size > BENCH_MAX_INPUT {
        return -101;
    }

    let compressed_len = unsafe { BENCH_COMPRESSED_LEN };
    let compressed_size = unsafe { BENCH_COMPRESSED_SIZE };
    if compressed_len == 0 || compressed_size != size {
        return -102;
    }

    unsafe {
        DBG_UNCOMP_CALL_COMPRESSED_PTR = BENCH_COMPRESSED.as_ptr() as usize;
        DBG_UNCOMP_CALL_COMPRESSED_LEN = compressed_len;
        DBG_UNCOMP_CALL_DST_PTR = BENCH_UNCOMPRESSED.as_mut_ptr() as usize;
        DBG_UNCOMP_CALL_DST_LEN = size;
        DBG_UNCOMP_CALL_LAST_RET = 0;
    }

    let ret = unsafe {
        snappy_uncompress_with_len(
            BENCH_COMPRESSED.as_ptr(),
            compressed_len,
            BENCH_UNCOMPRESSED.as_mut_ptr(),
            size,
        )
    };
    unsafe {
        DBG_UNCOMP_CALL_LAST_RET = ret;
    }
    if ret != 0 {
        return ret;
    }

    0
}

#[no_mangle]
pub extern "C" fn bench_verify_compress(size: u32) -> i32 {
    let size = size as usize;
    if size == 0 {
        return -140;
    }
    if size > BENCH_MAX_INPUT {
        return -141;
    }

    let compressed_len = unsafe { BENCH_COMPRESSED_LEN };
    let compressed_size = unsafe { BENCH_COMPRESSED_SIZE };
    if compressed_len == 0 || compressed_size != size {
        return -142;
    }

    let max_len = unsafe { snappy_max_compressed_length(size) };
    if compressed_len > max_len {
        return -143; 
    }
    0
}

/// Helper for debugging: expose last compressed_len.
#[no_mangle]
pub extern "C" fn bench_get_compressed_len() -> usize {
    unsafe { BENCH_COMPRESSED_LEN }
}

#[no_mangle]
pub extern "C" fn bench_verify_uncompress(size: u32) -> i32 {
    let size = size as usize;
    if size == 0 {
        return -150;
    }
    if size > BENCH_MAX_INPUT {
        return -151;
    }

    let compressed_len = unsafe { BENCH_COMPRESSED_LEN };
    let compressed_size = unsafe { BENCH_COMPRESSED_SIZE };
    if compressed_len == 0 || compressed_size != size {
        return -152;
    }

    if unsafe { memcmp(BENCH_UNCOMPRESSED.as_ptr(), BENCH_TARGET.as_ptr(), size) } != 0 {
        return -155;
    }

    0
}

#[no_mangle]
pub extern "C" fn bench_debug_uncomp_compressed_ptr() -> usize {
    unsafe { DBG_UNCOMP_CALL_COMPRESSED_PTR }
}

#[no_mangle]
pub extern "C" fn bench_debug_uncomp_compressed_len() -> usize {
    unsafe { DBG_UNCOMP_CALL_COMPRESSED_LEN }
}

#[no_mangle]
pub extern "C" fn bench_debug_uncomp_dst_ptr() -> usize {
    unsafe { DBG_UNCOMP_CALL_DST_PTR }
}

#[no_mangle]
pub extern "C" fn bench_debug_uncomp_dst_len() -> usize {
    unsafe { DBG_UNCOMP_CALL_DST_LEN }
}

#[no_mangle]
pub extern "C" fn bench_debug_uncomp_last_ret() -> i32 {
    unsafe { DBG_UNCOMP_CALL_LAST_RET }
}

#[no_mangle]
pub extern "C" fn bench_debug_first_mismatch(size: u32) -> i32 {
    let size = size as usize;
    if size == 0 || size > BENCH_MAX_INPUT {
        return -1;
    }
    let mut i = 0usize;
    while i < size {
        let mismatch = unsafe { BENCH_UNCOMPRESSED[i] != BENCH_TARGET[i] };
        if mismatch {
            return i as i32;
        }
        i += 1;
    }
    -1
}

#[no_mangle]
pub extern "C" fn bench_debug_target_byte_at(idx: u32) -> i32 {
    let idx = idx as usize;
    if idx >= BENCH_MAX_INPUT {
        return -1;
    }
    unsafe { BENCH_TARGET[idx] as i32 }
}

#[no_mangle]
pub extern "C" fn bench_debug_uncompressed_byte_at(idx: u32) -> i32 {
    let idx = idx as usize;
    if idx >= BENCH_MAX_INPUT {
        return -1;
    }
    unsafe { BENCH_UNCOMPRESSED[idx] as i32 }
}

#[panic_handler]
fn panic(_: &core::panic::PanicInfo) -> ! { loop {} } 
