// Copyright "Towards ML-KEM & ML-DSA on OpenTitan" Authors
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/dif/dif_otbn.h"
#include "sw/device/lib/testing/entropy_testutils.h"
#include "sw/device/lib/testing/otbn_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

#include "hw/top_earlgrey/sw/autogen/top_earlgrey.h"

enum {
  /**
   * Data width of big number subset, in bytes.
   */
  kOtbnWlenBytes = 256 / 8,
};

OTTF_DEFINE_TEST_CONFIG();


// Testcase for bn.addv and bn.subv
OTBN_DECLARE_APP_SYMBOLS(bnaddsubv_test);
OTBN_DECLARE_SYMBOL_ADDR(bnaddsubv_test, operand1);
OTBN_DECLARE_SYMBOL_ADDR(bnaddsubv_test, result);
static const otbn_app_t kAppBnAddSubVTest = OTBN_APP_T_INIT(bnaddsubv_test);
static const otbn_addr_t kBnAddSubVOperands = OTBN_ADDR_T_INIT(bnaddsubv_test, operand1);
static const otbn_addr_t kBnAddSubVResult = OTBN_ADDR_T_INIT(bnaddsubv_test, result);

// Testcase for bn.addvm and bn.subvm
OTBN_DECLARE_APP_SYMBOLS(bnaddsubvm_test);
OTBN_DECLARE_SYMBOL_ADDR(bnaddsubvm_test, operand1);
OTBN_DECLARE_SYMBOL_ADDR(bnaddsubvm_test, result);
static const otbn_app_t kAppBnAddSubVMTest = OTBN_APP_T_INIT(bnaddsubvm_test);
static const otbn_addr_t kBnAddSubVMOperands = OTBN_ADDR_T_INIT(bnaddsubvm_test, operand1);
static const otbn_addr_t kBnAddSubVMResult = OTBN_ADDR_T_INIT(bnaddsubvm_test, result);

// Testvectors
static const uint32_t kExpectedBnAddSubV[] = {
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0,
    0x2, 
    0x4, 
    0x6, 
    0x8, 
    0xa, 
    0xc, 
    0xe, 
    0x10, 
    0xfffffffe, 
    0xfffffffd, 
    0xfffffffc, 
    0xfffffffb, 
    0xfffffffa, 
    0xfffffff9, 
    0xfffffff8, 
    0xfffffff7, 
    0x0, 
    0x1, 
    0x2, 
    0x3, 
    0x4, 
    0x5, 
    0x6, 
    0x7, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0, 
    0x0,
    0x00040002, 
    0x00080006, 
    0x000c000a, 
    0x0010000e, 
    0x00140012, 
    0x00180016, 
    0x001c001a, 
    0x0020001e,
    0xfffdfffe, 
    0xfffbfffc, 
    0xfff9fffa, 
    0xfff7fff8, 
    0xfff5fff6, 
    0xfff3fff4, 
    0xfff1fff2, 
    0xffeffff0, 
    0x00010000, 
    0x00030002, 
    0x00050004, 
    0x00070006, 
    0x00090008, 
    0x000b000a, 
    0x000d000c, 
    0x000f000e
};

static const uint32_t kExpectedBnAddSubVM[] = {
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000002,  
    0x00000004,  
    0x00000006,  
    0x00000008,  
    0x0000000A,  
    0x0000000C,  
    0x0000000E,  
    0x00000010,  
    0x007FDFFF,  
    0x007FDFFE,  
    0x007FDFFD,  
    0x007FDFFC,  
    0x007FDFFB,  
    0x007FDFFA,  
    0x007FDFF9,  
    0x007FDFF8,  
    0x00000000,  
    0x00000001,  
    0x00000002,  
    0x00000003,  
    0x00000004,  
    0x00000005,  
    0x00000006,  
    0x00000007,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00000000,  
    0x00040002,  
    0x00080006,  
    0x000c000a,  
    0x0010000e,  
    0x00140012,  
    0x00180016,  
    0x001c001a,  
    0x0020001e,  
    0x0CFE0CFF,  
    0x0CFC0CFD,  
    0x0CFA0CFB,  
    0x0CF80CF9,  
    0x0CF60CF7,  
    0x0CF40CF5,  
    0x0CF20CF3,  
    0x0CF00CF1,  
    0x00010000,  
    0x00030002,  
    0x00050004,  
    0x00070006,  
    0x00090008,  
    0x000b000a,  
    0x000d000c,  
    0x000f000e   
};

