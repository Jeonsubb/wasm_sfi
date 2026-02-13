#!/usr/bin/env python3
import csv
import os
import time

try:
    import wasmtime
except ImportError:
    raise SystemExit("missing python module: wasmtime (try: pip install wasmtime)")

ROOT = os.path.dirname(os.path.abspath(__file__))

MIN_POW = int(os.environ.get("BENCH_MIN_POW", "0"))
MAX_POW = int(os.environ.get("BENCH_MAX_POW", "21"))
SIZES = [1 << i for i in range(MIN_POW, MAX_POW + 1)]
RUNS = int(os.environ.get("BENCH_RUNS", "5"))

TIME_UNIT = "us"
TIME_SCALE = 1_000_000.0

VARIANT = "sfi"
WASM = os.path.join(ROOT, "build", "sfi", "final_sfi_snappy.wasm")
RESULT_DIR = os.path.join(ROOT, "bench_result")


def make_engine():
    config = wasmtime.Config()
    if hasattr(config, "wasm_multi_memory"):
        config.wasm_multi_memory = True
    return wasmtime.Engine(config)


def create_instance(engine, module):
    store = wasmtime.Store(engine)
    instance = wasmtime.Instance(store, module, [])
    return store, instance


def get_func(store, instance, name):
    exports = instance.exports(store)
    if name not in exports:
        raise SystemExit(f"missing export: {name}")
    return exports[name]


def run_uncompress_bench(fresh_funcs, out_csv_compress, out_csv_uncompress):
    comp_rows = []
    uncomp_rows = []
    for size in SIZES:
        for i in range(RUNS):
            (
                store,
                prepare_func,
                compress_func,
                uncompress_func,
                get_compressed_len_func,
                verify_uncompress_func,
            ) = fresh_funcs()
            try:
                ret = prepare_func(store, size)
            except Exception as exc:
                comp_rows.append(["bench_snappy_compress", VARIANT, size, i, "ERR", "", f"prepare: {exc}"])
                uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, "ERR", "", f"prepare: {exc}"])
                continue
            if ret is None:
                ret = 0
            if ret != 0:
                comp_rows.append(["bench_snappy_compress", VARIANT, size, i, "ERR", "", f"prepare: {ret}"])
                uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, "ERR", "", f"prepare: {ret}"])
                continue

            t0 = time.perf_counter()
            try:
                ret = compress_func(store, size)
            except Exception as exc:
                comp_rows.append(["bench_snappy_compress", VARIANT, size, i, "ERR", "", str(exc)])
                uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, "ERR", "", f"compress: {exc}"])
                continue
            t1 = time.perf_counter()
            if ret is None:
                ret = 0
            if ret != 0:
                comp_rows.append(["bench_snappy_compress", VARIANT, size, i, "ERR", "", ret])
                uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, "ERR", "", f"compress: {ret}"])
                continue
            comp_elapsed = (t1 - t0) * TIME_SCALE

            try:
                clen = get_compressed_len_func(store)
            except Exception as exc:
                comp_rows.append(["bench_snappy_compress", VARIANT, size, i, "ERR", "", f"compressed_len: {exc}"])
                uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, "ERR", "", f"compressed_len: {exc}"])
                continue

            comp_rows.append(["bench_snappy_compress", VARIANT, size, i, f"{comp_elapsed:.3f}", clen, 0])

            # uncompress timing
            t0 = time.perf_counter()
            try:
                ret = uncompress_func(store, size)
            except Exception as exc:
                uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, "ERR", clen, f"uncompress: {exc}"])
                continue
            t1 = time.perf_counter()
            if ret is None:
                ret = 0
            if ret != 0:
                uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, "ERR", clen, f"uncompress: {ret}"])
                continue
            uncomp_elapsed = (t1 - t0) * TIME_SCALE
            # verify_uncompress (result validation)
            try:
                ret = verify_uncompress_func(store, size)
            except Exception as exc:
                uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, "ERR", clen, f"verify_uncompress: {exc}"])
                continue
            if ret is None:
                ret = 0
            if ret != 0:
                uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, "ERR", clen, f"verify_uncompress: {ret}"])
                continue
            uncomp_rows.append(["bench_snappy_uncompress", VARIANT, size, i, f"{uncomp_elapsed:.3f}", clen, 0])

    os.makedirs(RESULT_DIR, exist_ok=True)
    with open(out_csv_compress, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["bench", "variant", "size", "run", TIME_UNIT, "compressed_len", "ret"])
        w.writerows(comp_rows)
    with open(out_csv_uncompress, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["bench", "variant", "size", "run", TIME_UNIT, "compressed_len", "ret"])
        w.writerows(uncomp_rows)

    print(f"wrote: {out_csv_compress}")
    print(f"wrote: {out_csv_uncompress}")


def main():
    if not os.path.exists(WASM):
        raise SystemExit(f"missing: {WASM}")

    engine = make_engine()
    module = wasmtime.Module.from_file(engine, WASM)

    def fresh_funcs():
        store, instance = create_instance(engine, module)
        prepare_func = get_func(store, instance, "bench_prepare")
        compress_func = get_func(store, instance, "bench_snappy_compress")
        uncompress_func = get_func(store, instance, "bench_snappy_uncompress")
        get_compressed_len = get_func(store, instance, "bench_get_compressed_len")
        verify_uncompress = get_func(store, instance, "bench_verify_uncompress")
        return (
            store,
            prepare_func,
            compress_func,
            uncompress_func,
            get_compressed_len,
            verify_uncompress,
        )

    run_uncompress_bench(
        fresh_funcs,
        os.path.join(RESULT_DIR, "sfi_compress.csv"),
        os.path.join(RESULT_DIR, "sfi_uncompress.csv"),
    )


if __name__ == "__main__":
    main()

