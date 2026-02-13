#pragma once

/*
 * Minimal freestanding setjmp/longjmp declarations for libpng build.
 * This is not a full ABI-compatible implementation.
 */
typedef int jmp_buf[1];

int setjmp(jmp_buf env);
void longjmp(jmp_buf env, int val);
