#ifndef SNAPPY_BENCH_SIZE_T_DEFINED
typedef __SIZE_TYPE__ size_t;
#define SNAPPY_BENCH_SIZE_T_DEFINED 1
#endif

#ifndef SNAPPY_BENCH_SSIZE_T_DEFINED
typedef __PTRDIFF_TYPE__ ssize_t;
#define SNAPPY_BENCH_SSIZE_T_DEFINED 1
#endif

#ifndef __cplusplus
typedef _Bool bool;
#endif
#ifndef true
#define true 1
#endif
#ifndef false
#define false 0
#endif

#ifndef NULL
#define NULL ((void *)0)
#endif

#ifndef UINT_MAX
#define UINT_MAX (~0u)
#endif

#ifndef EIO
#define EIO 5
#endif
#ifndef ENOMEM
#define ENOMEM 12
#endif

#define __LITTLE_ENDIAN 1234
#define __BIG_ENDIAN 4321
#define __BYTE_ORDER __LITTLE_ENDIAN
#define __LITTLE_ENDIAN__ 1
#define htole16(x) (x)
#define le32toh(x) (x)

#ifndef assert
#define assert(x) ((void)0)
#endif

#include "../support/stdlib.h"
#include "../support/string.h"

/* Snappy 의존성(compat.h, snappy.h, snappy.c)을 내장. */


#define get_unaligned_memcpy(x) ({ \
		typeof(*(x)) _ret; \
		memcpy(&_ret, (x), sizeof(*(x))); \
		_ret; })
#define put_unaligned_memcpy(v,x) ({ \
		typeof((v)) _v = (v); \
		memcpy((x), &_v, sizeof(*(x))); })

#define get_unaligned get_unaligned_memcpy
#define put_unaligned put_unaligned_memcpy
#define get_unaligned64 get_unaligned_memcpy
#define put_unaligned64 put_unaligned_memcpy

#define get_unaligned_le32(x) (le32toh(get_unaligned((u32 *)(x))))
#define put_unaligned_le16(v,x) (put_unaligned(htole16(v), (u16 *)(x)))

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned u32;
typedef unsigned long long u64;

#define BUG_ON(x) assert(!(x))

#define vmalloc(x) malloc(x)
#define vfree(x) free(x)

#define EXPORT_SYMBOL(x)

#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))

#define likely(x) __builtin_expect((x), 1)
#define unlikely(x) __builtin_expect((x), 0)

#define min_t(t,x,y) ((x) < (y) ? (x) : (y))
#define max_t(t,x,y) ((x) > (y) ? (x) : (y))

#define BITS_PER_LONG (__SIZEOF_LONG__ * 8)

#ifndef _LINUX_SNAPPY_H
#define _LINUX_SNAPPY_H 1

/* 압축에만 필요. 최악의 경우를 가정해 미리 할당함 */
struct snappy_env {
	unsigned short *hash_table;
	void *scratch;
	void *scratch_output;
};

int snappy_init_env(struct snappy_env *env);
int snappy_init_env_with_len(struct snappy_env *env, size_t env_len);
void snappy_free_env(struct snappy_env *env);
int snappy_uncompress(const char *compressed, size_t n, char *uncompressed);
int snappy_uncompress_with_len(const char *compressed, size_t n,
			       char *uncompressed, size_t uncompressed_len);
int snappy_compress_with_len(struct snappy_env *env, size_t env_len,
			     const char *input, size_t input_length,
			     char *compressed, size_t compressed_capacity,
			     size_t *compressed_length, size_t compressed_length_len);
bool snappy_verify_compress_len(size_t compressed_len, size_t input_len);
int snappy_compress(struct snappy_env *env,
		    const char *input,
		    size_t input_length,
		    char *compressed,
		    size_t *compressed_length);
bool snappy_uncompressed_length(const char *buf, size_t len, size_t *result);
bool snappy_uncompressed_length_with_len(const char *buf, size_t len,
					 size_t *result, size_t result_len);
size_t snappy_max_compressed_length(size_t source_len);

static bool snappy_uncompressed_length_internal(const char *start, size_t n,
						size_t *result);



#endif

/*
 * Google의 snappy 압축기를 C로 포팅한 구현.
 * lzo와 비슷한 압축률을 가지면서 매우 빠른 압축기임.
 * 64비트 리틀 엔디언에서 가장 잘 동작하지만, 다른 환경에서도 괜찮음.
 * Andi Kleen이 포팅함.
 * snappy 1.1.0 기준.
 */

/*
 * 저작권 2005 Google Inc. 모든 권리 보유.
 *
 * 소스 및 바이너리 형태로의 재배포와 사용은 수정 여부에 관계없이,
 * 아래 조건을 충족하는 경우 허용된다:
 *
 *     * 소스 코드를 재배포할 때에는 위 저작권 고지, 본 조건 목록,
 *       그리고 아래의 면책 조항을 그대로 포함해야 한다.
 *     * 바이너리 형태로 재배포할 때에는 위 저작권 고지, 본 조건 목록,
 *       그리고 아래의 면책 조항을 문서 및/또는 배포 자료에 포함해야 한다.
 *     * Google Inc.의 이름이나 기여자의 이름을 사전 서면 허가 없이
 *       본 소프트웨어에서 파생된 제품을 보증하거나 홍보하는 데 사용할 수 없다.
 *
 * 본 소프트웨어는 저작권자 및 기여자에 의해 "있는 그대로" 제공되며,
 * 명시적이거나 묵시적인 어떠한 보증(상품성, 특정 목적 적합성에 대한
 * 묵시적 보증을 포함하되 이에 국한되지 않음)도 부인된다.
 * 어떠한 경우에도 저작권자 또는 기여자는 직접, 간접, 부수적, 특별,
 * 징벌적 또는 결과적 손해(대체 상품이나 서비스의 조달, 사용, 데이터,
 * 이익의 손실, 또는 영업 중단을 포함하되 이에 국한되지 않음)에 대해
 * 책임을 지지 않는다. 이러한 손해가 계약, 엄격 책임, 또는 불법행위
 * (과실 포함) 등 어떠한 이론에 근거하든, 그리고 본 소프트웨어 사용으로
 * 인해 발생했더라도, 또한 그러한 손해 가능성을 사전에 통지받았더라도
 * 책임을 지지 않는다.
 */

#define CRASH_UNLESS(x) BUG_ON(!(x))
#define CHECK(cond) CRASH_UNLESS(cond)
#define CHECK_LE(a, b) CRASH_UNLESS((a) <= (b))
#define CHECK_GE(a, b) CRASH_UNLESS((a) >= (b))
#define CHECK_EQ(a, b) CRASH_UNLESS((a) == (b))
#define CHECK_NE(a, b) CRASH_UNLESS((a) != (b))
#define CHECK_LT(a, b) CRASH_UNLESS((a) < (b))
#define CHECK_GT(a, b) CRASH_UNLESS((a) > (b))

#define UNALIGNED_LOAD16(_p) get_unaligned((u16 *)(_p))
#define UNALIGNED_LOAD32(_p) get_unaligned((u32 *)(_p))
#define UNALIGNED_LOAD64(_p) get_unaligned64((u64 *)(_p))

#define UNALIGNED_STORE16(_p, _val) put_unaligned(_val, (u16 *)(_p))
#define UNALIGNED_STORE32(_p, _val) put_unaligned(_val, (u32 *)(_p))
#define UNALIGNED_STORE64(_p, _val) put_unaligned64(_val, (u64 *)(_p))

/* Rust 준비 단계를 C에서 처리하기 위한 데이터 풀 (mem0 사용) */
#define BENCH_MAX_INPUT (1u << 22)
#define BENCH_POOL_SIZE 9
#define BENCH_POOL_CHUNK (64 * 1024)
static u8 bench_input_pool[BENCH_POOL_SIZE][BENCH_POOL_CHUNK];
static bool bench_pool_ready;

