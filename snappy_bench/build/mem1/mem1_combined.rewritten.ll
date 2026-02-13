; ModuleID = '/home/ehdgns/wasm_sfi/snappy_bench/build/mem1/mem1_combined.rewritten.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-p:32:32-p10:8:8-p20:8:8-i64:64-n32:64-S128-ni:1:10:20"
target triple = "wasm32-unknown-unknown"

%struct.snappy_decompressor = type { ptr, ptr, ptr, i32, i8, [5 x i8] }
%struct.source = type { ptr, i32 }
%struct.writer = type { ptr, ptr, ptr }
%struct.sink = type { ptr }

@_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E = internal global <{ [4194304 x i8] }> zeroinitializer, align 1
@_ZN11rust_snappy16BENCH_COMPRESSED17h02e255e6b4d0b1b7E = internal global <{ [4893386 x i8] }> zeroinitializer, align 1
@_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E = internal global <{ [4194304 x i8] }> zeroinitializer, align 1
@_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0 = internal unnamed_addr global i32 0, align 4
@_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0 = internal unnamed_addr global i32 0, align 4
@_ZN11rust_snappy18BENCH_TARGET_READY17h50272c3ff1d65635E.0 = internal unnamed_addr global i1 false, align 1
@_ZN11rust_snappy17BENCH_TARGET_SIZE17h35ac4feaefc47175E.0 = internal unnamed_addr global i32 0, align 4
@_ZN11rust_snappy10SNAPPY_ENV17hbfdcf2c0e04c73a7E = internal global <{ [12 x i8] }> zeroinitializer, align 4
@_ZN11rust_snappy16SNAPPY_ENV_READY17h78e75501de0677ffE.0 = internal unnamed_addr global i1 false, align 1
@_ZN11rust_snappy30DBG_UNCOMP_CALL_COMPRESSED_PTR17hcf4e5717e3619959E.0 = internal unnamed_addr global i1 false, align 4
@_ZN11rust_snappy30DBG_UNCOMP_CALL_COMPRESSED_LEN17h8f5f7889ef364a87E.0 = internal unnamed_addr global i32 0, align 4
@_ZN11rust_snappy23DBG_UNCOMP_CALL_DST_PTR17h7f0bb02428098f21E.0 = internal unnamed_addr global i1 false, align 4
@_ZN11rust_snappy23DBG_UNCOMP_CALL_DST_LEN17h615aec0e6fdd6fbfE.0 = internal unnamed_addr global i32 0, align 4
@_ZN11rust_snappy24DBG_UNCOMP_CALL_LAST_RET17hf4252d1aacf057adE.0 = internal unnamed_addr global i32 0, align 4
@llvm.used = appending global [15 x ptr] [ptr @bench_fill_target_from_pool, ptr @snappy_compress_with_len, ptr @snappy_dbg_last_compressed_ptr, ptr @snappy_dbg_last_expected, ptr @snappy_dbg_last_n, ptr @snappy_dbg_last_stage, ptr @snappy_dbg_last_uncompressed_len, ptr @snappy_dbg_last_uncompressed_ptr, ptr @snappy_free_env, ptr @snappy_init_env_with_len, ptr @snappy_max_compressed_length, ptr @snappy_uncompress_with_len, ptr @snappy_uncompressed_length, ptr @snappy_uncompressed_length_with_len, ptr @snappy_verify_compress_len], section "llvm.metadata"
@bench_input_pool = internal global [9 x [65536 x i8]] zeroinitializer, align 16
@dbg_last_compressed_ptr = internal unnamed_addr global i32 0, align 4
@dbg_last_n = internal unnamed_addr global i32 0, align 4
@dbg_last_uncompressed_ptr = internal unnamed_addr global i32 0, align 4
@dbg_last_uncompressed_len = internal unnamed_addr global i32 0, align 4
@dbg_last_expected = internal unnamed_addr global i32 0, align 4
@dbg_last_stage = internal unnamed_addr global i32 0, align 4
@bench_pool_ready = internal unnamed_addr global i1 false, align 1
@wordmask = internal unnamed_addr constant [5 x i32] [i32 0, i32 255, i32 65535, i32 16777215, i32 -1], align 16
@char_table = internal unnamed_addr constant [256 x i16] [i16 1, i16 2052, i16 4097, i16 8193, i16 2, i16 2053, i16 4098, i16 8194, i16 3, i16 2054, i16 4099, i16 8195, i16 4, i16 2055, i16 4100, i16 8196, i16 5, i16 2056, i16 4101, i16 8197, i16 6, i16 2057, i16 4102, i16 8198, i16 7, i16 2058, i16 4103, i16 8199, i16 8, i16 2059, i16 4104, i16 8200, i16 9, i16 2308, i16 4105, i16 8201, i16 10, i16 2309, i16 4106, i16 8202, i16 11, i16 2310, i16 4107, i16 8203, i16 12, i16 2311, i16 4108, i16 8204, i16 13, i16 2312, i16 4109, i16 8205, i16 14, i16 2313, i16 4110, i16 8206, i16 15, i16 2314, i16 4111, i16 8207, i16 16, i16 2315, i16 4112, i16 8208, i16 17, i16 2564, i16 4113, i16 8209, i16 18, i16 2565, i16 4114, i16 8210, i16 19, i16 2566, i16 4115, i16 8211, i16 20, i16 2567, i16 4116, i16 8212, i16 21, i16 2568, i16 4117, i16 8213, i16 22, i16 2569, i16 4118, i16 8214, i16 23, i16 2570, i16 4119, i16 8215, i16 24, i16 2571, i16 4120, i16 8216, i16 25, i16 2820, i16 4121, i16 8217, i16 26, i16 2821, i16 4122, i16 8218, i16 27, i16 2822, i16 4123, i16 8219, i16 28, i16 2823, i16 4124, i16 8220, i16 29, i16 2824, i16 4125, i16 8221, i16 30, i16 2825, i16 4126, i16 8222, i16 31, i16 2826, i16 4127, i16 8223, i16 32, i16 2827, i16 4128, i16 8224, i16 33, i16 3076, i16 4129, i16 8225, i16 34, i16 3077, i16 4130, i16 8226, i16 35, i16 3078, i16 4131, i16 8227, i16 36, i16 3079, i16 4132, i16 8228, i16 37, i16 3080, i16 4133, i16 8229, i16 38, i16 3081, i16 4134, i16 8230, i16 39, i16 3082, i16 4135, i16 8231, i16 40, i16 3083, i16 4136, i16 8232, i16 41, i16 3332, i16 4137, i16 8233, i16 42, i16 3333, i16 4138, i16 8234, i16 43, i16 3334, i16 4139, i16 8235, i16 44, i16 3335, i16 4140, i16 8236, i16 45, i16 3336, i16 4141, i16 8237, i16 46, i16 3337, i16 4142, i16 8238, i16 47, i16 3338, i16 4143, i16 8239, i16 48, i16 3339, i16 4144, i16 8240, i16 49, i16 3588, i16 4145, i16 8241, i16 50, i16 3589, i16 4146, i16 8242, i16 51, i16 3590, i16 4147, i16 8243, i16 52, i16 3591, i16 4148, i16 8244, i16 53, i16 3592, i16 4149, i16 8245, i16 54, i16 3593, i16 4150, i16 8246, i16 55, i16 3594, i16 4151, i16 8247, i16 56, i16 3595, i16 4152, i16 8248, i16 57, i16 3844, i16 4153, i16 8249, i16 58, i16 3845, i16 4154, i16 8250, i16 59, i16 3846, i16 4155, i16 8251, i16 60, i16 3847, i16 4156, i16 8252, i16 2049, i16 3848, i16 4157, i16 8253, i16 4097, i16 3849, i16 4158, i16 8254, i16 6145, i16 3850, i16 4159, i16 8255, i16 8193, i16 3851, i16 4160, i16 8256], align 16

; Function Attrs: nounwind
define dso_local noundef i32 @bench_prepare(i32 noundef %size) unnamed_addr #0 {
start:
  %0 = icmp eq i32 %size, 0
  br i1 %0, label %bb8, label %bb2

bb2:                                              ; preds = %start
  %_3 = icmp ugt i32 %size, 4194304
  br i1 %_3, label %bb8, label %bb4

bb8:                                              ; preds = %bb7, %bb4, %bb2, %start
  %_0.sroa.0.0 = phi i32 [ 0, %bb7 ], [ -120, %start ], [ -121, %bb2 ], [ %fill_ret, %bb4 ]
  ret i32 %_0.sroa.0.0

bb4:                                              ; preds = %bb2
  %mem1buf = call ptr @__mem1_alloc(i32 %size)
  %mem1_addr = ptrtoint ptr %mem1buf to i32
  call void @__memcpy_0_to_1(i32 %mem1_addr, i32 ptrtoint (ptr @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E to i32), i32 %size)
  %int2ptr = inttoptr i32 %mem1_addr to ptr
  %fill_ret = tail call noundef i32 @bench_fill_target_from_pool(ptr noundef nonnull %int2ptr, i32 noundef %size) #29, !ffi.rewritten !3
  call void @__memcpy_1_to_0(i32 ptrtoint (ptr @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E to i32), i32 %mem1_addr, i32 %size)
  call void @__mem1_free(ptr %mem1buf)
  %1 = icmp eq i32 %fill_ret, 0
  br i1 %1, label %bb7, label %bb8

bb7:                                              ; preds = %bb4
  store i1 true, ptr @_ZN11rust_snappy18BENCH_TARGET_READY17h50272c3ff1d65635E.0, align 1
  store i32 %size, ptr @_ZN11rust_snappy17BENCH_TARGET_SIZE17h35ac4feaefc47175E.0, align 4
  store i32 0, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4
  store i32 0, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4
  br label %bb8
}

; Function Attrs: nounwind
define dso_local noundef i32 @bench_snappy_compress(i32 noundef %size) unnamed_addr #0 {
start:
  %compressed_len.i = alloca [4 x i8], align 4
  %0 = icmp eq i32 %size, 0
  br i1 %0, label %_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit, label %bb2.i

bb2.i:                                            ; preds = %start
  %_3.i = icmp ugt i32 %size, 4194304
  br i1 %_3.i, label %_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit, label %bb4.i

bb4.i:                                            ; preds = %bb2.i
  %.b1.i = load i1, ptr @_ZN11rust_snappy18BENCH_TARGET_READY17h50272c3ff1d65635E.0, align 1
  %target_size.i = load i32, ptr @_ZN11rust_snappy17BENCH_TARGET_SIZE17h35ac4feaefc47175E.0, align 4, !noundef !3
  %_8.i = icmp eq i32 %target_size.i, %size
  %or.cond.not.i = and i1 %.b1.i, %_8.i
  br i1 %or.cond.not.i, label %bb6.i, label %_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit

bb6.i:                                            ; preds = %bb4.i
  %.b1.i.i = load i1, ptr @_ZN11rust_snappy16SNAPPY_ENV_READY17h78e75501de0677ffE.0, align 1
  br i1 %.b1.i.i, label %bb10.i, label %bb2.i.i

bb2.i.i:                                          ; preds = %bb6.i
  %mem1buf = call ptr @__mem1_alloc(i32 12)
  %mem1_addr = ptrtoint ptr %mem1buf to i32
  call void @__memcpy_0_to_1(i32 %mem1_addr, i32 ptrtoint (ptr @_ZN11rust_snappy10SNAPPY_ENV17hbfdcf2c0e04c73a7E to i32), i32 12)
  %int2ptr = inttoptr i32 %mem1_addr to ptr
  %_3.i.i = tail call noundef i32 @snappy_init_env_with_len(ptr noundef nonnull %int2ptr, i32 noundef 12) #29, !ffi.rewritten !3
  call void @__memcpy_1_to_0(i32 ptrtoint (ptr @_ZN11rust_snappy10SNAPPY_ENV17hbfdcf2c0e04c73a7E to i32), i32 %mem1_addr, i32 12)
  call void @__mem1_free(ptr %mem1buf)
  %1 = icmp eq i32 %_3.i.i, 0
  br i1 %1, label %bb5.i.i, label %_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit

bb5.i.i:                                          ; preds = %bb2.i.i
  store i1 true, ptr @_ZN11rust_snappy16SNAPPY_ENV_READY17h78e75501de0677ffE.0, align 1
  br label %bb10.i

bb10.i:                                           ; preds = %bb5.i.i, %bb6.i
  %max_len.i = tail call noundef i32 @snappy_max_compressed_length(i32 noundef %size) #29
  %_11.i = icmp ugt i32 %max_len.i, 4893386
  br i1 %_11.i, label %_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit, label %bb13.i

