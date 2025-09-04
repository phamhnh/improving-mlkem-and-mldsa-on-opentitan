// Original 256-bit non-vectorized adder

module ref_adder
    import otbn_pkg::*;
(
  input logic [WLEN-1:0]  A,
  input logic [WLEN-1:0]  B,
  input logic             cin,
  output logic [WLEN-1:0] res,
  output logic            cout
);
  logic [WLEN:0] sum;
  assign sum = A + B + {254'b0, cin};
  assign res = sum[WLEN-1:0];
  assign cout = sum[WLEN];
endmodule