static void bench_fill_input_pattern(u8 *dst, size_t size, u32 tag)
{
	u8 mix = (u8)(tag * 17);
	for (size_t i = 0; i < size; i++) {
		dst[i] = (u8)(i * 31 + 17 + mix);
	}
}

static void bench_init_pool(void)
{
	if (bench_pool_ready)
		return;
	for (size_t p = 0; p < BENCH_POOL_SIZE; p++) {
		bench_fill_input_pattern(bench_input_pool[p], BENCH_POOL_CHUNK, (u32)p);
	}
	bench_pool_ready = true;
}

__attribute__((export_name("bench_fill_target_from_pool")))
int bench_fill_target_from_pool(void *dst_mem0, size_t size)
{
	if (size == 0)
		return -120;
	if (size > BENCH_MAX_INPUT)
		return -121;

	bench_init_pool();

	size_t offset = 0;
	size_t pool_idx = 0;
	while (offset < size) {
		size_t remaining = size - offset;
		size_t copy_len = remaining < BENCH_POOL_CHUNK ? remaining : BENCH_POOL_CHUNK;
		memcpy((u8 *)dst_mem0 + offset,
		       bench_input_pool[pool_idx],
		       copy_len);
		offset += copy_len;
		pool_idx++;
		if (pool_idx == BENCH_POOL_SIZE)
			pool_idx = 0;
	}

	return 0;
}

/*
 * 일부 플랫폼(특히 ARM)에서는 UNALIGNED_LOAD64 + UNALIGNED_STORE64보다
 * 더 효율적일 수 있음.
 */
/* snappy.c 원본 함수 */
static inline void unaligned_copy64(const void *src, void *dst)
{
	if (sizeof(void *) == 8) {
		UNALIGNED_STORE64(dst, UNALIGNED_LOAD64(src));
	} else {
		const char *src_char = (const char *)(src);
		char *dst_char = (char *)(dst);

		UNALIGNED_STORE32(dst_char, UNALIGNED_LOAD32(src_char));
		UNALIGNED_STORE32(dst_char + 4, UNALIGNED_LOAD32(src_char + 4));
	}
}

#ifdef NDEBUG

#define DCHECK(cond) do {} while(0)
#define DCHECK_LE(a, b) do {} while(0)
#define DCHECK_GE(a, b) do {} while(0)
#define DCHECK_EQ(a, b) do {} while(0)
#define DCHECK_NE(a, b) do {} while(0)
#define DCHECK_LT(a, b) do {} while(0)
#define DCHECK_GT(a, b) do {} while(0)

#else

#define DCHECK(cond) CHECK(cond)
#define DCHECK_LE(a, b) CHECK_LE(a, b)
#define DCHECK_GE(a, b) CHECK_GE(a, b)
#define DCHECK_EQ(a, b) CHECK_EQ(a, b)
#define DCHECK_NE(a, b) CHECK_NE(a, b)
#define DCHECK_LT(a, b) CHECK_LT(a, b)
#define DCHECK_GT(a, b) CHECK_GT(a, b)

#endif

/* snappy.c 원본 함수 */
static inline bool is_little_endian(void)
{
#ifdef __LITTLE_ENDIAN__
	return true;
#endif
	return false;
}

/* snappy.c 원본 함수 */
static inline int log2_floor(u32 n)
{
	return n == 0 ? -1 : 31 ^ __builtin_clz(n);
}

/* snappy.c 원본 함수 */
static inline int find_lsb_set_non_zero(u32 n)
{
	return __builtin_ctz(n);
}

/* snappy.c 원본 함수 */
static inline int find_lsb_set_non_zero64(u64 n)
{
	return __builtin_ctzll(n);
}

#define kmax32 5

/*
 * [ptr,limit-1] 범위 바이트 접두사에서 varint32 파싱을 시도한다.
 * limit을 넘어서 읽지 않는다. 유효하고 종료된 varint32가 범위 내에 있으면
 * *OUTPUT에 저장하고 varint32 마지막 바이트 바로 뒤를 가리키는
 * 포인터를 반환한다. 그렇지 않으면 NULL을 반환한다. 성공 시
 * "result <= limit".
 */
static inline const char *varint_parse32_with_limit(const char *p,
						    const char *l,
						    u32 * OUTPUT)
{
	const unsigned char *ptr = (const unsigned char *)(p);
	const unsigned char *limit = (const unsigned char *)(l);
	u32 b, result;

	if (ptr >= limit)
		return NULL;
	b = *(ptr++);
	result = b & 127;
	if (b < 128)
		goto done;
	if (ptr >= limit)
		return NULL;
	b = *(ptr++);
	result |= (b & 127) << 7;
	if (b < 128)
		goto done;
	if (ptr >= limit)
		return NULL;
	b = *(ptr++);
	result |= (b & 127) << 14;
	if (b < 128)
		goto done;
	if (ptr >= limit)
		return NULL;
	b = *(ptr++);
	result |= (b & 127) << 21;
	if (b < 128)
		goto done;
	if (ptr >= limit)
		return NULL;
	b = *(ptr++);
	result |= (b & 127) << 28;
	if (b < 16)
		goto done;
	return NULL;		/* 값이 varint32로는 너무 김 */
done:
	*OUTPUT = result;
	return (const char *)(ptr);
}

/*
 * 전제: "ptr"은 "v"를 담을 수 있을 만큼의 버퍼를 가리킴.
 * 효과: "v"를 "ptr"에 인코딩하고, 마지막 인코딩 바이트 바로 뒤를
 *       가리키는 포인터를 반환함.
 */
static inline char *varint_encode32(char *sptr, u32 v)
{
	/* 문자를 unsigned로 취급하여 처리 */
	unsigned char *ptr = (unsigned char *)(sptr);
	static const int B = 128;

	if (v < (1 << 7)) {
		*(ptr++) = v;
	} else if (v < (1 << 14)) {
		*(ptr++) = v | B;
		*(ptr++) = v >> 7;
	} else if (v < (1 << 21)) {
		*(ptr++) = v | B;
		*(ptr++) = (v >> 7) | B;
		*(ptr++) = v >> 14;
	} else if (v < (1 << 28)) {
		*(ptr++) = v | B;
		*(ptr++) = (v >> 7) | B;
		*(ptr++) = (v >> 14) | B;
		*(ptr++) = v >> 21;
	} else {
		*(ptr++) = v | B;
		*(ptr++) = (v >> 7) | B;
		*(ptr++) = (v >> 14) | B;
		*(ptr++) = (v >> 21) | B;
		*(ptr++) = v >> 28;
	}
	return (char *)(ptr);
}


struct source {
	const char *ptr;
	size_t left;
};

/* snappy.c 원본 함수 */
static inline int available(struct source *s)
{
	return s->left;
}

static inline const char *peek(struct source *s, size_t * len)
{
	*len = s->left;
	return s->ptr;
}

/* snappy.c 원본 함수 */
static inline void skip(struct source *s, size_t n)
{
	s->left -= n;
	s->ptr += n;
}

struct sink {
	char *dest;
};

/* snappy.c 원본 함수 */
static inline void append(struct sink *s, const char *data, size_t n)
{
	if (data != s->dest)
		memcpy(s->dest, data, n);
	s->dest += n;
}

#define sink_peek(s, n) sink_peek_no_sg(s)

static inline void *sink_peek_no_sg(const struct sink *s)
{
	return s->dest;
}


struct writer {
	char *base;
	char *op;
	char *op_limit;
};

/* 압축 해제 전에 호출 */
/* snappy.c 원본 함수 */
static inline void writer_set_expected_length(struct writer *w, size_t len)
{
	w->op_limit = w->op + len;
}

/* 압축 해제 후에 호출 */
/* snappy.c 원본 함수 */
static inline bool writer_check_length(struct writer *w)
{
	return w->op == w->op_limit;
}