bb13.i:                                           ; preds = %bb10.i
  store i32 0, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4
  store i32 0, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %compressed_len.i)
  store i32 %max_len.i, ptr %compressed_len.i, align 4
  %mem1buf1 = call ptr @__mem1_alloc(i32 12)
  %mem1_addr2 = ptrtoint ptr %mem1buf1 to i32
  call void @__memcpy_0_to_1(i32 %mem1_addr2, i32 ptrtoint (ptr @_ZN11rust_snappy10SNAPPY_ENV17hbfdcf2c0e04c73a7E to i32), i32 12)
  %int2ptr3 = inttoptr i32 %mem1_addr2 to ptr
  %mem1buf4 = call ptr @__mem1_alloc(i32 %size)
  %mem1_addr5 = ptrtoint ptr %mem1buf4 to i32
  call void @__memcpy_0_to_1(i32 %mem1_addr5, i32 ptrtoint (ptr @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E to i32), i32 %size)
  %int2ptr6 = inttoptr i32 %mem1_addr5 to ptr
  %mem1buf7 = call ptr @__mem1_alloc(i32 %max_len.i)
  %mem1_addr8 = ptrtoint ptr %mem1buf7 to i32
  call void @__memcpy_0_to_1(i32 %mem1_addr8, i32 ptrtoint (ptr @_ZN11rust_snappy16BENCH_COMPRESSED17h02e255e6b4d0b1b7E to i32), i32 %max_len.i)
  %int2ptr9 = inttoptr i32 %mem1_addr8 to ptr
  %ptr2int = ptrtoint ptr %compressed_len.i to i32
  %mem1buf10 = call ptr @__mem1_alloc(i32 4)
  %mem1_addr11 = ptrtoint ptr %mem1buf10 to i32
  call void @__memcpy_0_to_1(i32 %mem1_addr11, i32 %ptr2int, i32 4)
  %int2ptr12 = inttoptr i32 %mem1_addr11 to ptr
  %_16.i = call noundef i32 @snappy_compress_with_len(ptr noundef nonnull %int2ptr3, i32 noundef 12, ptr noundef nonnull %int2ptr6, i32 noundef %size, ptr noundef nonnull %int2ptr9, i32 noundef %max_len.i, ptr noundef nonnull %int2ptr12, i32 noundef 4) #29, !ffi.rewritten !3
  call void @__memcpy_1_to_0(i32 ptrtoint (ptr @_ZN11rust_snappy10SNAPPY_ENV17hbfdcf2c0e04c73a7E to i32), i32 %mem1_addr2, i32 12)
  call void @__mem1_free(ptr %mem1buf1)
  call void @__memcpy_1_to_0(i32 ptrtoint (ptr @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E to i32), i32 %mem1_addr5, i32 %size)
  call void @__mem1_free(ptr %mem1buf4)
  call void @__memcpy_1_to_0(i32 ptrtoint (ptr @_ZN11rust_snappy16BENCH_COMPRESSED17h02e255e6b4d0b1b7E to i32), i32 %mem1_addr8, i32 %max_len.i)
  call void @__mem1_free(ptr %mem1buf7)
  call void @__memcpy_1_to_0(i32 %ptr2int, i32 %mem1_addr11, i32 4)
  call void @__mem1_free(ptr %mem1buf10)
  %2 = icmp eq i32 %_16.i, 0
  br i1 %2, label %bb16.i, label %bb17.i

bb16.i:                                           ; preds = %bb13.i
  %_28.i = load i32, ptr %compressed_len.i, align 4, !noundef !3
  store i32 %_28.i, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4
  store i32 %size, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4
  br label %bb17.i

bb17.i:                                           ; preds = %bb16.i, %bb13.i
  %result.sroa.0.0.i = phi i32 [ 0, %bb16.i ], [ -94, %bb13.i ]
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %compressed_len.i)
  br label %_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit

_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit: ; preds = %bb17.i, %bb10.i, %bb2.i.i, %bb4.i, %bb2.i, %start
  %_0.sroa.0.0.i = phi i32 [ %result.sroa.0.0.i, %bb17.i ], [ -90, %start ], [ -91, %bb2.i ], [ -92, %bb4.i ], [ -93, %bb10.i ], [ -92, %bb2.i.i ]
  ret i32 %_0.sroa.0.0.i
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #1

; Function Attrs: nounwind
define dso_local noundef i32 @bench_snappy_uncompress(i32 noundef %size) unnamed_addr #0 {
start:
  %0 = icmp eq i32 %size, 0
  br i1 %0, label %_ZN11rust_snappy28bench_snappy_uncompress_impl17hd2bbec78fc0269afE.exit, label %bb2.i

bb2.i:                                            ; preds = %start
  %_3.i = icmp ugt i32 %size, 4194304
  br i1 %_3.i, label %_ZN11rust_snappy28bench_snappy_uncompress_impl17hd2bbec78fc0269afE.exit, label %bb4.i

bb4.i:                                            ; preds = %bb2.i
  %compressed_len.i = load i32, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4, !noundef !3
  %compressed_size.i = load i32, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4, !noundef !3
  %1 = icmp eq i32 %compressed_len.i, 0
  %_8.i = icmp ne i32 %compressed_size.i, %size
  %or.cond.i = or i1 %1, %_8.i
  br i1 %or.cond.i, label %_ZN11rust_snappy28bench_snappy_uncompress_impl17hd2bbec78fc0269afE.exit, label %bb6.i

bb6.i:                                            ; preds = %bb4.i
  store i1 true, ptr @_ZN11rust_snappy30DBG_UNCOMP_CALL_COMPRESSED_PTR17hcf4e5717e3619959E.0, align 4
  store i32 %compressed_len.i, ptr @_ZN11rust_snappy30DBG_UNCOMP_CALL_COMPRESSED_LEN17h8f5f7889ef364a87E.0, align 4
  store i1 true, ptr @_ZN11rust_snappy23DBG_UNCOMP_CALL_DST_PTR17h7f0bb02428098f21E.0, align 4
  store i32 %size, ptr @_ZN11rust_snappy23DBG_UNCOMP_CALL_DST_LEN17h615aec0e6fdd6fbfE.0, align 4
  store i32 0, ptr @_ZN11rust_snappy24DBG_UNCOMP_CALL_LAST_RET17hf4252d1aacf057adE.0, align 4
  %mem1buf = call ptr @__mem1_alloc(i32 %compressed_len.i)
  %mem1_addr = ptrtoint ptr %mem1buf to i32
  call void @__memcpy_0_to_1(i32 %mem1_addr, i32 ptrtoint (ptr @_ZN11rust_snappy16BENCH_COMPRESSED17h02e255e6b4d0b1b7E to i32), i32 %compressed_len.i)
  %int2ptr = inttoptr i32 %mem1_addr to ptr
  %mem1buf1 = call ptr @__mem1_alloc(i32 %size)
  %mem1_addr2 = ptrtoint ptr %mem1buf1 to i32
  call void @__memcpy_0_to_1(i32 %mem1_addr2, i32 ptrtoint (ptr @_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E to i32), i32 %size)
  %int2ptr3 = inttoptr i32 %mem1_addr2 to ptr
  %ret.i = tail call noundef i32 @snappy_uncompress_with_len(ptr noundef nonnull %int2ptr, i32 noundef %compressed_len.i, ptr noundef nonnull %int2ptr3, i32 noundef %size) #29, !ffi.rewritten !3
  call void @__memcpy_1_to_0(i32 ptrtoint (ptr @_ZN11rust_snappy16BENCH_COMPRESSED17h02e255e6b4d0b1b7E to i32), i32 %mem1_addr, i32 %compressed_len.i)
  call void @__mem1_free(ptr %mem1buf)
  call void @__memcpy_1_to_0(i32 ptrtoint (ptr @_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E to i32), i32 %mem1_addr2, i32 %size)
  call void @__mem1_free(ptr %mem1buf1)
  store i32 %ret.i, ptr @_ZN11rust_snappy24DBG_UNCOMP_CALL_LAST_RET17hf4252d1aacf057adE.0, align 4
  br label %_ZN11rust_snappy28bench_snappy_uncompress_impl17hd2bbec78fc0269afE.exit

_ZN11rust_snappy28bench_snappy_uncompress_impl17hd2bbec78fc0269afE.exit: ; preds = %bb6.i, %bb4.i, %bb2.i, %start
  %_0.sroa.0.0.i = phi i32 [ -100, %start ], [ -101, %bb2.i ], [ -102, %bb4.i ], [ %ret.i, %bb6.i ]
  ret i32 %_0.sroa.0.0.i
}

; Function Attrs: nounwind
define dso_local noundef i32 @bench_verify_compress(i32 noundef %size) unnamed_addr #0 {
start:
  %0 = icmp eq i32 %size, 0
  br i1 %0, label %bb11, label %bb2

bb2:                                              ; preds = %start
  %_3 = icmp ugt i32 %size, 4194304
  br i1 %_3, label %bb11, label %bb4

bb11:                                             ; preds = %bb6, %bb4, %bb2, %start
  %_0.sroa.0.0 = phi i32 [ -140, %start ], [ -141, %bb2 ], [ -142, %bb4 ], [ %., %bb6 ]
  ret i32 %_0.sroa.0.0

bb4:                                              ; preds = %bb2
  %compressed_len = load i32, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4, !noundef !3
  %compressed_size = load i32, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4, !noundef !3
  %1 = icmp eq i32 %compressed_len, 0
  %_8 = icmp ne i32 %compressed_size, %size
  %or.cond = or i1 %1, %_8
  br i1 %or.cond, label %bb11, label %bb6

bb6:                                              ; preds = %bb4
  %max_len = tail call noundef i32 @snappy_max_compressed_length(i32 noundef %size) #29
  %_10 = icmp ugt i32 %compressed_len, %max_len
  %. = select i1 %_10, i32 -143, i32 0
  br label %bb11
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_get_compressed_len() unnamed_addr #2 {
start:
  %_0 = load i32, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4, !noundef !3
  ret i32 %_0
}

; Function Attrs: mustprogress nofree nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_verify_uncompress(i32 noundef %size) unnamed_addr #3 {
start:
  %0 = icmp eq i32 %size, 0
  br i1 %0, label %bb11, label %bb2

bb2:                                              ; preds = %start
  %_3 = icmp ugt i32 %size, 4194304
  br i1 %_3, label %bb11, label %bb4

bb11:                                             ; preds = %bb6, %bb4, %bb2, %start
  %_0.sroa.0.0 = phi i32 [ -150, %start ], [ -151, %bb2 ], [ -152, %bb4 ], [ %., %bb6 ]
  ret i32 %_0.sroa.0.0

bb4:                                              ; preds = %bb2
  %compressed_len = load i32, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4, !noundef !3
  %compressed_size = load i32, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4, !noundef !3
  %1 = icmp eq i32 %compressed_len, 0
  %_8 = icmp ne i32 %compressed_size, %size
  %or.cond = or i1 %1, %_8
  br i1 %or.cond, label %bb11, label %bb6

bb6:                                              ; preds = %bb4
  %_9 = tail call noundef i32 @memcmp(ptr noundef nonnull @_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E, ptr noundef nonnull @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E, i32 noundef %size) #29
  %2 = icmp eq i32 %_9, 0
  %. = select i1 %2, i32 0, i32 -155
  br label %bb11
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_debug_uncomp_compressed_ptr() unnamed_addr #2 {
start:
  %_0.b = load i1, ptr @_ZN11rust_snappy30DBG_UNCOMP_CALL_COMPRESSED_PTR17hcf4e5717e3619959E.0, align 4
  %_0 = select i1 %_0.b, i32 ptrtoint (ptr @_ZN11rust_snappy16BENCH_COMPRESSED17h02e255e6b4d0b1b7E to i32), i32 0
  ret i32 %_0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_debug_uncomp_compressed_len() unnamed_addr #2 {
start:
  %_0 = load i32, ptr @_ZN11rust_snappy30DBG_UNCOMP_CALL_COMPRESSED_LEN17h8f5f7889ef364a87E.0, align 4, !noundef !3
  ret i32 %_0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_debug_uncomp_dst_ptr() unnamed_addr #2 {
start:
  %_0.b = load i1, ptr @_ZN11rust_snappy23DBG_UNCOMP_CALL_DST_PTR17h7f0bb02428098f21E.0, align 4
  %_0 = select i1 %_0.b, i32 ptrtoint (ptr @_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E to i32), i32 0
  ret i32 %_0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_debug_uncomp_dst_len() unnamed_addr #2 {
start:
  %_0 = load i32, ptr @_ZN11rust_snappy23DBG_UNCOMP_CALL_DST_LEN17h615aec0e6fdd6fbfE.0, align 4, !noundef !3
  ret i32 %_0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_debug_uncomp_last_ret() unnamed_addr #2 {
start:
  %_0 = load i32, ptr @_ZN11rust_snappy24DBG_UNCOMP_CALL_LAST_RET17hf4252d1aacf057adE.0, align 4, !noundef !3
  ret i32 %_0
}

; Function Attrs: nofree norecurse nosync nounwind memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_debug_first_mismatch(i32 noundef %size) unnamed_addr #4 {
start:
  %0 = add i32 %size, -1
  %or.cond = icmp ult i32 %0, 4194304
  br i1 %or.cond, label %bb7, label %bb11

bb11:                                             ; preds = %bb9, %bb7, %start
  %_0.sroa.0.0 = phi i32 [ -1, %start ], [ -1, %bb9 ], [ %i.sroa.0.07, %bb7 ]
  ret i32 %_0.sroa.0.0

bb7:                                              ; preds = %bb9, %start
  %i.sroa.0.07 = phi i32 [ %3, %bb9 ], [ 0, %start ]
  %1 = getelementptr inbounds [4194304 x i8], ptr @_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E, i32 0, i32 %i.sroa.0.07
  %_8 = load i8, ptr %1, align 1, !noundef !3
  %2 = getelementptr inbounds [4194304 x i8], ptr @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E, i32 0, i32 %i.sroa.0.07
  %_12 = load i8, ptr %2, align 1, !noundef !3
  %mismatch.not = icmp eq i8 %_8, %_12
  br i1 %mismatch.not, label %bb9, label %bb11