static const uint32_t kOperandsBnAddSubV[] = {
    0x00000001, 
    0x00000002,
    0x00000003, 
    0x00000004,
    0x00000005, 
    0x00000006,
    0x00000007, 
    0x00000008,
    0x00000001, 
    0x00000002,
    0x00000003, 
    0x00000004,
    0x00000005, 
    0x00000006,
    0x00000007, 
    0x00000008,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007,
    0x000a0009, 
    0x000c000b, 
    0x000e000d, 
    0x0010000f, 
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000a0009, 
    0x000c000b, 
    0x000e000d, 
    0x0010000f,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
    0xffffffff, 
    0xffffffff,
};

static const uint32_t kOperandsBnAddSubVM[] = {
    0x00000001, 
    0x00000002,
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008, 
    0x00000001, 
    0x00000002, 
    0x00000003, 
    0x00000004, 
    0x00000005, 
    0x00000006, 
    0x00000007, 
    0x00000008,     
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x007fe000, 
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000a0009, 
    0x000c000b, 
    0x000e000d, 
    0x0010000f, 
    0x00020001, 
    0x00040003, 
    0x00060005, 
    0x00080007, 
    0x000a0009, 
    0x000c000b, 
    0x000e000d, 
    0x0010000f, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
    0x0D000D00, 
};

// Testcase for bn.addv and bn.subv
static void test_bnaddsubv(dif_otbn_t *otbn){
  // Load the Smoke Test App
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppBnAddSubVTest));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(kOperandsBnAddSubV), &kOperandsBnAddSubV, kBnAddSubVOperands)); 
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  for (uint32_t i = 0; i < 32 * 8; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, kBnAddSubVResult + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      CHECK(data[j] == kExpectedBnAddSubV[j + (i / kOtbnWlenBytes * 8)],
            "Unexpected data at index %d: 0x%08x (actual) != 0x%08x (expected)",
            j + (i / kOtbnWlenBytes * 8), data[j], kExpectedBnAddSubV[j + (i / kOtbnWlenBytes * 8)]);
    }
  }
}

// Testcase for bn.addvm and bn.subvm
static void test_bnaddsubvm(dif_otbn_t *otbn){
  // Load the Smoke Test App
  CHECK_STATUS_OK(otbn_testutils_load_app(otbn, kAppBnAddSubVMTest));
  CHECK_STATUS_OK(otbn_testutils_write_data(otbn, sizeof(kOperandsBnAddSubVM), &kOperandsBnAddSubVM, kBnAddSubVMOperands)); 
  CHECK_STATUS_OK(otbn_testutils_execute(otbn));
  CHECK_STATUS_OK(otbn_testutils_wait_for_done(otbn, kDifOtbnErrBitsNoError));

  for (uint32_t i = 0; i < 32 * 8; i += kOtbnWlenBytes) {
    uint32_t data[kOtbnWlenBytes / sizeof(uint32_t)];
    CHECK_DIF_OK(dif_otbn_dmem_read(otbn, kBnAddSubVMResult + i, data, kOtbnWlenBytes));
    LOG_INFO("DMEM @%04d: 0x%08x%08x%08x%08x%08x%08x%08x%08x\n",
             i / kOtbnWlenBytes, data[7], data[6], data[5], data[4], data[3],
             data[2], data[1], data[0]);
    for (uint32_t j = 0; j < 8; j++) {
      CHECK(data[j] == kExpectedBnAddSubVM[j+(i/kOtbnWlenBytes*8)],
            "Unexpected data at index %d: 0x%08x (actual) != 0x%08x (expected)",
            j + (i / kOtbnWlenBytes * 8), data[j], kExpectedBnAddSubVM[j + (i / kOtbnWlenBytes * 8)]);
    }
  }
}

bool test_main(void) {
  // Initialise the entropy source and OTBN
  dif_otbn_t otbn;
  CHECK_STATUS_OK(entropy_testutils_auto_mode_init());
  CHECK_DIF_OK(
      dif_otbn_init(mmio_region_from_addr(TOP_EARLGREY_OTBN_BASE_ADDR), &otbn));

  // Test bn.addv and bn.subv
  test_bnaddsubv(&otbn);

  // Test bn.addvm and bn.subvm
  test_bnaddsubvm(&otbn);

  return true;
}