/*
 * "src"에서 "op"로 "len" 바이트를 한 바이트씩 복사한다. 입력과 출력
 * 영역이 겹칠 수 있는 COPY 동작 처리에 사용한다.
 * 예를 들어:
 *   src    == "ab"
 *   op     == src + 2
 *   len    == 20
 * IncrementalCopy(src, op, len) 이후 결과는
 *   ababababababababababab
 * 처럼 "ab"가 11번 반복된다.
 * 이는 memcpy()나 memmove()의 의미와 일치하지 않는다.
 */
/* snappy.c 원본 함수 */
static inline void incremental_copy(const char *src, char *op, ssize_t len)
{
	DCHECK_GT(len, 0);
	do {
		*op++ = *src++;
	} while (--len > 0);
}

/*
 * IncrementalCopy와 동일하지만 복사 끝 이후 최대 10바이트까지
 * 추가로 쓸 수 있으며 더 빠르다.
 *
 * 루프의 주요 부분은 8바이트씩 단순 복사를 반복한다.
 * 하지만 op와 src가 8바이트보다 가까우면(길이 < 8의 반복 패턴),
 * 올바른 결과를 얻기 위해 먼저 패턴을 확장한다.
 * 예를 들어, 8바이트의 <src>와 <op> 패턴 구간이 아래와 같을 때:
 *
 *    abxxxxxxxxxxxx
 *    [------]           src
 *      [------]         op
 *
 * <src>에서 <op>로 8바이트를 한 번 복사하면 패턴이 한 번 반복되고,
 * 이후에는 <src>를 움직이지 않고 <op>를 2바이트 이동할 수 있다:
 *
 *    ababxxxxxxxxxx
 *    [------]           src
 *        [------]       op
 *
 * 이런 과정을 두 구간이 겹치지 않을 때까지 반복한다.
 *
 * 이는 한 바이트가 여러 번 반복되는 특수한 경우에 매우 잘 동작하며,
 * 일반적인 경우의 성능 저하를 크게 만들지 않는다.
 *
 * 매치 끝을 넘어 추가로 쓰게 되는 최악의 경우는
 * op - src == 1 이고 len == 1 일 때이다. 마지막 복사는 [0..7]을 읽고
 * [4..11]에 쓰는데, 원래는 위치 1에만 써야 한다. 즉 10바이트가 초과로 쓰인다.
 */

#define kmax_increment_copy_overflow  10

static inline void incremental_copy_fast_path(const char *src, char *op,
					      ssize_t len)
{
	while (op - src < 8) {
		unaligned_copy64(src, op);
		len -= op - src;
		op += op - src;
	}
	while (len > 0) {
		unaligned_copy64(src, op);
		src += 8;
		op += 8;
		len -= 8;
	}
}

static inline bool writer_append_from_self(struct writer *w, u32 offset,
					   u32 len)
{
	char *const op = w->op;
	CHECK_LE(op, w->op_limit);
	const u32 space_left = w->op_limit - op;

	if (op - w->base <= offset - 1u)	/* -1u는 offset==0을 잡아낸다 */
		return false;
	if (len <= 16 && offset >= 8 && space_left >= 16) {
		/* 빠른 경로: 동적 호출의 대부분(70-80%)에
		 * 사용됨. */
		unaligned_copy64(op - offset, op);
		unaligned_copy64(op - offset + 8, op + 8);
	} else {
		if (space_left >= len + kmax_increment_copy_overflow) {
			incremental_copy_fast_path(op - offset, op, len);
		} else {
			if (space_left < len) {
				return false;
			}
			incremental_copy(op - offset, op, len);
		}
	}

	w->op = op + len;
	return true;
}

/* snappy.c 원본 함수 */
static inline bool writer_append(struct writer *w, const char *ip, u32 len)
{
	char *const op = w->op;
	CHECK_LE(op, w->op_limit);
	const u32 space_left = w->op_limit - op;
	if (space_left < len)
		return false;
	memcpy(op, ip, len);
	w->op = op + len;
	return true;
}

static inline bool writer_try_fast_append(struct writer *w, const char *ip, 
					  u32 available_bytes, u32 len)
{
	char *const op = w->op;
	const int space_left = w->op_limit - op;
	if (len <= 16 && available_bytes >= 16 && space_left >= 16) {
		/* 빠른 경로: 호출의 대부분(~95%)에 사용됨 */
		unaligned_copy64(ip, op);
		unaligned_copy64(ip + 8, op + 8);
		w->op = op + len;
		return true;
	}
	return false;
}

/*
 * 어떤 해시 함수든 유효한 압축 비트스트림을 만들 수 있지만,
 * 좋은 해시 함수는 충돌 수를 줄여 압축 가능한 입력에서는 압축률을 높이고,
 * 압축 불가능한 입력에서는 속도를 높인다. 해시 함수가 충분히 빠른 것도
 * 중요하며, 매우 자주 호출된다.
 */
/* snappy.c 원본 함수 */
static inline u32 hash_bytes(u32 bytes, int shift)
{
	u32 kmul = 0x1e35a7bd;
	return (bytes * kmul) >> shift;
}

/* snappy.c 원본 함수 */
static inline u32 hash(const char *p, int shift)
{
	return hash_bytes(UNALIGNED_LOAD32(p), shift);
}

/*
 * 압축 데이터는 다음과 같이 정의할 수 있다:
 *    compressed := item* literal*
 *    item       := literal* copy
 *
 * 마지막 literal 연속 구간의 공간 증폭은 최대 62/60이다.
 * 길이 60의 literal은 태그 1바이트 + 길이 정보용 추가 1바이트가 필요하기 때문.
 *
 * item의 증폭은 더 까다롭다. "copy" op가 4바이트를 복사한다고 하자.
 * 인코딩 코드의 특수 검사 때문에 offset < 65536일 때만 4바이트 copy를 만들며,
 * 이 경우 copy op는 3바이트로 인코딩된다. 따라서 이 타입의 item은
 * literal 표현에 대해 최대 62/60 증폭에 그친다.
 *
 * "copy" op가 5바이트를 복사하고 offset이 충분히 크면,
 * copy op 인코딩에 5바이트가 필요하다. 이때 최악의 경우는
 * 1바이트 literal + 5바이트 copy로, 6바이트 입력이 7바이트
 * "compressed" 데이터가 된다.
 *
 * 이 마지막 요인이 지배적이므로 최종 추정치는 다음과 같다:
 */
__attribute__((export_name("snappy_max_compressed_length")))
/* snappy.c 원본 함수 */
size_t snappy_max_compressed_length(size_t source_len)
{
	return 32 + source_len + source_len / 6;
}
EXPORT_SYMBOL(snappy_max_compressed_length);

enum {
	LITERAL = 0,
	COPY_1_BYTE_OFFSET = 1,	/* opcode에 길이 3비트 + 오프셋 3비트 */
	COPY_2_BYTE_OFFSET = 2,
	COPY_4_BYTE_OFFSET = 3
};

static inline char *emit_literal(char *op,
				 const char *literal,
				 int len, bool allow_fast_path)
{
	int n = len - 1;	/* 길이 0 리터럴은 허용되지 않음 */

	if (n < 60) {
		/* 태그 바이트에 들어감 */
		*op++ = LITERAL | (n << 2);

/*
 * 대부분의 copy는 16바이트 미만이라 memcpy 호출은 과하다.
 * 이 빠른 경로는 최대 15바이트를 더 복사할 수 있지만,
 * 메인 루프에서는 양쪽에 여유가 있어 괜찮다:
 *
 *   - 입력은 메인 루프 동안 항상 kInputMarginBytes = 15 바이트의 여유가 있고,
 *     그렇지 않다면 allow_fast_path = false.
 *   - 출력은 항상 32바이트의 여유가 있다( MaxCompressedLength 참고 ).
 */
		if (allow_fast_path && len <= 16) {
			unaligned_copy64(literal, op);
			unaligned_copy64(literal + 8, op + 8);
			return op + len;
		}
	} else {
		/* 뒤이어 오는 바이트에 인코딩 */
		char *base = op;
		int count = 0;
		op++;
		while (n > 0) {
			*op++ = n & 0xff;
			n >>= 8;
			count++;
		}
		DCHECK(count >= 1);
		DCHECK(count <= 4);
		*base = LITERAL | ((59 + count) << 2);
	}
	memcpy(op, literal, len);
	return op + len;
}