bb9:                                              ; preds = %bb7
  %3 = add nuw i32 %i.sroa.0.07, 1
  %exitcond.not = icmp eq i32 %3, %size
  br i1 %exitcond.not, label %bb11, label %bb7
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_debug_target_byte_at(i32 noundef %idx) unnamed_addr #2 {
start:
  %_3 = icmp ugt i32 %idx, 4194303
  br i1 %_3, label %bb4, label %bb3

bb3:                                              ; preds = %start
  %0 = getelementptr inbounds [4194304 x i8], ptr @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E, i32 0, i32 %idx
  %_4 = load i8, ptr %0, align 1, !noundef !3
  %1 = zext i8 %_4 to i32
  br label %bb4

bb4:                                              ; preds = %bb3, %start
  %_0.sroa.0.0 = phi i32 [ %1, %bb3 ], [ -1, %start ]
  ret i32 %_0.sroa.0.0
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_debug_uncompressed_byte_at(i32 noundef %idx) unnamed_addr #2 {
start:
  %_3 = icmp ugt i32 %idx, 4194303
  br i1 %_3, label %bb4, label %bb3

bb3:                                              ; preds = %start
  %0 = getelementptr inbounds [4194304 x i8], ptr @_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E, i32 0, i32 %idx
  %_4 = load i8, ptr %0, align 1, !noundef !3
  %1 = zext i8 %_4 to i32
  br label %bb4

bb4:                                              ; preds = %bb3, %start
  %_0.sroa.0.0 = phi i32 [ %1, %bb3 ], [ -1, %start ]
  ret i32 %_0.sroa.0.0
}

; Function Attrs: nofree norecurse noreturn nosync nounwind memory(none)
define hidden void @rust_begin_unwind(ptr noalias nocapture noundef readonly align 4 dereferenceable(20) %_1) unnamed_addr #5 {
start:
  br label %bb1

bb1:                                              ; preds = %bb1, %start
  br label %bb1
}

; Function Attrs: minsize nounwind optsize
define hidden noundef i32 @bench_fill_target_from_pool(ptr noundef %0, i32 noundef %1) #6 {
  %3 = icmp eq i32 %1, 0
  br i1 %3, label %42, label %4

4:                                                ; preds = %2
  %5 = icmp ugt i32 %1, 4194304
  br i1 %5, label %42, label %6

6:                                                ; preds = %4
  %7 = load i1, ptr @bench_pool_ready, align 1
  call void asm sideeffect "nop", ""()
  br i1 %7, label %12, label %8

8:                                                ; preds = %6, %26
  %9 = phi i32 [ %27, %26 ], [ 0, %6 ]
  %10 = icmp eq i32 %9, 9
  br i1 %10, label %11, label %13

11:                                               ; preds = %8
  store i1 true, ptr @bench_pool_ready, align 1
  call void asm sideeffect "nop", ""()
  br label %12

12:                                               ; preds = %6, %11
  br label %28

13:                                               ; preds = %8
  %14 = getelementptr inbounds [9 x [65536 x i8]], ptr @bench_input_pool, i32 0, i32 %9
  %15 = mul nuw nsw i32 %9, 17
  %16 = add nuw nsw i32 %15, 17
  br label %17

17:                                               ; preds = %20, %13
  %18 = phi i32 [ 0, %13 ], [ %25, %20 ]
  %19 = icmp eq i32 %18, 65536
  br i1 %19, label %26, label %20

20:                                               ; preds = %17
  %21 = mul nuw nsw i32 %18, 31
  %22 = add nuw nsw i32 %16, %21
  %23 = trunc i32 %22 to i8
  %24 = getelementptr inbounds i8, ptr %14, i32 %18
  store i8 %23, ptr %24, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %25 = add nuw nsw i32 %18, 1
  br label %17, !llvm.loop !7

26:                                               ; preds = %17
  %27 = add nuw nsw i32 %9, 1
  br label %8, !llvm.loop !9

28:                                               ; preds = %12, %32
  %29 = phi i32 [ %41, %32 ], [ 0, %12 ]
  %30 = phi i32 [ %38, %32 ], [ 0, %12 ]
  %31 = icmp ult i32 %30, %1
  br i1 %31, label %32, label %42

32:                                               ; preds = %28
  %33 = sub nsw i32 %1, %30
  %34 = tail call i32 @llvm.umin.i32(i32 %33, i32 65536)
  %35 = getelementptr inbounds i8, ptr %0, i32 %30
  %36 = getelementptr inbounds [9 x [65536 x i8]], ptr @bench_input_pool, i32 0, i32 %29
  %37 = tail call ptr @memcpy(ptr noundef %35, ptr noundef nonnull %36, i32 noundef %34) #30
  %38 = add nuw nsw i32 %34, %30
  %39 = add i32 %29, 1
  %40 = icmp eq i32 %39, 9
  %41 = select i1 %40, i32 0, i32 %39
  br label %28, !llvm.loop !10

42:                                               ; preds = %28, %4, %2
  %43 = phi i32 [ -120, %2 ], [ -121, %4 ], [ 0, %28 ]
  ret i32 %43
}

; Function Attrs: minsize nounwind optsize
define hidden noundef i32 @snappy_compress_with_len(ptr nocapture noundef readonly %0, i32 noundef %1, ptr noundef %2, i32 noundef %3, ptr noundef %4, i32 noundef %5, ptr nocapture noundef writeonly %6, i32 noundef %7) #7 {
  %9 = icmp ult i32 %1, 12
  %10 = icmp ult i32 %7, 4
  %11 = or i1 %9, %10
  br i1 %11, label %19, label %12

12:                                               ; preds = %8
  %13 = add i32 %3, 32
  %14 = udiv i32 %3, 6
  %15 = add i32 %13, %14
  %16 = icmp ugt i32 %15, %5
  br i1 %16, label %19, label %17

17:                                               ; preds = %12
  %18 = tail call i32 @snappy_compress(ptr noundef %0, ptr noundef %2, i32 noundef %3, ptr noundef %4, ptr noundef %6) #31
  br label %19

19:                                               ; preds = %12, %8, %17
  %20 = phi i32 [ %18, %17 ], [ -5, %8 ], [ -5, %12 ]
  ret i32 %20
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none)
define hidden i32 @snappy_dbg_last_compressed_ptr() #8 {
  %1 = load i32, ptr @dbg_last_compressed_ptr, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none)
define hidden i32 @snappy_dbg_last_expected() #9 {
  %1 = load i32, ptr @dbg_last_expected, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none)
define hidden i32 @snappy_dbg_last_n() #10 {
  %1 = load i32, ptr @dbg_last_n, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none)
define hidden i32 @snappy_dbg_last_stage() #11 {
  %1 = load i32, ptr @dbg_last_stage, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none)
define hidden i32 @snappy_dbg_last_uncompressed_len() #12 {
  %1 = load i32, ptr @dbg_last_uncompressed_len, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  ret i32 %1
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none)
define hidden i32 @snappy_dbg_last_uncompressed_ptr() #13 {
  %1 = load i32, ptr @dbg_last_uncompressed_ptr, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  ret i32 %1
}

; Function Attrs: minsize nounwind optsize
define hidden void @snappy_free_env(ptr noundef %0) #14 {
  %2 = load ptr, ptr %0, align 4, !tbaa !15
  call void asm sideeffect "nop", ""()
  tail call void @free(ptr noundef %2) #30
  tail call fastcc void @clear_env(ptr noundef nonnull %0) #31
  ret void
}

; Function Attrs: minsize nounwind optsize
define hidden i32 @snappy_init_env_with_len(ptr noundef %0, i32 noundef %1) #15 {
  %3 = icmp ult i32 %1, 12
  br i1 %3, label %6, label %4

4:                                                ; preds = %2
  %5 = tail call i32 @snappy_init_env(ptr noundef %0) #31, !range !18
  br label %6

6:                                                ; preds = %2, %4
  %7 = phi i32 [ %5, %4 ], [ -5, %2 ]
  ret i32 %7
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define hidden noundef i32 @snappy_max_compressed_length(i32 noundef %0) #16 {
  %2 = add i32 %0, 32
  %3 = udiv i32 %0, 6
  %4 = add i32 %2, %3
  ret i32 %4
}

; Function Attrs: minsize nounwind optsize
define hidden noundef i32 @snappy_uncompress_with_len(ptr noundef %0, i32 noundef %1, ptr noundef %2, i32 noundef %3) #17 {
  %5 = alloca i32, align 4
  %6 = ptrtoint ptr %0 to i32
  store i32 %6, ptr @dbg_last_compressed_ptr, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  store i32 %1, ptr @dbg_last_n, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  %7 = ptrtoint ptr %2 to i32
  store i32 %7, ptr @dbg_last_uncompressed_ptr, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  store i32 %3, ptr @dbg_last_uncompressed_len, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  store i32 0, ptr @dbg_last_expected, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %5) #29
  store i32 0, ptr %5, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  %8 = call fastcc zeroext i1 @snappy_uncompressed_length_internal(ptr noundef %0, i32 noundef %1, ptr noundef nonnull %5) #31
  br i1 %8, label %9, label %17

9:                                                ; preds = %4
  %10 = load i32, ptr %5, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  store i32 %10, ptr @dbg_last_expected, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  %11 = icmp ugt i32 %10, %3
  br i1 %11, label %17, label %12

12:                                               ; preds = %9
  store i32 3, ptr @dbg_last_stage, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  %13 = tail call i32 @snappy_uncompress(ptr noundef %0, i32 noundef %1, ptr noundef %2) #31, !range !19
  %14 = icmp eq i32 %13, 0
  %15 = select i1 %14, i32 100, i32 -203
  %16 = select i1 %14, i32 0, i32 -203
  br label %17

17:                                               ; preds = %12, %9, %4
  %18 = phi i32 [ -201, %4 ], [ -202, %9 ], [ %15, %12 ]
  %19 = phi i32 [ -201, %4 ], [ -202, %9 ], [ %16, %12 ]
  store i32 %18, ptr @dbg_last_stage, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %5) #29
  ret i32 %19
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define hidden noundef zeroext i1 @snappy_uncompressed_length(ptr nocapture noundef readonly %0, i32 noundef %1, ptr nocapture noundef writeonly %2) #18 {
  %4 = tail call fastcc zeroext i1 @snappy_uncompressed_length_internal(ptr noundef %0, i32 noundef %1, ptr noundef %2) #31
  ret i1 %4
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define hidden noundef zeroext i1 @snappy_uncompressed_length_with_len(ptr nocapture noundef readonly %0, i32 noundef %1, ptr nocapture noundef writeonly %2, i32 noundef %3) #19 {
  %5 = icmp ult i32 %3, 4
  br i1 %5, label %8, label %6

6:                                                ; preds = %4
  %7 = tail call fastcc zeroext i1 @snappy_uncompressed_length_internal(ptr noundef %0, i32 noundef %1, ptr noundef %2) #31
  br label %8

8:                                                ; preds = %4, %6
  %9 = phi i1 [ %7, %6 ], [ false, %4 ]
  ret i1 %9
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none)
define hidden noundef zeroext i1 @snappy_verify_compress_len(i32 noundef %0, i32 noundef %1) #20 {
  %3 = icmp ult i32 %0, %1
  ret i1 %3
}

; Function Attrs: minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite)
define internal fastcc noundef zeroext i1 @snappy_uncompressed_length_internal(ptr nocapture noundef readonly %0, i32 noundef %1, ptr nocapture noundef writeonly %2) unnamed_addr #21 {
  %4 = icmp sgt i32 %1, 0
  br i1 %4, label %5, label %51

5:                                                ; preds = %3
  %6 = getelementptr inbounds i8, ptr %0, i32 1
  %7 = load i8, ptr %0, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %8 = and i8 %7, 127
  %9 = zext nneg i8 %8 to i32
  %10 = icmp sgt i8 %7, -1
  br i1 %10, label %49, label %11

11:                                               ; preds = %5
  %12 = icmp eq i32 %1, 1
  br i1 %12, label %51, label %13

13:                                               ; preds = %11
  %14 = getelementptr inbounds i8, ptr %0, i32 2
  %15 = load i8, ptr %6, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %16 = zext i8 %15 to i32
  %17 = shl nuw nsw i32 %16, 7
  %18 = and i32 %17, 16256
  %19 = or disjoint i32 %18, %9
  %20 = icmp sgt i8 %15, -1
  br i1 %20, label %49, label %21

21:                                               ; preds = %13
  %22 = icmp ugt i32 %1, 2
  br i1 %22, label %23, label %51

23:                                               ; preds = %21
  %24 = getelementptr inbounds i8, ptr %0, i32 3
  %25 = load i8, ptr %14, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %26 = zext i8 %25 to i32
  %27 = shl nuw nsw i32 %26, 14
  %28 = and i32 %27, 2080768
  %29 = or disjoint i32 %28, %19
  %30 = icmp sgt i8 %25, -1
  br i1 %30, label %49, label %31

31:                                               ; preds = %23
  %32 = icmp eq i32 %1, 3
  br i1 %32, label %51, label %33

33:                                               ; preds = %31
  %34 = getelementptr inbounds i8, ptr %0, i32 4
  %35 = load i8, ptr %24, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %36 = zext i8 %35 to i32
  %37 = shl nuw nsw i32 %36, 21
  %38 = and i32 %37, 266338304
  %39 = or disjoint i32 %38, %29
  %40 = icmp sgt i8 %35, -1
  br i1 %40, label %49, label %41

41:                                               ; preds = %33
  %42 = icmp ugt i32 %1, 4
  br i1 %42, label %43, label %51

