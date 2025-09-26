/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.text

#define SEEDBYTES 32
#define CRHBYTES 64
#define TRBYTES 64
#define RNDBYTES 32
#define N 256
#define Q 8380417
#define D 13
#define ROOT_OF_UNITY 1753

#if DILITHIUM_MODE == 2
#define K 4
#define L 4
#define ETA 2
#define TAU 39
#define BETA 78
#define GAMMA1 131072
#define GAMMA2 95232
#define OMEGA 80
#define CTILDEBYTES 32

#define POLYVECK_BYTES 4096
#define POLYVECL_BYTES 4096

#define CRYPTO_PUBLICKEYBYTES 1312
#define CRYPTO_SECRETKEYBYTES 2560
#define CRYPTO_BYTES 2420

#elif DILITHIUM_MODE == 3
#define K 6
#define L 5
#define ETA 4
#define TAU 49
#define BETA 196
#define GAMMA1 524288
#define GAMMA2 261888
#define OMEGA 55
#define CTILDEBYTES 48

#define POLYVECK_BYTES 6144
#define POLYVECL_BYTES 5120

#define CRYPTO_PUBLICKEYBYTES 1952
#define CRYPTO_SECRETKEYBYTES 4032
#define CRYPTO_BYTES 3309

#elif DILITHIUM_MODE == 5
#define K 8
#define L 7
#define ETA 2
#define TAU 60
#define BETA 120
#define GAMMA1 524288
#define GAMMA2 261888
#define OMEGA 75
#define CTILDEBYTES 64

#define POLYVECK_BYTES 8192
#define POLYVECL_BYTES 7168

#define CRYPTO_PUBLICKEYBYTES 2592
#define CRYPTO_SECRETKEYBYTES 4896
#define CRYPTO_BYTES 4627

#endif

#define POLYT1_PACKEDBYTES  320
#define POLYT0_PACKEDBYTES  416
#define POLYVECH_PACKEDBYTES (OMEGA + K)

#if GAMMA1 == (1 << 17)
#define POLYZ_PACKEDBYTES   576
#elif GAMMA1 == (1 << 19)
#define POLYZ_PACKEDBYTES   640
#endif

#if GAMMA2 == (Q-1)/88
#define POLYW1_PACKEDBYTES  192
#elif GAMMA2 == (Q-1)/32
#define POLYW1_PACKEDBYTES  128
#endif

#if ETA == 2
#define POLYETA_PACKEDBYTES  96
#elif ETA == 4
#define POLYETA_PACKEDBYTES 128
#endif

/* Register aliases */
.equ x0, zero
.equ x2, sp
.equ x3, fp

.equ x5, t0
.equ x6, t1
.equ x7, t2

.equ x8, s0
.equ x9, s1

.equ x10, a0
.equ x11, a1

.equ x12, a2
.equ x13, a3
.equ x14, a4
.equ x15, a5
.equ x16, a6
.equ x17, a7

.equ x18, s2
.equ x19, s3
.equ x20, s4
.equ x21, s5
.equ x22, s6
.equ x23, s7
.equ x24, s8
.equ x25, s9
.equ x26, s10
.equ x27, s11

.equ x28, t3
.equ x29, t4
.equ x30, t5
.equ x31, t6

.equ w31, bn0

/* Macros */
.macro push reg
    addi sp, sp, -4      /* Decrement stack pointer by 4 bytes */
    sw \reg, 0(sp)      /* Store register value at the top of the stack */
.endm

.macro pop reg
    lw \reg, 0(sp)      /* Load value from the top of the stack into register */
    addi sp, sp, 4     /* Increment stack pointer by 4 bytes */
.endm

/**
 * decompose
 *
 * For finite field element a, compute high and low bits a0, a1 such that a
 * mod^+ Q = a1*ALPHA + a0 with -ALPHA/2 < a0 <= ALPHA/2 except if a1 =
 * (Q-1)/ALPHA where we set a1 = 0 and -ALPHA/2 <= a0 = a mod^+ Q - Q < 0.
 * Assumes a to be standard representative.
 * 
 * Returns: output element vector "a0" in w1, output element vector "a1" in w2
 *
 * @param[in] w0: input element vector
 * @param[in] w5-w11: constants in the following order: 1<<23,
 * decompose_const, qm1half_const, 43 or 15, gamma2x2_vec_const,
 * modulus_base, 0xFFFFFFFF
 *
 * clobbered registers: w1-w4, t0, t3-t4
 */
.global decompose
decompose:
    /* "a", "a{0,1}" refer to the variable names from the reference code */ 
#if GAMMA2 == (Q-1)/88
    LOOPI 8, 19
#elif GAMMA2 == (Q-1)/32
    LOOPI 8, 16
#endif
        bn.and w12, w0, w11 /* Mask 32-bit coefficient */
        bn.rshi w0, bn0, w0 >> 32 /* Discard used coefficient */

        /* Compute "a1" */
        bn.addi w3, w12, 127 /* a1  = (a + 127) */
        bn.rshi w3, bn0, w3 >> 7 /* a1  = (a + 127) >> 7 */