static inline char *emit_copy_less_than64(char *op, int offset, int len)
{
	DCHECK_LE(len, 64);
	DCHECK_GE(len, 4);
	DCHECK_LT(offset, 65536);

	if ((len < 12) && (offset < 2048)) {
		int len_minus_4 = len - 4;
		DCHECK(len_minus_4 < 8);	/* 3비트에 들어야 함 */
		*op++ =
		    COPY_1_BYTE_OFFSET + ((len_minus_4) << 2) + ((offset >> 8)
								 << 5);
		*op++ = offset & 0xff;
	} else {
		*op++ = COPY_2_BYTE_OFFSET + ((len - 1) << 2);
		put_unaligned_le16(offset, op);
		op += 2;
	}
	return op;
}

static inline char *emit_copy(char *op, int offset, int len)
{
	/*
	 * 64바이트 복사를 출력하되 최소 4바이트는 남겨둔다.
	 */
	while (len >= 68) {
		op = emit_copy_less_than64(op, offset, 64);
		len -= 64;
	}

	/*
	 * 한 번의 copy에 다 담기 어려우면 60바이트 copy를 추가로 출력한다.
	 */
	if (len > 64) {
		op = emit_copy_less_than64(op, offset, 60);
		len -= 60;
	}

	/* 나머지 출력 */
	op = emit_copy_less_than64(op, offset, len);
	return op;
}

/**
 * snappy_uncompressed_length - 압축 해제 결과의 길이를 반환.
 * @start: 압축된 버퍼
 * @n: 압축된 버퍼 길이
 * @result: 압축 해제된 출력 길이를 여기에 기록
 *
 * 성공 시 true, 실패 시 false.
 */
static bool snappy_uncompressed_length_internal(const char *start, size_t n,
						size_t *result)
{
	u32 v = 0;
	const char *limit = start + n;
	if (varint_parse32_with_limit(start, limit, &v) != NULL) {
		*result = v;
		return true;
	} else {
		return false;
	}
}

__attribute__((export_name("snappy_uncompressed_length")))
/* snappy.c 원본 함수 */
bool snappy_uncompressed_length(const char *start, size_t n, size_t *result)
{
	return snappy_uncompressed_length_internal(start, n, result);
}
EXPORT_SYMBOL(snappy_uncompressed_length);

__attribute__((export_name("snappy_uncompressed_length_with_len")))
bool snappy_uncompressed_length_with_len(const char *start, size_t n,
					 size_t *result, size_t result_len)
{
	if (result_len < sizeof(*result))
		return false;
	return snappy_uncompressed_length_internal(start, n, result);
}
EXPORT_SYMBOL(snappy_uncompressed_length_with_len);

/*
 * 압축 블록의 크기. 압축 코드의 많은 부분은 kBlockSize <= 65536을 가정한다.
 * 특히 해시 테이블은 16비트 오프셋만 저장할 수 있고, EmitCopy()도
 * 오프셋이 65535 이하라고 가정한다. 이를 변경하면 프레이밍 포맷에
 * 영향을 준다.
 * 더 큰 블록 크기로 압축된 오래된 데이터가 있을 수 있으므로,
 * 압축 해제 코드는 긴 backreference의 부재를 가정하면 안 된다.
 */
#define kblock_log 16
#define kblock_size (1 << kblock_log)

/*
 * 이 값은 메모리를 절약하기 위해 절반이나 1/4로 줄일 수 있지만
 * 압축률이 약간 나빠질 수 있다.
 */
#define kmax_hash_table_bits 14
#define kmax_hash_table_size (1U << kmax_hash_table_bits)

/*
 * 입력이 작으면 더 작은 해시 테이블을 사용한다.
 * 테이블을 초기화하는 데 O(해시 테이블 크기) 비용이 들기 때문에,
 * 입력이 짧으면 그만큼 큰 해시 테이블이 필요하지 않다.
 */
static u16 *get_hash_table(struct snappy_env *env, size_t input_size,
			      int *table_size)
{
	unsigned htsize = 256;

	DCHECK(kmax_hash_table_size >= 256);
	while (htsize < kmax_hash_table_size && htsize < input_size)
		htsize <<= 1;
	CHECK_EQ(0, htsize & (htsize - 1));
	CHECK_LE(htsize, kmax_hash_table_size);

	u16 *table;
	table = env->hash_table;

	*table_size = htsize;
	memset(table, 0, htsize * sizeof(*table));
	return table;
}

/*
 * 다음을 만족하는 가장 큰 n을 반환한다:
 *
 *   s1[0,n-1] == s2[0,n-1]
 *   그리고 n <= (s2_limit - s2).
 *
 * *s2_limit 이후를 읽지 않는다.
 * *(s1 + (s2_limit - s2)) 이후를 읽지 않는다.
 * s2_limit >= s2 이어야 한다.
 *
 * 속도를 위해 x86_64용 별도 구현. x86_64가 리틀 엔디언임을 이용한다.
 */
#if defined(__LITTLE_ENDIAN__) && BITS_PER_LONG == 64
static inline int find_match_length(const char *s1,
				    const char *s2, const char *s2_limit)
{
	int matched = 0;

	DCHECK_GE(s2_limit, s2);
	/*
	 * 매치 길이를 찾는다. 64비트 단위로 비교하다가
	 * 일치하지 않는 64비트 블록을 찾으면, 첫 불일치 비트를 찾아
	 * 매치 길이를 계산한다.
	 */
	while (likely(s2 <= s2_limit - 8)) {
		if (unlikely
		    (UNALIGNED_LOAD64(s2) == UNALIGNED_LOAD64(s1 + matched))) {
			s2 += 8;
			matched += 8;
		} else {
			/*
			 * 현재(2008년 중반) Opteron 모델에는
			 * 첫 불일치 바이트를 찾는 3% 더 효율적인 코드 시퀀스가 있다.
			 * 그러나 아래 코드는 Intel Core 2 이상에서 ~10% 더 좋고,
			 * AMD의 bsf 명령이 개선될 것으로 예상한다.
			 */
			u64 x =
			    UNALIGNED_LOAD64(s2) ^ UNALIGNED_LOAD64(s1 +
								    matched);
			int matching_bits = find_lsb_set_non_zero64(x);
			matched += matching_bits >> 3;
			return matched;
		}
	}
	while (likely(s2 < s2_limit)) {
		if (likely(s1[matched] == *s2)) {
			++s2;
			++matched;
		} else {
			return matched;
		}
	}
	return matched;
}
#else
static inline int find_match_length(const char *s1,
				    const char *s2, const char *s2_limit)
{
	/* 위의 x86-64 버전을 기반으로 한 구현. */
	DCHECK_GE(s2_limit, s2);
	int matched = 0;

	while (s2 <= s2_limit - 4 &&
	       UNALIGNED_LOAD32(s2) == UNALIGNED_LOAD32(s1 + matched)) {
		s2 += 4;
		matched += 4;
	}
	if (is_little_endian() && s2 <= s2_limit - 4) {
		u32 x =
		    UNALIGNED_LOAD32(s2) ^ UNALIGNED_LOAD32(s1 + matched);
		int matching_bits = find_lsb_set_non_zero(x);
		matched += matching_bits >> 3;
	} else {
		while ((s2 < s2_limit) && (s1[matched] == *s2)) {
			++s2;
			++matched;
		}
	}
	return matched;
}
#endif