43:                                               ; preds = %41
  %44 = load i8, ptr %34, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %45 = zext i8 %44 to i32
  %46 = shl i32 %45, 28
  %47 = or disjoint i32 %46, %39
  %48 = icmp ult i8 %44, 16
  br i1 %48, label %49, label %51

49:                                               ; preds = %43, %33, %23, %13, %5
  %50 = phi i32 [ %9, %5 ], [ %19, %13 ], [ %29, %23 ], [ %39, %33 ], [ %47, %43 ]
  store i32 %50, ptr %2, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  br label %51

51:                                               ; preds = %43, %41, %31, %21, %11, %3, %49
  %52 = phi i1 [ true, %49 ], [ false, %3 ], [ false, %11 ], [ false, %21 ], [ false, %31 ], [ false, %41 ], [ false, %43 ]
  ret i1 %52
}

; Function Attrs: minsize nounwind optsize
define hidden noundef i32 @snappy_uncompress(ptr noundef %0, i32 noundef %1, ptr noundef %2) local_unnamed_addr #22 {
  %4 = alloca i32, align 4
  %5 = alloca i32, align 4
  %6 = alloca %struct.snappy_decompressor, align 4
  %7 = alloca %struct.source, align 4
  %8 = alloca %struct.writer, align 4
  call void @llvm.lifetime.start.p0(i64 8, ptr nonnull %7) #29
  %9 = getelementptr inbounds %struct.source, ptr %7, i32 0, i32 1
  call void @llvm.lifetime.start.p0(i64 12, ptr nonnull %8) #29
  store ptr %2, ptr %8, align 4, !tbaa !20
  call void asm sideeffect "nop", ""()
  %10 = getelementptr inbounds %struct.writer, ptr %8, i32 0, i32 1
  store ptr %2, ptr %10, align 4, !tbaa !22
  call void asm sideeffect "nop", ""()
  %11 = getelementptr inbounds %struct.writer, ptr %8, i32 0, i32 2
  call void @llvm.lifetime.start.p0(i64 24, ptr nonnull %6) #29
  store ptr %7, ptr %6, align 4, !tbaa !23
  call void asm sideeffect "nop", ""()
  %12 = getelementptr inbounds %struct.snappy_decompressor, ptr %6, i32 0, i32 1
  store ptr null, ptr %12, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  %13 = getelementptr inbounds %struct.snappy_decompressor, ptr %6, i32 0, i32 2
  store ptr null, ptr %13, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  %14 = getelementptr inbounds %struct.snappy_decompressor, ptr %6, i32 0, i32 3
  store i32 0, ptr %14, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  %15 = getelementptr inbounds %struct.snappy_decompressor, ptr %6, i32 0, i32 4
  store i8 0, ptr %15, align 4, !tbaa !29
  call void asm sideeffect "nop", ""()
  %16 = load i32, ptr %9, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %17 = load ptr, ptr %7, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  br label %18

18:                                               ; preds = %28, %3
  %19 = phi ptr [ %17, %3 ], [ %31, %28 ]
  %20 = phi i32 [ %16, %3 ], [ %30, %28 ]
  %21 = phi ptr [ %0, %3 ], [ %31, %28 ]
  %22 = phi i32 [ %1, %3 ], [ %30, %28 ]
  %23 = phi i32 [ 0, %3 ], [ %35, %28 ]
  %24 = phi i32 [ 0, %3 ], [ %37, %28 ]
  %25 = icmp ugt i32 %24, 31
  %26 = icmp eq i32 %22, 0
  %27 = select i1 %25, i1 true, i1 %26
  br i1 %27, label %241, label %28

28:                                               ; preds = %18
  %29 = load i8, ptr %21, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %30 = add i32 %22, -1
  %31 = getelementptr inbounds i8, ptr %21, i32 1
  %32 = and i8 %29, 127
  %33 = zext nneg i8 %32 to i32
  %34 = shl i32 %33, %24
  %35 = or i32 %34, %23
  %36 = icmp sgt i8 %29, -1
  %37 = add nuw nsw i32 %24, 7
  br i1 %36, label %38, label %18

38:                                               ; preds = %28
  store i32 %30, ptr %9, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  store ptr %31, ptr %7, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  %39 = getelementptr inbounds i8, ptr %2, i32 %35
  store ptr %39, ptr %11, align 4, !tbaa !33
  call void asm sideeffect "nop", ""()
  %40 = call fastcc zeroext i1 @refill_tag(ptr noundef nonnull %6) #31
  br i1 %40, label %41, label %226

41:                                               ; preds = %38
  %42 = load ptr, ptr %12, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  br label %43

43:                                               ; preds = %224, %41
  %44 = phi ptr [ %42, %41 ], [ %225, %224 ]
  %45 = load ptr, ptr %13, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  %46 = ptrtoint ptr %45 to i32
  %47 = ptrtoint ptr %44 to i32
  %48 = sub i32 %46, %47
  %49 = icmp slt i32 %48, 5
  br i1 %49, label %50, label %54

50:                                               ; preds = %43
  store ptr %44, ptr %12, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  %51 = call fastcc zeroext i1 @refill_tag(ptr noundef nonnull %6) #31
  br i1 %51, label %52, label %226

52:                                               ; preds = %50
  %53 = load ptr, ptr %12, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  br label %54

54:                                               ; preds = %52, %43
  %55 = phi ptr [ %53, %52 ], [ %44, %43 ]
  %56 = getelementptr inbounds i8, ptr %55, i32 1
  %57 = load i8, ptr %55, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %58 = zext i8 %57 to i32
  %59 = and i32 %58, 3
  %60 = icmp eq i32 %59, 0
  br i1 %60, label %61, label %139

61:                                               ; preds = %54
  %62 = lshr exact i32 %58, 2
  %63 = add nuw nsw i32 %62, 1
  %64 = load ptr, ptr %13, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  %65 = ptrtoint ptr %64 to i32
  %66 = ptrtoint ptr %56 to i32
  %67 = sub i32 %65, %66
  %68 = load ptr, ptr %10, align 4, !tbaa !22
  call void asm sideeffect "nop", ""()
  %69 = load ptr, ptr %11, align 4, !tbaa !33
  call void asm sideeffect "nop", ""()
  %70 = ptrtoint ptr %69 to i32
  %71 = ptrtoint ptr %68 to i32
  %72 = sub i32 %70, %71
  %73 = icmp ult i8 %57, 64
  %74 = icmp ugt i32 %67, 15
  %75 = and i1 %73, %74
  %76 = icmp sgt i32 %72, 15
  %77 = select i1 %75, i1 %76, i1 false
  br i1 %77, label %78, label %90

78:                                               ; preds = %61
  call fastcc void @unaligned_copy64(ptr noundef nonnull %56, ptr noundef %68) #31
  %79 = getelementptr inbounds i8, ptr %55, i32 9
  %80 = getelementptr inbounds i8, ptr %68, i32 8
  call fastcc void @unaligned_copy64(ptr noundef nonnull %79, ptr noundef nonnull %80) #31
  %81 = getelementptr inbounds i8, ptr %68, i32 %63
  store ptr %81, ptr %10, align 4, !tbaa !22
  call void asm sideeffect "nop", ""()
  %82 = getelementptr inbounds i8, ptr %56, i32 %63
  %83 = load ptr, ptr %13, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  %84 = ptrtoint ptr %83 to i32
  %85 = ptrtoint ptr %82 to i32
  %86 = sub i32 %84, %85
  %87 = icmp slt i32 %86, 5
  br i1 %87, label %88, label %224

88:                                               ; preds = %78
  store ptr %82, ptr %12, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  %89 = call fastcc zeroext i1 @refill_tag(ptr noundef nonnull %6) #31
  br i1 %89, label %222, label %226

90:                                               ; preds = %61
  %91 = icmp ugt i8 %57, -20
  br i1 %91, label %92, label %105, !prof !34

92:                                               ; preds = %90
  %93 = add nsw i32 %62, -59
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %4) #29
  %94 = call ptr @memcpy(ptr noundef nonnull %4, ptr noundef nonnull %56, i32 noundef 4) #30
  %95 = load i32, ptr %4, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %4) #29
  %96 = getelementptr inbounds [5 x i32], ptr @wordmask, i32 0, i32 %93
  %97 = load i32, ptr %96, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  %98 = and i32 %97, %95
  %99 = add i32 %98, 1
  %100 = getelementptr inbounds i8, ptr %56, i32 %93
  %101 = load ptr, ptr %13, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  %102 = ptrtoint ptr %101 to i32
  %103 = ptrtoint ptr %100 to i32
  %104 = sub i32 %102, %103
  br label %105

105:                                              ; preds = %92, %90
  %106 = phi i32 [ %67, %90 ], [ %104, %92 ]
  %107 = phi i32 [ %63, %90 ], [ %99, %92 ]
  %108 = phi ptr [ %56, %90 ], [ %100, %92 ]
  br label %109

109:                                              ; preds = %105, %125
  %110 = phi i32 [ %121, %125 ], [ %106, %105 ]
  %111 = phi i32 [ %126, %125 ], [ %107, %105 ]
  %112 = phi ptr [ %123, %125 ], [ %108, %105 ]
  %113 = icmp ult i32 %110, %111
  br i1 %113, label %114, label %128

114:                                              ; preds = %109
  %115 = call fastcc zeroext i1 @writer_append(ptr noundef nonnull %8, ptr noundef %112, i32 noundef %110) #31
  br i1 %115, label %116, label %226

116:                                              ; preds = %114
  %117 = load ptr, ptr %6, align 4, !tbaa !23
  call void asm sideeffect "nop", ""()
  %118 = load i32, ptr %14, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  %119 = getelementptr inbounds %struct.source, ptr %117, i32 0, i32 1
  %120 = load i32, ptr %119, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %121 = sub i32 %120, %118
  store i32 %121, ptr %119, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %122 = load ptr, ptr %117, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  %123 = getelementptr inbounds i8, ptr %122, i32 %118
  store ptr %123, ptr %117, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  store i32 %121, ptr %14, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  %124 = icmp eq i32 %121, 0
  br i1 %124, label %226, label %125

125:                                              ; preds = %116
  %126 = sub i32 %111, %110
  %127 = getelementptr inbounds i8, ptr %122, i32 %120
  store ptr %127, ptr %13, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  br label %109, !llvm.loop !35

128:                                              ; preds = %109
  %129 = call fastcc zeroext i1 @writer_append(ptr noundef nonnull %8, ptr noundef %112, i32 noundef %111) #31
  br i1 %129, label %130, label %226

130:                                              ; preds = %128
  %131 = getelementptr inbounds i8, ptr %112, i32 %111
  %132 = load ptr, ptr %13, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  %133 = ptrtoint ptr %132 to i32
  %134 = ptrtoint ptr %131 to i32
  %135 = sub i32 %133, %134
  %136 = icmp slt i32 %135, 5
  br i1 %136, label %137, label %224

137:                                              ; preds = %130
  store ptr %131, ptr %12, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  %138 = call fastcc zeroext i1 @refill_tag(ptr noundef nonnull %6) #31
  br i1 %138, label %222, label %226

139:                                              ; preds = %54
  %140 = getelementptr inbounds [256 x i16], ptr @char_table, i32 0, i32 %58
  %141 = load i16, ptr %140, align 2, !tbaa !36
  call void asm sideeffect "nop", ""()
  %142 = zext i16 %141 to i32
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %5) #29
  %143 = call ptr @memcpy(ptr noundef nonnull %5, ptr noundef nonnull %56, i32 noundef 4) #30
  %144 = load i32, ptr %5, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %5) #29
  %145 = lshr i32 %142, 11
  %146 = getelementptr inbounds [5 x i32], ptr @wordmask, i32 0, i32 %145
  %147 = load i32, ptr %146, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  %148 = and i32 %147, %144
  %149 = and i32 %142, 255
  %150 = getelementptr inbounds i8, ptr %56, i32 %145
  %151 = and i32 %142, 1792
  %152 = add i32 %148, %151
  %153 = load ptr, ptr %10, align 4, !tbaa !22
  call void asm sideeffect "nop", ""()
  %154 = load ptr, ptr %11, align 4, !tbaa !33
  call void asm sideeffect "nop", ""()
  %155 = ptrtoint ptr %154 to i32
  %156 = ptrtoint ptr %153 to i32
  %157 = sub i32 %155, %156
  %158 = load ptr, ptr %8, align 4, !tbaa !20
  call void asm sideeffect "nop", ""()
  %159 = ptrtoint ptr %158 to i32
  %160 = sub i32 %156, %159
  %161 = add i32 %152, -1
  %162 = icmp ugt i32 %160, %161
  br i1 %162, label %163, label %226

163:                                              ; preds = %139
  %164 = icmp ult i32 %149, 17
  %165 = icmp ugt i32 %152, 7
  %166 = and i1 %164, %165
  %167 = icmp ugt i32 %157, 15
  %168 = select i1 %166, i1 %167, i1 false
  br i1 %168, label %169, label %174

169:                                              ; preds = %163
  %170 = sub i32 0, %152
  %171 = getelementptr inbounds i8, ptr %153, i32 %170
  call fastcc void @unaligned_copy64(ptr noundef nonnull %171, ptr noundef %153) #31
  %172 = getelementptr inbounds i8, ptr %171, i32 8
  %173 = getelementptr inbounds i8, ptr %153, i32 8
  call fastcc void @unaligned_copy64(ptr noundef nonnull %172, ptr noundef nonnull %173) #31
  br label %213

174:                                              ; preds = %163
  %175 = add nuw nsw i32 %149, 10
  %176 = icmp ult i32 %157, %175
  br i1 %176, label %199, label %177

