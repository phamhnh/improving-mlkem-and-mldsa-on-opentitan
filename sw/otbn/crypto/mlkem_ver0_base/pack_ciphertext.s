/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.text

#if (KYBER_K == 2)
#define KYBER_POLYVECCOMPRESSED_LOOP 4
#elif (KYBER_K == 3)
#define KYBER_POLYVECCOMPRESSED_LOOP 6
#endif

/*
 * Name:        poly_compress
 *
 * Description: Compression and subsequent serialization of a polynomial
 *
 * Arguments:   - uint8_t r: output byte array (of length KYBER_POLYCOMPRESSEDBYTES)
 *              - poly a: input polynomial, n=256, q=3329
 *
 * Flags: Clobbers FG0, has no meaning beyond the scope of this subroutine.
 *
 * @param[in]  w31: all-zero
 * @param[in]  x11: dptr_input, dmem pointer to input polynomial
 * @param[in]  x13 (w3): const_80635
 * @param[in]  x15 (w2): dptr_modulus_over_2
 * @param[out] x12: dptr_output, dmem pointer to output byte array
 *
 * clobbered registers: x4-x30, w0-w31
 */

poly_compress:
#if (KYBER_K == 2 || KYBER_K == 3)
  bn.rshi w3, w31, w3 >> 4 /* 80635 */
  bn.addi w5, w31, 1
  bn.rshi w5, w5, w31 >> 240
  bn.subi w5, w5, 1 /* mask = 0xffff */
  LOOPI 4, 12
    LOOPI 4, 10
      bn.lid  x4, 0(x11++)  /* Load input */
      bn.rshi w0, w0, w31 >> 252 /* <= 4 */
      bn.add  w0, w0, w2 /* pseudo-vect: +1665 */
      LOOPI 16, 5
        bn.and          w1, w0, w5
        bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *80635 */
        bn.rshi         w1, w31, w1 >> 28 /* >= 28 */
        bn.rshi         w4, w1, w4 >> 4 /* save 4 bits */
        bn.rshi         w0, w31, w0 >> 16
      NOP 
    bn.sid x8, 0(x12++)
