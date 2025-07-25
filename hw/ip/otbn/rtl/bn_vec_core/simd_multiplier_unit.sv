module simd_multiplier_unit (
  input  logic [255:0] op_a,
  input  logic [255:0] op_b,
  input  logic [2:0]   mode,            // 000: 64x64, 001: 32x32 even, 010: 32x32 odd, 011: 16x16 all, 100: 16x16 even
  input  logic [1:0]   a_word_sel,
  input  logic [1:0]   b_word_sel,
  input  logic         b_word32_sel,
  input  logic         b_word16_sel,
  input  logic         is_scalar_broadcast,
  input  logic [1:0]   data_type_64_shift,

  output logic [511:0] result
);

  localparam WIDTH = 16;
  localparam TILE_ROWS = 4;
  localparam TILE_COLS = 4;

  logic [1:0] select [TILE_ROWS-1:0][TILE_COLS-1:0];
  logic [31:0] pp [TILE_ROWS-1:0][TILE_COLS-1:0];
  logic [255:0] B_prepared;

//  b_word_select_broadcast b_broadcaster (
//    .op_b(op_b),
//    .b_word_sel(b_word_sel),
//    .b_word32_sel(b_word32_sel),
//    .b_word16_sel(b_word16_sel),
//    .is_scalar_broadcast(is_scalar_broadcast),
//    .mode(mode),
//    .B_prepared(B_prepared)
//  );

