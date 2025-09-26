/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.text

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

/**
 * Constant Time Dilithium base multiplication (pointwise)
 *
 * Returns: poly_pointwise(input1, input2)
 *
 * This implements the base multiplication for Dilithium, where n=256,q=8380417.
 *
 * Flags: -
 *
 * @param[in]  x10: dptr_input1, dmem pointer to first word of input1 polynomial
 * @param[in]  x11: dptr_input2, dmem pointer to first word of input2 polynomial
 * @param[in]  w31: all-zero
 * @param[out] x12: dmem pointer to result
 *
 * clobbered registers: x4-x6, w2-w4
 */
.globl poly_pointwise
poly_pointwise:
    #define mask w7
    #define qprime w8.2
    #define q w8.3
    
    /* Init constants */

    /* Load mask */
    bn.addi mask, bn0, 1
    bn.or   mask, bn0, mask << 32
    bn.subi mask, mask, 1

    /* Load q' to w8.0 */
    li t0, 8
    la t1, qprime_single
    bn.lid t0, 0(t1)
    bn.or w8, bn0, w8 << 128

    /* Load q to w8.2 */
    li t0, 9
    la t1, modulus
    bn.lid t0, 0(t1)
    bn.and w9, mask, w9
    bn.or w8, w8, w9 << 192

    /* Load alpha = 1 */
    bn.addi w10, bn0, 1
    bn.or w8, w8, w10 << 64
    /* Constants for WDRs */
    li t0, 0
    li t1, 1
    li t2, 6

    LOOPI 32, 13
        bn.lid t0, 0(a0++)
        bn.lid t1, 0(a1++)

        LOOPI 8, 9
            /* Mask one coefficient to working registers */
            bn.and w4, w0, w7
            bn.and w5, w1, w7
            /* Shift out used coefficient */
            bn.rshi w0, bn0, w0 >> 32

            /* Do operation */
            /* c = a * b */
            bn.mulqacc.wo.z w5, qprime, w5.0, 0
            /* Multiply q' */
            bn.mulqacc.wo.z w4, w4.0, w5.0, 192
            /* Extract upper 32-bits of bottom result half */
            /* + 1 */
            bn.add w4, w8, w4 >> 160
            bn.mulqacc.wo.z w4, w4.1, q, 0
            bn.rshi w4, w8, w4 >> 32

            /* Append result to output */
            bn.rshi w1, w4, w1 >> 32
        /* Store 8 coefficients */
        bn.sid t1, 0(a2++)
    ret

/**
 * Constant Time Dilithium base multiplication (pointwise) with accumulation
 *
 * Returns: poly_pointwise_acc(input1, input2)
 *
 * This implements the base multiplication for Dilithium, where n=256,q=8380417.
 * Accumulates onto the output polynomial.
 *
 * Flags: -
 * 
 * @param[in]  x10: dptr_input1, dmem pointer to first word of input1 polynomial
 * @param[in]  x11: dptr_input2, dmem pointer to first word of input2 polynomial
 * @param[in]  w31: all-zero
 * @param[in/out] x12: dmem pointer to result
 *
 * clobbered registers: x4-x6, w2-w4
 */
.globl poly_pointwise_acc
poly_pointwise_acc:
    #define mask w7
    #define qprime w8.2
    #define q w8.3
    
    /* Init constants */

    /* Load mask */
    bn.addi mask, bn0, 1
    bn.or   mask, bn0, mask << 32
    bn.subi mask, mask, 1

    /* Load q' to w8.0 */
    li t0, 8
    la t1, qprime_single
    bn.lid t0, 0(t1)
    bn.or w8, bn0, w8 << 128

    /* Load q to w8.2 */
    li t0, 9
    la t1, modulus
    bn.lid t0, 0(t1)
    bn.and w9, mask, w9
    bn.or w8, w8, w9 << 192

    /* Load alpha = 1 */
    bn.addi w10, bn0, 1
    bn.or w8, w8, w10 << 64

    /* Constants for WDRs */
    li t0, 0
    li t1, 1
    li t2, 2
    li t3, 6

    LOOPI 32, 15
        bn.lid t0, 0(a0++)
        bn.lid t1, 0(a1++)
        bn.lid t2, 0(a2)

        LOOPI 8, 9
            /* Mask one coefficient to working registers */
            bn.and w4, w0, mask
            bn.and w5, w1, mask
            /* Shift out used coefficient */
            bn.rshi w0, bn0, w0 >> 32

            /* Do operation */
            /* c = a * b */
            bn.mulqacc.wo.z w5, qprime, w5.0, 0
            /* Multiply q' */
            bn.mulqacc.wo.z w4, w5.0, w4.0, 192
            /* + 1 */
            bn.add w4, w8, w4 >> 160
            bn.mulqacc.wo.z w4, w4.1, q, 0
            bn.rshi w4, w8, w4 >> 32

            /* Append result to output */
            bn.rshi w1, w4, w1 >> 32

        bn.add w1, w1, w2 /* Accumulate */

        /* Store 8 coefficients */
        bn.sid t1, 0(a2++)
    ret
