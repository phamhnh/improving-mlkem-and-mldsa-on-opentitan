module csa_carry4_top_cin1
(
  input logic [127:0] S1,
  input logic [127:0] DI1,
  output logic [3:0]  O_HI1 [0:31],
  output logic [3:0]  CO_HI1 [0:31]
);
	// COMPUTE CARRY4 CHAIN FOR TOP 128 BITS WHEN CARRY IN = 1
	CARRY4 c_hi1_0 (.CI(1'b1), .CYINIT(1'b0), .DI(DI1[3:0]), .S(S1[3:0]), .O(O_HI1[0]), .CO(CO_HI1[0]));
	CARRY4 c_hi1_1 (.CI(CO_HI1[0][3]), .CYINIT(1'b0), .DI(DI1[7:4]), .S(S1[7:4]), .O(O_HI1[1]), .CO(CO_HI1[1]));
	CARRY4 c_hi1_2 (.CI(CO_HI1[1][3]), .CYINIT(1'b0), .DI(DI1[11:8]), .S(S1[11:8]), .O(O_HI1[2]), .CO(CO_HI1[2]));
	CARRY4 c_hi1_3 (.CI(CO_HI1[2][3]), .CYINIT(1'b0), .DI(DI1[15:12]), .S(S1[15:12]), .O(O_HI1[3]), .CO(CO_HI1[3]));
	CARRY4 c_hi1_4 (.CI(CO_HI1[3][3]), .CYINIT(1'b0), .DI(DI1[19:16]), .S(S1[19:16]), .O(O_HI1[4]), .CO(CO_HI1[4]));
	CARRY4 c_hi1_5 (.CI(CO_HI1[4][3]), .CYINIT(1'b0), .DI(DI1[23:20]), .S(S1[23:20]), .O(O_HI1[5]), .CO(CO_HI1[5]));
	CARRY4 c_hi1_6 (.CI(CO_HI1[5][3]), .CYINIT(1'b0), .DI(DI1[27:24]), .S(S1[27:24]), .O(O_HI1[6]), .CO(CO_HI1[6]));
	CARRY4 c_hi1_7 (.CI(CO_HI1[6][3]), .CYINIT(1'b0), .DI(DI1[31:28]), .S(S1[31:28]), .O(O_HI1[7]), .CO(CO_HI1[7]));
	CARRY4 c_hi1_8 (.CI(CO_HI1[7][3]), .CYINIT(1'b0), .DI(DI1[35:32]), .S(S1[35:32]), .O(O_HI1[8]), .CO(CO_HI1[8]));
	CARRY4 c_hi1_9 (.CI(CO_HI1[8][3]), .CYINIT(1'b0), .DI(DI1[39:36]), .S(S1[39:36]), .O(O_HI1[9]), .CO(CO_HI1[9]));
	CARRY4 c_hi1_10 (.CI(CO_HI1[9][3]), .CYINIT(1'b0), .DI(DI1[43:40]), .S(S1[43:40]), .O(O_HI1[10]), .CO(CO_HI1[10]));
	CARRY4 c_hi1_11 (.CI(CO_HI1[10][3]), .CYINIT(1'b0), .DI(DI1[47:44]), .S(S1[47:44]), .O(O_HI1[11]), .CO(CO_HI1[11]));
	CARRY4 c_hi1_12 (.CI(CO_HI1[11][3]), .CYINIT(1'b0), .DI(DI1[51:48]), .S(S1[51:48]), .O(O_HI1[12]), .CO(CO_HI1[12]));
	CARRY4 c_hi1_13 (.CI(CO_HI1[12][3]), .CYINIT(1'b0), .DI(DI1[55:52]), .S(S1[55:52]), .O(O_HI1[13]), .CO(CO_HI1[13]));
	CARRY4 c_hi1_14 (.CI(CO_HI1[13][3]), .CYINIT(1'b0), .DI(DI1[59:56]), .S(S1[59:56]), .O(O_HI1[14]), .CO(CO_HI1[14]));
	CARRY4 c_hi1_15 (.CI(CO_HI1[14][3]), .CYINIT(1'b0), .DI(DI1[63:60]), .S(S1[63:60]), .O(O_HI1[15]), .CO(CO_HI1[15]));
	CARRY4 c_hi1_16 (.CI(CO_HI1[15][3]), .CYINIT(1'b0), .DI(DI1[67:64]), .S(S1[67:64]), .O(O_HI1[16]), .CO(CO_HI1[16]));
	CARRY4 c_hi1_17 (.CI(CO_HI1[16][3]), .CYINIT(1'b0), .DI(DI1[71:68]), .S(S1[71:68]), .O(O_HI1[17]), .CO(CO_HI1[17]));
	CARRY4 c_hi1_18 (.CI(CO_HI1[17][3]), .CYINIT(1'b0), .DI(DI1[75:72]), .S(S1[75:72]), .O(O_HI1[18]), .CO(CO_HI1[18]));
	CARRY4 c_hi1_19 (.CI(CO_HI1[18][3]), .CYINIT(1'b0), .DI(DI1[79:76]), .S(S1[79:76]), .O(O_HI1[19]), .CO(CO_HI1[19]));
	CARRY4 c_hi1_20 (.CI(CO_HI1[19][3]), .CYINIT(1'b0), .DI(DI1[83:80]), .S(S1[83:80]), .O(O_HI1[20]), .CO(CO_HI1[20]));
	CARRY4 c_hi1_21 (.CI(CO_HI1[20][3]), .CYINIT(1'b0), .DI(DI1[87:84]), .S(S1[87:84]), .O(O_HI1[21]), .CO(CO_HI1[21]));
	CARRY4 c_hi1_22 (.CI(CO_HI1[21][3]), .CYINIT(1'b0), .DI(DI1[91:88]), .S(S1[91:88]), .O(O_HI1[22]), .CO(CO_HI1[22]));
	CARRY4 c_hi1_23 (.CI(CO_HI1[22][3]), .CYINIT(1'b0), .DI(DI1[95:92]), .S(S1[95:92]), .O(O_HI1[23]), .CO(CO_HI1[23]));
	CARRY4 c_hi1_24 (.CI(CO_HI1[23][3]), .CYINIT(1'b0), .DI(DI1[99:96]), .S(S1[99:96]), .O(O_HI1[24]), .CO(CO_HI1[24]));
	CARRY4 c_hi1_25 (.CI(CO_HI1[24][3]), .CYINIT(1'b0), .DI(DI1[103:100]), .S(S1[103:100]), .O(O_HI1[25]), .CO(CO_HI1[25]));
	CARRY4 c_hi1_26 (.CI(CO_HI1[25][3]), .CYINIT(1'b0), .DI(DI1[107:104]), .S(S1[107:104]), .O(O_HI1[26]), .CO(CO_HI1[26]));
	CARRY4 c_hi1_27 (.CI(CO_HI1[26][3]), .CYINIT(1'b0), .DI(DI1[111:108]), .S(S1[111:108]), .O(O_HI1[27]), .CO(CO_HI1[27]));
	CARRY4 c_hi1_28 (.CI(CO_HI1[27][3]), .CYINIT(1'b0), .DI(DI1[115:112]), .S(S1[115:112]), .O(O_HI1[28]), .CO(CO_HI1[28]));
	CARRY4 c_hi1_29 (.CI(CO_HI1[28][3]), .CYINIT(1'b0), .DI(DI1[119:116]), .S(S1[119:116]), .O(O_HI1[29]), .CO(CO_HI1[29]));
	CARRY4 c_hi1_30 (.CI(CO_HI1[29][3]), .CYINIT(1'b0), .DI(DI1[123:120]), .S(S1[123:120]), .O(O_HI1[30]), .CO(CO_HI1[30]));
	CARRY4 c_hi1_31 (.CI(CO_HI1[30][3]), .CYINIT(1'b0), .DI(DI1[127:124]), .S(S1[127:124]), .O(O_HI1[31]), .CO(CO_HI1[31]));
endmodule
