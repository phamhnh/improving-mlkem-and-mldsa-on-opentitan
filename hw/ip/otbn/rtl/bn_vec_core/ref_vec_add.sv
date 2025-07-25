`timescale 1ns/1ps

module ref_vec_add (
    input  logic [255:0] A,
    input  logic [255:0] B,
    input  logic [1:0]   word_mode,   // 00: scalar, 11: vec32, 10: vec16
    input  logic         cin,
    output logic [255:0] sum,
    output logic         cout
);

    localparam MODE_64 = 2'b00;
    localparam MODE_32 = 2'b11;
    localparam MODE_16 = 2'b10;

    logic [16:0] sum16_0 ;
    logic [16:0] sum16_1 ;
    logic [16:0] sum16_2 ;
    logic [16:0] sum16_3 ;
    logic [16:0] sum16_4 ;
    logic [16:0] sum16_5 ;
    logic [16:0] sum16_6 ;
    logic [16:0] sum16_7 ;
    logic [16:0] sum16_8 ;
    logic [16:0] sum16_9 ;
    logic [16:0] sum16_10;
    logic [16:0] sum16_11;
    logic [16:0] sum16_12;
    logic [16:0] sum16_13;
    logic [16:0] sum16_14;
    logic [16:0] sum16_15;

    logic [32:0] sum32_0;
    logic [32:0] sum32_1;
    logic [32:0] sum32_2;
    logic [32:0] sum32_3;
    logic [32:0] sum32_4;
    logic [32:0] sum32_5;
    logic [32:0] sum32_6;
    logic [32:0] sum32_7;

    logic [256:0] sum256;


    always_comb begin
        sum16_0  = A[15:0]    + B[15:0];
        sum16_1  = A[31:16]   + B[31:16];
        sum16_2  = A[47:32]   + B[47:32];
        sum16_3  = A[63:48]   + B[63:48];
        sum16_4  = A[79:64]   + B[79:64];
        sum16_5  = A[95:80]   + B[95:80];
        sum16_6  = A[111:96]  + B[111:96];
        sum16_7  = A[127:112] + B[127:112];
        sum16_8  = A[143:128] + B[143:128];
        sum16_9  = A[159:144] + B[159:144];
        sum16_10 = A[175:160] + B[175:160];
        sum16_11 = A[191:176] + B[191:176];
        sum16_12 = A[207:192] + B[207:192];
        sum16_13 = A[223:208] + B[223:208];
        sum16_14 = A[239:224] + B[239:224];
        sum16_15 = A[255:240] + B[255:240];

        sum32_0 = {16'h0, sum16_0} + {sum16_1, 16'h0};
        sum32_1 = {16'h0, sum16_2} + {sum16_3, 16'h0};
        sum32_2 = {16'h0, sum16_4} + {sum16_5, 16'h0};
        sum32_3 = {16'h0, sum16_6} + {sum16_7, 16'h0};
        sum32_4 = {16'h0, sum16_8} + {sum16_9, 16'h0};
        sum32_5 = {16'h0, sum16_10} + {sum16_11, 16'h0};
        sum32_6 = {16'h0, sum16_12} + {sum16_13, 16'h0};
        sum32_7 = {16'h0, sum16_14} + {sum16_15, 16'h0};

        sum256 = {224'h0, sum32_0        } +
                        {192'h0, sum32_1,  32'h0} +
                        {160'h0, sum32_2,  64'h0} +
                        {128'h0, sum32_3,  96'h0} +
                        { 96'h0, sum32_4, 128'h0} +
                        { 64'h0, sum32_5, 160'h0} +
                        { 32'h0, sum32_6, 192'h0} +
                        {        sum32_7, 224'h0};
    end
    

    assign sum = word_mode == MODE_64 ? sum256[255:0] + {255'h0, cin} :
                 word_mode == MODE_32 ? {sum32_7[31:0], 
                              sum32_6[31:0],
                              sum32_5[31:0],
                              sum32_4[31:0],
                              sum32_3[31:0],
                              sum32_2[31:0],
                              sum32_1[31:0],
                              sum32_0[31:0]} :
                 word_mode == MODE_16 ? {sum16_15[15:0],
                              sum16_14[15:0],
                              sum16_13[15:0],
                              sum16_12[15:0],
                              sum16_11[15:0],
                              sum16_10[15:0],
                              sum16_9[15:0],
                              sum16_8[15:0],
                              sum16_7[15:0],
                              sum16_6[15:0],
                              sum16_5[15:0],
                              sum16_4[15:0],
                              sum16_3[15:0],
                              sum16_2[15:0],
                              sum16_1[15:0],
                              sum16_0[15:0]} : 256'h0;

    assign cout = sum256[256];

endmodule

