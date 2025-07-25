module buffer_bit (
    input  logic [255:0] A,
    input  logic [255:0] B,
    input  logic [1:0]   word_mode,   // 00: scalar, 01: vec32, 10: vec16
    input  logic         cin,
    output logic [255:0] sum,
    output logic         cout
);

  localparam MODE_64 = 2'b00;
  localparam MODE_32 = 2'b11;
  localparam MODE_16 = 2'b10;

  genvar i;

  logic [270:0] A_buffed;
  logic [270:0] B_buffed;

  logic [271:0] res_buffed;

  generate
    for (i = 0; i < 16; i++) begin : pick_out_bits0
      assign A_buffed[i*17 +: 16] = A[i*16 +: 16];
      assign B_buffed[i*17 +: 16] = B[i*16 +: 16];
    end

    for (i = 0; i < 15; i = i+2) begin : pick_out_bits1
      assign A_buffed[i*17+16] = 1'b0;
      assign B_buffed[i*17+16] = (word_mode == MODE_64) ? 1'b1 : 
                                 (word_mode == MODE_32) ? 1'b1 : 1'b0;
    end

    for (i = 1; i < 15; i = i+2) begin : pick_out_bits2
      assign A_buffed[i*17+16] = 1'b0;
      assign B_buffed[i*17+16] = (word_mode == MODE_64) ? 1'b1 : 1'b0;
    end
  endgenerate

  assign res_buffed = A_buffed + B_buffed + ((word_mode == MODE_64) ? {271'b0, cin} : 272'b0);

  generate
    for (i = 0; i < 16; i++) begin : pick_out_bits
      assign sum[i*16 +: 16] = res_buffed[i*17 +: 16];
    end
  endgenerate

  assign cout = (word_mode == MODE_64) ? res_buffed[271] : 1'b0;

endmodule