/*
 * 0 <= offset <= 4일 때 GetU32AtOffset(GetEightBytesAt(p), offset)는
 * UNALIGNED_LOAD32(p + offset)와 같다. 동기: x86-64 하드웨어에서
 * UNALIGNED_LOAD32(p) ... UNALIGNED_LOAD32(p+1) ... UNALIGNED_LOAD32(p+2)
 * 같은 겹치는 로드가 UNALIGNED_LOAD64(p) 후 시프트/캐스트하는 것보다
 * 느리다는 경험적 결과가 있다.
 *
 * 64비트/32비트 버전을 분리했다. 이상적으로는 두 함수를 없애고
 * UNALIGNED_LOAD64 호출을 GetUint32AtOffset 안에 인라인하고 싶지만,
 * GCC(적어도 4.6 기준)가 값 중복 로드를 피하도록 충분히 똑똑하지 않다.
 * 64비트에서는 GetEightBytesAt() 호출 시 로드가 이루어지고,
 * 32비트에서는 GetUint32AtOffset() 시점에 로드된다.
 */

#if BITS_PER_LONG == 64

typedef u64 eight_bytes_reference;

/* snappy.c 원본 함수 */
static inline eight_bytes_reference get_eight_bytes_at(const char* ptr)
{
	return UNALIGNED_LOAD64(ptr);
}

/* snappy.c 원본 함수 */
static inline u32 get_u32_at_offset(u64 v, int offset)
{
	DCHECK_GE(offset, 0);
	DCHECK_LE(offset, 4);
	return v >> (is_little_endian()? 8 * offset : 32 - 8 * offset);
}

#else

typedef const char *eight_bytes_reference;

/* snappy.c 원본 함수 */
static inline eight_bytes_reference get_eight_bytes_at(const char* ptr) 
{
	return ptr;
}

/* snappy.c 원본 함수 */
static inline u32 get_u32_at_offset(const char *v, int offset) 
{
	DCHECK_GE(offset, 0);
	DCHECK_LE(offset, 4);
	return UNALIGNED_LOAD32(v + offset);
}
#endif

/*
 * "uncompressed length" 접두사를 출력하지 않는 평탄 배열 압축.
 * "input" 문자열을 "*op" 버퍼로 압축한다.
 *
 * 요구사항: "input" 길이는 최대 "kBlockSize" 바이트.
 * 요구사항: "op"는 "MaxCompressedLength(input.size())" 이상 크기의 버퍼.
 * 요구사항: "table[0..table_size-1]"의 모든 요소는 0으로 초기화됨.
 * 요구사항: "table_size"는 2의 거듭제곱.
 *
 * "op" 버퍼 안에서 "end" 포인터를 반환한다.
 * "end - op"가 "input"의 압축 크기이다.
 */

static char *compress_fragment(const char *const input,
			       const size_t input_size,
			       char *op, u16 * table, const unsigned table_size)
{
	/* "ip"는 입력 포인터이고, "op"는 출력 포인터다. */
	const char *ip = input;
	CHECK_LE(input_size, kblock_size);
	CHECK_EQ(table_size & (table_size - 1), 0);
	const int shift = 32 - log2_floor(table_size);
	DCHECK_EQ(UINT_MAX >> shift, table_size - 1);
	const char *ip_end = input + input_size;
	const char *baseip = ip;
	/*
	 * [next_emit, ip) 구간의 바이트를 literal로 출력한다.
	 * 또는 메인 루프 이후에는 [next_emit, ip_end).
	 */
	const char *next_emit = ip;

	const unsigned kinput_margin_bytes = 15;

	if (likely(input_size >= kinput_margin_bytes)) {
		const char *const ip_limit = input + input_size -
			kinput_margin_bytes;

		u32 next_hash;
		for (next_hash = hash(++ip, shift);;) {
			DCHECK_LT(next_emit, ip);
/*
 * 이 루프의 본체는 EmitLiteral을 한 번 호출한 뒤 EmitCopy를 한 번 이상 호출한다.
 * (입력을 거의 소진한 경우에는 emit_remainder로 이동한다.)
 *
 * 첫 반복에서는 이제 막 시작했으므로 복사할 것이 없고,
 * EmitLiteral을 한 번 호출해야 한다. 그리고 현재 반복이
 * 다음 EmitCopy 호출(있다면) 전에 EmitLiteral을 호출해야 한다고
 * 판단했을 때만 새로운 반복을 시작한다.
 *
 * 1단계: 입력에서 4바이트 매치를 찾기 위해 앞으로 스캔한다.
 * 입력이 거의 끝나면 emit_remainder로 이동한다.
 *
 * 휴리스틱 매치 스킵: 32바이트 동안 매치가 없으면
 * 다음부터는 한 바이트씩 건너뛰며 본다. 32바이트가 더 스캔되면
 * 두 바이트씩 건너뛰며 본다, 이런 식으로 늘린다. 매치가 발견되면
 * 즉시 다시 모든 바이트를 검사한다. 이는 압축 가능한 데이터에서
 * 약간의 손실(~5% 성능, ~0.1% 밀도)을 유발하지만,
 * 비압축 데이터(예: JPEG)에서는 큰 이득이다. 압축기는
 * 데이터가 비압축임을 빠르게 "깨닫고" 모든 위치에서
 * 매치를 찾느라 시간을 쓰지 않는다.
 *
 * "skip" 변수는 마지막 매치 이후의 바이트 수를 추적하며,
 * 이를 32로 나눈 값(즉, 5비트 오른쪽 시프트)이
 * 각 반복에서 앞으로 이동할 바이트 수다.
 */
			u32 skip_bytes = 32;

			const char *next_ip = ip;
			const char *candidate;
			do {
				ip = next_ip;
				u32 hval = next_hash;
				DCHECK_EQ(hval, hash(ip, shift));
				u32 bytes_between_hash_lookups = skip_bytes++ >> 5;
				next_ip = ip + bytes_between_hash_lookups;
				if (unlikely(next_ip > ip_limit)) {
					goto emit_remainder;
				}
				next_hash = hash(next_ip, shift);
				candidate = baseip + table[hval];
				DCHECK_GE(candidate, baseip);
				DCHECK_LT(candidate, ip);

				table[hval] = ip - baseip;
			} while (likely(UNALIGNED_LOAD32(ip) !=
					UNALIGNED_LOAD32(candidate)));

/*
 * 2단계: 4바이트 매치를 찾았다. 이후 4바이트보다 더 매치되는지 확인한다.
 * 그러나 매치 이전의 입력 바이트 [next_emit, ip)는 매치되지 않았으므로
 * "literal bytes"로 출력한다.
 */
			DCHECK_LE(next_emit + 16, ip_end);
			op = emit_literal(op, next_emit, ip - next_emit, true);

/*
 * 3단계: EmitCopy를 호출하고, 다음 동작이 또 다른 EmitCopy가 될 수 있는지
 * 확인한다. 마지막 EmitCopy 호출이 소비한 직후의 입력에서 매치를 찾지 못할 때까지
 * 반복한다.
 *
 * 이 루프를 정상적으로 빠져나오면 다음에 EmitLiteral을 호출해야 한다.
 * 다만 literal의 크기는 아직 알 수 없으므로 메인 루프의 다음 반복으로
 * 진행해 처리한다. 입력을 거의 소진한 경우에는 goto로 빠져나올 수도 있다.
 */
			eight_bytes_reference input_bytes;
			u32 candidate_bytes = 0;

			do {
/*
 * ip에서 4바이트 매치를 찾았고, ip 이전에는 "literal bytes"를
 * 출력할 필요가 없다.
 */
				const char *base = ip;
				int matched = 4 +
				    find_match_length(candidate + 4, ip + 4,
						      ip_end);
				ip += matched;
				int offset = base - candidate;
				DCHECK_EQ(0, memcmp(base, candidate, matched));
				op = emit_copy(op, offset, matched);
/*
 * 지금 바로 ip에서 작업할 수도 있지만, 압축률을 높이기 위해
 * 먼저 table[Hash(ip - 1, ...)]를 갱신한다.
 */
				const char *insert_tail = ip - 1;
				next_emit = ip;
				if (unlikely(ip >= ip_limit)) {
					goto emit_remainder;
				}
				input_bytes = get_eight_bytes_at(insert_tail);
				u32 prev_hash =
				    hash_bytes(get_u32_at_offset
					       (input_bytes, 0), shift);
				table[prev_hash] = ip - baseip - 1;
				u32 cur_hash =
				    hash_bytes(get_u32_at_offset
					       (input_bytes, 1), shift);
				candidate = baseip + table[cur_hash];
				candidate_bytes = UNALIGNED_LOAD32(candidate);
				table[cur_hash] = ip - baseip;
			} while (get_u32_at_offset(input_bytes, 1) ==
				 candidate_bytes);

			next_hash =
			    hash_bytes(get_u32_at_offset(input_bytes, 2),
				       shift);
			++ip;
		}
	}

emit_remainder:
	/* 남은 바이트를 literal로 출력 */
	if (next_emit < ip_end)
		op = emit_literal(op, next_emit, ip_end - next_emit, false);

	return op;
}

