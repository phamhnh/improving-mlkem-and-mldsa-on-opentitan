/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* 256-bit vector addition and subtraction example. */

.section .text.start

li x2, 0
li x3, 1
li x4, 2
li x5, 3
la x6, result

/***********************************/
/*    Tests for bn.addv/subv.8S    */
/***********************************/

/* Load mod WSR with base li pseudo-instruction*/
li    x23, 0x7fe001
csrrw x0, 0x7d0, x23

/* Load operands into WDRs */
bn.lid x2, 0(x0)
bn.lid x3, 32(x0)

/* Perform vector addition and subtraction, limbs are 32-bit. */
bn.addv.8S w3, w0, w1
bn.subv.8S w2, w0, w1

/* store result from [w2, w3] to dmem */
bn.sid x4, 0(x6++)
bn.sid x5, 0(x6++)

/* Load operands into WDRs */
bn.lid x2, 64(x0)
bn.lid x3, 32(x0)

/* Perform vector addition and subtraction, limbs are 32-bit. */
bn.addv.8S w3, w0, w1
bn.subv.8S w2, w0, w1

/* store result from [w2, w3] to dmem */
bn.sid x4, 0(x6++)
bn.sid x5, 0(x6++)

/***********************************/
/*    Tests for bn.addv/subv.16H   */
/***********************************/

/* Load mod WSR with base li pseudo-instruction*/
li    x23, 0x00000D01
csrrw x0, 0x7d0, x23

/* Load operands into WDRs */
bn.lid x2, 96(x0)
bn.lid x3, 128(x0)

/* Perform vector addition and subtraction, limbs are 32-bit. */
bn.addv.16H w3, w0, w1
bn.subv.16H w2, w0, w1

/* store result from [w2, w3] to dmem */
bn.sid x4, 0(x6++)
bn.sid x5, 0(x6++)

/* Load operands into WDRs */
bn.lid x2, 160(x0)
bn.lid x3, 128(x0)

/* Perform vector addition and subtraction, limbs are 32-bit. */
bn.addv.16H w3, w0, w1
bn.subv.16H w2, w0, w1

/* store result from [w2, w3] to dmem */
bn.sid x4, 0(x6++)
bn.sid x5, 0(x6++)

ecall

.data

/* 256-bit integer
   0000000800000007 0000000600000005
   0000000400000003 0000000200000001 
   (.quad below is in reverse order) */

.globl operand1
operand1:
  .quad 0x0000000200000001
  .quad 0x0000000400000003
  .quad 0x0000000600000005
  .quad 0x0000000800000007

operand2:
  .quad 0x0000000200000001
  .quad 0x0000000400000003
  .quad 0x0000000600000005
  .quad 0x0000000800000007

operand3:
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff

operand4:
  .quad 0x0004000300020001
  .quad 0x0008000700060005
  .quad 0x000c000b000a0009
  .quad 0x0010000f000e000d

operand5:
  .quad 0x0004000300020001
  .quad 0x0008000700060005
  .quad 0x000c000b000a0009
  .quad 0x0010000f000e000d

operand6:
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff
  .quad 0xffffffffffffffff

.globl result
result:
  .zero 32*8
