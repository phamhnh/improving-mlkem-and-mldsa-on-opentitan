module kogge_stone_adder_256 (
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

    logic [255:0] g, p;

    logic [255:0] g0, p0;           // Initial generate and propagate
    logic [255:0] carry;

    // Stage 0: Generate and Propagate
    assign g = A & B;
    assign p = A ^ B;

    // Level-wise generate and propagate
    logic [255:0] g1, p1;
    logic [255:0] g2, p2;
    logic [255:0] g3, p3;
    logic [255:0] g4, p4;
    logic [255:0] g5, p5;
    logic [255:0] g6, p6;
    logic [255:0] g7, p7;
    logic [255:0] g8, p8;

    genvar i;

    assign g0[0] = g[0] | (p[0] & cin);
    assign p0[0] = 1'b0;

    generate
        for (i = 1; i < 256; i = i + 1) begin : setup
            assign g0[i] = g[i];
            assign p0[i] = p[i];
        end
    endgenerate


    // Stage 1: distance 1
    generate
        for (i = 0; i < 256; i = i + 1) begin
            if (i == 0) begin
                assign g1[i] = g0[i];
                assign p1[i] = p0[i];
            end else begin
                assign g1[i] = (((word_mode == MODE_16) && ((i % 16) == 0)) |
                                ((word_mode == MODE_32) && ((i % 32) == 0))) ? g0[i] : g0[i] | (p0[i] & g0[i-1]);
                assign p1[i] = (((word_mode == MODE_16) && ((i % 16) == 0)) |
                                ((word_mode == MODE_32) && ((i % 32) == 0))) ? p0[i] : p0[i] & p0[i-1];
            end
        end
    endgenerate

    // Stage 2: distance 2
    generate
        for (i = 0; i < 256; i = i + 1) begin
            if (i < 2) begin
                assign g2[i] = g1[i];
                assign p2[i] = p1[i];
            end else begin
                assign g2[i] = (((word_mode == MODE_16) && ((i % 16) < 2)) |
                                ((word_mode == MODE_32) && ((i % 32) < 2))) ? g1[i] : g1[i] | (p1[i] & g1[i-2]);
                assign p2[i] = (((word_mode == MODE_16) && ((i % 16) < 2)) |
                                ((word_mode == MODE_32) && ((i % 32) < 2))) ? p1[i] : p1[i] & p1[i-2];
            end
        end
    endgenerate

    // Stage 3: distance 4
    generate
        for (i = 0; i < 256; i = i + 1) begin
            if (i < 4) begin
                assign g3[i] = g2[i];
                assign p3[i] = p2[i];
            end else begin
                assign g3[i] = (((word_mode == MODE_16) && ((i % 16) < 4)) |
                                ((word_mode == MODE_32) && ((i % 32) < 4))) ? g2[i] : g2[i] | (p2[i] & g2[i-4]);
                assign p3[i] = (((word_mode == MODE_16) && ((i % 16) < 4)) |
                                ((word_mode == MODE_32) && ((i % 32) < 4))) ? p2[i] : p2[i] & p2[i-4];
            end
        end
    endgenerate

    // Stage 4: distance 8
    generate
        for (i = 0; i < 256; i = i + 1) begin
            if (i < 8) begin
                assign g4[i] = g3[i];
                assign p4[i] = p3[i];
            end else begin
                assign g4[i] = (((word_mode == MODE_16) && ((i % 16) < 8)) |
                                ((word_mode == MODE_32) && ((i % 32) < 8))) ? g3[i] : g3[i] | (p3[i] & g3[i-8]);
                assign p4[i] = (((word_mode == MODE_16) && ((i % 16) < 8)) |
                                ((word_mode == MODE_32) && ((i % 32) < 8))) ? p3[i] : p3[i] & p3[i-8];
            end
        end
    endgenerate

    // Stage 5: distance 16
    generate
        for (i = 0; i < 256; i = i + 1) begin
            if (i < 16) begin
                assign g5[i] = g4[i];
                assign p5[i] = p4[i];
            end else begin
                assign g5[i] = ((word_mode == MODE_16) | ((word_mode == MODE_32) && ((i % 32) < 16))) ? g4[i] : g4[i] | (p4[i] & g4[i-16]);
                assign p5[i] = ((word_mode == MODE_16) | ((word_mode == MODE_32) && ((i % 32) < 16))) ? p4[i] : p4[i] & p4[i-16];
            end
        end
    endgenerate

    // Stage 6: distance 32
    generate
        for (i = 0; i < 256; i = i + 1) begin
            if (i < 32) begin
                assign g6[i] = g5[i];
                assign p6[i] = p5[i];
            end else begin
                assign g6[i] = (word_mode == MODE_64) ? g5[i] | (p5[i] & g5[i-32]) : g5[i];
                assign p6[i] = (word_mode == MODE_64) ? p5[i] & p5[i-32] : p5[i];
            end
        end
    endgenerate

    // Stage 7: distance 64
    generate
        for (i = 0; i < 256; i = i + 1) begin
            if (i < 64) begin
                assign g7[i] = g6[i];
                assign p7[i] = p6[i];
            end else begin
                assign g7[i] = (word_mode == MODE_64) ? g6[i] | (p6[i] & g6[i-64]) : g6[i];
                assign p7[i] = (word_mode == MODE_64) ? p6[i] & p6[i-64] : p6[i];
            end
        end
    endgenerate

    // Stage 8: distance 128
    generate
        for (i = 0; i < 256; i = i + 1) begin
            if (i < 128) begin
                assign g8[i] = g7[i];
                assign p8[i] = p7[i];
            end else begin
                assign g8[i] = (word_mode == MODE_64) ? g7[i] | (p7[i] & g7[i-128]) : g7[i];
                assign p8[i] = (word_mode == MODE_64) ? p7[i] & p7[i-128] : p7[i];
            end
        end
    endgenerate

    // Carry computation
    assign carry[0] = (word_mode == MODE_64) ? cin : 1'b0;
    generate
        for (i = 1; i < 256; i = i + 1) begin
            assign carry[i] = (((word_mode == MODE_16) && ((i % 16) == 0)) |
                               ((word_mode == MODE_32) && ((i % 32) == 0))) ? 1'b0 : g8[i-1];
        end
    endgenerate

    // Final sum
    assign sum = p ^ carry;
    assign cout = (word_mode == MODE_64) ? g8[255] : 1'b0;

endmodule