177:                                              ; preds = %174
  %178 = sub i32 0, %152
  %179 = getelementptr inbounds i8, ptr %153, i32 %178
  %180 = ptrtoint ptr %179 to i32
  br label %181

181:                                              ; preds = %187, %177
  %182 = phi ptr [ %153, %177 ], [ %189, %187 ]
  %183 = phi i32 [ %149, %177 ], [ %188, %187 ]
  %184 = ptrtoint ptr %182 to i32
  %185 = sub i32 %184, %180
  %186 = icmp slt i32 %185, 8
  br i1 %186, label %187, label %190

187:                                              ; preds = %181
  call fastcc void @unaligned_copy64(ptr noundef %179, ptr noundef %182) #31
  %188 = sub nsw i32 %183, %185
  %189 = getelementptr inbounds i8, ptr %182, i32 %185
  br label %181, !llvm.loop !38

190:                                              ; preds = %181, %195
  %191 = phi ptr [ %196, %195 ], [ %179, %181 ]
  %192 = phi ptr [ %197, %195 ], [ %182, %181 ]
  %193 = phi i32 [ %198, %195 ], [ %183, %181 ]
  %194 = icmp sgt i32 %193, 0
  br i1 %194, label %195, label %213

195:                                              ; preds = %190
  call fastcc void @unaligned_copy64(ptr noundef %191, ptr noundef %192) #31
  %196 = getelementptr inbounds i8, ptr %191, i32 8
  %197 = getelementptr inbounds i8, ptr %192, i32 8
  %198 = add nsw i32 %193, -8
  br label %190, !llvm.loop !39

199:                                              ; preds = %174
  %200 = icmp ult i32 %157, %149
  br i1 %200, label %226, label %201

201:                                              ; preds = %199
  %202 = sub i32 0, %152
  %203 = getelementptr inbounds i8, ptr %153, i32 %202
  br label %204

204:                                              ; preds = %204, %201
  %205 = phi ptr [ %203, %201 ], [ %208, %204 ]
  %206 = phi ptr [ %153, %201 ], [ %210, %204 ]
  %207 = phi i32 [ %149, %201 ], [ %211, %204 ]
  %208 = getelementptr inbounds i8, ptr %205, i32 1
  %209 = load i8, ptr %205, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %210 = getelementptr inbounds i8, ptr %206, i32 1
  store i8 %209, ptr %206, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %211 = add nsw i32 %207, -1
  %212 = icmp ugt i32 %207, 1
  br i1 %212, label %204, label %213, !llvm.loop !40

213:                                              ; preds = %190, %204, %169
  %214 = getelementptr inbounds i8, ptr %153, i32 %149
  store ptr %214, ptr %10, align 4, !tbaa !22
  call void asm sideeffect "nop", ""()
  %215 = load ptr, ptr %13, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  %216 = ptrtoint ptr %215 to i32
  %217 = ptrtoint ptr %150 to i32
  %218 = sub i32 %216, %217
  %219 = icmp slt i32 %218, 5
  br i1 %219, label %220, label %224

220:                                              ; preds = %213
  store ptr %150, ptr %12, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  %221 = call fastcc zeroext i1 @refill_tag(ptr noundef nonnull %6) #31
  br i1 %221, label %222, label %226

222:                                              ; preds = %220, %137, %88
  %223 = load ptr, ptr %12, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  br label %224

224:                                              ; preds = %222, %213, %130, %78
  %225 = phi ptr [ %131, %130 ], [ %82, %78 ], [ %150, %213 ], [ %223, %222 ]
  br label %43

226:                                              ; preds = %220, %199, %139, %137, %128, %88, %50, %116, %114, %38
  %227 = load ptr, ptr %6, align 4, !tbaa !23
  call void asm sideeffect "nop", ""()
  %228 = load i32, ptr %14, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  %229 = getelementptr inbounds %struct.source, ptr %227, i32 0, i32 1
  %230 = load i32, ptr %229, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %231 = sub i32 %230, %228
  store i32 %231, ptr %229, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %232 = load ptr, ptr %227, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  %233 = getelementptr inbounds i8, ptr %232, i32 %228
  store ptr %233, ptr %227, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  %234 = load i8, ptr %15, align 4, !tbaa !29, !range !41, !noundef !3
  call void asm sideeffect "nop", ""()
  %235 = icmp eq i8 %234, 0
  br i1 %235, label %240, label %236

236:                                              ; preds = %226
  %237 = load ptr, ptr %10, align 4, !tbaa !22
  call void asm sideeffect "nop", ""()
  %238 = load ptr, ptr %11, align 4, !tbaa !33
  call void asm sideeffect "nop", ""()
  %239 = icmp eq ptr %237, %238
  br i1 %239, label %242, label %240

240:                                              ; preds = %236, %226
  br label %242

241:                                              ; preds = %18
  store i32 %20, ptr %9, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  store ptr %19, ptr %7, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  br label %242

242:                                              ; preds = %241, %236, %240
  %243 = phi i32 [ -5, %240 ], [ 0, %236 ], [ -5, %241 ]
  call void @llvm.lifetime.end.p0(i64 24, ptr nonnull %6) #29
  call void @llvm.lifetime.end.p0(i64 12, ptr nonnull %8) #29
  call void @llvm.lifetime.end.p0(i64 8, ptr nonnull %7) #29
  ret i32 %243
}

; Function Attrs: minsize nounwind optsize
define internal fastcc noundef zeroext i1 @refill_tag(ptr noundef %0) unnamed_addr #22 {
  %2 = getelementptr inbounds %struct.snappy_decompressor, ptr %0, i32 0, i32 1
  %3 = load ptr, ptr %2, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  %4 = getelementptr inbounds %struct.snappy_decompressor, ptr %0, i32 0, i32 2
  %5 = load ptr, ptr %4, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  %6 = icmp eq ptr %3, %5
  br i1 %6, label %7, label %21

7:                                                ; preds = %1
  %8 = load ptr, ptr %0, align 4, !tbaa !23
  call void asm sideeffect "nop", ""()
  %9 = getelementptr inbounds %struct.snappy_decompressor, ptr %0, i32 0, i32 3
  %10 = load i32, ptr %9, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  %11 = getelementptr inbounds %struct.source, ptr %8, i32 0, i32 1
  %12 = load i32, ptr %11, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %13 = sub i32 %12, %10
  store i32 %13, ptr %11, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %14 = load ptr, ptr %8, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  %15 = getelementptr inbounds i8, ptr %14, i32 %10
  store ptr %15, ptr %8, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  store i32 %13, ptr %9, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  %16 = icmp eq i32 %12, %10
  br i1 %16, label %17, label %19

17:                                               ; preds = %7
  %18 = getelementptr inbounds %struct.snappy_decompressor, ptr %0, i32 0, i32 4
  store i8 1, ptr %18, align 4, !tbaa !29
  call void asm sideeffect "nop", ""()
  br label %82

19:                                               ; preds = %7
  %20 = getelementptr inbounds i8, ptr %14, i32 %12
  store ptr %20, ptr %4, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  br label %21

21:                                               ; preds = %19, %1
  %22 = phi ptr [ %20, %19 ], [ %5, %1 ]
  %23 = phi ptr [ %15, %19 ], [ %3, %1 ]
  %24 = load i8, ptr %23, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %25 = zext i8 %24 to i32
  %26 = getelementptr inbounds [256 x i16], ptr @char_table, i32 0, i32 %25
  %27 = load i16, ptr %26, align 2, !tbaa !36
  call void asm sideeffect "nop", ""()
  %28 = lshr i16 %27, 11
  %29 = add nuw nsw i16 %28, 1
  %30 = zext nneg i16 %29 to i32
  %31 = ptrtoint ptr %22 to i32
  %32 = ptrtoint ptr %23 to i32
  %33 = sub i32 %31, %32
  %34 = icmp ult i32 %33, %30
  br i1 %34, label %35, label %67

35:                                               ; preds = %21
  %36 = getelementptr inbounds %struct.snappy_decompressor, ptr %0, i32 0, i32 5
  %37 = tail call ptr @memmove(ptr noundef nonnull %36, ptr noundef nonnull %23, i32 noundef %33) #30
  %38 = load ptr, ptr %0, align 4, !tbaa !23
  call void asm sideeffect "nop", ""()
  %39 = getelementptr inbounds %struct.snappy_decompressor, ptr %0, i32 0, i32 3
  %40 = load i32, ptr %39, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  %41 = getelementptr inbounds %struct.source, ptr %38, i32 0, i32 1
  %42 = load i32, ptr %41, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %43 = sub i32 %42, %40
  store i32 %43, ptr %41, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %44 = load ptr, ptr %38, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  %45 = getelementptr inbounds i8, ptr %44, i32 %40
  store ptr %45, ptr %38, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  store i32 0, ptr %39, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  br label %46

46:                                               ; preds = %53, %35
  %47 = phi ptr [ %45, %35 ], [ %64, %53 ]
  %48 = phi i32 [ %43, %35 ], [ %62, %53 ]
  %49 = phi i32 [ %33, %35 ], [ %58, %53 ]
  %50 = icmp ult i32 %49, %30
  br i1 %50, label %51, label %65

51:                                               ; preds = %46
  %52 = icmp eq i32 %48, 0
  br i1 %52, label %82, label %53

53:                                               ; preds = %51
  %54 = sub nsw i32 %30, %49
  %55 = tail call i32 @llvm.umin.i32(i32 %54, i32 %48)
  %56 = getelementptr inbounds i8, ptr %36, i32 %49
  %57 = tail call ptr @memcpy(ptr noundef nonnull %56, ptr noundef %47, i32 noundef %55) #30
  %58 = add i32 %55, %49
  %59 = load ptr, ptr %0, align 4, !tbaa !23
  call void asm sideeffect "nop", ""()
  %60 = getelementptr inbounds %struct.source, ptr %59, i32 0, i32 1
  %61 = load i32, ptr %60, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %62 = sub i32 %61, %55
  store i32 %62, ptr %60, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %63 = load ptr, ptr %59, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  %64 = getelementptr inbounds i8, ptr %63, i32 %55
  store ptr %64, ptr %59, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  br label %46, !llvm.loop !42

65:                                               ; preds = %46
  store ptr %36, ptr %2, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  %66 = getelementptr inbounds i8, ptr %36, i32 %30
  store ptr %66, ptr %4, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  br label %82

67:                                               ; preds = %21
  %68 = icmp ult i32 %33, 5
  br i1 %68, label %69, label %81

69:                                               ; preds = %67
  %70 = getelementptr inbounds %struct.snappy_decompressor, ptr %0, i32 0, i32 5
  %71 = tail call ptr @memmove(ptr noundef nonnull %70, ptr noundef nonnull %23, i32 noundef %33) #30
  %72 = load ptr, ptr %0, align 4, !tbaa !23
  call void asm sideeffect "nop", ""()
  %73 = getelementptr inbounds %struct.snappy_decompressor, ptr %0, i32 0, i32 3
  %74 = load i32, ptr %73, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  %75 = getelementptr inbounds %struct.source, ptr %72, i32 0, i32 1
  %76 = load i32, ptr %75, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %77 = sub i32 %76, %74
  store i32 %77, ptr %75, align 4, !tbaa !30
  call void asm sideeffect "nop", ""()
  %78 = load ptr, ptr %72, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  %79 = getelementptr inbounds i8, ptr %78, i32 %74
  store ptr %79, ptr %72, align 4, !tbaa !32
  call void asm sideeffect "nop", ""()
  store i32 0, ptr %73, align 4, !tbaa !28
  call void asm sideeffect "nop", ""()
  store ptr %70, ptr %2, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  %80 = getelementptr inbounds i8, ptr %70, i32 %33
  store ptr %80, ptr %4, align 4, !tbaa !27
  call void asm sideeffect "nop", ""()
  br label %82

81:                                               ; preds = %67
  store ptr %23, ptr %2, align 4, !tbaa !26
  call void asm sideeffect "nop", ""()
  br label %82

82:                                               ; preds = %51, %17, %69, %81, %65
  %83 = phi i1 [ true, %69 ], [ true, %81 ], [ true, %65 ], [ false, %17 ], [ false, %51 ]
  ret i1 %83
}

; Function Attrs: inlinehint minsize nounwind optsize
define internal fastcc void @unaligned_copy64(ptr noundef %0, ptr noundef %1) unnamed_addr #23 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %3) #29
  %5 = call ptr @memcpy(ptr noundef nonnull %3, ptr noundef %0, i32 noundef 4) #30
  %6 = call ptr @memcpy(ptr noundef %1, ptr noundef nonnull %3, i32 noundef 4) #30
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %3) #29
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %4) #29
  %7 = getelementptr inbounds i8, ptr %0, i32 4
  %8 = call ptr @memcpy(ptr noundef nonnull %4, ptr noundef nonnull %7, i32 noundef 4) #30
  %9 = getelementptr inbounds i8, ptr %1, i32 4
  %10 = call ptr @memcpy(ptr noundef nonnull %9, ptr noundef nonnull %4, i32 noundef 4) #30
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %4) #29
  ret void
}

