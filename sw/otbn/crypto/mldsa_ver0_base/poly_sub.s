/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.text

/**
 * Constant Time Dilithium polynomial addition
 *
 * Returns: add(input1, input2) reduced mod q (taken from MOD WDR)
 *
 * This implements the polynomial addition for e.g. Dilithium, where n=256.
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
.global poly_sub
poly_sub:
    /* Init mask */
    bn.addi w7, w31, 1
    bn.or   w7, w31, w7 << 32
    bn.subi w7, w7, 1

    /* Set up constants for input/state */
    li x4, 1

    LOOPI 32, 9
        bn.lid x0, 0(x10++)
        bn.lid x4, 0(x11++)

        LOOPI 8, 5
            /* Mask one coefficient to working registers */
            bn.and w2, w0, w7
            bn.and w3, w1, w7
            /* Shift out used coefficient */
            bn.rshi w0, w31, w0 >> 32

            bn.subm w2, w2, w3
            bn.rshi w1, w2, w1 >> 32
        
        bn.sid x4, 0(x12++)
    ret
