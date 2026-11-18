module alu(
	input logic [7:0] A,
	input logic [7:0] B,
	input logic [1:0] aluOp,
	output logic [7:0] R,
	output logic [5:0] CC
);

always_comb begin

	case(aluOp)
	
	2'b00: R = A + B;
	2'b01: R = A - B;
	2'b10: R = A * B;
	2'b11: R = A & B;
	default: R = 8'b0;
	
	endcase
	
	
	CC[0] = A[7] & B[7] | A[7] & ~R[7] | B[7] & ~R[7];
	CC[1] = ~A[7] & B[7] | ~A[7] & R[7] | B[7] & R[7]; 
	CC[2] = ~A[7] & ~B[7] & R[7] | A[7] & B[7] & ~R[7];
	CC[3] = A[7] & ~B[7] & ~R[7] | ~A[7] & B[7] & R[7];
	CC[4] = R[7];
	CC[5] = R == 8'b0;

end



endmodule