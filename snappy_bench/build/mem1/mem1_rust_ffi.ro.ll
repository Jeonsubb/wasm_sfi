; ModuleID = '/home/ubuntu/wasm-mem1-copy-out-remove/snappy_bench/build/mem1/mem1_rust_ffi.ro.bc'
source_filename = "rust_snappy.b3f22ce14ab6cb0a-cgu.0"
target datalayout = "e-m:e-p:32:32-p10:8:8-p20:8:8-i64:64-n32:64-S128-ni:1:10:20"
target triple = "wasm32-unknown-unknown"

@_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E = internal global <{ [4194304 x i8] }> zeroinitializer, align 1
@_ZN11rust_snappy16BENCH_COMPRESSED17h02e255e6b4d0b1b7E = internal global <{ [4893386 x i8] }> zeroinitializer, align 1
@_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E = internal global <{ [4194304 x i8] }> zeroinitializer, align 1
@_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0 = internal unnamed_addr global i32 0, align 4
@_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0 = internal unnamed_addr global i32 0, align 4
@_ZN11rust_snappy18BENCH_TARGET_READY17h50272c3ff1d65635E.0 = internal unnamed_addr global i1 false, align 1
@_ZN11rust_snappy17BENCH_TARGET_SIZE17h35ac4feaefc47175E.0 = internal unnamed_addr global i32 0, align 4
@_ZN11rust_snappy10SNAPPY_ENV17hbfdcf2c0e04c73a7E = internal global <{ [12 x i8] }> zeroinitializer, align 4
@_ZN11rust_snappy16SNAPPY_ENV_READY17h78e75501de0677ffE.0 = internal unnamed_addr global i1 false, align 1

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
  %fill_ret = tail call noundef i32 @bench_fill_target_from_pool(ptr noundef nonnull @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E, i32 noundef %size) #6
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
  %target_size.i = load i32, ptr @_ZN11rust_snappy17BENCH_TARGET_SIZE17h35ac4feaefc47175E.0, align 4, !noundef !1
  %_8.i = icmp eq i32 %target_size.i, %size
  %or.cond.not.i = and i1 %.b1.i, %_8.i
  br i1 %or.cond.not.i, label %bb6.i, label %_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit

bb6.i:                                            ; preds = %bb4.i
  %.b1.i.i = load i1, ptr @_ZN11rust_snappy16SNAPPY_ENV_READY17h78e75501de0677ffE.0, align 1
  br i1 %.b1.i.i, label %bb10.i, label %bb2.i.i

bb2.i.i:                                          ; preds = %bb6.i
  %_3.i.i = tail call noundef i32 @snappy_init_env_with_len(ptr noundef nonnull @_ZN11rust_snappy10SNAPPY_ENV17hbfdcf2c0e04c73a7E, i32 noundef 12) #6
  %1 = icmp eq i32 %_3.i.i, 0
  br i1 %1, label %bb5.i.i, label %_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit

bb5.i.i:                                          ; preds = %bb2.i.i
  store i1 true, ptr @_ZN11rust_snappy16SNAPPY_ENV_READY17h78e75501de0677ffE.0, align 1
  br label %bb10.i

bb10.i:                                           ; preds = %bb5.i.i, %bb6.i
  %max_len.i = tail call noundef i32 @snappy_max_compressed_length(i32 noundef %size) #6
  %_11.i = icmp ugt i32 %max_len.i, 4893386
  br i1 %_11.i, label %_ZN11rust_snappy26bench_snappy_compress_impl17h4cfdaa49a8354de3E.exit, label %bb13.i

bb13.i:                                           ; preds = %bb10.i
  store i32 0, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4
  store i32 0, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4
  call void @llvm.lifetime.start.p0(i64 4, ptr nonnull %compressed_len.i)
  store i32 %max_len.i, ptr %compressed_len.i, align 4
  %_16.i = call noundef i32 @snappy_compress_with_len(ptr noundef nonnull @_ZN11rust_snappy10SNAPPY_ENV17hbfdcf2c0e04c73a7E, i32 noundef 12, ptr noundef nonnull @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E, i32 noundef %size, ptr noundef nonnull @_ZN11rust_snappy16BENCH_COMPRESSED17h02e255e6b4d0b1b7E, i32 noundef %max_len.i, ptr noundef nonnull %compressed_len.i, i32 noundef 4) #6
  %2 = icmp eq i32 %_16.i, 0
  br i1 %2, label %bb16.i, label %bb17.i

bb16.i:                                           ; preds = %bb13.i
  %_28.i = load i32, ptr %compressed_len.i, align 4, !noundef !1
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

; Function Attrs: nounwind
define dso_local noundef i32 @bench_snappy_uncompress(i32 noundef %size) unnamed_addr #0 {
start:
  %0 = icmp eq i32 %size, 0
  br i1 %0, label %_ZN11rust_snappy28bench_snappy_uncompress_impl17hd2bbec78fc0269afE.exit, label %bb2.i

bb2.i:                                            ; preds = %start
  %_3.i = icmp ugt i32 %size, 4194304
  br i1 %_3.i, label %_ZN11rust_snappy28bench_snappy_uncompress_impl17hd2bbec78fc0269afE.exit, label %bb4.i

