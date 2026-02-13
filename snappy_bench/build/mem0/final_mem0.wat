(module
  (type (;0;) (func))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param i32 i32) (result i32)))
  (type (;3;) (func (param i32 i32 i32 i32 i32 i32 i32 i32) (result i32)))
  (type (;4;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;5;) (func (result i32)))
  (type (;6;) (func (param i32 i32 i32) (result i32)))
  (type (;7;) (func (param i32)))
  (type (;8;) (func (param i32 i32 i32 i32 i32) (result i32)))
  (type (;9;) (func (param i32 i32)))
  (type (;10;) (func (param i32 i32 i32)))
  (func $__wasm_call_ctors (type 0))
  (func $bench_prepare (type 1) (param i32) (result i32)
    (local i32)
    block  ;; label = @1
      local.get 0
      br_if 0 (;@1;)
      i32.const -120
      return
    end
    i32.const -121
    local.set 1
    block  ;; label = @1
      local.get 0
      i32.const 4194305
      i32.ge_u
      br_if 0 (;@1;)
      i32.const 1568
      local.get 0
      call $bench_fill_target_from_pool
      local.tee 1
      br_if 0 (;@1;)
      i32.const 0
      local.set 1
      i32.const 0
      local.get 0
      i32.store offset=13283576
      i32.const 0
      i32.const 1
      i32.store8 offset=13283572
      i32.const 0
      i32.const 0
      i32.store offset=13283564
      i32.const 0
      i32.const 0
      i32.store offset=13283568
    end
    local.get 1)
  (func $bench_fill_target_from_pool (type 2) (param i32 i32) (result i32)
    (local i32 i32 i32 i32 i32)
    block  ;; label = @1
      block  ;; label = @2
        local.get 1
        br_if 0 (;@2;)
        i32.const -120
        local.set 2
        br 1 (;@1;)
      end
      i32.const -121
      local.set 2
      local.get 1
      i32.const 4194304
      i32.gt_u
      br_if 0 (;@1;)
      i32.const 0
      local.set 2
      block  ;; label = @2
        i32.const 0
        i32.load8_u offset=13873464
        br_if 0 (;@2;)
        i32.const 13283616
        local.set 3
        i32.const 17
        local.set 4
        loop  ;; label = @3
          block  ;; label = @4
            local.get 2
            i32.const 9
            i32.ne
            br_if 0 (;@4;)
            i32.const 0
            i32.const 1
            i32.store8 offset=13873464
            br 2 (;@2;)
          end
          i32.const 0
          local.set 5
          local.get 4
          local.set 6
          block  ;; label = @4
            loop  ;; label = @5
              local.get 5
              i32.const 65536
              i32.eq
              br_if 1 (;@4;)
              local.get 3
              local.get 5
              i32.add
              local.get 6
              i32.store8
              local.get 6
              i32.const 31
              i32.add
              local.set 6
              local.get 5
              i32.const 1
              i32.add
              local.set 5
              br 0 (;@5;)
            end
          end
          local.get 4
          i32.const 17
          i32.add
          local.set 4
          local.get 3
          i32.const 65536
          i32.add
          local.set 3
          local.get 2
          i32.const 1
          i32.add
          local.set 2
          br 0 (;@3;)
        end
      end
      i32.const 0
      local.set 2
      i32.const 0
      local.set 6
      i32.const 0
      local.set 5
      loop  ;; label = @2
        local.get 1
        local.get 5
        i32.le_u
        br_if 1 (;@1;)
        local.get 0
        local.get 5
        i32.add
        local.get 6
        i32.const 16
        i32.shl
        i32.const 13283616
        i32.add
        local.get 1
        local.get 5
        i32.sub
        local.tee 3
        i32.const 65536
        local.get 3
        i32.const 65536
        i32.lt_u
        select
        local.tee 3
        call $memcpy
        drop
        i32.const 0
        local.get 6
        i32.const 1
        i32.add
        local.tee 6
        local.get 6
        i32.const 9
        i32.eq
        select
        local.set 6
        local.get 3
        local.get 5
        i32.add
        local.set 5
        br 0 (;@2;)
      end
    end
    local.get 2)
  (func $bench_snappy_compress (type 1) (param i32) (result i32)
    (local i32 i32 i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee 1
    global.set $__stack_pointer
    block  ;; label = @1
      block  ;; label = @2
        local.get 0
        br_if 0 (;@2;)
        i32.const -90
        local.set 2
        br 1 (;@1;)
      end
      i32.const -91
      local.set 2
      local.get 0
      i32.const 4194304
      i32.gt_u
      br_if 0 (;@1;)
      i32.const -92
      local.set 2
      i32.const 0
      i32.load8_u offset=13283572
      i32.eqz
      br_if 0 (;@1;)
      i32.const 0
      i32.load offset=13283576
      local.get 0
      i32.ne
      br_if 0 (;@1;)
      block  ;; label = @2
        i32.const 0
        i32.load8_u offset=13283592
        br_if 0 (;@2;)
        i32.const 13283580
        i32.const 12
        call $snappy_init_env_with_len
        br_if 1 (;@1;)
        i32.const 0
        i32.const 1
        i32.store8 offset=13283592
      end
      i32.const -93
      local.set 2
      local.get 0
      call $snappy_max_compressed_length
      local.tee 3
      i32.const 4893386
      i32.gt_u
      br_if 0 (;@1;)
      i32.const 0
      i32.const 0
      i32.store offset=13283568
      i32.const 0
      i32.const 0
      i32.store offset=13283564
      local.get 1
      local.get 3
      i32.store offset=12
      i32.const -94
      local.set 2
      i32.const 13283580
      i32.const 12
      i32.const 1568
      local.get 0
      i32.const 4195872
      local.get 3
      local.get 1
      i32.const 12
      i32.add
      i32.const 4
      call $snappy_compress_with_len
      br_if 0 (;@1;)
      i32.const 0
      local.get 1
      i32.load offset=12
      i32.store offset=13283564
      i32.const 0
      local.get 0
      i32.store offset=13283568
      i32.const 0
      local.set 2
    end
    local.get 1
    i32.const 16
    i32.add
    global.set $__stack_pointer
    local.get 2)
  (func $snappy_init_env_with_len (type 2) (param i32 i32) (result i32)
    (local i32)
    i32.const -5
    local.set 2
    block  ;; label = @1
      local.get 1
      i32.const 12
      i32.lt_u
      br_if 0 (;@1;)
      local.get 0
      call $snappy_init_env
      local.set 2
    end
    local.get 2)
  (func $snappy_max_compressed_length (type 1) (param i32) (result i32)
    local.get 0
    local.get 0
    i32.const 6
    i32.div_u
    i32.add
    i32.const 32
    i32.add)
  (func $snappy_compress_with_len (type 3) (param i32 i32 i32 i32 i32 i32 i32 i32) (result i32)
    (local i32)
    i32.const -5
    local.set 8
    block  ;; label = @1
      local.get 1
      i32.const 12
      i32.lt_u
      br_if 0 (;@1;)
      local.get 7
      i32.const 4
      i32.lt_u
      br_if 0 (;@1;)
      local.get 3
      local.get 3
      i32.const 6
      i32.div_u
      i32.add
      i32.const 32
      i32.add
      local.get 5
      i32.gt_u
      br_if 0 (;@1;)
      local.get 0
      local.get 2
      local.get 3
      local.get 4
      local.get 6
      call $snappy_compress
      local.set 8
    end
    local.get 8)
  (func $bench_snappy_uncompress (type 1) (param i32) (result i32)
    (local i32 i32)
    block  ;; label = @1
      local.get 0
      br_if 0 (;@1;)
      i32.const -100
      return
    end
    i32.const -101
    local.set 1
    block  ;; label = @1
      local.get 0
      i32.const 4194304
      i32.gt_u
      br_if 0 (;@1;)
      i32.const -102
      local.set 1
      i32.const 0
      i32.load offset=13283564
      local.tee 2
      i32.eqz
      br_if 0 (;@1;)
      i32.const 0
      i32.load offset=13283568
      local.get 0
      i32.ne
      br_if 0 (;@1;)
      i32.const 0
      local.get 2
      i32.store offset=13283600
      i32.const 0
      i32.const 1
      i32.store8 offset=13283596
      i32.const 0
      i32.const 1
      i32.store8 offset=13283604
      i32.const 0
      local.get 0
      i32.store offset=13283608
      i32.const 0
      i32.const 0
      i32.store offset=13283612
      i32.const 0
      i32.const 4195872
      local.get 2
      i32.const 9089258
      local.get 0
      call $snappy_uncompress_with_len
      local.tee 1
      i32.store offset=13283612
    end
    local.get 1)
  (func $snappy_uncompress_with_len (type 4) (param i32 i32 i32 i32) (result i32)
    (local i32 i32 i32 i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee 4
    global.set $__stack_pointer
    i32.const 0
    local.get 1
    i32.store offset=13873444
    i32.const 0
    local.get 0
    i32.store offset=13873440
    i32.const 0
    local.get 2
    i32.store offset=13873448
    i32.const 0
    local.get 3
    i32.store offset=13873452
    i32.const 0
    i32.const 0
    i32.store offset=13873456
    local.get 4
    i32.const 0
    i32.store offset=12
    i32.const -201
    local.set 5
    i32.const -201
    local.set 6
    block  ;; label = @1
      local.get 0
      local.get 1
      local.get 4
      i32.const 12
      i32.add
      call $snappy_uncompressed_length_internal
      i32.eqz
      br_if 0 (;@1;)
      i32.const 0
      local.get 4
      i32.load offset=12
      local.tee 7
      i32.store offset=13873456
      i32.const -202
      local.set 5
      i32.const -202
      local.set 6
      local.get 7
      local.get 3
      i32.gt_u
      br_if 0 (;@1;)
      i32.const 0
      i32.const 3
      i32.store offset=13873460
      i32.const -203
      i32.const 0
      local.get 0
      local.get 1
      local.get 2
      call $snappy_uncompress
      local.tee 1
      select
      local.set 6
      i32.const -203
      i32.const 100
      local.get 1
      select
      local.set 5
    end
    i32.const 0
    local.get 5
    i32.store offset=13873460
    local.get 4
    i32.const 16
    i32.add
    global.set $__stack_pointer
    local.get 6)
  (func $bench_verify_compress (type 1) (param i32) (result i32)
    (local i32 i32)
    block  ;; label = @1
      local.get 0
      br_if 0 (;@1;)
      i32.const -140
      return
    end
    i32.const -141
    local.set 1
    block  ;; label = @1
      local.get 0
      i32.const 4194305
      i32.ge_u
      br_if 0 (;@1;)
      i32.const -142
      local.set 1
      i32.const 0
      i32.load offset=13283564
      local.tee 2
      i32.eqz
      br_if 0 (;@1;)
      i32.const 0
      i32.load offset=13283568
      local.get 0
      i32.ne
      br_if 0 (;@1;)
      i32.const -143
      i32.const 0
      local.get 2
      local.get 0
      call $snappy_max_compressed_length
      i32.gt_u
      select
      local.set 1
    end
    local.get 1)
  (func $bench_get_compressed_len (type 5) (result i32)
    i32.const 0
    i32.load offset=13283564)
  (func $bench_verify_uncompress (type 1) (param i32) (result i32)
    (local i32)
    block  ;; label = @1
      local.get 0
      br_if 0 (;@1;)
      i32.const -150
      return
    end
    i32.const -151
    local.set 1
    block  ;; label = @1
      local.get 0
      i32.const 4194305
      i32.ge_u
      br_if 0 (;@1;)
      i32.const -152
      local.set 1
      i32.const 0
      i32.load offset=13283564
      i32.eqz
      br_if 0 (;@1;)
      i32.const 0
      i32.load offset=13283568
      local.get 0
      i32.ne
      br_if 0 (;@1;)
      i32.const -155
      i32.const 0
      i32.const 9089258
      i32.const 1568
      local.get 0
      call $memcmp
      select
      local.set 1
    end
    local.get 1)
  (func $memcmp (type 6) (param i32 i32 i32) (result i32)
    (local i32 i32)
    loop  ;; label = @1
      block  ;; label = @2
        local.get 2
        br_if 0 (;@2;)
        i32.const 0
        return
      end
      local.get 2
      i32.const -1
      i32.add
      local.set 2
      local.get 1
      i32.load8_u
      local.set 3
      local.get 0
      i32.load8_u
      local.set 4
      local.get 1
      i32.const 1
      i32.add
      local.set 1
      local.get 0
      i32.const 1
      i32.add
      local.set 0
      local.get 4
      local.get 3
      i32.eq
      br_if 0 (;@1;)
    end
    local.get 4
    local.get 3
    i32.sub)
  (func $bench_debug_uncomp_compressed_ptr (type 5) (result i32)
    i32.const 4195872
    i32.const 0
    i32.const 0
    i32.load8_u offset=13283596
    select)
  (func $bench_debug_uncomp_compressed_len (type 5) (result i32)
    i32.const 0
    i32.load offset=13283600)
  (func $bench_debug_uncomp_dst_ptr (type 5) (result i32)
    i32.const 9089258
    i32.const 0
    i32.const 0
    i32.load8_u offset=13283604
    select)
  (func $bench_debug_uncomp_dst_len (type 5) (result i32)
    i32.const 0
    i32.load offset=13283608)
  (func $bench_debug_uncomp_last_ret (type 5) (result i32)
    i32.const 0
    i32.load offset=13283612)
  (func $bench_debug_first_mismatch (type 1) (param i32) (result i32)
    (local i32 i32)
    i32.const -1
    local.set 1
    block  ;; label = @1
      local.get 0
      i32.const -1
      i32.add
      i32.const 4194303
      i32.gt_u
      br_if 0 (;@1;)
      i32.const 0
      local.set 2
      loop  ;; label = @2
        block  ;; label = @3
          local.get 2
          i32.const 9089258
          i32.add
          i32.load8_u
          local.get 2
          i32.const 1568
          i32.add
          i32.load8_u
          i32.eq
          br_if 0 (;@3;)
          local.get 2
          local.set 1
          br 2 (;@1;)
        end
        local.get 0
        local.get 2
        i32.const 1
        i32.add
        local.tee 2
        i32.ne
        br_if 0 (;@2;)
      end
    end
    local.get 1)
  (func $bench_debug_target_byte_at (type 1) (param i32) (result i32)
    (local i32)
    i32.const -1
    local.set 1
    block  ;; label = @1
      local.get 0
      i32.const 4194303
      i32.gt_u
      br_if 0 (;@1;)
      local.get 0
      i32.const 1568
      i32.add
      i32.load8_u
      local.set 1
    end
    local.get 1)
  (func $bench_debug_uncompressed_byte_at (type 1) (param i32) (result i32)
    (local i32)
    i32.const -1
    local.set 1
    block  ;; label = @1
      local.get 0
      i32.const 4194303
      i32.gt_u
      br_if 0 (;@1;)
      local.get 0
      i32.const 9089258
      i32.add
      i32.load8_u
      local.set 1
    end
    local.get 1)
  (func $rust_begin_unwind (type 7) (param i32)
    loop  ;; label = @1
      br 0 (;@1;)
    end)
  (func $memcpy (type 6) (param i32 i32 i32) (result i32)
    (local i32)
    i32.const 0
    local.set 3
    loop (result i32)  ;; label = @1
      block  ;; label = @2
        local.get 2
        local.get 3
        i32.ne
        br_if 0 (;@2;)
        local.get 0
        return
      end
      local.get 0
      local.get 3
      i32.add
      local.get 1
      local.get 3
      i32.add
      i32.load8_u
      i32.store8
      local.get 3
      i32.const 1
      i32.add
      local.set 3
      br 0 (;@1;)
    end)
  (func $snappy_compress (type 8) (param i32 i32 i32 i32 i32) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee 5
    global.set $__stack_pointer
    local.get 5
    local.get 3
    i32.store
    block  ;; label = @1
      block  ;; label = @2
        local.get 2
        i32.const 127
        i32.gt_u
        br_if 0 (;@2;)
        local.get 5
        local.get 2
        i32.store8 offset=7
        local.get 5
        i32.const 8
        i32.add
        local.set 6
        br 1 (;@1;)
      end
      block  ;; label = @2
        local.get 2
        i32.const 16383
        i32.gt_u
        br_if 0 (;@2;)
        local.get 5
        local.get 2
        i32.const 7
        i32.shr_u
        i32.store8 offset=8
        local.get 5
        local.get 2
        i32.const 128
        i32.or
        i32.store8 offset=7
        local.get 5
        i32.const 9
        i32.add
        local.set 6
        br 1 (;@1;)
      end
      block  ;; label = @2
        local.get 2
        i32.const 2097151
        i32.gt_u
        br_if 0 (;@2;)
        local.get 5
        local.get 2
        i32.const 14
        i32.shr_u
        i32.store8 offset=9
        local.get 5
        local.get 2
        i32.const 128
        i32.or
        i32.store8 offset=7
        local.get 5
        local.get 2
        i32.const 7
        i32.shr_u
        i32.const 128
        i32.or
        i32.store8 offset=8
        local.get 5
        i32.const 10
        i32.add
        local.set 6
        br 1 (;@1;)
      end
      local.get 5
      local.get 2
      i32.const 128
      i32.or
      i32.store8 offset=7
      local.get 5
      local.get 2
      i32.const 14
      i32.shr_u
      i32.const 128
      i32.or
      i32.store8 offset=9
      local.get 5
      local.get 2
      i32.const 7
      i32.shr_u
      i32.const 128
      i32.or
      i32.store8 offset=8
      local.get 2
      i32.const 21
      i32.shr_u
      local.set 6
      block  ;; label = @2
        local.get 2
        i32.const 268435455
        i32.gt_u
        br_if 0 (;@2;)
        local.get 5
        local.get 6
        i32.store8 offset=10
        local.get 5
        i32.const 11
        i32.add
        local.set 6
        br 1 (;@1;)
      end
      local.get 5
      local.get 2
      i32.const 28
      i32.shr_u
      i32.store8 offset=11
      local.get 5
      local.get 6
      i32.const 128
      i32.or
      i32.store8 offset=10
      local.get 5
      i32.const 12
      i32.add
      local.set 6
    end
    local.get 5
    local.get 5
    i32.const 7
    i32.add
    local.get 6
    local.get 5
    i32.const 7
    i32.add
    i32.sub
    call $append
    i32.const 0
    local.set 7
    local.get 2
    local.set 8
    loop (result i32)  ;; label = @1
      block  ;; label = @2
        block  ;; label = @3
          local.get 8
          i32.const 1
          i32.lt_s
          br_if 0 (;@3;)
          local.get 2
          br_if 1 (;@2;)
          i32.const -5
          local.set 7
        end
        local.get 4
        local.get 5
        i32.load
        local.get 3
        i32.sub
        i32.store
        local.get 5
        i32.const 16
        i32.add
        global.set $__stack_pointer
        local.get 7
        return
      end
      block  ;; label = @2
        local.get 2
        local.get 8
        i32.const 65536
        local.get 8
        i32.const 65536
        i32.lt_s
        select
        local.tee 9
        i32.ge_u
        br_if 0 (;@2;)
        local.get 0
        i32.load offset=4
        local.get 1
        local.get 2
        call $memcpy
        drop
        local.get 2
        local.set 6
        loop  ;; label = @3
          local.get 1
          local.get 6
          i32.add
          local.set 1
          i32.const 0
          local.set 6
          local.get 0
          i32.load offset=4
          local.get 2
          i32.add
          local.get 1
          i32.const 0
          call $memcpy
          drop
          br 0 (;@3;)
        end
      end
      local.get 9
      i32.const 16384
      local.get 9
      i32.const 16384
      i32.lt_u
      select
      local.set 10
      i32.const 256
      local.set 6
      loop  ;; label = @2
        local.get 6
        local.tee 11
        i32.const 1
        i32.shl
        local.set 6
        local.get 11
        local.get 10
        i32.lt_u
        br_if 0 (;@2;)
      end
      local.get 0
      i32.load
      i32.const 0
      local.get 6
      call $memset
      local.set 12
      block  ;; label = @2
        local.get 5
        i32.load
        local.tee 13
        br_if 0 (;@2;)
        local.get 0
        i32.load offset=8
        local.set 13
      end
      local.get 1
      local.get 9
      i32.add
      local.set 14
      block  ;; label = @2
        block  ;; label = @3
          local.get 8
          i32.const 15
          i32.ge_s
          br_if 0 (;@3;)
          local.get 13
          local.set 15
          br 1 (;@2;)
        end
        local.get 14
        i32.const -4
        i32.add
        local.set 16
        local.get 14
        i32.const -15
        i32.add
        local.set 17
        local.get 1
        i32.const 1
        i32.add
        local.tee 10
        i32.const 32
        local.get 11
        i32.clz
        i32.const 31
        i32.xor
        i32.sub
        local.tee 18
        call $hash
        local.set 19
        local.get 1
        local.set 20
        local.get 13
        local.set 15
        loop  ;; label = @3
          i32.const 32
          local.set 11
          loop  ;; label = @4
            block  ;; label = @5
              local.get 10
              local.tee 6
              local.get 11
              i32.const 5
              i32.shr_u
              i32.add
              local.tee 10
              local.get 17
              i32.le_u
              br_if 0 (;@5;)
              local.get 20
              local.set 1
              br 3 (;@2;)
            end
            local.get 19
            i32.const 1
            i32.shl
            local.set 21
            local.get 10
            local.get 18
            call $hash
            local.set 19
            local.get 12
            local.get 21
            i32.add
            local.tee 21
            i32.load16_u
            local.set 22
            local.get 21
            local.get 6
            local.get 1
            i32.sub
            i32.store16
            local.get 11
            i32.const 1
            i32.add
            local.set 11
            local.get 5
            i32.const 12
            i32.add
            local.get 6
            i32.const 4
            call $memcpy
            i32.load
            local.get 5
            i32.const 12
            i32.add
            local.get 1
            local.get 22
            i32.add
            local.tee 21
            i32.const 4
            call $memcpy
            i32.load
            i32.ne
            br_if 0 (;@4;)
          end
          local.get 15
          local.get 20
          local.get 6
          local.get 20
          i32.sub
          i32.const 1
          call $emit_literal
          local.set 15
          loop  ;; label = @4
            local.get 6
            i32.const 4
            i32.add
            local.set 19
            local.get 21
            i32.const 4
            i32.add
            local.set 22
            i32.const 0
            local.set 10
            block  ;; label = @5
              block  ;; label = @6
                block  ;; label = @7
                  loop  ;; label = @8
                    local.get 19
                    local.get 10
                    i32.add
                    local.tee 11
                    local.get 16
                    i32.gt_u
                    br_if 1 (;@7;)
                    local.get 5
                    i32.const 12
                    i32.add
                    local.get 11
                    i32.const 4
                    call $memcpy
                    i32.load
                    local.get 5
                    i32.const 12
                    i32.add
                    local.get 22
                    local.get 10
                    i32.add
                    local.tee 11
                    i32.const 4
                    call $memcpy
                    i32.load
                    i32.ne
                    br_if 2 (;@6;)
                    local.get 10
                    i32.const 4
                    i32.add
                    local.set 10
                    br 0 (;@8;)
                  end
                end
                loop  ;; label = @7
                  local.get 19
                  local.get 10
                  i32.add
                  local.tee 11
                  local.get 14
                  i32.ge_u
                  br_if 2 (;@5;)
                  local.get 22
                  local.get 10
                  i32.add
                  i32.load8_u
                  local.get 11
                  i32.load8_u
                  i32.ne
                  br_if 2 (;@5;)
                  local.get 10
                  i32.const 1
                  i32.add
                  local.set 10
                  br 0 (;@7;)
                end
              end
              local.get 5
              i32.const 12
              i32.add
              local.get 6
              local.get 10
              i32.add
              i32.const 4
              i32.add
              i32.const 4
              call $memcpy
              i32.load
              local.get 5
              i32.const 12
              i32.add
              local.get 11
              i32.const 4
              call $memcpy
              i32.load
              i32.xor
              i32.ctz
              i32.const 3
              i32.shr_u
              local.get 10
              i32.add
              local.set 10
            end
            local.get 6
            local.get 21
            i32.sub
            local.set 11
            local.get 10
            i32.const 4
            i32.add
            local.tee 19
            local.set 10
            block  ;; label = @5
              loop  ;; label = @6
                local.get 10
                i32.const 68
                i32.lt_s
                br_if 1 (;@5;)
                local.get 10
                i32.const -64
                i32.add
                local.set 10
                local.get 15
                local.get 11
                i32.const 64
                call $emit_copy_less_than64
                local.set 15
                br 0 (;@6;)
              end
            end
            local.get 6
            local.get 19
            i32.add
            local.set 6
            block  ;; label = @5
              local.get 10
              i32.const 65
              i32.lt_s
              br_if 0 (;@5;)
              local.get 10
              i32.const -60
              i32.add
              local.set 10
              local.get 15
              local.get 11
              i32.const 60
              call $emit_copy_less_than64
              local.set 15
            end
            local.get 15
            local.get 11
            local.get 10
            call $emit_copy_less_than64
            local.set 15
            block  ;; label = @5
              local.get 6
              local.get 17
              i32.lt_u
              br_if 0 (;@5;)
              local.get 6
              local.set 1
              br 3 (;@2;)
            end
            local.get 12
            local.get 6
            i32.const -1
            i32.add
            local.tee 11
            i32.const 0
            call $get_u32_at_offset
            i32.const 506832829
            i32.mul
            local.get 18
            i32.shr_u
            i32.const 1
            i32.shl
            i32.add
            local.get 6
            local.get 1
            i32.sub
            local.tee 10
            i32.const -1
            i32.add
            i32.store16
            local.get 5
            i32.const 12
            i32.add
            local.get 1
            local.get 12
            local.get 11
            i32.const 1
            call $get_u32_at_offset
            i32.const 506832829
            i32.mul
            local.get 18
            i32.shr_u
            i32.const 1
            i32.shl
            i32.add
            local.tee 19
            i32.load16_u
            i32.add
            local.tee 21
            i32.const 4
            call $memcpy
            i32.load
            local.set 22
            local.get 19
            local.get 10
            i32.store16
            local.get 22
            local.get 11
            i32.const 1
            call $get_u32_at_offset
            i32.eq
            br_if 0 (;@4;)
          end
          local.get 6
          i32.const 1
          i32.add
          local.set 10
          local.get 11
          i32.const 2
          call $get_u32_at_offset
          i32.const 506832829
          i32.mul
          local.get 18
          i32.shr_u
          local.set 19
          local.get 6
          local.set 20
          br 0 (;@3;)
        end
      end
      block  ;; label = @2
        local.get 1
        local.get 14
        i32.ge_u
        br_if 0 (;@2;)
        local.get 15
        local.get 1
        local.get 14
        local.get 1
        i32.sub
        i32.const 0
        call $emit_literal
        local.set 15
      end
      local.get 5
      local.get 13
      local.get 15
      local.get 13
      i32.sub
      call $append
      local.get 2
      local.get 9
      i32.sub
      local.set 2
      local.get 8
      local.get 9
      i32.sub
      local.set 8
      local.get 14
      local.set 1
      br 0 (;@1;)
    end)
  (func $snappy_dbg_last_compressed_ptr (type 5) (result i32)
    i32.const 0
    i32.load offset=13873440)
  (func $snappy_dbg_last_expected (type 5) (result i32)
    i32.const 0
    i32.load offset=13873456)
  (func $snappy_dbg_last_n (type 5) (result i32)
    i32.const 0
    i32.load offset=13873444)
  (func $snappy_dbg_last_stage (type 5) (result i32)
    i32.const 0
    i32.load offset=13873460)
  (func $snappy_dbg_last_uncompressed_len (type 5) (result i32)
    i32.const 0
    i32.load offset=13873452)
  (func $snappy_dbg_last_uncompressed_ptr (type 5) (result i32)
    i32.const 0
    i32.load offset=13873448)
  (func $snappy_free_env (type 7) (param i32)
    local.get 0
    i32.load
    call $free
    local.get 0
    call $clear_env)
  (func $free (type 7) (param i32))
  (func $clear_env (type 7) (param i32)
    local.get 0
    i32.const 0
    i32.const 12
    call $memset
    drop)
  (func $snappy_init_env (type 1) (param i32) (result i32)
    (local i32)
    local.get 0
    call $clear_env
    local.get 0
    i32.const 32768
    call $malloc
    local.tee 1
    i32.store
    i32.const 0
    i32.const -12
    local.get 1
    select)
  (func $snappy_uncompressed_length_internal (type 6) (param i32 i32 i32) (result i32)
    (local i32 i32 i32)
    i32.const 0
    local.set 3
    block  ;; label = @1
      local.get 1
      i32.const 1
      i32.lt_s
      br_if 0 (;@1;)
      local.get 0
      i32.load8_s
      local.tee 4
      i32.const 127
      i32.and
      local.set 5
      block  ;; label = @2
        local.get 4
        i32.const -1
        i32.gt_s
        br_if 0 (;@2;)
        local.get 1
        i32.const 1
        i32.eq
        br_if 1 (;@1;)
        local.get 0
        i32.load8_s offset=1
        local.tee 4
        i32.const 7
        i32.shl
        i32.const 16256
        i32.and
        local.get 5
        i32.or
        local.set 5
        local.get 4
        i32.const -1
        i32.gt_s
        br_if 0 (;@2;)
        local.get 1
        i32.const 3
        i32.lt_u
        br_if 1 (;@1;)
        local.get 0
        i32.load8_s offset=2
        local.tee 4
        i32.const 14
        i32.shl
        i32.const 2080768
        i32.and
        local.get 5
        i32.or
        local.set 5
        local.get 4
        i32.const -1
        i32.gt_s
        br_if 0 (;@2;)
        local.get 1
        i32.const 3
        i32.eq
        br_if 1 (;@1;)
        local.get 0
        i32.load8_s offset=3
        local.tee 4
        i32.const 21
        i32.shl
        i32.const 266338304
        i32.and
        local.get 5
        i32.or
        local.set 5
        local.get 4
        i32.const -1
        i32.gt_s
        br_if 0 (;@2;)
        local.get 1
        i32.const 5
        i32.lt_u
        br_if 1 (;@1;)
        local.get 0
        i32.load8_u offset=4
        local.tee 1
        i32.const 15
        i32.gt_u
        br_if 1 (;@1;)
        local.get 1
        i32.const 28
        i32.shl
        local.get 5
        i32.or
        local.set 5
      end
      local.get 2
      local.get 5
      i32.store
      i32.const 1
      local.set 3
    end
    local.get 3)
  (func $snappy_uncompress (type 6) (param i32 i32 i32) (result i32)
    (local i32 i32 i32 i32 i32 i32)
    global.get $__stack_pointer
    i32.const 48
    i32.sub
    local.tee 3
    global.set $__stack_pointer
    local.get 3
    local.get 2
    i32.store offset=4
    local.get 3
    local.get 2
    i32.store
    local.get 3
    i32.const 0
    i32.store8 offset=36
    local.get 3
    i32.const 0
    i32.store offset=32
    local.get 3
    i64.const 0
    i64.store offset=24 align=4
    local.get 3
    local.get 3
    i32.const 12
    i32.add
    i32.store offset=20
    local.get 3
    i32.load offset=12
    local.set 4
    local.get 3
    i32.load offset=16
    local.set 5
    i32.const 0
    local.set 6
    i32.const 0
    local.set 7
    block  ;; label = @1
      block  ;; label = @2
        block  ;; label = @3
          block  ;; label = @4
            loop  ;; label = @5
              local.get 7
              i32.const 31
              i32.gt_u
              br_if 1 (;@4;)
              local.get 1
              i32.eqz
              br_if 1 (;@4;)
              local.get 0
              i32.load8_s
              local.tee 8
              i32.const 127
              i32.and
              local.get 7
              i32.shl
              local.get 6
              i32.or
              local.set 6
              local.get 0
              i32.const 1
              i32.add
              local.tee 4
              local.set 0
              local.get 1
              i32.const -1
              i32.add
              local.tee 5
              local.set 1
              local.get 7
              i32.const 7
              i32.add
              local.set 7
              local.get 8
              i32.const 0
              i32.lt_s
              br_if 0 (;@5;)
            end
            local.get 3
            local.get 4
            i32.store offset=12
            local.get 3
            local.get 5
            i32.store offset=16
            local.get 3
            local.get 2
            local.get 6
            i32.add
            i32.store offset=8
            local.get 3
            i32.const 20
            i32.add
            call $refill_tag
            i32.eqz
            br_if 1 (;@3;)
            local.get 3
            i32.load offset=24
            local.set 1
            loop  ;; label = @5
              block  ;; label = @6
                local.get 3
                i32.load offset=28
                local.get 1
                i32.sub
                i32.const 4
                i32.gt_s
                br_if 0 (;@6;)
                local.get 3
                local.get 1
                i32.store offset=24
                local.get 3
                i32.const 20
                i32.add
                call $refill_tag
                i32.eqz
                br_if 3 (;@3;)
                local.get 3
                i32.load offset=24
                local.set 1
              end
              local.get 1
              i32.const 1
              i32.add
              local.set 8
              block  ;; label = @6
                block  ;; label = @7
                  local.get 1
                  i32.load8_u
                  local.tee 0
                  i32.const 3
                  i32.and
                  br_if 0 (;@7;)
                  local.get 3
                  i32.load offset=28
                  local.get 8
                  i32.sub
                  local.set 7
                  local.get 0
                  i32.const 2
                  i32.shr_u
                  local.tee 5
                  i32.const 1
                  i32.add
                  local.set 6
                  block  ;; label = @8
                    local.get 0
                    i32.const 63
                    i32.gt_u
                    br_if 0 (;@8;)
                    local.get 7
                    i32.const 16
                    i32.lt_u
                    br_if 0 (;@8;)
                    local.get 3
                    i32.load offset=8
                    local.get 3
                    i32.load offset=4
                    local.tee 4
                    i32.sub
                    i32.const 16
                    i32.lt_s
                    br_if 0 (;@8;)
                    local.get 8
                    local.get 4
                    call $unaligned_copy64
                    local.get 1
                    i32.const 9
                    i32.add
                    local.get 4
                    i32.const 8
                    i32.add
                    call $unaligned_copy64
                    local.get 3
                    local.get 4
                    local.get 6
                    i32.add
                    i32.store offset=4
                    local.get 3
                    i32.load offset=28
                    local.get 8
                    local.get 6
                    i32.add
                    local.tee 1
                    i32.sub
                    i32.const 4
                    i32.gt_s
                    br_if 3 (;@5;)
                    local.get 3
                    local.get 1
                    i32.store offset=24
                    local.get 3
                    i32.const 20
                    i32.add
                    call $refill_tag
                    i32.eqz
                    br_if 5 (;@3;)
                    br 2 (;@6;)
                  end
                  block  ;; label = @8
                    local.get 0
                    i32.const 237
                    i32.lt_u
                    br_if 0 (;@8;)
                    local.get 3
                    i32.const 44
                    i32.add
                    local.get 8
                    i32.const 4
                    call $memcpy
                    local.set 7
                    local.get 5
                    i32.const -59
                    i32.add
                    local.tee 1
                    i32.const 2
                    i32.shl
                    i32.const 1024
                    i32.add
                    i32.load
                    local.get 7
                    i32.load
                    i32.and
                    i32.const 1
                    i32.add
                    local.set 6
                    local.get 3
                    i32.load offset=28
                    local.get 8
                    local.get 1
                    i32.add
                    local.tee 8
                    i32.sub
                    local.set 7
                  end
                  block  ;; label = @8
                    loop  ;; label = @9
                      local.get 6
                      local.get 7
                      i32.le_u
                      br_if 1 (;@8;)
                      local.get 3
                      local.get 8
                      local.get 7
                      call $writer_append
                      i32.eqz
                      br_if 6 (;@3;)
                      local.get 3
                      i32.load offset=20
                      local.tee 1
                      local.get 1
                      i32.load offset=4
                      local.tee 4
                      local.get 3
                      i32.load offset=32
                      local.tee 8
                      i32.sub
                      local.tee 0
                      i32.store offset=4
                      local.get 1
                      local.get 8
                      local.get 1
                      i32.load
                      local.tee 5
                      i32.add
                      local.tee 8
                      i32.store
                      local.get 3
                      local.get 0
                      i32.store offset=32
                      local.get 0
                      i32.eqz
                      br_if 6 (;@3;)
                      local.get 3
                      local.get 5
                      local.get 4
                      i32.add
                      i32.store offset=28
                      local.get 6
                      local.get 7
                      i32.sub
                      local.set 6
                      local.get 0
                      local.set 7
                      br 0 (;@9;)
                    end
                  end
                  local.get 3
                  local.get 8
                  local.get 6
                  call $writer_append
                  i32.eqz
                  br_if 4 (;@3;)
                  local.get 3
                  i32.load offset=28
                  local.get 8
                  local.get 6
                  i32.add
                  local.tee 1
                  i32.sub
                  i32.const 4
                  i32.gt_s
                  br_if 2 (;@5;)
                  local.get 3
                  local.get 1
                  i32.store offset=24
                  local.get 3
                  i32.const 20
                  i32.add
                  call $refill_tag
                  br_if 1 (;@6;)
                  br 4 (;@3;)
                end
                local.get 3
                i32.const 44
                i32.add
                local.get 8
                i32.const 4
                call $memcpy
                local.set 1
                local.get 3
                i32.load offset=4
                local.tee 4
                local.get 3
                i32.load
                i32.sub
                local.get 0
                i32.const 1
                i32.shl
                i32.const 1056
                i32.add
                i32.load16_u
                local.tee 7
                i32.const 11
                i32.shr_u
                local.tee 2
                i32.const 2
                i32.shl
                i32.const 1024
                i32.add
                i32.load
                local.get 1
                i32.load
                i32.and
                local.get 7
                i32.const 1792
                i32.and
                i32.add
                local.tee 0
                i32.const -1
                i32.add
                i32.le_u
                br_if 3 (;@3;)
                local.get 3
                i32.load offset=8
                local.get 4
                i32.sub
                local.set 1
                block  ;; label = @7
                  block  ;; label = @8
                    local.get 7
                    i32.const 255
                    i32.and
                    local.tee 5
                    i32.const 16
                    i32.gt_u
                    br_if 0 (;@8;)
                    local.get 0
                    i32.const 8
                    i32.lt_u
                    br_if 0 (;@8;)
                    local.get 1
                    i32.const 16
                    i32.lt_u
                    br_if 0 (;@8;)
                    local.get 4
                    local.get 0
                    i32.sub
                    local.tee 7
                    local.get 4
                    call $unaligned_copy64
                    local.get 7
                    i32.const 8
                    i32.add
                    local.get 4
                    i32.const 8
                    i32.add
                    call $unaligned_copy64
                    br 1 (;@7;)
                  end
                  block  ;; label = @8
                    local.get 1
                    local.get 5
                    i32.const 10
                    i32.add
                    i32.lt_u
                    br_if 0 (;@8;)
                    local.get 4
                    local.get 0
                    i32.sub
                    local.set 1
                    local.get 4
                    local.set 7
                    local.get 5
                    local.set 0
                    block  ;; label = @9
                      loop  ;; label = @10
                        local.get 7
                        local.get 1
                        i32.sub
                        local.tee 6
                        i32.const 8
                        i32.ge_s
                        br_if 1 (;@9;)
                        local.get 1
                        local.get 7
                        call $unaligned_copy64
                        local.get 7
                        local.get 6
                        i32.add
                        local.set 7
                        local.get 0
                        local.get 6
                        i32.sub
                        local.set 0
                        br 0 (;@10;)
                      end
                    end
                    loop  ;; label = @9
                      local.get 0
                      i32.const 1
                      i32.lt_s
                      br_if 2 (;@7;)
                      local.get 1
                      local.get 7
                      call $unaligned_copy64
                      local.get 0
                      i32.const -8
                      i32.add
                      local.set 0
                      local.get 7
                      i32.const 8
                      i32.add
                      local.set 7
                      local.get 1
                      i32.const 8
                      i32.add
                      local.set 1
                      br 0 (;@9;)
                    end
                  end
                  local.get 1
                  local.get 5
                  i32.lt_u
                  br_if 4 (;@3;)
                  local.get 5
                  i32.const 1
                  i32.add
                  local.set 1
                  i32.const 0
                  local.get 0
                  i32.sub
                  local.set 0
                  local.get 4
                  local.set 7
                  loop  ;; label = @8
                    local.get 7
                    local.get 7
                    local.get 0
                    i32.add
                    i32.load8_u
                    i32.store8
                    local.get 7
                    i32.const 1
                    i32.add
                    local.set 7
                    local.get 1
                    i32.const -1
                    i32.add
                    local.tee 1
                    i32.const 1
                    i32.gt_u
                    br_if 0 (;@8;)
                  end
                end
                local.get 3
                local.get 4
                local.get 5
                i32.add
                i32.store offset=4
                local.get 3
                i32.load offset=28
                local.get 8
                local.get 2
                i32.add
                local.tee 1
                i32.sub
                i32.const 4
                i32.gt_s
                br_if 1 (;@5;)
                local.get 3
                local.get 1
                i32.store offset=24
                local.get 3
                i32.const 20
                i32.add
                call $refill_tag
                i32.eqz
                br_if 3 (;@3;)
              end
              local.get 3
              i32.load offset=24
              local.set 1
              br 0 (;@5;)
            end
          end
          local.get 3
          local.get 4
          i32.store offset=12
          local.get 3
          local.get 5
          i32.store offset=16
          br 1 (;@2;)
        end
        local.get 3
        i32.load offset=20
        local.tee 7
        local.get 7
        i32.load offset=4
        local.get 3
        i32.load offset=32
        local.tee 1
        i32.sub
        i32.store offset=4
        local.get 7
        local.get 1
        local.get 7
        i32.load
        i32.add
        i32.store
        local.get 3
        i32.load8_u offset=36
        i32.eqz
        br_if 0 (;@2;)
        local.get 3
        i32.load offset=4
        local.get 3
        i32.load offset=8
        i32.ne
        br_if 0 (;@2;)
        i32.const 0
        local.set 7
        br 1 (;@1;)
      end
      i32.const -5
      local.set 7
    end
    local.get 3
    i32.const 48
    i32.add
    global.set $__stack_pointer
    local.get 7)
  (func $snappy_uncompressed_length (type 6) (param i32 i32 i32) (result i32)
    local.get 0
    local.get 1
    local.get 2
    call $snappy_uncompressed_length_internal)
  (func $snappy_uncompressed_length_with_len (type 4) (param i32 i32 i32 i32) (result i32)
    (local i32)
    i32.const 0
    local.set 4
    block  ;; label = @1
      local.get 3
      i32.const 4
      i32.lt_u
      br_if 0 (;@1;)
      local.get 0
      local.get 1
      local.get 2
      call $snappy_uncompressed_length_internal
      local.set 4
    end
    local.get 4)
  (func $snappy_verify_compress_len (type 2) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.lt_u)
  (func $refill_tag (type 1) (param i32) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32)
    block  ;; label = @1
      block  ;; label = @2
        local.get 0
        i32.load offset=4
        local.tee 1
        local.get 0
        i32.load offset=8
        local.tee 2
        i32.ne
        br_if 0 (;@2;)
        local.get 0
        i32.load
        local.tee 2
        local.get 2
        i32.load offset=4
        local.tee 3
        local.get 0
        i32.load offset=12
        local.tee 4
        i32.sub
        local.tee 5
        i32.store offset=4
        local.get 2
        local.get 4
        local.get 2
        i32.load
        local.tee 6
        i32.add
        local.tee 1
        i32.store
        local.get 0
        local.get 5
        i32.store offset=12
        block  ;; label = @3
          local.get 3
          local.get 4
          i32.ne
          br_if 0 (;@3;)
          local.get 0
          i32.const 1
          i32.store8 offset=16
          br 2 (;@1;)
        end
        local.get 0
        local.get 6
        local.get 3
        i32.add
        local.tee 2
        i32.store offset=8
      end
      block  ;; label = @2
        block  ;; label = @3
          local.get 2
          local.get 1
          i32.sub
          local.tee 2
          local.get 1
          i32.load8_u
          i32.const 1
          i32.shl
          i32.const 1056
          i32.add
          i32.load16_u
          i32.const 11
          i32.shr_u
          i32.const 1
          i32.add
          local.tee 5
          i32.ge_u
          br_if 0 (;@3;)
          local.get 0
          i32.const 17
          i32.add
          local.get 1
          local.get 2
          call $memmove
          local.set 7
          local.get 0
          i32.load offset=12
          local.set 3
          local.get 0
          i32.const 0
          i32.store offset=12
          local.get 0
          i32.load
          local.tee 4
          local.get 4
          i32.load offset=4
          local.get 3
          i32.sub
          local.tee 1
          i32.store offset=4
          local.get 4
          local.get 3
          local.get 4
          i32.load
          i32.add
          local.tee 6
          i32.store
          block  ;; label = @4
            loop  ;; label = @5
              local.get 5
              local.get 2
              i32.le_u
              br_if 1 (;@4;)
              local.get 1
              i32.eqz
              br_if 4 (;@1;)
              local.get 7
              local.get 2
              i32.add
              local.get 6
              local.get 5
              local.get 2
              i32.sub
              local.tee 4
              local.get 1
              local.get 4
              local.get 1
              i32.lt_u
              select
              local.tee 4
              call $memcpy
              drop
              local.get 0
              i32.load
              local.tee 3
              local.get 3
              i32.load offset=4
              local.get 4
              i32.sub
              local.tee 1
              i32.store offset=4
              local.get 3
              local.get 4
              local.get 3
              i32.load
              i32.add
              local.tee 6
              i32.store
              local.get 4
              local.get 2
              i32.add
              local.set 2
              br 0 (;@5;)
            end
          end
          local.get 0
          local.get 7
          i32.store offset=4
          local.get 0
          local.get 7
          local.get 5
          i32.add
          i32.store offset=8
          br 1 (;@2;)
        end
        block  ;; label = @3
          local.get 2
          i32.const 4
          i32.gt_u
          br_if 0 (;@3;)
          local.get 0
          local.get 0
          i32.const 17
          i32.add
          local.get 1
          local.get 2
          call $memmove
          local.tee 4
          i32.store offset=4
          local.get 0
          i32.load offset=12
          local.set 1
          local.get 0
          i32.const 0
          i32.store offset=12
          local.get 0
          local.get 4
          local.get 2
          i32.add
          i32.store offset=8
          local.get 0
          i32.load
          local.tee 2
          local.get 2
          i32.load offset=4
          local.get 1
          i32.sub
          i32.store offset=4
          local.get 2
          local.get 1
          local.get 2
          i32.load
          i32.add
          i32.store
          br 1 (;@2;)
        end
        local.get 0
        local.get 1
        i32.store offset=4
      end
      i32.const 1
      return
    end
    i32.const 0)
  (func $unaligned_copy64 (type 9) (param i32 i32)
    (local i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee 2
    global.set $__stack_pointer
    local.get 1
    local.get 2
    i32.const 12
    i32.add
    local.get 0
    i32.const 4
    call $memcpy
    i32.const 4
    call $memcpy
    i32.const 4
    i32.add
    local.get 2
    i32.const 8
    i32.add
    local.get 0
    i32.const 4
    i32.add
    i32.const 4
    call $memcpy
    i32.const 4
    call $memcpy
    drop
    local.get 2
    i32.const 16
    i32.add
    global.set $__stack_pointer)
  (func $writer_append (type 6) (param i32 i32 i32) (result i32)
    (local i32 i32)
    block  ;; label = @1
      local.get 0
      i32.load offset=8
      local.get 0
      i32.load offset=4
      local.tee 3
      i32.sub
      local.tee 4
      local.get 2
      i32.lt_u
      br_if 0 (;@1;)
      local.get 0
      local.get 3
      local.get 1
      local.get 2
      call $memcpy
      local.get 2
      i32.add
      i32.store offset=4
    end
    local.get 4
    local.get 2
    i32.ge_u)
  (func $memmove (type 6) (param i32 i32 i32) (result i32)
    (local i32)
    block  ;; label = @1
      local.get 0
      local.get 1
      i32.eq
      br_if 0 (;@1;)
      local.get 2
      i32.eqz
      br_if 0 (;@1;)
      block  ;; label = @2
        local.get 0
        local.get 1
        i32.lt_u
        br_if 0 (;@2;)
        local.get 1
        i32.const -1
        i32.add
        local.set 1
        local.get 0
        i32.const -1
        i32.add
        local.set 3
        loop  ;; label = @3
          local.get 2
          i32.eqz
          br_if 2 (;@1;)
          local.get 3
          local.get 2
          i32.add
          local.get 1
          local.get 2
          i32.add
          i32.load8_u
          i32.store8
          local.get 2
          i32.const -1
          i32.add
          local.set 2
          br 0 (;@3;)
        end
      end
      local.get 0
      local.set 3
      loop  ;; label = @2
        local.get 2
        i32.eqz
        br_if 1 (;@1;)
        local.get 3
        local.get 1
        i32.load8_u
        i32.store8
        local.get 3
        i32.const 1
        i32.add
        local.set 3
        local.get 1
        i32.const 1
        i32.add
        local.set 1
        local.get 2
        i32.const -1
        i32.add
        local.set 2
        br 0 (;@2;)
      end
    end
    local.get 0)
  (func $malloc (type 1) (param i32) (result i32)
    (local i32)
    i32.const 0
    i32.const 0
    i32.load offset=13873468
    local.tee 1
    i32.const 13939008
    local.get 1
    select
    local.tee 1
    i32.const 8
    local.get 1
    i32.const 7
    i32.and
    local.tee 1
    i32.sub
    i32.const 0
    local.get 1
    select
    i32.add
    local.tee 1
    local.get 0
    i32.add
    i32.store offset=13873468
    local.get 1)
  (func $memset (type 6) (param i32 i32 i32) (result i32)
    (local i32)
    i32.const 0
    local.set 3
    loop (result i32)  ;; label = @1
      block  ;; label = @2
        local.get 2
        local.get 3
        i32.ne
        br_if 0 (;@2;)
        local.get 0
        return
      end
      local.get 0
      local.get 3
      i32.add
      local.get 1
      i32.store8
      local.get 3
      i32.const 1
      i32.add
      local.set 3
      br 0 (;@1;)
    end)
  (func $append (type 10) (param i32 i32 i32)
    (local i32)
    block  ;; label = @1
      local.get 0
      i32.load
      local.tee 3
      local.get 1
      i32.eq
      br_if 0 (;@1;)
      local.get 3
      local.get 1
      local.get 2
      call $memcpy
      drop
      local.get 0
      i32.load
      local.set 1
    end
    local.get 0
    local.get 1
    local.get 2
    i32.add
    i32.store)
  (func $hash (type 2) (param i32 i32) (result i32)
    (local i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee 2
    global.set $__stack_pointer
    local.get 2
    i32.const 12
    i32.add
    local.get 0
    i32.const 4
    call $memcpy
    i32.load
    local.set 0
    local.get 2
    i32.const 16
    i32.add
    global.set $__stack_pointer
    local.get 0
    i32.const 506832829
    i32.mul
    local.get 1
    i32.shr_u)
  (func $emit_literal (type 4) (param i32 i32 i32 i32) (result i32)
    (local i32 i32)
    local.get 2
    i32.const -1
    i32.add
    local.set 4
    block  ;; label = @1
      block  ;; label = @2
        block  ;; label = @3
          block  ;; label = @4
            local.get 2
            i32.const 61
            i32.lt_s
            br_if 0 (;@4;)
            i32.const 1
            local.set 3
            loop  ;; label = @5
              local.get 0
              local.get 3
              i32.add
              local.set 5
              local.get 4
              i32.const 1
              i32.lt_s
              br_if 2 (;@3;)
              local.get 5
              local.get 4
              i32.store8
              local.get 3
              i32.const 1
              i32.add
              local.set 3
              local.get 4
              i32.const 8
              i32.shr_u
              local.set 4
              br 0 (;@5;)
            end
          end
          local.get 0
          local.get 4
          i32.const 2
          i32.shl
          i32.store8
          local.get 0
          i32.const 1
          i32.add
          local.set 5
          local.get 2
          i32.const 16
          i32.gt_s
          br_if 1 (;@2;)
          local.get 3
          i32.eqz
          br_if 1 (;@2;)
          local.get 1
          local.get 5
          call $unaligned_copy64
          local.get 1
          i32.const 8
          i32.add
          local.get 0
          i32.const 9
          i32.add
          call $unaligned_copy64
          br 2 (;@1;)
        end
        local.get 0
        local.get 3
        i32.const 2
        i32.shl
        i32.const -24
        i32.add
        i32.store8
      end
      local.get 5
      local.get 1
      local.get 2
      call $memcpy
      local.set 5
    end
    local.get 5
    local.get 2
    i32.add)
  (func $emit_copy_less_than64 (type 6) (param i32 i32 i32) (result i32)
    (local i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee 3
    global.set $__stack_pointer
    block  ;; label = @1
      block  ;; label = @2
        local.get 1
        i32.const 2047
        i32.gt_s
        br_if 0 (;@2;)
        local.get 2
        i32.const 11
        i32.gt_s
        br_if 0 (;@2;)
        local.get 0
        local.get 1
        i32.store8 offset=1
        local.get 0
        local.get 2
        i32.const 2
        i32.shl
        local.get 1
        i32.const 3
        i32.shr_u
        i32.const 224
        i32.and
        i32.add
        i32.const 241
        i32.add
        i32.store8
        local.get 0
        i32.const 2
        i32.add
        local.set 0
        br 1 (;@1;)
      end
      local.get 0
      local.get 2
      i32.const 2
      i32.shl
      i32.const -2
      i32.add
      i32.store8
      local.get 3
      local.get 1
      i32.store offset=12
      local.get 0
      i32.const 1
      i32.add
      local.get 3
      i32.const 12
      i32.add
      i32.const 2
      call $memcpy
      drop
      local.get 0
      i32.const 3
      i32.add
      local.set 0
    end
    local.get 3
    i32.const 16
    i32.add
    global.set $__stack_pointer
    local.get 0)
  (func $get_u32_at_offset (type 2) (param i32 i32) (result i32)
    (local i32)
    global.get $__stack_pointer
    i32.const 16
    i32.sub
    local.tee 2
    global.set $__stack_pointer
    local.get 2
    i32.const 12
    i32.add
    local.get 0
    local.get 1
    i32.add
    i32.const 4
    call $memcpy
    i32.load
    local.set 1
    local.get 2
    i32.const 16
    i32.add
    global.set $__stack_pointer
    local.get 1)
  (func $calloc (type 2) (param i32 i32) (result i32)
    local.get 1
    local.get 0
    i32.mul
    local.tee 0
    call $malloc
    i32.const 0
    local.get 0
    call $memset)
  (func $realloc (type 2) (param i32 i32) (result i32)
    block  ;; label = @1
      local.get 0
      br_if 0 (;@1;)
      local.get 1
      call $malloc
      return
    end
    block  ;; label = @1
      local.get 1
      br_if 0 (;@1;)
      i32.const 0
      return
    end
    local.get 1
    call $malloc
    local.get 0
    local.get 1
    call $memcpy)
  (table (;0;) 1 1 funcref)
  (memory (;0;) 320 320)
  (global $__stack_pointer (mut i32) (i32.const 13939008))
  (global (;1;) i32 (i32.const 13939008))
  (global (;2;) i32 (i32.const 1024))
  (global (;3;) i32 (i32.const 13873472))
  (global (;4;) i32 (i32.const 1024))
  (global (;5;) i32 (i32.const 20971520))
  (global (;6;) i32 (i32.const 0))
  (global (;7;) i32 (i32.const 1))
  (export "memory" (memory 0))
  (export "__wasm_call_ctors" (func $__wasm_call_ctors))
  (export "bench_prepare" (func $bench_prepare))
  (export "bench_fill_target_from_pool" (func $bench_fill_target_from_pool))
  (export "bench_snappy_compress" (func $bench_snappy_compress))
  (export "snappy_init_env_with_len" (func $snappy_init_env_with_len))
  (export "snappy_max_compressed_length" (func $snappy_max_compressed_length))
  (export "snappy_compress_with_len" (func $snappy_compress_with_len))
  (export "bench_snappy_uncompress" (func $bench_snappy_uncompress))
  (export "snappy_uncompress_with_len" (func $snappy_uncompress_with_len))
  (export "bench_verify_compress" (func $bench_verify_compress))
  (export "bench_get_compressed_len" (func $bench_get_compressed_len))
  (export "bench_verify_uncompress" (func $bench_verify_uncompress))
  (export "memcmp" (func $memcmp))
  (export "bench_debug_uncomp_compressed_ptr" (func $bench_debug_uncomp_compressed_ptr))
  (export "bench_debug_uncomp_compressed_len" (func $bench_debug_uncomp_compressed_len))
  (export "bench_debug_uncomp_dst_ptr" (func $bench_debug_uncomp_dst_ptr))
  (export "bench_debug_uncomp_dst_len" (func $bench_debug_uncomp_dst_len))
  (export "bench_debug_uncomp_last_ret" (func $bench_debug_uncomp_last_ret))
  (export "bench_debug_first_mismatch" (func $bench_debug_first_mismatch))
  (export "bench_debug_target_byte_at" (func $bench_debug_target_byte_at))
  (export "bench_debug_uncompressed_byte_at" (func $bench_debug_uncompressed_byte_at))
  (export "rust_begin_unwind" (func $rust_begin_unwind))
  (export "memcpy" (func $memcpy))
  (export "snappy_compress" (func $snappy_compress))
  (export "snappy_dbg_last_compressed_ptr" (func $snappy_dbg_last_compressed_ptr))
  (export "snappy_dbg_last_expected" (func $snappy_dbg_last_expected))
  (export "snappy_dbg_last_n" (func $snappy_dbg_last_n))
  (export "snappy_dbg_last_stage" (func $snappy_dbg_last_stage))
  (export "snappy_dbg_last_uncompressed_len" (func $snappy_dbg_last_uncompressed_len))
  (export "snappy_dbg_last_uncompressed_ptr" (func $snappy_dbg_last_uncompressed_ptr))
  (export "snappy_free_env" (func $snappy_free_env))
  (export "free" (func $free))
  (export "snappy_init_env" (func $snappy_init_env))
  (export "snappy_uncompress" (func $snappy_uncompress))
  (export "snappy_uncompressed_length" (func $snappy_uncompressed_length))
  (export "snappy_uncompressed_length_with_len" (func $snappy_uncompressed_length_with_len))
  (export "snappy_verify_compress_len" (func $snappy_verify_compress_len))
  (export "memmove" (func $memmove))
  (export "malloc" (func $malloc))
  (export "memset" (func $memset))
  (export "__heap_base" (global 1))
  (export "calloc" (func $calloc))
  (export "realloc" (func $realloc))
  (export "__indirect_function_table" (table 0))
  (export "__dso_handle" (global 2))
  (export "__data_end" (global 3))
  (export "__global_base" (global 4))
  (export "__heap_end" (global 5))
  (export "__memory_base" (global 6))
  (export "__table_base" (global 7))
  (data $.rodata (i32.const 1024) "\00\00\00\00\ff\00\00\00\ff\ff\00\00\ff\ff\ff\00\ff\ff\ff\ff\00\00\00\00\00\00\00\00\00\00\00\00\01\00\04\08\01\10\01 \02\00\05\08\02\10\02 \03\00\06\08\03\10\03 \04\00\07\08\04\10\04 \05\00\08\08\05\10\05 \06\00\09\08\06\10\06 \07\00\0a\08\07\10\07 \08\00\0b\08\08\10\08 \09\00\04\09\09\10\09 \0a\00\05\09\0a\10\0a \0b\00\06\09\0b\10\0b \0c\00\07\09\0c\10\0c \0d\00\08\09\0d\10\0d \0e\00\09\09\0e\10\0e \0f\00\0a\09\0f\10\0f \10\00\0b\09\10\10\10 \11\00\04\0a\11\10\11 \12\00\05\0a\12\10\12 \13\00\06\0a\13\10\13 \14\00\07\0a\14\10\14 \15\00\08\0a\15\10\15 \16\00\09\0a\16\10\16 \17\00\0a\0a\17\10\17 \18\00\0b\0a\18\10\18 \19\00\04\0b\19\10\19 \1a\00\05\0b\1a\10\1a \1b\00\06\0b\1b\10\1b \1c\00\07\0b\1c\10\1c \1d\00\08\0b\1d\10\1d \1e\00\09\0b\1e\10\1e \1f\00\0a\0b\1f\10\1f  \00\0b\0b \10  !\00\04\0c!\10! \22\00\05\0c\22\10\22 #\00\06\0c#\10# $\00\07\0c$\10$ %\00\08\0c%\10% &\00\09\0c&\10& '\00\0a\0c'\10' (\00\0b\0c(\10( )\00\04\0d)\10) *\00\05\0d*\10* +\00\06\0d+\10+ ,\00\07\0d,\10, -\00\08\0d-\10- .\00\09\0d.\10. /\00\0a\0d/\10/ 0\00\0b\0d0\100 1\00\04\0e1\101 2\00\05\0e2\102 3\00\06\0e3\103 4\00\07\0e4\104 5\00\08\0e5\105 6\00\09\0e6\106 7\00\0a\0e7\107 8\00\0b\0e8\108 9\00\04\0f9\109 :\00\05\0f:\10: ;\00\06\0f;\10; <\00\07\0f<\10< \01\08\08\0f=\10= \01\10\09\0f>\10> \01\18\0a\0f?\10? \01 \0b\0f@\10@ "))