//module b_word_select_broadcast (
//  input  logic [256-1:0] op_b,
//
//  // Hierarchical selects:
//  input  logic [1:0] b_word_sel,   // 64-bit word
//  input  logic       b_word32_sel, // 32-bit word inside 64-bit
//  input  logic       b_word16_sel, // 16-bit word inside 32-bit
//
//  input  logic       is_scalar_broadcast,
//  input  logic [1:0] mode,
//
//  output logic [256-1:0] B_prepared
//);

  logic [63:0] b_word;
  logic [31:0] b_word32;
  logic [15:0] b_word16;
  logic [15:0] B_slices [0:3];

  assign b_word = op_b[64*b_word_sel +: 64];
  assign b_word32 = b_word32_sel ? b_word[63:32] : b_word[31:0];
  assign b_word16 = b_word16_sel ? b_word32[31:16] : b_word32[15:0];

  int laneB;

  always_comb begin
    laneB = '0;

    B_prepared = '0;

    B_slices[0] = '0;
    B_slices[1] = '0;
    B_slices[2] = '0;
    B_slices[3] = '0;

    if (is_scalar_broadcast) begin
      if (mode == 2'b00) begin
        // 64×64: broadcast all 4 16-bit slices of selected 64-bit word
        for (int k = 0; k < 4; k++) begin
          B_slices[k] = b_word[16*k +: 16];
        end
      end else if (mode == 2'b01 || mode == 2'b10) begin
        // 32×32: broadcast the 2 slices from selected 32-bit word
        B_slices[0] = b_word32[15:0];
        B_slices[1] = b_word32[31:16];
        B_slices[2] = b_word32[15:0];
        B_slices[3] = b_word32[31:16];
      end else begin
        // 16×16: broadcast the selected 16-bit word to all slices
        for (int k = 0; k < 4; k++) begin
          B_slices[k] = b_word16;
        end
      end

      // Replicate slices to every diagonal group
      for (int k = 0; k < 4; k++) begin
        for (int g = 0; g < 4; g++) begin
          laneB = g*4 + k;
          B_prepared[laneB*16+: 16] = B_slices[k];
        end
      end

    end else begin
      B_prepared = op_b;
    end
  end

//endmodule

  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l


  always_comb begin
    case (mode)
      3'b000: begin // 64×64
        select[0][0] = a_word_sel;
        select[0][1] = a_word_sel;
        select[0][2] = a_word_sel;
        select[0][3] = a_word_sel;

        select[1][0] = a_word_sel;
        select[1][1] = a_word_sel;
        select[1][2] = a_word_sel;
        select[1][3] = a_word_sel;

        select[2][0] = a_word_sel;
        select[2][1] = a_word_sel;
        select[2][2] = a_word_sel;
        select[2][3] = a_word_sel;

        select[3][0] = a_word_sel;
        select[3][1] = a_word_sel;
        select[3][2] = a_word_sel;
        select[3][3] = a_word_sel;
      end
      3'b001: begin // 32×32
  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l

        select[0][0] = 2'd0;
        select[0][1] = 2'd0;
        select[0][2] = 2'd1;
        select[0][3] = 2'd1;

        select[1][0] = 2'd0;
        select[1][1] = 2'd0;
        select[1][2] = 2'd1;
        select[1][3] = 2'd1;

        select[2][0] = 2'd2;
        select[2][1] = 2'd2;
        select[2][2] = 2'd3;
        select[2][3] = 2'd3;

        select[3][0] = 2'd2;
        select[3][1] = 2'd2;
        select[3][2] = 2'd3;
        select[3][3] = 2'd3;
      end

      3'b010: begin // 32×32
  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l

        select[0][0] = 2'd3;
        select[0][1] = 2'd3;
        select[0][2] = 2'd2;
        select[0][3] = 2'd2;

        select[1][0] = 2'd3;
        select[1][1] = 2'd3;
        select[1][2] = 2'd2;
        select[1][3] = 2'd2;

        select[2][0] = 2'd1;
        select[2][1] = 2'd1;
        select[2][2] = 2'd0;
        select[2][3] = 2'd0;

        select[3][0] = 2'd1;
        select[3][1] = 2'd1;
        select[3][2] = 2'd0;
        select[3][3] = 2'd0;
      end
      default: begin // 16×16
  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l

        select[0][0] = 2'd0;
        select[0][1] = 2'd3;
        select[0][2] = 2'd1;
        select[0][3] = 2'd2;

        select[1][0] = 2'd3;
        select[1][1] = 2'd0;
        select[1][2] = 2'd2;
        select[1][3] = 2'd1;

        select[2][0] = 2'd2;
        select[2][1] = 2'd1;
        select[2][2] = 2'd3;
        select[2][3] = 2'd0;

        select[3][0] = 2'd1;
        select[3][1] = 2'd2;
        select[3][2] = 2'd0;
        select[3][3] = 2'd3;
      end
    endcase
  end

//  diagonal_tiled_simd tiled_simd (
//    .op_a(op_a),
//    .op_b(B_prepared),
//    .select(select),
//    .pp(pp)
//  );

//module diagonal_tiled_simd #(
//  parameter WIDTH = 16,
//  parameter TILE_ROWS = 4,
//  parameter TILE_COLS = 4
//)(
//  input logic [255:0] op_a,
//  input logic [255:0] op_b,
//  input logic [1:0] select [TILE_ROWS-1:0][TILE_COLS-1:0],
//  output logic [31:0] pp [TILE_ROWS-1:0][TILE_COLS-1:0]
//);

  logic [WIDTH-1:0] cols [TILE_ROWS-1:0][TILE_COLS-1:0];
  logic [WIDTH-1:0] rows [TILE_ROWS-1:0][TILE_COLS-1:0];

  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l


  always_comb begin
    // Word 0: hHlL  → slices: [h,H,l,L]
    cols[0][0] = op_a[       0 +: 16];  // L
    cols[1][0] = op_a[      16 +: 16];  // l
    cols[2][0] = op_a[      32 +: 16];  // H
    cols[3][0] = op_a[      48 +: 16];  // h

    // Word 1: lLhH  -> slices: [l,L,h,H]
    cols[0][1] = op_a[ 64 + 32 +: 16];  // H
    cols[1][1] = op_a[ 64 + 48 +: 16];  // h
    cols[2][1] = op_a[ 64 +  0 +: 16];  // L
    cols[3][1] = op_a[ 64 + 16 +: 16];  // l
    
    // Word 2: hHlL  -> slices: [h,H,l,L]
    cols[0][2] = op_a[128 +  0 +: 16];  // L
    cols[1][2] = op_a[128 + 16 +: 16];  // l
    cols[2][2] = op_a[128 + 32 +: 16];  // H
    cols[3][2] = op_a[128 + 48 +: 16];  // h
    
    // Word 3: lLhH  -> slices: [l,L,h,H]
    cols[0][3] = op_a[192 + 32 +: 16];  // H
    cols[1][3] = op_a[192 + 48 +: 16];  // h
    cols[2][3] = op_a[192 +  0 +: 16];  // L
    cols[3][3] = op_a[192 + 16 +: 16];  // l
    
    
    // Word 0: HhlL  -> slices: [H,h,l,L]
    rows[0][0] = B_prepared[      0 +: 16];   // L
    rows[1][0] = B_prepared[     16 +: 16];   // l
    rows[2][0] = B_prepared[     48 +: 16];   // h
    rows[3][0] = B_prepared[     32 +: 16];   // H
    
    // Word 1: HhlL
    rows[0][1] = B_prepared[ 64 +  0 +: 16];   // L
    rows[1][1] = B_prepared[ 64 + 16 +: 16];   // l
    rows[2][1] = B_prepared[ 64 + 48 +: 16];   // h
    rows[3][1] = B_prepared[ 64 + 32 +: 16];   // H
    
    // Word 2: lLHh  -> slices: [l,L,H,h]
    rows[0][2] = B_prepared[128 + 48 +: 16];   // h
    rows[1][2] = B_prepared[128 + 32 +: 16];   // H
    rows[2][2] = B_prepared[128 +  0 +: 16];   // L
    rows[3][2] = B_prepared[128 + 16 +: 16];   // l
    
    // Word 3: lLHh
    rows[0][3] = B_prepared[192 + 48 +: 16];   // h
    rows[1][3] = B_prepared[192 + 32 +: 16];   // H
    rows[2][3] = B_prepared[192 +  0 +: 16];   // L
    rows[3][3] = B_prepared[192 + 16 +: 16];   // l
  end

  genvar i, j;
  generate
    for (i = 0; i < TILE_ROWS; i++) begin : tiles_i
      for (j = 0; j < TILE_COLS; j++) begin : tiles_j
        logic [WIDTH-1:0] col, row;

        always_comb begin
          col = cols[j][select[i][j]];
          row = rows[i][select[i][j]];
        end

        assign pp[i][j] = col * row;

      end
    end
  endgenerate

//endmodule

  int i0;
  int j0; 
  int i1; 
  int j1; 
  int lane;

  logic [63:0] w00;
  logic [63:0] w01;
  logic [63:0] w10;
  logic [63:0] w11;



  logic [63:0] word_product;
  logic [127:0] scalar_sum;

  logic [127:0] result_64;

  always_comb begin
    result = '0;
    word_product = '0;
    scalar_sum = '0;

    result_64 = '0;

    w00 = '0;
    w01 = '0;
    w10 = '0;
    w11 = '0;

    i0 = '0;
    j0 = '0;
    i1 = '0;
    j1 = '0;

    lane = '0;

    case (mode)
      3'b000: begin
  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l

        if ((a_word_sel) == 2'b00) begin
          w00 = (pp[0][0] <<  0) + (pp[0][1] << 16) + (pp[1][0] << 16) + (pp[1][1] << 32);
          w01 = (pp[0][2] <<  0) + (pp[0][3] << 16) + (pp[1][2] << 16) + (pp[1][3] << 32);
          w10 = (pp[3][0] <<  0) + (pp[3][1] << 16) + (pp[2][0] << 16) + (pp[2][1] << 32);
          w11 = (pp[3][2] <<  0) + (pp[3][3] << 16) + (pp[2][2] << 16) + (pp[2][3] << 32);
        end
        else if ((a_word_sel) == 2'b01) begin
          w00 = (pp[0][2] <<  0) + (pp[0][3] << 16) + (pp[1][2] << 16) + (pp[1][3] << 32);
          w01 = (pp[0][0] <<  0) + (pp[0][1] << 16) + (pp[1][0] << 16) + (pp[1][1] << 32);
          w10 = (pp[3][2] <<  0) + (pp[3][3] << 16) + (pp[2][2] << 16) + (pp[2][3] << 32);
          w11 = (pp[3][0] <<  0) + (pp[3][1] << 16) + (pp[2][0] << 16) + (pp[2][1] << 32);
        end
        else if ((a_word_sel) == 2'b10) begin
          w00 = (pp[2][0] <<  0) + (pp[2][1] << 16) + (pp[3][0] << 16) + (pp[3][1] << 32);
          w01 = (pp[2][2] <<  0) + (pp[2][3] << 16) + (pp[3][2] << 16) + (pp[3][3] << 32);
          w10 = (pp[1][0] <<  0) + (pp[1][1] << 16) + (pp[0][0] << 16) + (pp[0][1] << 32);
          w11 = (pp[1][2] <<  0) + (pp[1][3] << 16) + (pp[0][2] << 16) + (pp[0][3] << 32);
        end
        else if ((a_word_sel) == 2'b11) begin
          w00 = (pp[2][2] <<  0) + (pp[2][3] << 16) + (pp[3][2] << 16) + (pp[3][3] << 32);
          w01 = (pp[2][0] <<  0) + (pp[2][1] << 16) + (pp[3][0] << 16) + (pp[3][1] << 32);
          w10 = (pp[1][2] <<  0) + (pp[1][3] << 16) + (pp[0][2] << 16) + (pp[0][3] << 32);
          w11 = (pp[1][0] <<  0) + (pp[1][1] << 16) + (pp[0][0] << 16) + (pp[0][1] << 32);
        end

        result_64 = (w00 <<  0) + (w01 << 32) + (w10 << 32) + (w11 << 64);

        unique case (data_type_64_shift)
          2'd0: result[  0 +: 128] = result_64;
          2'd1: result[ 64 +: 128] = result_64;
          2'd2: result[128 +: 128] = result_64;
          2'd3: result[192 +: 128] = result_64;
        endcase
      end
      3'b001: begin
  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l

        w00 = (pp[0][0] <<  0) + (pp[0][1] << 16) + (pp[1][0] << 16) + (pp[1][1] << 32);
        w01 = (pp[0][2] <<  0) + (pp[0][3] << 16) + (pp[1][2] << 16) + (pp[1][3] << 32);
        w10 = (pp[2][0] <<  0) + (pp[2][1] << 16) + (pp[3][0] << 16) + (pp[3][1] << 32);
        w11 = (pp[2][2] <<  0) + (pp[2][3] << 16) + (pp[3][2] << 16) + (pp[3][3] << 32);

        //result[127:0] = {w11, w10, w01, w00};
        result = {{64'b0}, w11, {64'b0}, w10, {64'b0}, w01, {64'b0}, w00};
      end
      3'b010: begin
  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l

        w00 = (pp[3][2] <<  0) + (pp[3][3] << 16) + (pp[2][2] << 16) + (pp[2][3] << 32);
        w01 = (pp[3][0] <<  0) + (pp[3][1] << 16) + (pp[2][0] << 16) + (pp[2][1] << 32);
        w10 = (pp[1][2] <<  0) + (pp[1][3] << 16) + (pp[0][2] << 16) + (pp[0][3] << 32);
        w11 = (pp[1][0] <<  0) + (pp[1][1] << 16) + (pp[0][0] << 16) + (pp[0][1] << 32);

        //result[127:0] = {w11, w10, w01, w00};
        result = {w11, {64'b0}, w10, {64'b0}, w01, {64'b0}, w00, {64'b0}};
      end
      3'b011: begin
  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l

            result[ 0*32 +: 32] = pp[0][0];
            result[ 1*32 +: 32] = pp[1][1];
            result[ 2*32 +: 32] = pp[3][2];
            result[ 3*32 +: 32] = pp[2][3];

            result[ 4*32 +: 32] = pp[0][2];
            result[ 5*32 +: 32] = pp[1][3];
            result[ 6*32 +: 32] = pp[3][0];
            result[ 7*32 +: 32] = pp[2][1];

            result[ 8*32 +: 32] = pp[2][0];
            result[ 9*32 +: 32] = pp[3][1];
            result[10*32 +: 32] = pp[1][2];
            result[11*32 +: 32] = pp[0][3];

            result[12*32 +: 32] = pp[2][2];
            result[13*32 +: 32] = pp[3][3];
            result[14*32 +: 32] = pp[1][0];
            result[15*32 +: 32] = pp[0][1];
      end
      3'b100: begin
  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l

            result[ 0*32 +: 32] = pp[0][0];
            result[ 1*32 +: 32] = 32'b0;
            result[ 2*32 +: 32] = pp[3][2];
            result[ 3*32 +: 32] = 32'b0;

            result[ 4*32 +: 32] = pp[0][2];
            result[ 5*32 +: 32] = 32'b0;
            result[ 6*32 +: 32] = pp[3][0];
            result[ 7*32 +: 32] = 32'b0;

            result[ 8*32 +: 32] = pp[2][0];
            result[ 9*32 +: 32] = 32'b0;
            result[10*32 +: 32] = pp[1][2];
            result[11*32 +: 32] = 32'b0;

            result[12*32 +: 32] = pp[2][2];
            result[13*32 +: 32] = 32'b0;
            result[14*32 +: 32] = pp[1][0];
            result[15*32 +: 32] = 32'b0;
      end
      3'b101: begin
  //   hHlL    lLhH    hHlL    lLhH

  //   ---/ L  -/-- L  /--- h  --/- h
  //   --/- l  /--- l  -/-- H  ---/ H
  //   /--- h  --/- h  ---/ L  -/-- L
  //   -/-- H  ---/ H  --/- l  /--- l

            result[ 0*32 +: 32] = 32'b0;
            result[ 1*32 +: 32] = pp[1][1];
            result[ 2*32 +: 32] = 32'b0;
            result[ 3*32 +: 32] = pp[2][3];

            result[ 4*32 +: 32] = 32'b0;
            result[ 5*32 +: 32] = pp[1][3];
            result[ 6*32 +: 32] = 32'b0;
            result[ 7*32 +: 32] = pp[2][1];

            result[ 8*32 +: 32] = 32'b0;
            result[ 9*32 +: 32] = pp[3][1];
            result[10*32 +: 32] = 32'b0;
            result[11*32 +: 32] = pp[0][3];

            result[12*32 +: 32] = 32'b0;
            result[13*32 +: 32] = pp[3][3];
            result[14*32 +: 32] = 32'b0;
            result[15*32 +: 32] = pp[0][1];
      end
      default: begin
      end
    endcase
  end

endmodule

