/* Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */
/* Modified by phamhnh. */

/* 256-bit trn1 and trn2 example. */

.section .text.start

/******************************/
/*    Tests for bn.trn.16h    */
/******************************/

/* Load operands into WDRs */
li x2, 0
li x3, 1
li x4, 2
li x5, 3
la x6, result

bn.lid x2, 0(x0)
bn.lid x3, 32(x0)

/* Perform 16H transpose limbs are 16-bit. */
bn.trn1.16h w3, w0, w1
bn.trn2.16h w2, w0, w1

/* store result from [w2, w3] to dmem */
bn.sid x4, 0(x6++)
bn.sid x5, 0(x6++)

/******************************/
/*    Tests for bn.trn.8S    */
/******************************/

/* Load operands into WDRs */
bn.lid x2, 64(x0)
bn.lid x3, 96(x0)

/* Perform 8S transpose, limbs are 32-bit. */
bn.trn1.8S w3, w0, w1
bn.trn2.8S w2, w0, w1

/* store result from [w2, w3] to dmem */
bn.sid x4, 0(x6++)
bn.sid x5, 0(x6++)

/******************************/
/*    Tests for bn.trn.4D    */
/******************************/

/* Load operands into WDRs */
bn.lid x2, 128(x0)
bn.lid x3, 160(x0)

/* Perform 4D transpose limbs are 64-bit. */
bn.trn1.4D w3, w0, w1
bn.trn2.4D w2, w0, w1

/* store result from [w2, w3] to dmem */
bn.sid x4, 0(x6++)
bn.sid x5, 0(x6++)

/******************************/
/*    Tests for bn.trn.2D    */
/******************************/

/* Load operands into WDRs */
bn.lid x2, 192(x0)
bn.lid x3, 224(x0)

/* Perform 2Q tranpose, limbs are 128-bit. */
bn.trn1.2Q w3, w0, w1
bn.trn2.2Q w2, w0, w1

/* store result from [w2, w3] to dmem */
bn.sid x4, 0(x6++)
bn.sid x5, 0(x6++)

ecall

.data
.globl operand1
/* 256-bit integer
   0010000f000e000d 000c000b000a0009
   0008000700060005 0004000300020001 
   (.quad below is in reverse order) */

operand1:
  .quad 0x0004000300020001
  .quad 0x0008000700060005
  .quad 0x000c000b000a0009
  .quad 0x0010000f000e000d

/* 256-bit integer
   0010000f000e000d 000c000b000a0009
   0008000700060005 0004000300020001 
   (.quad below is in reverse order) */

operand2:
  .quad 0x0004000300020001
  .quad 0x0008000700060005
  .quad 0x000c000b000a0009
  .quad 0x0010000f000e000d

/* 256-bit integer
   0000000800000007 0000000600000005
   0000000400000003 0000000200000001 
   (.quad below is in reverse order) */

operand3:
  .quad 0x0000000200000001
  .quad 0x0000000400000003
  .quad 0x0000000600000005
  .quad 0x0000000800000007

/* 256-bit integer
   0000000800000007 0000000600000005
   0000000400000003 0000000200000001 
   (.quad below is in reverse order) */

operand4:
  .quad 0x0000000200000001
  .quad 0x0000000400000003
  .quad 0x0000000600000005
  .quad 0x0000000800000007

/* 256-bit integer
   0000000000000004 0000000000000003
   0000000000000002 0000000000000001 
   (.quad below is in reverse order) */

operand5:
  .quad 0x0000000000000001
  .quad 0x0000000000000002
  .quad 0x0000000000000003
  .quad 0x0000000000000004

/* 256-bit integer
   0000000000000000 0000000000000002
   0000000000000000 0000000000000001 
   (.quad below is in reverse order) */

operand6:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000002
  .quad 0x0000000000000000

/* 256-bit integer
   0000000000000000 0000000000000002
   0000000000000000 0000000000000001 
   (.quad below is in reverse order) */

operand7:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000002
  .quad 0x0000000000000000

operand8:
  .quad 0x0000000000000001
  .quad 0x0000000000000000
  .quad 0x0000000000000002
  .quad 0x0000000000000000

.globl result
result:
  .zero 32*8