/*
 * -----------------------------------------------------------------------
 *  압축 해제 코드용 룩업 테이블. 아래 ComputeTable()에서 생성됨.
 * -----------------------------------------------------------------------
 */

/* i가 [0,4] 범위일 때 하위 8*i 비트를 추출하는 마스크 매핑 */
static const u32 wordmask[] = {
	0u, 0xffu, 0xffffu, 0xffffffu, 0xffffffffu
};

/*
 * 룩업 테이블 항목당 저장되는 데이터:
 *       범위   사용 비트     설명
 *      ------------------------------------
 *      1..64   0..7          opcode 바이트에 인코딩된 literal/copy 길이
 *      0..7    8..10         opcode 바이트에 인코딩된 copy 오프셋 / 256
 *      0..4    11..13        opcode 이후의 추가 바이트 수
 *
 * 길이에 7비트면 충분하지만 효율 때문에 8비트를 사용한다:
 *      (1) 바이트 추출이 비트필드보다 빠름
 *      (2) copy 오프셋이 정렬되어 <<8이 필요 없게 됨
 */
static const u16 char_table[256] = {
	0x0001, 0x0804, 0x1001, 0x2001, 0x0002, 0x0805, 0x1002, 0x2002,
	0x0003, 0x0806, 0x1003, 0x2003, 0x0004, 0x0807, 0x1004, 0x2004,
	0x0005, 0x0808, 0x1005, 0x2005, 0x0006, 0x0809, 0x1006, 0x2006,
	0x0007, 0x080a, 0x1007, 0x2007, 0x0008, 0x080b, 0x1008, 0x2008,
	0x0009, 0x0904, 0x1009, 0x2009, 0x000a, 0x0905, 0x100a, 0x200a,
	0x000b, 0x0906, 0x100b, 0x200b, 0x000c, 0x0907, 0x100c, 0x200c,
	0x000d, 0x0908, 0x100d, 0x200d, 0x000e, 0x0909, 0x100e, 0x200e,
	0x000f, 0x090a, 0x100f, 0x200f, 0x0010, 0x090b, 0x1010, 0x2010,
	0x0011, 0x0a04, 0x1011, 0x2011, 0x0012, 0x0a05, 0x1012, 0x2012,
	0x0013, 0x0a06, 0x1013, 0x2013, 0x0014, 0x0a07, 0x1014, 0x2014,
	0x0015, 0x0a08, 0x1015, 0x2015, 0x0016, 0x0a09, 0x1016, 0x2016,
	0x0017, 0x0a0a, 0x1017, 0x2017, 0x0018, 0x0a0b, 0x1018, 0x2018,
	0x0019, 0x0b04, 0x1019, 0x2019, 0x001a, 0x0b05, 0x101a, 0x201a,
	0x001b, 0x0b06, 0x101b, 0x201b, 0x001c, 0x0b07, 0x101c, 0x201c,
	0x001d, 0x0b08, 0x101d, 0x201d, 0x001e, 0x0b09, 0x101e, 0x201e,
	0x001f, 0x0b0a, 0x101f, 0x201f, 0x0020, 0x0b0b, 0x1020, 0x2020,
	0x0021, 0x0c04, 0x1021, 0x2021, 0x0022, 0x0c05, 0x1022, 0x2022,
	0x0023, 0x0c06, 0x1023, 0x2023, 0x0024, 0x0c07, 0x1024, 0x2024,
	0x0025, 0x0c08, 0x1025, 0x2025, 0x0026, 0x0c09, 0x1026, 0x2026,
	0x0027, 0x0c0a, 0x1027, 0x2027, 0x0028, 0x0c0b, 0x1028, 0x2028,
	0x0029, 0x0d04, 0x1029, 0x2029, 0x002a, 0x0d05, 0x102a, 0x202a,
	0x002b, 0x0d06, 0x102b, 0x202b, 0x002c, 0x0d07, 0x102c, 0x202c,
	0x002d, 0x0d08, 0x102d, 0x202d, 0x002e, 0x0d09, 0x102e, 0x202e,
	0x002f, 0x0d0a, 0x102f, 0x202f, 0x0030, 0x0d0b, 0x1030, 0x2030,
	0x0031, 0x0e04, 0x1031, 0x2031, 0x0032, 0x0e05, 0x1032, 0x2032,
	0x0033, 0x0e06, 0x1033, 0x2033, 0x0034, 0x0e07, 0x1034, 0x2034,
	0x0035, 0x0e08, 0x1035, 0x2035, 0x0036, 0x0e09, 0x1036, 0x2036,
	0x0037, 0x0e0a, 0x1037, 0x2037, 0x0038, 0x0e0b, 0x1038, 0x2038,
	0x0039, 0x0f04, 0x1039, 0x2039, 0x003a, 0x0f05, 0x103a, 0x203a,
	0x003b, 0x0f06, 0x103b, 0x203b, 0x003c, 0x0f07, 0x103c, 0x203c,
	0x0801, 0x0f08, 0x103d, 0x203d, 0x1001, 0x0f09, 0x103e, 0x203e,
	0x1801, 0x0f0a, 0x103f, 0x203f, 0x2001, 0x0f0b, 0x1040, 0x2040
};

struct snappy_decompressor {
	struct source *reader;	/* 압축 해제할 바이트의 기본 소스 */
	const char *ip;		/* 다음 버퍼 바이트를 가리킴 */
	const char *ip_limit;	/* 버퍼된 바이트의 바로 뒤를 가리킴 */
	u32 peeked;		/* reader에서 미리 본 바이트(건너뛰어야 함) */
	bool eof;		/* 오류 없이 입력 끝에 도달했는가? */
	char scratch[5];	/* peekfast 경계용 임시 버퍼 */
};

static void
init_snappy_decompressor(struct snappy_decompressor *d, struct source *reader)
{
	d->reader = reader;
	d->ip = NULL;
	d->ip_limit = NULL;
	d->peeked = 0;
	d->eof = false;
}

/* snappy.c 원본 함수 */
static void exit_snappy_decompressor(struct snappy_decompressor *d)
{
	skip(d->reader, d->peeked);
}

/*
 * 압축 데이터 시작에 저장된 압축 해제 길이를 읽는다.
 * 성공 시 *result에 길이를 저장하고 true를 반환한다.
 * 실패 시 false를 반환한다.
 */
static bool read_uncompressed_length(struct snappy_decompressor *d,
				     u32 * result)
{
	DCHECK(d->ip == NULL);	/*
			 * 아직 아무것도 읽지 않았어야 함
			 * 길이는 1..5바이트로 인코딩됨
			 */
	*result = 0;
	u32 shift = 0;
	while (true) {
		if (shift >= 32)
			return false;
		size_t n;
		const char *ip = peek(d->reader, &n);
		if (n == 0)
			return false;
		const unsigned char c = *(const unsigned char *)(ip);
		skip(d->reader, 1);
		*result |= (u32) (c & 0x7f) << shift;
		if (c < 128) {
			break;
		}
		shift += 7;
	}
	return true;
}

static bool refill_tag(struct snappy_decompressor *d);

/*
 * 입력에서 찾은 다음 항목을 처리한다.
 * 성공 시 true, 오류 또는 입력 끝이면 false.
 */
