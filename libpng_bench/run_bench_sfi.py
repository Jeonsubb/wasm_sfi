#!/usr/bin/env python3
import csv
import os
import time

try:
    import wasmtime
except ImportError:
    raise SystemExit("missing python module: wasmtime (try: pip install wasmtime)")

ROOT = os.path.dirname(os.path.abspath(__file__))
MANIFEST = os.environ.get("DATASET_MANIFEST", os.path.join(ROOT, "data", "dataset_sizes.csv"))

MIN_POW = int(os.environ.get("BENCH_MIN_POW", "10"))
MAX_POW = int(os.environ.get("BENCH_MAX_POW", "21"))
RUNS = int(os.environ.get("BENCH_RUNS", "5"))

TIME_UNIT = "us"
TIME_SCALE = 1_000_000.0

VARIANT = "sfi"
WASM = os.path.join(ROOT, "build", "sfi", "final_sfi_libpng.wasm")
RESULT_DIR = os.path.join(ROOT, "bench_result")


def compute_compression_ratio(raw_size, encoded_size):
    # libpng는 "얼마나 빨랐는가"뿐 아니라 "얼마나 줄였는가"를 함께 봐야
    # 품질/성능 trade-off를 해석할 수 있으므로 ratio를 각 run 결과에 기록한다.
    if raw_size <= 0:
        return ""
    return f"{(float(encoded_size) / float(raw_size)):.6f}"


def load_sizes():
    sizes = []
    if os.path.exists(MANIFEST):
        with open(MANIFEST, "r", newline="") as f:
            for row in csv.DictReader(f):
                try:
                    sizes.append(int(row["raw_bytes"]))
                except (KeyError, ValueError):
                    continue
    if sizes:
        return sizes
    return [1 << i for i in range(MIN_POW, MAX_POW + 1)]


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


def run_bench(sizes, fresh_funcs, out_csv_encode, out_csv_decode):
    enc_rows = []
    dec_rows = []
    for size in sizes:
        for i in range(RUNS):
            store, prepare_func, encode_func, decode_func, get_encoded_len, verify_decode = fresh_funcs()
            try:
                ret = prepare_func(store, size)
            except Exception as exc:
                enc_rows.append(["bench_png_encode", VARIANT, size, i, "ERR", "", "", f"prepare: {exc}"])
                dec_rows.append(["bench_png_decode", VARIANT, size, i, "ERR", "", "", f"prepare: {exc}"])
                continue
            if ret is None:
                ret = 0
            if ret != 0:
                enc_rows.append(["bench_png_encode", VARIANT, size, i, "ERR", "", "", f"prepare: {ret}"])
                dec_rows.append(["bench_png_decode", VARIANT, size, i, "ERR", "", "", f"prepare: {ret}"])
                continue

            t0 = time.perf_counter()
            try:
                ret = encode_func(store, size)
            except Exception as exc:
                enc_rows.append(["bench_png_encode", VARIANT, size, i, "ERR", "", "", str(exc)])
                dec_rows.append(["bench_png_decode", VARIANT, size, i, "ERR", "", "", f"encode: {exc}"])
                continue
            t1 = time.perf_counter()
            if ret is None:
                ret = 0
            if ret != 0:
                enc_rows.append(["bench_png_encode", VARIANT, size, i, "ERR", "", "", ret])
                dec_rows.append(["bench_png_decode", VARIANT, size, i, "ERR", "", "", f"encode: {ret}"])
                continue
            enc_elapsed = (t1 - t0) * TIME_SCALE

            try:
                enc_len = get_encoded_len(store)
            except Exception as exc:
                enc_rows.append(["bench_png_encode", VARIANT, size, i, "ERR", "", "", f"encoded_len: {exc}"])
                dec_rows.append(["bench_png_decode", VARIANT, size, i, "ERR", "", "", f"encoded_len: {exc}"])
                continue

            ratio = compute_compression_ratio(size, enc_len)
            enc_rows.append(["bench_png_encode", VARIANT, size, i, f"{enc_elapsed:.3f}", enc_len, ratio, 0])

            t0 = time.perf_counter()
            try:
                ret = decode_func(store, size)
            except Exception as exc:
                dec_rows.append(["bench_png_decode", VARIANT, size, i, "ERR", enc_len, "", f"decode: {exc}"])
                continue
            t1 = time.perf_counter()
            if ret is None:
                ret = 0
            if ret != 0:
                dec_rows.append(["bench_png_decode", VARIANT, size, i, "ERR", enc_len, "", f"decode: {ret}"])
                continue
            dec_elapsed = (t1 - t0) * TIME_SCALE

            try:
                ret = verify_decode(store, size)
            except Exception as exc:
                dec_rows.append(["bench_png_decode", VARIANT, size, i, "ERR", enc_len, "", f"verify_decode: {exc}"])
                continue
            if ret is None:
                ret = 0
            if ret != 0:
                dec_rows.append(["bench_png_decode", VARIANT, size, i, "ERR", enc_len, "", f"verify_decode: {ret}"])
                continue
            ratio = compute_compression_ratio(size, enc_len)
            dec_rows.append(["bench_png_decode", VARIANT, size, i, f"{dec_elapsed:.3f}", enc_len, ratio, 0])

    os.makedirs(RESULT_DIR, exist_ok=True)
    with open(out_csv_encode, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["bench", "variant", "size", "run", TIME_UNIT, "encoded_len", "compression_ratio", "ret"])
        w.writerows(enc_rows)
    with open(out_csv_decode, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["bench", "variant", "size", "run", TIME_UNIT, "encoded_len", "compression_ratio", "ret"])
        w.writerows(dec_rows)
    print(f"wrote: {out_csv_encode}")
    print(f"wrote: {out_csv_decode}")


def main():
    if not os.path.exists(WASM):
        raise SystemExit(f"missing: {WASM}")

    sizes = load_sizes()
    engine = make_engine()
    module = wasmtime.Module.from_file(engine, WASM)

    def fresh_funcs():
        store, instance = create_instance(engine, module)
        prepare_func = get_func(store, instance, "bench_prepare")
        encode_func = get_func(store, instance, "bench_png_encode")
        decode_func = get_func(store, instance, "bench_png_decode")
        get_encoded_len = get_func(store, instance, "bench_get_encoded_len")
        verify_decode = get_func(store, instance, "bench_verify_decode")
        return store, prepare_func, encode_func, decode_func, get_encoded_len, verify_decode

    run_bench(
        sizes,
        fresh_funcs,
        os.path.join(RESULT_DIR, "sfi_encode.csv"),
        os.path.join(RESULT_DIR, "sfi_decode.csv"),
    )


if __name__ == "__main__":
    main()