#if GAMMA2 == (Q-1)/88
        bn.mulqacc.wo.z w3, w3.0, w6.0, 0 /* a1*11275 */
        bn.add          w3, w3, w5        /* a1*11275 + (1 << 23) */
        bn.rshi         w3, bn0, w3 >> 24 /* (a1*11275 + (1 << 23)) >> 24 */

        bn.sub w4, w8, w3 /* (43 - a1) */
        bn.rshi w4, bn0, w4 >> 255 /* (43 - a1) >> 31) get sign bit */
        bn.mulqacc.wo.z w4, w4.0, w3.0, 0 /* ((43 - a1) >> 31) & a1 */
        bn.xor w3, w3, w4 /* a1 ^= ((43 - a1) >> 31) & a1 */
#elif GAMMA2 == (Q-1)/32
        bn.mulqacc.wo.z w3, w3.0, w6.0, 0 /* a1*1025 */
        bn.add          w3, w3, w5        /* a1*1025 + (1 << 21) */
        bn.rshi         w3, bn0, w3 >> 22 /* (a1*1025 + (1 << 21)) >> 22 */
        bn.and          w3, w3, w8        /* & 15 */
#endif
        bn.rshi w2, w3, w2 >> 32 /* Accumulate output */

        /* Compute "a0" */
        bn.mulqacc.wo.z w4, w3.0, w9.0, 0 /* a1*2*GAMMA2 */
        bn.sub w4, w12, w4 /* a - a1*2*GAMMA2 */

        bn.sub          w12, w7, w4 /* ((Q-1)/2 - *a0) */
        bn.rshi         w12, bn0, w12 >> 255 /* Get the sign bit */
        bn.mulqacc.wo.z w12, w12.0, w10.0, 0 /* Subtract Q if sign is 1 */
        bn.sub          w4, w4, w12 /* *a0 -= (((Q-1)/2 - *a0) >> 31) & Q; */

        bn.rshi w1, w4, w1 >> 32 /* Accumulate output */
    
    ret

/**
 * decompose
 *
 * For finite field element a, compute high and low bits a0, a1 such that a
 * mod^+ Q = a1*ALPHA + a0 with -ALPHA/2 < a0 <= ALPHA/2 except if a1 =
 * (Q-1)/ALPHA where we set a1 = 0 and -ALPHA/2 <= a0 = a mod^+ Q - Q < 0.
 * Assumes a to be standard representative.
 * 
 * Returns: output element vector "a0" in w1, output element vector "a1" in w2
 *
 * @param[in] w0: input element vector
 * @param[in] w5-w11: constants in the following order: 1<<23,
 * decompose_const, qm1half_const, 43 or 15, gamma2x2_vec_const,
 * modulus_base, 0xFFFFFFFF
 *
 * clobbered registers: w1-w4, t0, t3-t4
 */
.global decompose_unsigned
decompose_unsigned:
    /* "a", "a{0,1}" refer to the variable names from the reference code */ 
#if GAMMA2 == (Q-1)/88
    LOOPI 8, 19
#elif GAMMA2 == (Q-1)/32
    LOOPI 8, 16
#endif
        bn.and w12, w0, w11 /* Mask 32-bit coefficient */
        bn.rshi w0, bn0, w0 >> 32 /* Discard used coefficient */

        /* Compute "a1" */
        bn.addi w3, w12, 127 /* a1  = (a + 127) */
        bn.rshi w3, bn0, w3 >> 7 /* a1  = (a + 127) >> 7 */
#if GAMMA2 == (Q-1)/88
        bn.mulqacc.wo.z w3, w3.0, w6.0, 0 /* a1*11275 */
        bn.add          w3, w3, w5        /* a1*11275 + (1 << 23) */
        bn.rshi         w3, bn0, w3 >> 24 /* (a1*11275 + (1 << 23)) >> 24 */

        bn.sub w4, w8, w3 /* (43 - a1) */
        bn.rshi w4, bn0, w4 >> 255 /* (43 - a1) >> 31) get sign bit */
        bn.mulqacc.wo.z w4, w4.0, w3.0, 0 /* ((43 - a1) >> 31) & a1 */
        bn.xor w3, w3, w4 /* a1 ^= ((43 - a1) >> 31) & a1 */
#elif GAMMA2 == (Q-1)/32
        bn.mulqacc.wo.z w3, w3.0, w6.0, 0 /* a1*1025 */
        bn.add          w3, w3, w5        /* a1*1025 + (1 << 21) */
        bn.rshi         w3, bn0, w3 >> 22 /* (a1*1025 + (1 << 21)) >> 22 */
        bn.and          w3, w3, w8        /* & 15 */
#endif
        bn.rshi w2, w3, w2 >> 32 /* Accumulate output */

        /* Compute "a0" */
        bn.mulqacc.wo.z w4, w3.0, w9.0, 0 /* a1*2*GAMMA2 */
        bn.subm w4, w12, w4 /* a - a1*2*GAMMA2 */

        bn.subm          w12, w7, w4 /* ((Q-1)/2 - *a0) */
        bn.rshi         w12, bn0, w12 >> 255 /* Get the sign bit */
        bn.mulqacc.wo.z w12, w12.0, w10.0, 0 /* Subtract Q if sign is 1 */
        bn.sub          w4, w4, w12 /* *a0 -= (((Q-1)/2 - *a0) >> 31) & Q; */

        bn.rshi w1, w4, w1 >> 32 /* Accumulate output */
    
    ret
