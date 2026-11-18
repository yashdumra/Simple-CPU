module regfile(
	input logic clk,
	input logic rst_n,
	input logic WE,
	input logic [1:0] selA,
	input logic [1:0] selB,
	input logic [7:0] dataW,
	output logic [7:0] dataA,
	output logic [7:0] dataB
);

logic [7:0] reg1, reg2, reg3, reg4;	
always_ff@(posedge clk or negedge rst_n) begin

	if(!rst_n) begin
	reg1 <= 8'b0;
	reg2 <= 8'b0;
	reg3 <= 8'b0;
	reg4 <= 8'b0;
			
	end
	
	else if(WE) begin
	
	if(selA == 2'b0)
		reg1 <= dataW;
	if(selA == 2'b01)
		reg2 <= dataW;
	if(selA == 2'b10)
		reg3 <= dataW;
	if(selA == 2'b11)
		reg4 <= dataW;

	
	end
end


always_comb begin

case (selA)
    2'b00: dataA = reg1;
    2'b01: dataA = reg2;
    2'b10: dataA = reg3;
    2'b11: dataA = reg4;
endcase

case (selB)
    2'b00: dataB = reg1;
    2'b01: dataB = reg2;
    2'b10: dataB = reg3;
    2'b11: dataB = reg4;
endcase

end


endmodule