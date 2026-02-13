#pragma once

// Minimal endian definitions for wasm32 little-endian
#define __LITTLE_ENDIAN 1234
#define __BIG_ENDIAN    4321
#define __BYTE_ORDER    __LITTLE_ENDIAN

#define htole16(x) (x)
#define le32toh(x) (x)