#elif (KYBER_K == 4)
  bn.addi w5, w31, 1
  bn.rshi w5, w5, w31 >> 240
  bn.subi w5, w5, 1 /* mask = 0xffff */
  bn.and  w2, w2, w5 /* 1665 */
  bn.subi w2, w2, 1  /* 1664 */
  bn.rshi w3, w31, w3 >> 4
  bn.addi w3, w3, 1 /* 40318 */
  /* First WDR */
  LOOPI 3, 10
    bn.lid x4, 0(x11++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w31 >> 16
      bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
      bn.add          w1, w1, w2         /* +1664 */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
      bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
      bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
      bn.rshi         w0, w31, w0 >> 16
    NOP 
  bn.lid x4, 0(x11++)
  LOOPI 3, 7
    bn.rshi         w1, w0, w31 >> 16
    bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
    bn.add          w1, w1, w2         /* +1664 */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
    bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
    bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
    bn.rshi         w0, w31, w0 >> 16
  bn.rshi         w1, w0, w31 >> 16
  bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
  bn.add          w1, w1, w2         /* +1664 */
  bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
  bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
  bn.rshi         w4, w1, w4 >> 1 /* save 5 bits */
  bn.rshi         w0, w31, w0 >> 16
  bn.sid  x8, 0(x12++)
  
  /* Second WDR */
  bn.rshi w4, w1, w4 >> 5
  LOOPI 12, 7
    bn.rshi         w1, w0, w31 >> 16
    bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
    bn.add          w1, w1, w2         /* +1664 */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
    bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
    bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
    bn.rshi         w0, w31, w0 >> 16
  LOOPI 2, 10
    bn.lid x4, 0(x11++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w31 >> 16
      bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
      bn.add          w1, w1, w2         /* +1664 */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
      bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
      bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
      bn.rshi         w0, w31, w0 >> 16
    NOP 
  bn.lid x4, 0(x11++)
  LOOPI 6, 7
    bn.rshi         w1, w0, w31 >> 16
    bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
    bn.add          w1, w1, w2         /* +1664 */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
    bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
    bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
    bn.rshi         w0, w31, w0 >> 16
  bn.rshi         w1, w0, w31 >> 16
  bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
  bn.add          w1, w1, w2         /* +1664 */
  bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
  bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
  bn.rshi         w4, w1, w4 >> 2 /* save 5 bits */
  bn.rshi         w0, w31, w0 >> 16
  bn.sid  x8, 0(x12++)

  /* Third WDR */
  bn.rshi w4, w1, w4 >> 5
  LOOPI 9, 7
    bn.rshi         w1, w0, w31 >> 16
    bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
    bn.add          w1, w1, w2         /* +1664 */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
    bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
    bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
    bn.rshi         w0, w31, w0 >> 16
  LOOPI 2, 10
    bn.lid x4, 0(x11++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w31 >> 16
      bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
      bn.add          w1, w1, w2         /* +1664 */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
      bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
      bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
      bn.rshi         w0, w31, w0 >> 16
    NOP 
  bn.lid x4, 0(x11++)
  LOOPI 9, 7
    bn.rshi         w1, w0, w31 >> 16
    bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
    bn.add          w1, w1, w2         /* +1664 */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
    bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
    bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
    bn.rshi         w0, w31, w0 >> 16
  bn.rshi         w1, w0, w31 >> 16
  bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
  bn.add          w1, w1, w2         /* +1664 */
  bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
  bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
  bn.rshi         w4, w1, w4 >> 3 /* save 5 bits */
  bn.rshi         w0, w31, w0 >> 16
  bn.sid  x8, 0(x12++)

  /* Fourth WDR */
  bn.rshi w4, w1, w4 >> 5
  LOOPI 6, 7
    bn.rshi         w1, w0, w31 >> 16
    bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
    bn.add          w1, w1, w2         /* +1664 */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
    bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
    bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
    bn.rshi         w0, w31, w0 >> 16
  LOOPI 2, 10
    bn.lid x4, 0(x11++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w31 >> 16
      bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
      bn.add          w1, w1, w2         /* +1664 */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
      bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
      bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
      bn.rshi         w0, w31, w0 >> 16
    NOP 
  bn.lid x4, 0(x11++)
  LOOPI 12, 7
    bn.rshi         w1, w0, w31 >> 16
    bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
    bn.add          w1, w1, w2         /* +1664 */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
    bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
    bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
    bn.rshi         w0, w31, w0 >> 16
  bn.rshi         w1, w0, w31 >> 16
  bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
  bn.add          w1, w1, w2         /* +1664 */
  bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
  bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
  bn.rshi         w4, w1, w4 >> 4 /* save 5 bits */
  bn.rshi         w0, w31, w0 >> 16
  bn.sid  x8, 0(x12++)

  /* Fifth WDR */
  bn.rshi w4, w1, w4 >> 5
  LOOPI 3, 7
    bn.rshi         w1, w0, w31 >> 16
    bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
    bn.add          w1, w1, w2         /* +1664 */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
    bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
    bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
    bn.rshi         w0, w31, w0 >> 16
  LOOPI 3, 10
    bn.lid x4, 0(x11++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w31 >> 16
      bn.rshi         w1, w31, w1 >> 235 /* <= 5 */
      bn.add          w1, w1, w2         /* +1664 */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *40318 */
      bn.rshi         w1, w31, w1 >> 27 /* >= 27 */
      bn.rshi         w4, w1, w4 >> 5 /* save 5 bits */
      bn.rshi         w0, w31, w0 >> 16
    NOP 
  bn.sid  x8, 0(x12++)
#endif
  ret

/*
 * Name:        polyvec_compress
 *
 * Description: Compress and serialize vector of polynomials
 *
 * Arguments:   - uint8_t r: output byte array (of length KYBER_POLYCOMPRESSEDBYTES)
 *              - poly a: input polynomial, n=256, q=3329
 *
 * Flags: Clobbers FG0, has no meaning beyond the scope of this subroutine.
 *
 * @param[in]  w31: all-zero
 * @param[in]  x10: dptr_input, dmem pointer to input polynomial
 * @param[in]  x13: const_1290167
 * @param[in]  x15: dptr_modulus_over_2
 * @param[out] x12: dptr_output, dmem pointer to output byte array
 *
 * clobbered registers: x4-x30, w0-w31
 */
polyvec_compress:
#if (KYBER_K == 2 || KYBER_K == 3)
  bn.rshi w7, w31, w2 >> 240 /* extract (Q+1)/2 */
  LOOPI KYBER_POLYVECCOMPRESSED_LOOP, 141
    /* First WDR: 25 coeffs (250 bits) + 6 bits of 10th coeff of next load */
    bn.lid x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi          w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi          w1, w31, w1 >> 230 /* << 10 */
      bn.add           w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z  w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi          w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi          w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi          w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 9, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 230 /* << 10 */
    bn.add          w1, w1, w7 /* +1665 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
    bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
    bn.rshi         w4, w1, w4 >> 6 /* store 6 bits of w1 to w4 */
    bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.sid          x8, 0(x12++)

    /* Second WDR: 4 bits + 25 coeffs (250 bits) + 2 bits */
    bn.rshi w4, w1, w4 >> 10 /* store 4 bits of w1 to w4 */
    LOOPI 6, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 3, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 230 /* << 10 */
    bn.add          w1, w1, w7 /* +1665 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
    bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
    bn.rshi         w4, w1, w4 >> 2 /* store 2 bits of w1 to w4 */
    bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.sid          x8, 0(x12++)

    /* Third WDR: 8 bits + 24 coeffs (240 bits) + 8 bits */
    bn.rshi w4, w1, w4 >> 10 /* store 8 bits of w1 to w4 */
    LOOPI 12, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 12, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 230 /* << 10 */
    bn.add          w1, w1, w7 /* +1665 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
    bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
    bn.rshi         w4, w1, w4 >> 8 /* store 8 bits of w1 to w4 */
    bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.sid          x8, 0(x12++)

    /* Fourth WDR: 2 bits + 25 coeffs (250 bits) + 4 bits */
    bn.rshi w4, w1, w4 >> 10 /* store 2 bits of w1 to w4 */
    LOOPI 3, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 6, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 230 /* << 10 */
    bn.add          w1, w1, w7 /* +1665 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
    bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
    bn.rshi         w4, w1, w4 >> 4 /* store 4 bits of w1 to w4 */
    bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.sid          x8, 0(x12++)

    /* Fifth WDR: 6 bits + 25 coeffs (250 bits) */
    bn.rshi w4, w1, w4 >> 10 /* store 6 bits of w1 to w4 */
    LOOPI 9, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 230 /* << 10 */
      bn.add          w1, w1, w7 /* +1665 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *1290167 (w3) */
      bn.rshi         w1, w31, w1 >> 32 /* >> 32 */
      bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.sid x8, 0(x12++)
#elif (KYBER_K == 4)
  bn.rshi w7, w31, w2 >> 240 /* extract (Q+1)/2 */
  bn.subi w7, w7, 1 /* 1664 */
  bn.rshi w3, w31, w3 >> 1 
  bn.addi w3, w3, 1 /* 645084 */
  LOOPI KYBER_K, 313
    /* 1st WDR */
    bn.lid x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 7, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 3 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 2nd WDR */
    bn.rshi w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi w0, w31, w0 >> 16 /* shift out used coeff */
    LOOPI 8, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 14, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 6 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 3rd WDR */
    bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid          x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 5, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 9 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 4th WDR */
    bn.rshi w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi w0, w31, w0 >> 16 /* shift out used coeff */
    LOOPI 10, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 13, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 1 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 5th WDR */
    bn.rshi w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi w0, w31, w0 >> 16 /* shift out used coeff */
    LOOPI 2, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 4, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 4 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 6th WDR */
    bn.rshi w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi w0, w31, w0 >> 16 /* shift out used coeff */
    LOOPI 11, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 11, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 7 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 7th WDR */
    bn.rshi w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi w0, w31, w0 >> 16 /* shift out used coeff */
    LOOPI 4, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 2, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 10 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 8th WDR */
    bn.rshi w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi w0, w31, w0 >> 16 /* shift out used coeff */
    LOOPI 13, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 10, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 2 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 9th WDR */
    bn.rshi w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi w0, w31, w0 >> 16 /* shift out used coeff */
    LOOPI 5, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 5 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 10th WDR */
    bn.rshi w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi w0, w31, w0 >> 16 /* shift out used coeff */
    LOOPI 14, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 8, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
    bn.rshi         w1, w31, w1 >> 229 /* << 11 */
    bn.add          w1, w1, w7 /* +1664 (w7) */
    bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
    bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
    bn.rshi         w4, w1, w4 >> 8 /* store res to w4 */
    bn.sid          x8, 0(x12++)

    /* 11th WDR */
    bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
    bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    LOOPI 7, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.lid x4, 0(x10++)
    LOOPI 16, 7
      bn.rshi         w1, w0, w1 >> 16 /* shift one coeff on w1 */
      bn.rshi         w1, w31, w1 >> 229 /* << 11 */
      bn.add          w1, w1, w7 /* +1664 (w7) */
      bn.mulqacc.wo.z w1, w1.0, w3.0, 0 /* *645084 (w3) */
      bn.rshi         w1, w31, w1 >> 31 /* >> 31 */
      bn.rshi         w4, w1, w4 >> 11 /* store res to w4 */
      bn.rshi         w0, w31, w0 >> 16 /* shift out used coeff */
    bn.sid x8, 0(x12++)
#endif 
  ret


/*
 * Name:        pack_ciphertext 
 *
 * Description: Serialize the ciphertext as concatenation of the
 *              compressed and serialized vector of polynomials b
 *              and the compressed and serialized polynomial v
 *
 * Arguments:   - uint8_t *r: pointer to the output serialized ciphertext
 *              - polyvec *b: pointer to the input vector of polynomials b
 *              - poly *v: pointer to the input polynomial v
 *
 * Flags: Clobbers FG0, has no meaning beyond the scope of this subroutine.
 *
 * @param[in]  w31: all-zero
 * @param[in]  x10: dptr_b, dmem pointer to first input polynomial
 * @param[in]  x11: dptr_v, dmem pointer to second input polynomial
 * @param[in]  x13: const_1290167
 * @param[in]  x15: dptr_modulus_over_2
 * @param[out] x12: dptr_output, dmem pointer to output byte array
 *
 * clobbered registers: x4-x30, w0-w31
 */

.globl pack_ciphertext
pack_ciphertext:
  /* Set up registers for input and output */
  li x4, 0
  li x5, 1
  li x6, 2
  li x7, 3
  li x8, 4

  /* Load const */
  bn.lid  x6, 0(x15) /* modulus_over_2 (w2) */
  bn.lid  x7, 0(x13) /* const_1290167 (w3) */

  bn.xor  w31, w31, w31
  bn.xor  w1, w1, w1
  jal     x1, polyvec_compress
  jal     x1, poly_compress

  ret


/*
 * Name:        poly_decompress
 *
 * Description: De-serialization and subsequent decompression of a polynomial;
 *              approximate inverse of poly_compress
 *
 * Arguments:   - uint8_t r: input byte array (of length KYBER_POLYCOMPRESSEDBYTES)
 *              - poly a: output polynomial, n=256, q=3329
 *
 * Flags: Clobbers FG0, has no meaning beyond the scope of this subroutine.
 *
 * @param[in]  w31: all-zero
 * @param[in]  x10: dptr_input, dmem pointer to input byte array
 * @param[out] x12: dptr_output, dmem pointer to output polynomial
 *
 * clobbered registers: x4-x30, w0-w31
 */

poly_decompress:
#if (KYBER_K == 2 || KYBER_K == 3)
  bn.rshi w2, w31, w2 >> 248 /* 0xf */
  bn.rshi w3, w31, w3 >> 240 /* 8 */
  LOOPI 4, 11
    bn.lid x4, 0(x10++)
    LOOPI 4, 8
      LOOPI 16, 6
        bn.and          w1, w0, w2 
        bn.mulqacc.wo.z w1, w1.0, w6.0, 0
        bn.add          w1, w1, w3
        bn.rshi         w1, w31, w1 >> 4
        bn.rshi         w4, w1, w4 >> 16
        bn.rshi         w0, w31, w0 >> 4
      bn.sid x8, 0(x12++)
    NOP 
#elif (KYBER_K == 4)
  bn.rshi w2, w31, w2 >> 247 /* 0x1f */
  bn.rshi w3, w31, w3 >> 239 /* 16 */
  /* 1st+2nd+3rd WDRs */
  bn.lid x4, 0(x10++)
  LOOPI 3, 8
    LOOPI 16, 6
      bn.and          w1, w0, w2 
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w3
      bn.rshi         w1, w31, w1 >> 5
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 5
    bn.sid x8, 0(x12++)

  /* 4th WDR */
  LOOPI 3, 6
    bn.and          w1, w0, w2 
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w3
    bn.rshi         w1, w31, w1 >> 5
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 5
  bn.rshi         w1, w0, w1 >> 1
  bn.lid          x4, 0(x10++)
  bn.rshi         w1, w0, w1 >> 4
  bn.rshi         w1, w31, w1 >> 251
  bn.rshi         w0, w31, w0 >> 4
  bn.mulqacc.wo.z w1, w1.0, w6.0, 0
  bn.add          w1, w1, w3
  bn.rshi         w1, w31, w1 >> 5
  bn.rshi         w4, w1, w4 >> 16
  LOOPI 12, 6
    bn.and          w1, w0, w2 
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w3
    bn.rshi         w1, w31, w1 >> 5
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 5
  bn.sid x8, 0(x12++)

  /* 5th+6th WDR */
  LOOPI 2, 8
    LOOPI 16, 6
      bn.and          w1, w0, w2 
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w3
      bn.rshi         w1, w31, w1 >> 5
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 5
    bn.sid x8, 0(x12++)
  
  /* 7th WDR */
  LOOPI 6, 6
    bn.and          w1, w0, w2 
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w3
    bn.rshi         w1, w31, w1 >> 5
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 5
  bn.rshi         w1, w0, w1 >> 2
  bn.lid          x4, 0(x10++)
  bn.rshi         w1, w0, w1 >> 3
  bn.rshi         w1, w31, w1 >> 251
  bn.rshi         w0, w31, w0 >> 3
  bn.mulqacc.wo.z w1, w1.0, w6.0, 0
  bn.add          w1, w1, w3
  bn.rshi         w1, w31, w1 >> 5
  bn.rshi         w4, w1, w4 >> 16
  LOOPI 9, 6
    bn.and          w1, w0, w2 
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w3
    bn.rshi         w1, w31, w1 >> 5
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 5
  bn.sid x8, 0(x12++)

  /* 8th+9th WDR */
  LOOPI 2, 8
    LOOPI 16, 6
      bn.and          w1, w0, w2 
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w3
      bn.rshi         w1, w31, w1 >> 5
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 5
    bn.sid x8, 0(x12++)

  /* 10th WDR */
  LOOPI 9, 6
    bn.and          w1, w0, w2 
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w3
    bn.rshi         w1, w31, w1 >> 5
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 5
  bn.rshi         w1, w0, w1 >> 3
  bn.lid          x4, 0(x10++)
  bn.rshi         w1, w0, w1 >> 2
  bn.rshi         w1, w31, w1 >> 251
  bn.rshi         w0, w31, w0 >> 2
  bn.mulqacc.wo.z w1, w1.0, w6.0, 0
  bn.add          w1, w1, w3
  bn.rshi         w1, w31, w1 >> 5
  bn.rshi         w4, w1, w4 >> 16
  LOOPI 6, 6
    bn.and          w1, w0, w2 
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w3
    bn.rshi         w1, w31, w1 >> 5
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 5
  bn.sid x8, 0(x12++)

  /* 11th+12th WDR */
  LOOPI 2, 8
    LOOPI 16, 6
      bn.and          w1, w0, w2 
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w3
      bn.rshi         w1, w31, w1 >> 5
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 5
    bn.sid x8, 0(x12++)
  
  /* 13th WDR */
  LOOPI 12, 6
    bn.and          w1, w0, w2 
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w3
    bn.rshi         w1, w31, w1 >> 5
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 5
  bn.rshi         w1, w0, w1 >> 4
  bn.lid          x4, 0(x10++)
  bn.rshi         w1, w0, w1 >> 1
  bn.rshi         w1, w31, w1 >> 251
  bn.rshi         w0, w31, w0 >> 1
  bn.mulqacc.wo.z w1, w1.0, w6.0, 0
  bn.add          w1, w1, w3
  bn.rshi         w1, w31, w1 >> 5
  bn.rshi         w4, w1, w4 >> 16
  LOOPI 3, 6
    bn.and          w1, w0, w2 
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w3
    bn.rshi         w1, w31, w1 >> 5
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 5
  bn.sid x8, 0(x12++)

  /* 14th+15th+16th WDR */
  LOOPI 3, 8
    LOOPI 16, 6
      bn.and          w1, w0, w2 
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w3
      bn.rshi         w1, w31, w1 >> 5
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 5 
    bn.sid x8, 0(x12++)
#endif 
  ret

/*
 * Name:        polyvec_decompress
 *
 * Description: De-serialize and decompress vector of polynomials;
 *              approximate inverse of polyvec_compress
 *
 * Arguments:   - polyvec *r:       pointer to output vector of polynomials
 *              - const uint8_t *a: pointer to input byte array
 *                                  (of length KYBER_POLYVECCOMPRESSEDBYTES)
 * Flags: Clobbers FG0, has no meaning beyond the scope of this subroutine.
 *
 * @param[in]  w31: all-zero
 * @param[in]  x10: dptr_input, dmem pointer to input polynomial
 * @param[out] x12: dptr_output, dmem pointer to output byte array
 *
 * clobbered registers: x4-x30, w0-w31
 */

polyvec_decompress:
#if (KYBER_K == 2 || KYBER_K == 3)
  bn.rshi w5, w31, w2 >> 242 /* 0x3ff */
  bn.rshi w7, w31, w3 >> 234 /* 512 */
  LOOPI KYBER_POLYVECCOMPRESSED_LOOP, 129
    /* First WDR: 160 bits of w0 */
    bn.lid x4, 0(x10++)
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.sid x8, 0(x12++)

    /* Second WDR: 90 bits + 6 bits + (Reload) 4 bits + 60 bits */
    LOOPI 9, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.rshi         w1, w0, w1 >> 6
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 4
    bn.rshi         w1, w31, w1 >> 246
    bn.rshi         w0, w31, w0 >> 4
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 10
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 6, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.sid x8, 0(x12++)

    /* Third WDR: 160 bits */
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.sid x8, 0(x12++)

    /* Fourth WDR: 30 bits + 2 bits + (Reload) 8 bits + 120 bits */
    LOOPI 3, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.rshi         w1, w0, w1 >> 2
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 8
    bn.rshi         w1, w31, w1 >> 246
    bn.rshi         w0, w31, w0 >> 8
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 10
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 12, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.sid x8, 0(x12++)

    /* Fifth WDR: 120 bits + 8 bits + (Reload) 2 bits + 30 bits */
    LOOPI 12, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.rshi         w1, w0, w1 >> 8
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 2
    bn.rshi         w1, w31, w1 >> 246
    bn.rshi         w0, w31, w0 >> 2
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 10
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 3, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.sid x8, 0(x12++)

    /* Sixth WDR: 160 bits */
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.sid x8, 0(x12++)

    /* Seventh WDR: 60 bits + 4 bits + (Reload) 6 bits + 90 bits */
    LOOPI 6, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.rshi         w1, w0, w1 >> 4
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 6
    bn.rshi         w1, w31, w1 >> 246
    bn.rshi         w0, w31, w0 >> 6
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 10
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 9, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.sid x8, 0(x12++)

    /* Eigth WDR: 160 bits */
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 10
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 10
    bn.sid x8, 0(x12++)
#elif (KYBER_K == 4)
  bn.rshi w5, w31, w2 >> 241 /* 0x7ff */
  bn.rshi w7, w31, w3 >> 233 /* 1024 */
  LOOPI KYBER_K, 287
    /* First WDR */
    bn.lid x4, 0(x10++) 
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 2nd WDR */
    LOOPI 7, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 3
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 8
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 8
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 8, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* Third WDR: 160 bits */
    LOOPI 14, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 6
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 5
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 5
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    bn.and          w1, w0, w5
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 4th WDR */
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 5th WDR */
    LOOPI 5, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 9
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 2
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 2
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 10, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 6th WDR */
    LOOPI 13, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 1
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 10
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 10
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 2, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 7th WDR */
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 8th WDR */
    LOOPI 4, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 4
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 7
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 7
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 11, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 9th WDR */
    LOOPI 11, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 7
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 4
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 4
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 4, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 10th WDR */
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 11th WDR */
    LOOPI 2, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 10
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 1
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 1
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 13, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 12th WDR */
    LOOPI 10, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 2
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 9
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 9
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 5, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 13th WDR */
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 14th WDR */
    bn.and          w1, w0, w5
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 5
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 6
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 6
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 14, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 15th WDR */
    LOOPI 8, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.rshi         w1, w0, w1 >> 8
    bn.lid          x4, 0(x10++)
    bn.rshi         w1, w0, w1 >> 3
    bn.rshi         w1, w31, w1 >> 245
    bn.rshi         w0, w31, w0 >> 3
    bn.mulqacc.wo.z w1, w1.0, w6.0, 0
    bn.add          w1, w1, w7
    bn.rshi         w1, w31, w1 >> 11
    bn.rshi         w4, w1, w4 >> 16
    LOOPI 7, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)

    /* 16th WDR */
    LOOPI 16, 6
      bn.and          w1, w0, w5
      bn.mulqacc.wo.z w1, w1.0, w6.0, 0
      bn.add          w1, w1, w7
      bn.rshi         w1, w31, w1 >> 11
      bn.rshi         w4, w1, w4 >> 16
      bn.rshi         w0, w31, w0 >> 11
    bn.sid x8, 0(x12++)
#endif 
  ret

/*
 * Name:        unpack_ciphertext 
 *
 * Description: Serialize the secret key
 *
 * Arguments:   - uint8_t *r: pointer to output serialized secret key
 *              - polyvec *sk: pointer to input vector of polynomials (secret key)
 *
 * Flags: Clobbers FG0, has no meaning beyond the scope of this subroutine.
 *
 * @param[in]  x10: dptr_input, dmem pointer to first input byte array 
 * @param[in]  x13: const_8
 * @param[in]  x14: modulus
 * @param[in]  x15: const_0x0fff
 * @param[out] x12: dptr_output, dmem pointer to output ciphertext
 * @param[in]  w31: all-zero
 *
 * clobbered registers: x4-x30, w0-w31
 */

.globl unpack_ciphertext
unpack_ciphertext:
  /* Set up registers for input and output */
  li x4, 0
  li x5, 1
  li x6, 2
  li x7, 3
  li x8, 4
  li x9, 6

  /* Load const */
  bn.lid  x6, 0(x15) /* const_0x0fff (w2) */
  bn.lid  x7, 0(x13) /* const_8 (w3) */
  bn.lid  x9, 0(x14) /* modulus (w6) */

  bn.xor     w31, w31, w31
  bn.xor     w1, w1, w1
  jal        x1, polyvec_decompress
  jal        x1, poly_decompress

  ret