; Function Attrs: inlinehint minsize nounwind optsize
define internal fastcc noundef zeroext i1 @writer_append(ptr nocapture noundef %0, ptr noundef %1, i32 noundef %2) unnamed_addr #23 {
  %4 = getelementptr inbounds %struct.writer, ptr %0, i32 0, i32 1
  %5 = load ptr, ptr %4, align 4, !tbaa !22
  call void asm sideeffect "nop", ""()
  %6 = getelementptr inbounds %struct.writer, ptr %0, i32 0, i32 2
  %7 = load ptr, ptr %6, align 4, !tbaa !33
  call void asm sideeffect "nop", ""()
  %8 = ptrtoint ptr %7 to i32
  %9 = ptrtoint ptr %5 to i32
  %10 = sub i32 %8, %9
  %11 = icmp uge i32 %10, %2
  br i1 %11, label %12, label %15

12:                                               ; preds = %3
  %13 = tail call ptr @memcpy(ptr noundef %5, ptr noundef %1, i32 noundef %2) #30
  %14 = getelementptr inbounds i8, ptr %5, i32 %2
  store ptr %14, ptr %4, align 4, !tbaa !22
  call void asm sideeffect "nop", ""()
  br label %15

15:                                               ; preds = %3, %12
  ret i1 %11
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.umin.i32(i32, i32) #24

; Function Attrs: minsize nounwind optsize
define hidden i32 @snappy_init_env(ptr noundef %0) local_unnamed_addr #22 {
  tail call fastcc void @clear_env(ptr noundef %0) #31
  %2 = tail call ptr @malloc(i32 noundef 32768) #30
  store ptr %2, ptr %0, align 4, !tbaa !15
  call void asm sideeffect "nop", ""()
  %3 = icmp eq ptr %2, null
  %4 = select i1 %3, i32 -12, i32 0
  ret i32 %4
}

; Function Attrs: inlinehint minsize nounwind optsize
define internal fastcc void @clear_env(ptr noundef %0) unnamed_addr #23 {
  %2 = tail call ptr @memset(ptr noundef %0, i32 noundef 0, i32 noundef 12) #30
  ret void
}

; Function Attrs: minsize nounwind optsize
define hidden noundef i32 @snappy_compress(ptr nocapture noundef readonly %0, ptr noundef %1, i32 noundef %2, ptr noundef %3, ptr nocapture noundef writeonly %4) local_unnamed_addr #22 {
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  %8 = alloca i32, align 4
  %9 = alloca i32, align 4
  %10 = alloca i32, align 4
  %11 = alloca i32, align 4
  %12 = alloca i32, align 4
  %13 = alloca [5 x i8], align 1
  %14 = alloca %struct.sink, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %14) #29
  store ptr %3, ptr %14, align 4, !tbaa !43
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.start.p0(i64 5, ptr nonnull %13) #29
  %15 = icmp ult i32 %2, 128
  br i1 %15, label %16, label %19

16:                                               ; preds = %5
  %17 = trunc i32 %2 to i8
  %18 = getelementptr inbounds i8, ptr %13, i32 1
  store i8 %17, ptr %13, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  br label %64

19:                                               ; preds = %5
  %20 = icmp ult i32 %2, 16384
  br i1 %20, label %21, label %28

21:                                               ; preds = %19
  %22 = trunc i32 %2 to i8
  %23 = or i8 %22, -128
  %24 = getelementptr inbounds i8, ptr %13, i32 1
  store i8 %23, ptr %13, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %25 = lshr i32 %2, 7
  %26 = trunc i32 %25 to i8
  %27 = getelementptr inbounds i8, ptr %13, i32 2
  store i8 %26, ptr %24, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  br label %64

28:                                               ; preds = %19
  %29 = icmp ult i32 %2, 2097152
  br i1 %29, label %30, label %41

30:                                               ; preds = %28
  %31 = trunc i32 %2 to i8
  %32 = or i8 %31, -128
  %33 = getelementptr inbounds i8, ptr %13, i32 1
  store i8 %32, ptr %13, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %34 = lshr i32 %2, 7
  %35 = trunc i32 %34 to i8
  %36 = or i8 %35, -128
  %37 = getelementptr inbounds i8, ptr %13, i32 2
  store i8 %36, ptr %33, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %38 = lshr i32 %2, 14
  %39 = trunc i32 %38 to i8
  %40 = getelementptr inbounds i8, ptr %13, i32 3
  store i8 %39, ptr %37, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  br label %64

41:                                               ; preds = %28
  %42 = icmp ult i32 %2, 268435456
  %43 = trunc i32 %2 to i8
  %44 = or i8 %43, -128
  %45 = getelementptr inbounds i8, ptr %13, i32 1
  store i8 %44, ptr %13, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %46 = lshr i32 %2, 7
  %47 = trunc i32 %46 to i8
  %48 = or i8 %47, -128
  %49 = getelementptr inbounds i8, ptr %13, i32 2
  store i8 %48, ptr %45, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %50 = lshr i32 %2, 14
  %51 = trunc i32 %50 to i8
  %52 = or i8 %51, -128
  %53 = getelementptr inbounds i8, ptr %13, i32 3
  store i8 %52, ptr %49, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %54 = lshr i32 %2, 21
  %55 = trunc i32 %54 to i8
  br i1 %42, label %56, label %58

56:                                               ; preds = %41
  %57 = getelementptr inbounds i8, ptr %13, i32 4
  store i8 %55, ptr %53, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  br label %64

58:                                               ; preds = %41
  %59 = or i8 %55, -128
  %60 = getelementptr inbounds i8, ptr %13, i32 4
  store i8 %59, ptr %53, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %61 = lshr i32 %2, 28
  %62 = trunc i32 %61 to i8
  %63 = getelementptr inbounds i8, ptr %13, i32 5
  store i8 %62, ptr %60, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  br label %64

64:                                               ; preds = %58, %56, %30, %21, %16
  %65 = phi ptr [ %18, %16 ], [ %27, %21 ], [ %40, %30 ], [ %57, %56 ], [ %63, %58 ]
  %66 = ptrtoint ptr %65 to i32
  %67 = ptrtoint ptr %13 to i32
  %68 = sub i32 %66, %67
  call fastcc void @append(ptr noundef nonnull %14, ptr noundef nonnull %13, i32 noundef %68) #31
  %69 = getelementptr inbounds %struct.writer, ptr %0, i32 0, i32 1
  %70 = getelementptr inbounds %struct.writer, ptr %0, i32 0, i32 2
  br label %71

71:                                               ; preds = %247, %64
  %72 = phi i32 [ %2, %64 ], [ %253, %247 ]
  %73 = phi ptr [ %1, %64 ], [ %254, %247 ]
  %74 = phi i32 [ %2, %64 ], [ %252, %247 ]
  %75 = icmp sgt i32 %74, 0
  br i1 %75, label %76, label %255

76:                                               ; preds = %71
  %77 = icmp eq i32 %72, 0
  br i1 %77, label %255, label %78

78:                                               ; preds = %76
  %79 = call i32 @llvm.smin.i32(i32 %74, i32 65536)
  %80 = icmp ult i32 %72, %79
  br i1 %80, label %81, label %91

81:                                               ; preds = %78
  %82 = load ptr, ptr %69, align 4, !tbaa !45
  call void asm sideeffect "nop", ""()
  %83 = call ptr @memcpy(ptr noundef %82, ptr noundef %73, i32 noundef %72) #30
  br label %84

84:                                               ; preds = %81, %84
  %85 = phi ptr [ %73, %81 ], [ %87, %84 ]
  %86 = phi i32 [ %72, %81 ], [ 0, %84 ]
  %87 = getelementptr inbounds i8, ptr %85, i32 %86
  %88 = load ptr, ptr %69, align 4, !tbaa !45
  call void asm sideeffect "nop", ""()
  %89 = getelementptr inbounds i8, ptr %88, i32 %72
  %90 = call ptr @memcpy(ptr noundef nonnull %89, ptr noundef %87, i32 noundef 0) #30
  br label %84, !llvm.loop !46

91:                                               ; preds = %78
  %92 = call i32 @llvm.umin.i32(i32 %79, i32 16384)
  br label %93

93:                                               ; preds = %93, %91
  %94 = phi i32 [ 256, %91 ], [ %96, %93 ]
  %95 = icmp ult i32 %94, %92
  %96 = shl i32 %94, 1
  br i1 %95, label %93, label %97, !llvm.loop !47

97:                                               ; preds = %93
  %98 = load ptr, ptr %0, align 4, !tbaa !15
  call void asm sideeffect "nop", ""()
  %99 = call ptr @memset(ptr noundef %98, i32 noundef 0, i32 noundef %96) #30
  %100 = load ptr, ptr %14, align 4, !tbaa !43
  call void asm sideeffect "nop", ""()
  %101 = icmp eq ptr %100, null
  br i1 %101, label %102, label %104

102:                                              ; preds = %97
  %103 = load ptr, ptr %70, align 4, !tbaa !48
  call void asm sideeffect "nop", ""()
  br label %104

104:                                              ; preds = %102, %97
  %105 = phi ptr [ %100, %97 ], [ %103, %102 ]
  %106 = call i32 @llvm.ctlz.i32(i32 %94, i1 false), !range !49
  %107 = xor i32 %106, 31
  %108 = sub nuw nsw i32 32, %107
  %109 = getelementptr inbounds i8, ptr %73, i32 %79
  %110 = icmp sgt i32 %74, 14
  br i1 %110, label %111, label %238, !prof !50

111:                                              ; preds = %104
  %112 = getelementptr inbounds i8, ptr %109, i32 -15
  %113 = getelementptr inbounds i8, ptr %73, i32 1
  %114 = call fastcc i32 @hash(ptr noundef nonnull %113, i32 noundef %108) #31
  %115 = ptrtoint ptr %73 to i32
  %116 = getelementptr inbounds i8, ptr %109, i32 -4
  br label %117

117:                                              ; preds = %233, %111
  %118 = phi i32 [ %114, %111 ], [ %236, %233 ]
  %119 = phi ptr [ %73, %111 ], [ %202, %233 ]
  %120 = phi ptr [ %113, %111 ], [ %237, %233 ]
  %121 = phi ptr [ %105, %111 ], [ %210, %233 ]
  br label %122

122:                                              ; preds = %129, %117
  %123 = phi ptr [ %120, %117 ], [ %127, %129 ]
  %124 = phi i32 [ 32, %117 ], [ %130, %129 ]
  %125 = phi i32 [ %118, %117 ], [ %131, %129 ]
  %126 = lshr i32 %124, 5
  %127 = getelementptr inbounds i8, ptr %123, i32 %126
  %128 = icmp ugt ptr %127, %112
  br i1 %128, label %238, label %129, !prof !34

129:                                              ; preds = %122
  %130 = add i32 %124, 1
  %131 = call fastcc i32 @hash(ptr noundef %127, i32 noundef %108) #31
  %132 = getelementptr inbounds i16, ptr %98, i32 %125
  %133 = load i16, ptr %132, align 2, !tbaa !36
  call void asm sideeffect "nop", ""()
  %134 = zext i16 %133 to i32
  %135 = getelementptr inbounds i8, ptr %73, i32 %134
  %136 = ptrtoint ptr %123 to i32
  %137 = sub i32 %136, %115
  %138 = trunc i32 %137 to i16
  store i16 %138, ptr %132, align 2, !tbaa !36
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %10) #29
  %139 = call ptr @memcpy(ptr noundef nonnull %10, ptr noundef %123, i32 noundef 4) #30
  %140 = load i32, ptr %10, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %10) #29
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %11) #29
  %141 = call ptr @memcpy(ptr noundef nonnull %11, ptr noundef %135, i32 noundef 4) #30
  %142 = load i32, ptr %11, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %11) #29
  %143 = icmp eq i32 %140, %142
  br i1 %143, label %144, label %122, !prof !34, !llvm.loop !51

144:                                              ; preds = %129
  %145 = ptrtoint ptr %119 to i32
  %146 = sub i32 %136, %145
  %147 = call fastcc ptr @emit_literal(ptr noundef %121, ptr noundef %119, i32 noundef %146, i1 noundef zeroext true) #31
  br label %148

148:                                              ; preds = %212, %144
  %149 = phi ptr [ %135, %144 ], [ %228, %212 ]
  %150 = phi ptr [ %123, %144 ], [ %202, %212 ]
  %151 = phi ptr [ %147, %144 ], [ %210, %212 ]
  %152 = getelementptr inbounds i8, ptr %149, i32 4
  br label %153

153:                                              ; preds = %165, %148
  %154 = phi i32 [ 0, %148 ], [ %166, %165 ]
  %155 = phi ptr [ %150, %148 ], [ %156, %165 ]
  %156 = getelementptr inbounds i8, ptr %155, i32 4
  %157 = icmp ugt ptr %156, %116
  br i1 %157, label %176, label %158

158:                                              ; preds = %153
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %6) #29
  %159 = call ptr @memcpy(ptr noundef nonnull %6, ptr noundef nonnull %156, i32 noundef 4) #30
  %160 = load i32, ptr %6, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %6) #29
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %7) #29
  %161 = getelementptr inbounds i8, ptr %152, i32 %154
  %162 = call ptr @memcpy(ptr noundef nonnull %7, ptr noundef nonnull %161, i32 noundef 4) #30
  %163 = load i32, ptr %7, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %7) #29
  %164 = icmp eq i32 %160, %163
  br i1 %164, label %165, label %167

165:                                              ; preds = %158
  %166 = add nuw nsw i32 %154, 4
  br label %153, !llvm.loop !52

