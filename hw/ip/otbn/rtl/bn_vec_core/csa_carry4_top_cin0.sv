module csa_carry4_top_cin0
(
  input logic [127:0] S0,
  input logic [127:0] DI0,
  output logic [3:0]  O_HI0 [0:31],
  output logic [3:0]  CO_HI0 [0:31]
);
	// COMPUTE CARRY4 CHAIN FOR TOP 128 BITS WHEN CARRY IN = 0
	CARRY4 c_hi0_0 (.CI(1'b0), .CYINIT(1'b0), .DI(DI0[3:0]), .S(S0[3:0]), .O(O_HI0[0]), .CO(CO_HI0[0]));
	CARRY4 c_hi0_1 (.CI(CO_HI0[0][3]), .CYINIT(1'b0), .DI(DI0[7:4]), .S(S0[7:4]), .O(O_HI0[1]), .CO(CO_HI0[1]));
	CARRY4 c_hi0_2 (.CI(CO_HI0[1][3]), .CYINIT(1'b0), .DI(DI0[11:8]), .S(S0[11:8]), .O(O_HI0[2]), .CO(CO_HI0[2]));
	CARRY4 c_hi0_3 (.CI(CO_HI0[2][3]), .CYINIT(1'b0), .DI(DI0[15:12]), .S(S0[15:12]), .O(O_HI0[3]), .CO(CO_HI0[3]));
	CARRY4 c_hi0_4 (.CI(CO_HI0[3][3]), .CYINIT(1'b0), .DI(DI0[19:16]), .S(S0[19:16]), .O(O_HI0[4]), .CO(CO_HI0[4]));
	CARRY4 c_hi0_5 (.CI(CO_HI0[4][3]), .CYINIT(1'b0), .DI(DI0[23:20]), .S(S0[23:20]), .O(O_HI0[5]), .CO(CO_HI0[5]));
	CARRY4 c_hi0_6 (.CI(CO_HI0[5][3]), .CYINIT(1'b0), .DI(DI0[27:24]), .S(S0[27:24]), .O(O_HI0[6]), .CO(CO_HI0[6]));
	CARRY4 c_hi0_7 (.CI(CO_HI0[6][3]), .CYINIT(1'b0), .DI(DI0[31:28]), .S(S0[31:28]), .O(O_HI0[7]), .CO(CO_HI0[7]));
	CARRY4 c_hi0_8 (.CI(CO_HI0[7][3]), .CYINIT(1'b0), .DI(DI0[35:32]), .S(S0[35:32]), .O(O_HI0[8]), .CO(CO_HI0[8]));
	CARRY4 c_hi0_9 (.CI(CO_HI0[8][3]), .CYINIT(1'b0), .DI(DI0[39:36]), .S(S0[39:36]), .O(O_HI0[9]), .CO(CO_HI0[9]));
	CARRY4 c_hi0_10 (.CI(CO_HI0[9][3]), .CYINIT(1'b0), .DI(DI0[43:40]), .S(S0[43:40]), .O(O_HI0[10]), .CO(CO_HI0[10]));
	CARRY4 c_hi0_11 (.CI(CO_HI0[10][3]), .CYINIT(1'b0), .DI(DI0[47:44]), .S(S0[47:44]), .O(O_HI0[11]), .CO(CO_HI0[11]));
	CARRY4 c_hi0_12 (.CI(CO_HI0[11][3]), .CYINIT(1'b0), .DI(DI0[51:48]), .S(S0[51:48]), .O(O_HI0[12]), .CO(CO_HI0[12]));
	CARRY4 c_hi0_13 (.CI(CO_HI0[12][3]), .CYINIT(1'b0), .DI(DI0[55:52]), .S(S0[55:52]), .O(O_HI0[13]), .CO(CO_HI0[13]));
	CARRY4 c_hi0_14 (.CI(CO_HI0[13][3]), .CYINIT(1'b0), .DI(DI0[59:56]), .S(S0[59:56]), .O(O_HI0[14]), .CO(CO_HI0[14]));
	CARRY4 c_hi0_15 (.CI(CO_HI0[14][3]), .CYINIT(1'b0), .DI(DI0[63:60]), .S(S0[63:60]), .O(O_HI0[15]), .CO(CO_HI0[15]));
	CARRY4 c_hi0_16 (.CI(CO_HI0[15][3]), .CYINIT(1'b0), .DI(DI0[67:64]), .S(S0[67:64]), .O(O_HI0[16]), .CO(CO_HI0[16]));
	CARRY4 c_hi0_17 (.CI(CO_HI0[16][3]), .CYINIT(1'b0), .DI(DI0[71:68]), .S(S0[71:68]), .O(O_HI0[17]), .CO(CO_HI0[17]));
	CARRY4 c_hi0_18 (.CI(CO_HI0[17][3]), .CYINIT(1'b0), .DI(DI0[75:72]), .S(S0[75:72]), .O(O_HI0[18]), .CO(CO_HI0[18]));
	CARRY4 c_hi0_19 (.CI(CO_HI0[18][3]), .CYINIT(1'b0), .DI(DI0[79:76]), .S(S0[79:76]), .O(O_HI0[19]), .CO(CO_HI0[19]));
	CARRY4 c_hi0_20 (.CI(CO_HI0[19][3]), .CYINIT(1'b0), .DI(DI0[83:80]), .S(S0[83:80]), .O(O_HI0[20]), .CO(CO_HI0[20]));
	CARRY4 c_hi0_21 (.CI(CO_HI0[20][3]), .CYINIT(1'b0), .DI(DI0[87:84]), .S(S0[87:84]), .O(O_HI0[21]), .CO(CO_HI0[21]));
	CARRY4 c_hi0_22 (.CI(CO_HI0[21][3]), .CYINIT(1'b0), .DI(DI0[91:88]), .S(S0[91:88]), .O(O_HI0[22]), .CO(CO_HI0[22]));
	CARRY4 c_hi0_23 (.CI(CO_HI0[22][3]), .CYINIT(1'b0), .DI(DI0[95:92]), .S(S0[95:92]), .O(O_HI0[23]), .CO(CO_HI0[23]));
	CARRY4 c_hi0_24 (.CI(CO_HI0[23][3]), .CYINIT(1'b0), .DI(DI0[99:96]), .S(S0[99:96]), .O(O_HI0[24]), .CO(CO_HI0[24]));
	CARRY4 c_hi0_25 (.CI(CO_HI0[24][3]), .CYINIT(1'b0), .DI(DI0[103:100]), .S(S0[103:100]), .O(O_HI0[25]), .CO(CO_HI0[25]));
	CARRY4 c_hi0_26 (.CI(CO_HI0[25][3]), .CYINIT(1'b0), .DI(DI0[107:104]), .S(S0[107:104]), .O(O_HI0[26]), .CO(CO_HI0[26]));
	CARRY4 c_hi0_27 (.CI(CO_HI0[26][3]), .CYINIT(1'b0), .DI(DI0[111:108]), .S(S0[111:108]), .O(O_HI0[27]), .CO(CO_HI0[27]));
	CARRY4 c_hi0_28 (.CI(CO_HI0[27][3]), .CYINIT(1'b0), .DI(DI0[115:112]), .S(S0[115:112]), .O(O_HI0[28]), .CO(CO_HI0[28]));
	CARRY4 c_hi0_29 (.CI(CO_HI0[28][3]), .CYINIT(1'b0), .DI(DI0[119:116]), .S(S0[119:116]), .O(O_HI0[29]), .CO(CO_HI0[29]));
	CARRY4 c_hi0_30 (.CI(CO_HI0[29][3]), .CYINIT(1'b0), .DI(DI0[123:120]), .S(S0[123:120]), .O(O_HI0[30]), .CO(CO_HI0[30]));
	CARRY4 c_hi0_31 (.CI(CO_HI0[30][3]), .CYINIT(1'b0), .DI(DI0[127:124]), .S(S0[127:124]), .O(O_HI0[31]), .CO(CO_HI0[31]));
endmodule
