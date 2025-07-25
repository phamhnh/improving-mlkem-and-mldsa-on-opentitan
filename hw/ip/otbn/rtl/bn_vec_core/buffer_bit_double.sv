module buffer_bit_double (
    input  logic [255:0] A,
    input  logic [255:0] B,
    input  logic [1:0]   word_mode,   // 00: scalar, 01: vec32, 10: vec16
    input  logic         cin,
    output logic [255:0] sum,
    output logic         cout
);

  localparam MODE_64 = 2'b00;
  localparam MODE_32 = 2'b11;
  //localparam MODE_16 = 2'b10;

  genvar i;

  logic [262:0] A_buffed;
  logic [262:0] B_buffed;

  logic [263:0] res_buffed;

  logic unused_ok;
  assign unused_ok = res_buffed[230] ^ res_buffed[197] ^ res_buffed[164] ^ res_buffed[131]
                   ^ res_buffed[98] ^ res_buffed[65] ^ res_buffed[32];

  generate
    for (i = 0; i < 8; i++) begin : pick_out_bits0
      assign A_buffed[i*33 +: 32] = A[i*32 +: 32];
      assign B_buffed[i*33 +: 32] = B[i*32 +: 32];
    end

    for (i = 0; i < 7; i = i+2) begin : pick_out_bits1
      assign A_buffed[i*33+32] = 1'b0;
      assign B_buffed[i*33+32] = (word_mode == MODE_64) ? 1'b1 : 
                                 (word_mode == MODE_32) ? 1'b1 : 1'b0;
    end

    for (i = 1; i < 7; i = i+2) begin : pick_out_bits2
      assign A_buffed[i*33+32] = 1'b0;
      assign B_buffed[i*33+32] = (word_mode == MODE_64) ? 1'b1 : 1'b0;
    end
  endgenerate

  assign res_buffed = A_buffed + B_buffed + ((word_mode == MODE_64) ? {263'b0, cin} : 264'b0);

  generate
    for (i = 0; i < 8; i++) begin : pick_out_bits
      assign sum[i*32 +: 32] = res_buffed[i*33 +: 32];
    end
  endgenerate

  assign cout = (word_mode == MODE_64) ? res_buffed[263] : 1'b0;

endmodule