bb4.i:                                            ; preds = %bb2.i
  %compressed_len.i = load i32, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4, !noundef !1
  %compressed_size.i = load i32, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4, !noundef !1
  %1 = icmp eq i32 %compressed_len.i, 0
  %_8.i = icmp ne i32 %compressed_size.i, %size
  %or.cond.i = or i1 %1, %_8.i
  br i1 %or.cond.i, label %_ZN11rust_snappy28bench_snappy_uncompress_impl17hd2bbec78fc0269afE.exit, label %bb6.i

bb6.i:                                            ; preds = %bb4.i
  %ret.i = tail call noundef i32 @snappy_uncompress_with_len(ptr noundef nonnull @_ZN11rust_snappy16BENCH_COMPRESSED17h02e255e6b4d0b1b7E, i32 noundef %compressed_len.i, ptr noundef nonnull @_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E, i32 noundef %size) #6
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
  %compressed_len = load i32, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4, !noundef !1
  %compressed_size = load i32, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4, !noundef !1
  %1 = icmp eq i32 %compressed_len, 0
  %_8 = icmp ne i32 %compressed_size, %size
  %or.cond = or i1 %1, %_8
  br i1 %or.cond, label %bb11, label %bb6

bb6:                                              ; preds = %bb4
  %max_len = tail call noundef i32 @snappy_max_compressed_length(i32 noundef %size) #6
  %_10 = icmp ugt i32 %compressed_len, %max_len
  %. = select i1 %_10, i32 -143, i32 0
  br label %bb11
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_get_compressed_len() unnamed_addr #1 {
start:
  %_0 = load i32, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4, !noundef !1
  ret i32 %_0
}

; Function Attrs: mustprogress nofree nounwind willreturn memory(read, argmem: none, inaccessiblemem: none)
define dso_local noundef i32 @bench_verify_uncompress(i32 noundef %size) unnamed_addr #2 {
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
  %compressed_len = load i32, ptr @_ZN11rust_snappy20BENCH_COMPRESSED_LEN17h9f3939e79eb2d8e4E.0, align 4, !noundef !1
  %compressed_size = load i32, ptr @_ZN11rust_snappy21BENCH_COMPRESSED_SIZE17hc0778b03ca24e4d2E.0, align 4, !noundef !1
  %1 = icmp eq i32 %compressed_len, 0
  %_8 = icmp ne i32 %compressed_size, %size
  %or.cond = or i1 %1, %_8
  br i1 %or.cond, label %bb11, label %bb6

bb6:                                              ; preds = %bb4
  %_9 = tail call noundef i32 @memcmp(ptr noundef nonnull @_ZN11rust_snappy18BENCH_UNCOMPRESSED17h5463976b7621d031E, ptr noundef nonnull @_ZN11rust_snappy12BENCH_TARGET17hae7d3ff8efd34119E, i32 noundef %size) #6
  %2 = icmp eq i32 %_9, 0
  %. = select i1 %2, i32 0, i32 -155
  br label %bb11
}

; Function Attrs: nofree norecurse noreturn nosync nounwind memory(none)
define hidden void @rust_begin_unwind(ptr noalias nocapture noundef readonly align 4 dereferenceable(20) %_1) unnamed_addr #3 {
start:
  br label %bb1

bb1:                                              ; preds = %bb1, %start
  br label %bb1
}

; Function Attrs: nounwind
declare dso_local noundef i32 @bench_fill_target_from_pool(ptr noundef, i32 noundef) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local noundef i32 @snappy_init_env_with_len(ptr noundef, i32 noundef) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local noundef i32 @snappy_max_compressed_length(i32 noundef) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local noundef i32 @snappy_compress_with_len(ptr noundef, i32 noundef, ptr noundef, i32 noundef, ptr noundef, i32 noundef, ptr noundef, i32 noundef) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local noundef i32 @snappy_uncompress_with_len(ptr noundef, i32 noundef, ptr noundef, i32 noundef) unnamed_addr #0

; Function Attrs: mustprogress nofree nounwind willreturn memory(argmem: read)
declare dso_local noundef i32 @memcmp(ptr nocapture noundef, ptr nocapture noundef, i32 noundef) unnamed_addr #4

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(i64 immarg, ptr nocapture) #5

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(i64 immarg, ptr nocapture) #5

attributes #0 = { nounwind "target-cpu"="generic" }
attributes #1 = { mustprogress nofree norecurse nosync nounwind willreturn memory(read, argmem: none, inaccessiblemem: none) "target-cpu"="generic" }
attributes #2 = { mustprogress nofree nounwind willreturn memory(read, argmem: none, inaccessiblemem: none) "target-cpu"="generic" }
attributes #3 = { nofree norecurse noreturn nosync nounwind memory(none) "target-cpu"="generic" }
attributes #4 = { mustprogress nofree nounwind willreturn memory(argmem: read) "target-cpu"="generic" }
attributes #5 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #6 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"rustc version 1.80.0-nightly (e82c861d7 2024-05-04)"}
!1 = !{}
