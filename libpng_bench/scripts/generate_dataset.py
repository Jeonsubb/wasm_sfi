#!/usr/bin/env python3
import csv
import os
import random
import struct
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(ROOT, "data")
PNG_DIR = os.path.join(DATA_DIR, "png_samples")
MANIFEST = os.path.join(DATA_DIR, "dataset_sizes.csv")

MIN_POW = int(os.environ.get("DATASET_MIN_POW", "10"))
MAX_POW = int(os.environ.get("DATASET_MAX_POW", "21"))
SEED = int(os.environ.get("DATASET_SEED", "42"))


def png_chunk(chunk_type: bytes, payload: bytes) -> bytes:
    length = struct.pack(">I", len(payload))
    crc = zlib.crc32(chunk_type)
    crc = zlib.crc32(payload, crc) & 0xFFFFFFFF
    return length + chunk_type + payload + struct.pack(">I", crc)


def make_png(width: int, height: int, rgba: bytes, compression_level: int = 6) -> bytes:
    if len(rgba) != width * height * 4:
        raise ValueError("rgba size mismatch")

    rows = []
    row_stride = width * 4
    for y in range(height):
        row = rgba[y * row_stride : (y + 1) * row_stride]
        rows.append(b"\x00" + row)
    raw = b"".join(rows)

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    idat = zlib.compress(raw, level=compression_level)

    return (
        b"\x89PNG\r\n\x1a\n"
        + png_chunk(b"IHDR", ihdr)
        + png_chunk(b"IDAT", idat)
        + png_chunk(b"IEND", b"")
    )


def dims_for_raw(raw_bytes: int) -> tuple[int, int, int]:
    raw_bytes = max(4, (raw_bytes + 3) & ~3)
    width = 256
    row = width * 4
    height = max(1, (raw_bytes + row - 1) // row)
    total = row * height
    return width, height, total


def build_rgba_compressible(total: int) -> bytes:
    out = bytearray(total)
    for i in range(0, total, 4):
        x = (i // 4) % 256
        y = ((i // 4) // 256) % 256
        out[i + 0] = x
        out[i + 1] = y
        out[i + 2] = (x ^ y) & 0xFF
        out[i + 3] = 255
    return bytes(out)


def build_rgba_random(total: int, rng: random.Random) -> bytes:
    return bytes(rng.getrandbits(8) for _ in range(total))


def main():
    os.makedirs(PNG_DIR, exist_ok=True)
    rng = random.Random(SEED)

    rows = []
    for p in range(MIN_POW, MAX_POW + 1):
        requested = 1 << p
        width, height, raw_total = dims_for_raw(requested)

        rgba_comp = build_rgba_compressible(raw_total)
        rgba_rand = build_rgba_random(raw_total, rng)

        png_comp = make_png(width, height, rgba_comp, compression_level=6)
        png_rand = make_png(width, height, rgba_rand, compression_level=6)

        comp_name = f"pow{p:02d}_{requested}_compressible.png"
        rand_name = f"pow{p:02d}_{requested}_random.png"
        comp_path = os.path.join(PNG_DIR, comp_name)
        rand_path = os.path.join(PNG_DIR, rand_name)

        with open(comp_path, "wb") as f:
            f.write(png_comp)
        with open(rand_path, "wb") as f:
            f.write(png_rand)

        rows.append(
            {
                "pow": p,
                "raw_bytes": requested,
                "aligned_rgba_bytes": raw_total,
                "width": width,
                "height": height,
                "compressible_png_bytes": len(png_comp),
                "random_png_bytes": len(png_rand),
                "compressible_png": os.path.relpath(comp_path, ROOT),
                "random_png": os.path.relpath(rand_path, ROOT),
            }
        )

    with open(MANIFEST, "w", newline="") as f:
        w = csv.DictWriter(
            f,
            fieldnames=[
                "pow",
                "raw_bytes",
                "aligned_rgba_bytes",
                "width",
                "height",
                "compressible_png_bytes",
                "random_png_bytes",
                "compressible_png",
                "random_png",
            ],
        )
        w.writeheader()
        w.writerows(rows)

    print(f"wrote manifest: {MANIFEST}")
    print(f"wrote png samples under: {PNG_DIR}")


if __name__ == "__main__":
    main()
