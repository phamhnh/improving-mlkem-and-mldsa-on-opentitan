/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */


/* 256-bit vector shift example. */

.section .text.start

/******************************/
/*    Tests for bn.shv.8S     */
/******************************/

li x2, 1
li x4, 3
la x3, result

/* Load operands into WDRs */
bn.lid x2, 0(x0)

/* Perform vector shift, limbs are 32-bit. */
bn.shv.8S w3, w1 << 1
bn.shv.8S w3, w1 << 2
bn.shv.8S w3, w1 << 3
bn.shv.8S w3, w1 << 4
bn.shv.8S w3, w1 << 5
bn.shv.8S w3, w1 << 6
bn.shv.8S w3, w1 << 7
bn.shv.8S w3, w1 << 8
bn.shv.8S w3, w1 << 9
bn.shv.8S w3, w1 << 10
bn.shv.8S w3, w1 << 11
bn.shv.8S w3, w1 << 12
bn.shv.8S w3, w1 << 13
bn.shv.8S w3, w1 << 14
bn.shv.8S w3, w1 << 15
bn.shv.8S w3, w1 << 16
bn.shv.8S w3, w1 << 17
bn.shv.8S w3, w1 << 18
bn.shv.8S w3, w1 << 19
bn.shv.8S w3, w1 << 20
bn.shv.8S w3, w1 << 21
bn.shv.8S w3, w1 << 22
bn.shv.8S w3, w1 << 23
bn.shv.8S w3, w1 << 24
bn.shv.8S w3, w1 << 25
bn.shv.8S w3, w1 << 26
bn.shv.8S w3, w1 << 27
bn.shv.8S w3, w1 << 28
bn.shv.8S w3, w1 << 29
bn.shv.8S w3, w1 << 30
bn.shv.8S w3, w1 << 31

bn.shv.8S w3, w1 >> 1
bn.shv.8S w3, w1 >> 2
bn.shv.8S w3, w1 >> 3
bn.shv.8S w3, w1 >> 4
bn.shv.8S w3, w1 >> 5
bn.shv.8S w3, w1 >> 6
bn.shv.8S w3, w1 >> 7
bn.shv.8S w3, w1 >> 8
bn.shv.8S w3, w1 >> 9
bn.shv.8S w3, w1 >> 10
bn.shv.8S w3, w1 >> 11
bn.shv.8S w3, w1 >> 12
bn.shv.8S w3, w1 >> 13
bn.shv.8S w3, w1 >> 14
bn.shv.8S w3, w1 >> 15
bn.shv.8S w3, w1 >> 16
bn.shv.8S w3, w1 >> 17
bn.shv.8S w3, w1 >> 18
bn.shv.8S w3, w1 >> 19
bn.shv.8S w3, w1 >> 20
bn.shv.8S w3, w1 >> 21
bn.shv.8S w3, w1 >> 22
bn.shv.8S w3, w1 >> 23
bn.shv.8S w3, w1 >> 24
bn.shv.8S w3, w1 >> 25
bn.shv.8S w3, w1 >> 26
bn.shv.8S w3, w1 >> 27
bn.shv.8S w3, w1 >> 28
bn.shv.8S w3, w1 >> 29
bn.shv.8S w3, w1 >> 30
bn.shv.8S w3, w1 >> 31

/* store results to dmem */
bn.sid x4, 0(x3++)

/******************************/
/*    Tests for bn.shv.8S     */
/******************************/

/* Perform vector shift, limbs are 16-bit. */
bn.shv.16H w3, w1 << 1
bn.shv.16H w3, w1 << 2
bn.shv.16H w3, w1 << 3
bn.shv.16H w3, w1 << 4
bn.shv.16H w3, w1 << 5
bn.shv.16H w3, w1 << 6
bn.shv.16H w3, w1 << 7
bn.shv.16H w3, w1 << 8
bn.shv.16H w3, w1 << 9
bn.shv.16H w3, w1 << 10
bn.shv.16H w3, w1 << 11
bn.shv.16H w3, w1 << 12
bn.shv.16H w3, w1 << 13
bn.shv.16H w3, w1 << 14
bn.shv.16H w3, w1 << 15

bn.shv.16H w3, w1 >> 1
bn.shv.16H w3, w1 >> 2
bn.shv.16H w3, w1 >> 3
bn.shv.16H w3, w1 >> 4
bn.shv.16H w3, w1 >> 5
bn.shv.16H w3, w1 >> 6
bn.shv.16H w3, w1 >> 7
bn.shv.16H w3, w1 >> 8
bn.shv.16H w3, w1 >> 9
bn.shv.16H w3, w1 >> 10
bn.shv.16H w3, w1 >> 11
bn.shv.16H w3, w1 >> 12
bn.shv.16H w3, w1 >> 13
bn.shv.16H w3, w1 >> 14
bn.shv.16H w3, w1 >> 15

/* store results to dmem */
bn.sid x4, 0(x3++)

ecall

.data
.globl operand1
operand1:
  .quad 0x1101001010010000
  .quad 0x0001010101101010
  .quad 0x1011010011010100
  .quad 0x0001000100010001

.globl result
result:
  .zero 32*2