167:                                              ; preds = %158
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %8) #29
  %168 = call ptr @memcpy(ptr noundef nonnull %8, ptr noundef nonnull %156, i32 noundef 4) #30
  %169 = load i32, ptr %8, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %8) #29
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %9) #29
  %170 = call ptr @memcpy(ptr noundef nonnull %9, ptr noundef nonnull %161, i32 noundef 4) #30
  %171 = load i32, ptr %9, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %9) #29
  %172 = xor i32 %171, %169
  %173 = call i32 @llvm.cttz.i32(i32 %172, i1 false), !range !49
  %174 = lshr i32 %173, 3
  %175 = add nuw nsw i32 %174, %154
  br label %188

176:                                              ; preds = %153, %185
  %177 = phi i32 [ %187, %185 ], [ %154, %153 ]
  %178 = phi ptr [ %186, %185 ], [ %156, %153 ]
  %179 = icmp ult ptr %178, %109
  br i1 %179, label %180, label %188

180:                                              ; preds = %176
  %181 = getelementptr inbounds i8, ptr %152, i32 %177
  %182 = load i8, ptr %181, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %183 = load i8, ptr %178, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %184 = icmp eq i8 %182, %183
  br i1 %184, label %185, label %188

185:                                              ; preds = %180
  %186 = getelementptr inbounds i8, ptr %178, i32 1
  %187 = add nuw nsw i32 %177, 1
  br label %176, !llvm.loop !53

188:                                              ; preds = %180, %176, %167
  %189 = phi i32 [ %175, %167 ], [ %177, %176 ], [ %177, %180 ]
  %190 = add nsw i32 %189, 4
  %191 = ptrtoint ptr %150 to i32
  %192 = ptrtoint ptr %149 to i32
  %193 = sub i32 %191, %192
  br label %194

194:                                              ; preds = %198, %188
  %195 = phi ptr [ %151, %188 ], [ %199, %198 ]
  %196 = phi i32 [ %190, %188 ], [ %200, %198 ]
  %197 = icmp sgt i32 %196, 67
  br i1 %197, label %198, label %201

198:                                              ; preds = %194
  %199 = call fastcc ptr @emit_copy_less_than64(ptr noundef %195, i32 noundef %193, i32 noundef 64) #31
  %200 = add nsw i32 %196, -64
  br label %194, !llvm.loop !54

201:                                              ; preds = %194
  %202 = getelementptr inbounds i8, ptr %150, i32 %190
  %203 = icmp sgt i32 %196, 64
  br i1 %203, label %204, label %207

204:                                              ; preds = %201
  %205 = call fastcc ptr @emit_copy_less_than64(ptr noundef %195, i32 noundef %193, i32 noundef 60) #31
  %206 = add nsw i32 %196, -60
  br label %207

207:                                              ; preds = %204, %201
  %208 = phi ptr [ %205, %204 ], [ %195, %201 ]
  %209 = phi i32 [ %206, %204 ], [ %196, %201 ]
  %210 = call fastcc nonnull ptr @emit_copy_less_than64(ptr noundef %208, i32 noundef %193, i32 noundef %209) #31
  %211 = icmp ult ptr %202, %112
  br i1 %211, label %212, label %238, !prof !50

212:                                              ; preds = %207
  %213 = getelementptr inbounds i8, ptr %202, i32 -1
  %214 = call fastcc i32 @get_u32_at_offset(ptr noundef nonnull %213, i32 noundef 0) #31
  %215 = mul i32 %214, 506832829
  %216 = lshr i32 %215, %108
  %217 = ptrtoint ptr %202 to i32
  %218 = sub i32 %217, %115
  %219 = trunc i32 %218 to i16
  %220 = add i16 %219, -1
  %221 = getelementptr inbounds i16, ptr %98, i32 %216
  store i16 %220, ptr %221, align 2, !tbaa !36
  call void asm sideeffect "nop", ""()
  %222 = call fastcc i32 @get_u32_at_offset(ptr noundef nonnull %213, i32 noundef 1) #31
  %223 = mul i32 %222, 506832829
  %224 = lshr i32 %223, %108
  %225 = getelementptr inbounds i16, ptr %98, i32 %224
  %226 = load i16, ptr %225, align 2, !tbaa !36
  call void asm sideeffect "nop", ""()
  %227 = zext i16 %226 to i32
  %228 = getelementptr inbounds i8, ptr %73, i32 %227
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %12) #29
  %229 = call ptr @memcpy(ptr noundef nonnull %12, ptr noundef %228, i32 noundef 4) #30
  %230 = load i32, ptr %12, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %12) #29
  store i16 %219, ptr %225, align 2, !tbaa !36
  call void asm sideeffect "nop", ""()
  %231 = call fastcc i32 @get_u32_at_offset(ptr noundef nonnull %213, i32 noundef 1) #31
  %232 = icmp eq i32 %231, %230
  br i1 %232, label %148, label %233, !llvm.loop !55

233:                                              ; preds = %212
  %234 = call fastcc i32 @get_u32_at_offset(ptr noundef nonnull %213, i32 noundef 2) #31
  %235 = mul i32 %234, 506832829
  %236 = lshr i32 %235, %108
  %237 = getelementptr inbounds i8, ptr %202, i32 1
  br label %117

238:                                              ; preds = %122, %207, %104
  %239 = phi ptr [ %73, %104 ], [ %202, %207 ], [ %119, %122 ]
  %240 = phi ptr [ %105, %104 ], [ %210, %207 ], [ %121, %122 ]
  %241 = icmp ult ptr %239, %109
  br i1 %241, label %242, label %247

242:                                              ; preds = %238
  %243 = ptrtoint ptr %109 to i32
  %244 = ptrtoint ptr %239 to i32
  %245 = sub i32 %243, %244
  %246 = call fastcc ptr @emit_literal(ptr noundef %240, ptr noundef %239, i32 noundef %245, i1 noundef zeroext false) #31
  br label %247

247:                                              ; preds = %242, %238
  %248 = phi ptr [ %246, %242 ], [ %240, %238 ]
  %249 = ptrtoint ptr %248 to i32
  %250 = ptrtoint ptr %105 to i32
  %251 = sub i32 %249, %250
  call fastcc void @append(ptr noundef nonnull %14, ptr noundef %105, i32 noundef %251) #31
  %252 = sub nsw i32 %74, %79
  %253 = sub i32 %72, %79
  %254 = getelementptr inbounds i8, ptr %73, i32 %79
  br label %71

255:                                              ; preds = %71, %76
  %256 = phi i32 [ 0, %71 ], [ -5, %76 ]
  call void @llvm.lifetime.end.p0(i64 5, ptr nonnull %13) #29
  %257 = load ptr, ptr %14, align 4, !tbaa !43
  call void asm sideeffect "nop", ""()
  %258 = ptrtoint ptr %257 to i32
  %259 = ptrtoint ptr %3 to i32
  %260 = sub i32 %258, %259
  store i32 %260, ptr %4, align 4, !tbaa !11
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %14) #29
  ret i32 %256
}

; Function Attrs: inlinehint minsize nounwind optsize
define internal fastcc void @append(ptr nocapture noundef %0, ptr noundef %1, i32 noundef %2) unnamed_addr #23 {
  %4 = load ptr, ptr %0, align 4, !tbaa !43
  call void asm sideeffect "nop", ""()
  %5 = icmp eq ptr %4, %1
  br i1 %5, label %9, label %6

6:                                                ; preds = %3
  %7 = tail call ptr @memcpy(ptr noundef %4, ptr noundef %1, i32 noundef %2) #30
  %8 = load ptr, ptr %0, align 4, !tbaa !43
  call void asm sideeffect "nop", ""()
  br label %9

9:                                                ; preds = %6, %3
  %10 = phi ptr [ %8, %6 ], [ %1, %3 ]
  %11 = getelementptr inbounds i8, ptr %10, i32 %2
  store ptr %11, ptr %0, align 4, !tbaa !43
  call void asm sideeffect "nop", ""()
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smin.i32(i32, i32) #24

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.ctlz.i32(i32, i1 immarg) #24

; Function Attrs: inlinehint minsize nounwind optsize
define internal fastcc i32 @hash(ptr noundef %0, i32 noundef %1) unnamed_addr #23 {
  %3 = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %3) #29
  %4 = call ptr @memcpy(ptr noundef nonnull %3, ptr noundef %0, i32 noundef 4) #30
  %5 = load i32, ptr %3, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %3) #29
  %6 = mul i32 %5, 506832829
  %7 = lshr i32 %6, %1
  ret i32 %7
}

; Function Attrs: inlinehint minsize nounwind optsize
define internal fastcc nonnull ptr @emit_literal(ptr noundef %0, ptr noundef %1, i32 noundef %2, i1 noundef zeroext %3) unnamed_addr #23 {
  %5 = add nsw i32 %2, -1
  %6 = icmp slt i32 %2, 61
  br i1 %6, label %7, label %16

7:                                                ; preds = %4
  %8 = trunc i32 %5 to i8
  %9 = shl i8 %8, 2
  %10 = getelementptr inbounds i8, ptr %0, i32 1
  store i8 %9, ptr %0, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %11 = icmp slt i32 %2, 17
  %12 = and i1 %11, %3
  br i1 %12, label %13, label %30

13:                                               ; preds = %7
  tail call fastcc void @unaligned_copy64(ptr noundef %1, ptr noundef nonnull %10) #31
  %14 = getelementptr inbounds i8, ptr %1, i32 8
  %15 = getelementptr inbounds i8, ptr %0, i32 9
  tail call fastcc void @unaligned_copy64(ptr noundef nonnull %14, ptr noundef nonnull %15) #31
  br label %33

16:                                               ; preds = %4, %22
  %17 = phi ptr [ %20, %22 ], [ %0, %4 ]
  %18 = phi i32 [ %24, %22 ], [ %5, %4 ]
  %19 = phi i32 [ %25, %22 ], [ 0, %4 ]
  %20 = getelementptr inbounds i8, ptr %17, i32 1
  %21 = icmp sgt i32 %18, 0
  br i1 %21, label %22, label %26

22:                                               ; preds = %16
  %23 = trunc i32 %18 to i8
  store i8 %23, ptr %20, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %24 = lshr i32 %18, 8
  %25 = add nuw nsw i32 %19, 1
  br label %16, !llvm.loop !56

26:                                               ; preds = %16
  %27 = trunc i32 %19 to i8
  %28 = shl i8 %27, 2
  %29 = add i8 %28, -20
  store i8 %29, ptr %0, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  br label %30

30:                                               ; preds = %7, %26
  %31 = phi ptr [ %10, %7 ], [ %20, %26 ]
  %32 = tail call ptr @memcpy(ptr noundef nonnull %31, ptr noundef %1, i32 noundef %2) #30
  br label %33

33:                                               ; preds = %30, %13
  %34 = phi ptr [ %10, %13 ], [ %31, %30 ]
  %35 = getelementptr inbounds i8, ptr %34, i32 %2
  ret ptr %35
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.cttz.i32(i32, i1 immarg) #24

; Function Attrs: inlinehint minsize nounwind optsize
define internal fastcc nonnull ptr @emit_copy_less_than64(ptr noundef %0, i32 noundef %1, i32 noundef %2) unnamed_addr #23 {
  %4 = alloca i32, align 4
  %5 = icmp slt i32 %2, 12
  %6 = icmp slt i32 %1, 2048
  %7 = and i1 %6, %5
  br i1 %7, label %8, label %18

8:                                                ; preds = %3
  %9 = shl i32 %2, 2
  %10 = add i32 %9, 241
  %11 = lshr i32 %1, 3
  %12 = and i32 %11, 224
  %13 = add i32 %10, %12
  %14 = trunc i32 %13 to i8
  %15 = getelementptr inbounds i8, ptr %0, i32 1
  store i8 %14, ptr %0, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %16 = trunc i32 %1 to i8
  %17 = getelementptr inbounds i8, ptr %0, i32 2
  store i8 %16, ptr %15, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  br label %25

18:                                               ; preds = %3
  %19 = trunc i32 %2 to i8
  %20 = shl i8 %19, 2
  %21 = add i8 %20, -2
  %22 = getelementptr inbounds i8, ptr %0, i32 1
  store i8 %21, ptr %0, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %4) #29
  store i32 %1, ptr %4, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  %23 = call ptr @memcpy(ptr noundef nonnull %22, ptr noundef nonnull %4, i32 noundef 2) #30
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %4) #29
  %24 = getelementptr inbounds i8, ptr %0, i32 3
  br label %25

25:                                               ; preds = %18, %8
  %26 = phi ptr [ %17, %8 ], [ %24, %18 ]
  ret ptr %26
}

; Function Attrs: inlinehint minsize nounwind optsize
define internal fastcc i32 @get_u32_at_offset(ptr noundef %0, i32 noundef %1) unnamed_addr #23 {
  %3 = alloca i32, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %3) #29
  %4 = getelementptr inbounds i8, ptr %0, i32 %1
  %5 = call ptr @memcpy(ptr noundef nonnull %3, ptr noundef %4, i32 noundef 4) #30
  %6 = load i32, ptr %3, align 4, !tbaa !13
  call void asm sideeffect "nop", ""()
  call void @llvm.lifetime.end.p0(i64 4, ptr nonnull %3) #29
  ret i32 %6
}

; Function Attrs: minsize nofree norecurse nosync nounwind optsize memory(argmem: read)
define hidden i32 @memcmp(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, i32 noundef %2) local_unnamed_addr #25 {
  br label %4

4:                                                ; preds = %7, %3
  %5 = phi i32 [ 0, %3 ], [ %13, %7 ]
  %6 = icmp eq i32 %5, %2
  br i1 %6, label %18, label %7