static void decompress_all_tags(struct snappy_decompressor *d,
				struct writer *writer)
{
	const char *ip = d->ip;

	/*
	 * 이 refill fragment를 루프 시작에만 둘 수도 있지만,
	 * 각 분기 끝에 중복해 두면 컴파일러가 로컬 컨텍스트를 바탕으로
	 * <ip_limit_ - ip> 표현식을 더 잘 최적화할 수 있어
	 * 전체적으로 속도가 증가한다.
	 */
#define MAYBE_REFILL() \
        if (d->ip_limit - ip < 5) {		\
		d->ip = ip;			\
		if (!refill_tag(d)) return;	\
		ip = d->ip;			\
        }


	MAYBE_REFILL();
	for (;;) {
		if (d->ip_limit - ip < 5) {
			d->ip = ip;
			if (!refill_tag(d))
				return;
			ip = d->ip;
		}

		const unsigned char c = *(const unsigned char *)(ip++);

		if ((c & 0x3) == LITERAL) {
			u32 literal_length = (c >> 2) + 1;
			if (writer_try_fast_append(writer, ip, d->ip_limit - ip, 
						   literal_length)) {
				DCHECK_LT(literal_length, 61);
				ip += literal_length;
				MAYBE_REFILL();
				continue;
			}
			if (unlikely(literal_length >= 61)) {
				/* 긴 리터럴 */
				const u32 literal_ll = literal_length - 60;
				literal_length = (get_unaligned_le32(ip) &
						  wordmask[literal_ll]) + 1;
				ip += literal_ll;
			}

			u32 avail = d->ip_limit - ip;
			while (avail < literal_length) {
				if (!writer_append(writer, ip, avail))
					return;
				literal_length -= avail;
				skip(d->reader, d->peeked);
				size_t n;
				ip = peek(d->reader, &n);
				avail = n;
				d->peeked = avail;
				if (avail == 0)
					return;	/* 입력이 예상보다 일찍 끝남 */
				d->ip_limit = ip + avail;
			}
			if (!writer_append(writer, ip, literal_length))
				return;
			ip += literal_length;
			MAYBE_REFILL();
		} else {
			const u32 entry = char_table[c];
			const u32 trailer = get_unaligned_le32(ip) &
				wordmask[entry >> 11];
			const u32 length = entry & 0xff;
			ip += entry >> 11;

			/*
			 * copy_offset/256은 8..10비트에 인코딩됨.
			 * 그 비트들만 추출하면 copy_offset을 얻는다
			 * (비트필드는 8비트부터 시작).
			 */
			const u32 copy_offset = entry & 0x700;
			if (!writer_append_from_self(writer,
						     copy_offset + trailer,
						     length))
				return;
			MAYBE_REFILL();
		}
	}
}

#undef MAYBE_REFILL

/* snappy.c 원본 함수 */
static bool refill_tag(struct snappy_decompressor *d)
{
	const char *ip = d->ip;

	if (ip == d->ip_limit) {
		size_t n;
		/* reader에서 새 조각을 가져옴 */
		skip(d->reader, d->peeked); /* 미리 본 바이트를 모두 사용함 */
		ip = peek(d->reader, &n);
		d->peeked = n;
		if (n == 0) {
			d->eof = true;
			return false;
		}
		d->ip_limit = ip + n;
	}

	/* 태그 문자를 읽음 */
	DCHECK_LT(ip, d->ip_limit);
	const unsigned char c = *(const unsigned char *)(ip);
	const u32 entry = char_table[c];
	const u32 needed = (entry >> 11) + 1;	/* 'c'를 위한 +1바이트 */
	DCHECK_LE(needed, sizeof(d->scratch));

	/* 필요하면 reader에서 더 읽음 */
	u32 nbuf = d->ip_limit - ip;

	if (nbuf < needed) {
		/*
		 * ip와 reader의 바이트를 이어서 워드 내용을 만든다.
		 * 필요한 바이트를 "scratch"에 저장한다.
		 * 필요한 만큼만 읽으므로 호출자가 즉시 소비한다.
		 */
		memmove(d->scratch, ip, nbuf);
		skip(d->reader, d->peeked); /* 미리 본 바이트를 모두 사용함 */
		d->peeked = 0;
		while (nbuf < needed) {
			size_t length;
			const char *src = peek(d->reader, &length);
			if (length == 0)
				return false;
			u32 to_add = min_t(u32, needed - nbuf, length);
			memcpy(d->scratch + nbuf, src, to_add);
			nbuf += to_add;
			skip(d->reader, to_add);
		}
		DCHECK_EQ(nbuf, needed);
		d->ip = d->scratch;
		d->ip_limit = d->scratch + needed;
	} else if (nbuf < 5) {
		/*
		 * 충분한 바이트가 있지만 입력 끝을 넘지 않도록
		 * scratch로 복사한다.
		 */
		memmove(d->scratch, ip, nbuf);
		skip(d->reader, d->peeked); /* 미리 본 바이트를 모두 사용함 */
		d->peeked = 0;
		d->ip = d->scratch;
		d->ip_limit = d->scratch + nbuf;
	} else {
		/* reader가 반환한 버퍼 포인터를 그대로 사용 */
		d->ip = ip;
	}
	return true;
}

static int internal_uncompress(struct source *r,
			       struct writer *writer, u32 max_len)
{
	struct snappy_decompressor decompressor;
	u32 uncompressed_len = 0;

	init_snappy_decompressor(&decompressor, r);

	if (!read_uncompressed_length(&decompressor, &uncompressed_len))
		return -EIO;
	/* 가능한 DoS 공격을 방어 */
	if ((u64) (uncompressed_len) > max_len)
		return -EIO;

	writer_set_expected_length(writer, uncompressed_len);

	/* 전체 입력을 처리 */
	decompress_all_tags(&decompressor, writer);

	exit_snappy_decompressor(&decompressor);
	if (decompressor.eof && writer_check_length(writer))
		return 0;
	return -EIO;
}

static inline int compress(struct snappy_env *env, struct source *reader,
			   struct sink *writer)
{
	int err;
	size_t written = 0;
	int N = available(reader);
	char ulength[kmax32];
	char *p = varint_encode32(ulength, N);

	append(writer, ulength, p - ulength);
	written += (p - ulength);

	while (N > 0) {
		/* 가능하면 복사 없이 다음 압축 블록을 가져옴 */
		size_t fragment_size;
		const char *fragment = peek(reader, &fragment_size);
		if (fragment_size == 0) {
			err = -EIO;
			goto out;
		}
		const unsigned num_to_read = min_t(int, N, kblock_size);
		size_t bytes_read = fragment_size;

		int pending_advance = 0;
		if (bytes_read >= num_to_read) {
			/* reader가 반환한 버퍼가 충분히 큼 */
			pending_advance = num_to_read;
			fragment_size = num_to_read;
		}
		else {
			memcpy(env->scratch, fragment, bytes_read);
			skip(reader, bytes_read);

			while (bytes_read < num_to_read) {
				fragment = peek(reader, &fragment_size);
				size_t n =
				    min_t(size_t, fragment_size,
					  num_to_read - bytes_read);
				memcpy((char *)(env->scratch) + bytes_read, fragment, n);
				bytes_read += n;
				skip(reader, n);
			}
			DCHECK_EQ(bytes_read, num_to_read);
			fragment = env->scratch;
			fragment_size = num_to_read;
		}
		if (fragment_size < num_to_read)
			return -EIO;

		/* 압축용 인코딩 테이블 가져오기 */
		int table_size;
		u16 *table = get_hash_table(env, num_to_read, &table_size);

		/* input_fragment를 압축해 dest에 추가 */
		char *dest;
		dest = sink_peek(writer, snappy_max_compressed_length(num_to_read));
		if (!dest) {
			/*
			 * 출력용 scratch 버퍼가 필요함.
			 * byte sink가 한 덩어리로 충분한 공간을
			 * 제공하지 않기 때문.
			 */
			dest = env->scratch_output;
		}
		char *end = compress_fragment(fragment, fragment_size,
					      dest, table, table_size);
		append(writer, dest, end - dest);
		written += (end - dest);

		N -= num_to_read;
		skip(reader, pending_advance);
	}

