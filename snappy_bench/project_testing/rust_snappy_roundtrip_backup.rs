#[no_mangle]
pub extern "C" fn test_snappy_roundtrip() -> i32 {
    const INPUT_LEN: usize = 64;
    const MAX_COMPRESSED_LEN: usize = 32 + INPUT_LEN + INPUT_LEN / 6;

    let input = [0x61u8; INPUT_LEN];
    let mut compressed = [0u8; MAX_COMPRESSED_LEN];
    let mut uncompressed = [0u8; INPUT_LEN];
    let mut env = SnappyEnv {
        hash_table: core::ptr::null_mut(),
        scratch: core::ptr::null_mut(),
        scratch_output: core::ptr::null_mut(),
    };

    let mut uncompressed_len: usize = 0;
    let mut result: i32 = 0;

    if unsafe { snappy_init_env(&mut env as *mut SnappyEnv) } != 0 {
        return -70;
    }

    let max_len = unsafe { snappy_max_compressed_length(input.len()) };
    if max_len > compressed.len() {
        result = -71;
    } else {
        let mut compressed_len = compressed.len();
        if unsafe {
            snappy_compress(
                &mut env as *mut SnappyEnv,
                input.as_ptr(),
                input.len(),
                compressed.as_mut_ptr(),
                &mut compressed_len as *mut usize,
            )
        } != 0
        {
            result = -72;
        } else if !unsafe {
            snappy_uncompressed_length(
                compressed.as_ptr(),
                compressed_len,
                &mut uncompressed_len as *mut usize,
            )
        } {
            result = -73;
        } else if uncompressed_len != input.len() {
            result = -74;
        } else if uncompressed_len > uncompressed.len() {
            result = -75;
        } else if unsafe {
            snappy_uncompress(
                compressed.as_ptr(),
                compressed_len,
                uncompressed.as_mut_ptr(),
            )
        } != 0
        {
            result = -76;
        } else if unsafe { memcmp(uncompressed.as_ptr(), input.as_ptr(), uncompressed_len) } != 0
        {
            result = -77;
        }
    }

    unsafe {
        snappy_free_env(&mut env as *mut SnappyEnv);
    }

    result
}