7:                                                ; preds = %4
  %8 = getelementptr inbounds i8, ptr %0, i32 %5
  %9 = load i8, ptr %8, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %10 = getelementptr inbounds i8, ptr %1, i32 %5
  %11 = load i8, ptr %10, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %12 = icmp eq i8 %9, %11
  %13 = add i32 %5, 1
  br i1 %12, label %4, label %14, !llvm.loop !57

14:                                               ; preds = %7
  %15 = zext i8 %11 to i32
  %16 = zext i8 %9 to i32
  %17 = sub nsw i32 %16, %15
  br label %18

18:                                               ; preds = %4, %14
  %19 = phi i32 [ %17, %14 ], [ 0, %4 ]
  ret i32 %19
}

; Function Attrs: minsize nofree norecurse nosync nounwind optsize memory(argmem: readwrite)
define hidden noundef ptr @memcpy(ptr noundef returned writeonly %0, ptr nocapture noundef readonly %1, i32 noundef %2) local_unnamed_addr #26 {
  br label %4

4:                                                ; preds = %8, %3
  %5 = phi i32 [ 0, %3 ], [ %12, %8 ]
  %6 = icmp eq i32 %5, %2
  br i1 %6, label %7, label %8

7:                                                ; preds = %4
  ret ptr %0

8:                                                ; preds = %4
  %9 = getelementptr inbounds i8, ptr %1, i32 %5
  %10 = load i8, ptr %9, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %11 = getelementptr inbounds i8, ptr %0, i32 %5
  store i8 %10, ptr %11, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %12 = add i32 %5, 1
  br label %4, !llvm.loop !58
}

; Function Attrs: minsize nofree norecurse nosync nounwind optsize memory(argmem: readwrite)
define hidden noundef ptr @memmove(ptr noundef returned writeonly %0, ptr noundef readonly %1, i32 noundef %2) local_unnamed_addr #26 {
  %4 = icmp eq ptr %0, %1
  %5 = icmp eq i32 %2, 0
  %6 = or i1 %4, %5
  br i1 %6, label %25, label %7

7:                                                ; preds = %3
  %8 = icmp ult ptr %0, %1
  br i1 %8, label %9, label %17

9:                                                ; preds = %7, %12
  %10 = phi i32 [ %16, %12 ], [ 0, %7 ]
  %11 = icmp eq i32 %10, %2
  br i1 %11, label %25, label %12

12:                                               ; preds = %9
  %13 = getelementptr inbounds i8, ptr %1, i32 %10
  %14 = load i8, ptr %13, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %15 = getelementptr inbounds i8, ptr %0, i32 %10
  store i8 %14, ptr %15, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %16 = add i32 %10, 1
  br label %9, !llvm.loop !59

17:                                               ; preds = %7, %20
  %18 = phi i32 [ %21, %20 ], [ %2, %7 ]
  %19 = icmp eq i32 %18, 0
  br i1 %19, label %25, label %20

20:                                               ; preds = %17
  %21 = add i32 %18, -1
  %22 = getelementptr inbounds i8, ptr %1, i32 %21
  %23 = load i8, ptr %22, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %24 = getelementptr inbounds i8, ptr %0, i32 %21
  store i8 %23, ptr %24, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  br label %17, !llvm.loop !60

25:                                               ; preds = %17, %9, %3
  ret ptr %0
}

; Function Attrs: minsize nofree norecurse nosync nounwind optsize memory(argmem: write)
define hidden noundef ptr @memset(ptr noundef returned writeonly %0, i32 noundef %1, i32 noundef %2) local_unnamed_addr #27 {
  %4 = trunc i32 %1 to i8
  br label %5

5:                                                ; preds = %9, %3
  %6 = phi i32 [ 0, %3 ], [ %11, %9 ]
  %7 = icmp eq i32 %6, %2
  br i1 %7, label %8, label %9

8:                                                ; preds = %5
  ret ptr %0

9:                                                ; preds = %5
  %10 = getelementptr inbounds i8, ptr %0, i32 %6
  store i8 %4, ptr %10, align 1, !tbaa !4
  call void asm sideeffect "nop", ""()
  %11 = add i32 %6, 1
  br label %5, !llvm.loop !61
}

; Function Attrs: minsize nounwind optsize
define hidden ptr @malloc(i32 noundef %0) local_unnamed_addr #22 {
  %2 = tail call ptr @__mem1_alloc(i32 noundef %0) #30
  ret ptr %2
}

; Function Attrs: minsize optsize
declare ptr @__mem1_alloc(i32 noundef) local_unnamed_addr #28

; Function Attrs: minsize nounwind optsize
define hidden void @free(ptr noundef %0) local_unnamed_addr #22 {
  tail call void @__mem1_free(ptr noundef %0) #30
  ret void
}

; Function Attrs: minsize optsize
declare void @__mem1_free(ptr noundef) local_unnamed_addr #28

; Function Attrs: minsize nounwind optsize
define hidden ptr @calloc(i32 noundef %0, i32 noundef %1) local_unnamed_addr #22 {
  %3 = mul i32 %1, %0
  %4 = tail call ptr @__mem1_alloc(i32 noundef %3) #30
  %5 = icmp eq ptr %4, null
  br i1 %5, label %8, label %6

6:                                                ; preds = %2
  %7 = tail call ptr @memset(ptr noundef nonnull %4, i32 noundef 0, i32 noundef %3) #31
  br label %8

8:                                                ; preds = %6, %2
  ret ptr %4
}

; Function Attrs: minsize nounwind optsize
define hidden ptr @realloc(ptr noundef %0, i32 noundef %1) local_unnamed_addr #22 {
  %3 = icmp eq ptr %0, null
  br i1 %3, label %4, label %6

4:                                                ; preds = %2
  %5 = tail call ptr @__mem1_alloc(i32 noundef %1) #30
  br label %14

6:                                                ; preds = %2
  %7 = icmp eq i32 %1, 0
  br i1 %7, label %8, label %9

8:                                                ; preds = %6
  tail call void @__mem1_free(ptr noundef nonnull %0) #30
  br label %14

9:                                                ; preds = %6
  %10 = tail call ptr @__mem1_alloc(i32 noundef %1) #30
  %11 = icmp eq ptr %10, null
  br i1 %11, label %14, label %12

12:                                               ; preds = %9
  %13 = tail call ptr @memcpy(ptr noundef nonnull %10, ptr noundef nonnull %0, i32 noundef %1) #31
  br label %14

14:                                               ; preds = %9, %12, %8, %4
  %15 = phi ptr [ %5, %4 ], [ null, %8 ], [ %10, %12 ], [ null, %9 ]
  ret ptr %15
}

declare void @__memcpy_0_to_1(i32, i32, i32)

declare void @__memcpy_1_to_0(i32, i32, i32)

declare i32 @__mem1_memcmp_0_1(i32, i32, i32)

declare void @__mem1_warn(i32, i32, i32)

declare i32 @__mem0_cstrlen(i32, i32)

declare i32 @__mem0_read_le_prefix(i32, i32, i32)

declare void @__mem1_store8(i32, i32)

attributes #0 = { nounwind "target-cpu"="generic" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none) "target-cpu"="generic" }
attributes #3 = { mustprogress nofree nounwind willreturn memory(read, argmem: none, inaccessiblemem: none) "target-cpu"="generic" }
attributes #4 = { nofree norecurse nosync nounwind memory(read, argmem: none, inaccessiblemem: none) "target-cpu"="generic" }
attributes #5 = { nofree norecurse noreturn nosync nounwind memory(none) "target-cpu"="generic" }
attributes #6 = { minsize nounwind optsize "mem1-arg0"="ptrlike=1;dir=inout;len_arg=1" "mem1-ffi"="1" "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="bench_fill_target_from_pool" }
attributes #7 = { minsize nounwind optsize "mem1-arg0"="ptrlike=1;dir=inout;len_arg=1" "mem1-arg2"="ptrlike=1;dir=inout;len_arg=3" "mem1-arg4"="ptrlike=1;dir=inout;len_arg=5" "mem1-arg6"="ptrlike=1;dir=inout;len_arg=7" "mem1-ffi"="1" "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_compress_with_len" }
attributes #8 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_dbg_last_compressed_ptr" }
attributes #9 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_dbg_last_expected" }
attributes #10 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_dbg_last_n" }
attributes #11 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_dbg_last_stage" }
attributes #12 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_dbg_last_uncompressed_len" }
attributes #13 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(read, argmem: none, inaccessiblemem: none) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_dbg_last_uncompressed_ptr" }
attributes #14 = { minsize nounwind optsize "mem1-arg0"="ptrlike=1;dir=inout" "mem1-ffi"="1" "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_free_env" }
attributes #15 = { minsize nounwind optsize "mem1-arg0"="ptrlike=1;dir=inout;len_arg=1" "mem1-ffi"="1" "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_init_env_with_len" }
attributes #16 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_max_compressed_length" }
attributes #17 = { minsize nounwind optsize "mem1-arg0"="ptrlike=1;dir=inout;len_arg=1" "mem1-arg2"="ptrlike=1;dir=inout;len_arg=3" "mem1-ffi"="1" "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_uncompress_with_len" }
attributes #18 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite) "mem1-arg0"="ptrlike=1;dir=inout;len_arg=1" "mem1-arg2"="ptrlike=1;dir=inout;len_arg=1" "mem1-ffi"="1" "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_uncompressed_length" }
attributes #19 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite) "mem1-arg0"="ptrlike=1;dir=inout;len_arg=1" "mem1-arg2"="ptrlike=1;dir=inout;len_arg=3" "mem1-ffi"="1" "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_uncompressed_length_with_len" }
attributes #20 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(none) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" "wasm-export-name"="snappy_verify_compress_len" }
attributes #21 = { minsize mustprogress nofree norecurse nosync nounwind optsize willreturn memory(argmem: readwrite) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" }
attributes #22 = { minsize nounwind optsize "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" }
attributes #23 = { inlinehint minsize nounwind optsize "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" }
attributes #24 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #25 = { minsize nofree norecurse nosync nounwind optsize memory(argmem: read) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" }
attributes #26 = { minsize nofree norecurse nosync nounwind optsize memory(argmem: readwrite) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" }
attributes #27 = { minsize nofree norecurse nosync nounwind optsize memory(argmem: write) "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" }
attributes #28 = { minsize optsize "no-builtins" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+mutable-globals,+sign-ext" }
attributes #29 = { nounwind }
attributes #30 = { minsize nobuiltin nounwind optsize "no-builtins" }
attributes #31 = { minsize nobuiltin optsize "no-builtins" }

!llvm.ident = !{!0, !1, !1}
!llvm.module.flags = !{!2}

!0 = !{!"rustc version 1.80.0-nightly (e82c861d7 2024-05-04)"}
!1 = !{!"Ubuntu clang version 18.1.3 (1ubuntu1)"}
!2 = !{i32 1, !"wchar_size", i32 4}
!3 = !{}
!4 = !{!5, !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C/C++ TBAA"}
!7 = distinct !{!7, !8}
!8 = !{!"llvm.loop.mustprogress"}
!9 = distinct !{!9, !8}
!10 = distinct !{!10, !8}
!11 = !{!12, !12, i64 0}
!12 = !{!"long", !5, i64 0}
!13 = !{!14, !14, i64 0}
!14 = !{!"int", !5, i64 0}
!15 = !{!16, !17, i64 0}
!16 = !{!"snappy_env", !17, i64 0, !17, i64 4, !17, i64 8}
!17 = !{!"any pointer", !5, i64 0}
!18 = !{i32 -12, i32 1}
!19 = !{i32 -5, i32 1}
!20 = !{!21, !17, i64 0}
!21 = !{!"writer", !17, i64 0, !17, i64 4, !17, i64 8}
!22 = !{!21, !17, i64 4}
!23 = !{!24, !17, i64 0}
!24 = !{!"snappy_decompressor", !17, i64 0, !17, i64 4, !17, i64 8, !14, i64 12, !25, i64 16, !5, i64 17}
!25 = !{!"_Bool", !5, i64 0}
!26 = !{!24, !17, i64 4}
!27 = !{!24, !17, i64 8}
!28 = !{!24, !14, i64 12}
!29 = !{!24, !25, i64 16}
!30 = !{!31, !12, i64 4}
!31 = !{!"source", !17, i64 0, !12, i64 4}
!32 = !{!31, !17, i64 0}
!33 = !{!21, !17, i64 8}
!34 = !{!"branch_weights", i32 1, i32 2000}
!35 = distinct !{!35, !8}
!36 = !{!37, !37, i64 0}
!37 = !{!"short", !5, i64 0}
!38 = distinct !{!38, !8}
!39 = distinct !{!39, !8}
!40 = distinct !{!40, !8}
!41 = !{i8 0, i8 2}
!42 = distinct !{!42, !8}
!43 = !{!44, !17, i64 0}
!44 = !{!"sink", !17, i64 0}
!45 = !{!16, !17, i64 4}
!46 = distinct !{!46, !8}
!47 = distinct !{!47, !8}
!48 = !{!16, !17, i64 8}
!49 = !{i32 0, i32 33}
!50 = !{!"branch_weights", i32 2000, i32 1}
!51 = distinct !{!51, !8}
!52 = distinct !{!52, !8}
!53 = distinct !{!53, !8}
!54 = distinct !{!54, !8}
!55 = distinct !{!55, !8}
!56 = distinct !{!56, !8}
!57 = distinct !{!57, !8}
!58 = distinct !{!58, !8}
!59 = distinct !{!59, !8}
!60 = distinct !{!60, !8}
!61 = distinct !{!61, !8}