	err = 0;
out:
	return err;
}

/**
 * snappy_compress - snappy 압축기로 버퍼를 압축.
 * @env: 사전 할당된 환경
 * @input: 입력 버퍼
 * @input_length: 입력 버퍼 길이
 * @compressed: 압축 데이터 출력 버퍼
 * @compressed_length: 실제로 쓴 출력 길이를 여기에 기록
 *
 * 성공 시 0, 실패 시 음수 에러 코드.
 *
 * 출력 버퍼는 최소
 * snappy_max_compressed_length(input_length) 바이트여야 함.
 *
 * snappy_init_env로 미리 할당된 환경이 필요하다.
 * 이 환경은 호출 간 상태를 유지하지 않고 메모리만 미리 할당한다.
 */
int snappy_compress(struct snappy_env *env,
		    const char *input,
		    size_t input_length,
		    char *compressed, size_t *compressed_length)
{
	struct source reader = {
		.ptr = input,
		.left = input_length
	};
	struct sink writer = {
		.dest = compressed,
	};
	int err = compress(env, &reader, &writer);

	/* 추가된 바이트 수 계산 */
	*compressed_length = (writer.dest - compressed);
	return err;
}

/**
 * snappy_compress_with_len - 출력 길이를 명시해 압축.
 * @env: 사전 할당된 환경
 * @env_len: env 구조체 길이
 * @input: 입력 버퍼
 * @input_length: 입력 버퍼 길이
 * @compressed: 압축 데이터 출력 버퍼
 * @compressed_capacity: 출력 버퍼 크기
 * @compressed_length: 실제로 쓴 출력 길이를 여기에 기록
 * @compressed_length_len: compressed_length 포인터 길이
 *
 * 길이가 맞지 않으면 실패 처리한다.
 */
__attribute__((export_name("snappy_compress_with_len")))
int snappy_compress_with_len(struct snappy_env *env, size_t env_len,
			     const char *input, size_t input_length,
			     char *compressed, size_t compressed_capacity,
			     size_t *compressed_length, size_t compressed_length_len)
{
	if (env_len < sizeof(*env))
		return -EIO;
	if (compressed_length_len < sizeof(*compressed_length))
		return -EIO;
	if (compressed_capacity < snappy_max_compressed_length(input_length))
		return -EIO;
	return snappy_compress(env, input, input_length, compressed, compressed_length);
}
EXPORT_SYMBOL(snappy_compress_with_len);

__attribute__((export_name("snappy_verify_compress_len")))
bool snappy_verify_compress_len(size_t compressed_len, size_t input_len)
{
	return compressed_len < input_len;
}
EXPORT_SYMBOL(snappy_verify_compress_len);

/**
 * snappy_uncompress - snappy 압축 버퍼를 압축 해제.
 * @compressed: 압축 데이터 입력 버퍼
 * @n: 압축 버퍼 길이
 * @uncompressed: 압축 해제 데이터 버퍼
 *
 * 압축 해제 버퍼는 최소
 * snappy_uncompressed_length(compressed) 바이트여야 함.
 *
 * 성공 시 0, 실패 시 음수 에러 코드.
 */
/* snappy.c 원본 함수 */
int snappy_uncompress(const char *compressed, size_t n, char *uncompressed)
{
	struct source reader = {
		.ptr = compressed,
		.left = n
	};
	struct writer output = {
		.base = uncompressed,
		.op = uncompressed
	};
	return internal_uncompress(&reader, &output, 0xffffffff);
}

/**
 * snappy_uncompress_with_len - 출력 길이를 명시해 압축 해제.
 * @compressed: 압축 데이터 입력 버퍼
 * @n: 압축 버퍼 길이
 * @uncompressed: 압축 해제 데이터 버퍼
 * @uncompressed_len: 압축 해제 버퍼 길이
 *
 * 압축 데이터가 예상 길이를 넘으면 실패 처리한다.
 * 에러 코드: -201(헤더 파싱 실패), -202(출력 길이 초과), -203(디코드 실패)
 */
static size_t dbg_last_compressed_ptr = 0;
static size_t dbg_last_n = 0;
static size_t dbg_last_uncompressed_ptr = 0;
static size_t dbg_last_uncompressed_len = 0;
static size_t dbg_last_expected = 0;
static int dbg_last_stage = 0;

__attribute__((export_name("snappy_uncompress_with_len")))
int snappy_uncompress_with_len(const char *compressed, size_t n,
			       char *uncompressed, size_t uncompressed_len)
{
	dbg_last_compressed_ptr = (size_t)compressed;
	dbg_last_n = n;
	dbg_last_uncompressed_ptr = (size_t)uncompressed;
	dbg_last_uncompressed_len = uncompressed_len;
	dbg_last_expected = 0;
	dbg_last_stage = 1;

	size_t expected = 0;
	if (!snappy_uncompressed_length_internal(compressed, n, &expected))
	{
		dbg_last_stage = -201;
		return -201;
	}
	dbg_last_expected = expected;
	dbg_last_stage = 2;
	if (expected > uncompressed_len)
	{
		dbg_last_stage = -202;
		return -202;
	}
	dbg_last_stage = 3;
	if (snappy_uncompress(compressed, n, uncompressed) != 0)
	{
		dbg_last_stage = -203;
		return -203;
	}
	dbg_last_stage = 100;
	return 0;
}
EXPORT_SYMBOL(snappy_uncompress_with_len);

__attribute__((export_name("snappy_dbg_last_compressed_ptr")))
size_t snappy_dbg_last_compressed_ptr(void)
{
	return dbg_last_compressed_ptr;
}

__attribute__((export_name("snappy_dbg_last_n")))
size_t snappy_dbg_last_n(void)
{
	return dbg_last_n;
}

__attribute__((export_name("snappy_dbg_last_uncompressed_ptr")))
size_t snappy_dbg_last_uncompressed_ptr(void)
{
	return dbg_last_uncompressed_ptr;
}

__attribute__((export_name("snappy_dbg_last_uncompressed_len")))
size_t snappy_dbg_last_uncompressed_len(void)
{
	return dbg_last_uncompressed_len;
}

__attribute__((export_name("snappy_dbg_last_expected")))
size_t snappy_dbg_last_expected(void)
{
	return dbg_last_expected;
}

__attribute__((export_name("snappy_dbg_last_stage")))
int snappy_dbg_last_stage(void)
{
	return dbg_last_stage;
}

/* snappy.c 원본 함수 */
static inline void clear_env(struct snappy_env *env)
{
    memset(env, 0, sizeof(*env));
}


/**
 * snappy_init_env - snappy 압축 환경을 할당.
 * @env: 미리 할당할 환경
 *
 * 성공 시 0, 실패 시 음수 errno.
 * 프로세스 컨텍스트에서 호출해야 함.
 */
/* snappy.c 원본 함수 */
int snappy_init_env(struct snappy_env *env)
{
    clear_env(env);
	env->hash_table = vmalloc(sizeof(u16) * kmax_hash_table_size);
	if (!env->hash_table)
		return -ENOMEM;
	return 0;
}

__attribute__((export_name("snappy_init_env_with_len")))
int snappy_init_env_with_len(struct snappy_env *env, size_t env_len)
{
	if (env_len < sizeof(*env))
		return -EIO;
	return snappy_init_env(env);
}
EXPORT_SYMBOL(snappy_init_env_with_len);

/**
 * snappy_free_env - snappy 압축 환경을 해제.
 * @env: 해제할 환경
 *
 * 프로세스 컨텍스트에서 호출해야 함.
 */
__attribute__((export_name("snappy_free_env")))
/* snappy.c 원본 함수 */
void snappy_free_env(struct snappy_env *env)
{
	vfree(env->hash_table);
	clear_env(env);
}
EXPORT_SYMBOL(snappy_free_env);
