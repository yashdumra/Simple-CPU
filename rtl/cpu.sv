
module cpu(
    input logic clk,
    input logic rst_n,
    input logic wrA,
    input logic [1:0] selA,
    input logic [1:0] selB,
    input logic [1:0] aluOp,
    input logic imm,
    input logic [1:0] selR,
    output logic [7:0] dataA,
    output logic [7:0] outReg,
    output logic [7:0] result,
    output logic [5:0] CC
);

// Internal signals
logic [7:0] dataB;
logic [7:0] aluResult;
logic [7:0] memResult;

// Memory: 128 locations, 8 bits each
logic [7:0] mem [0:127];

// Write enables
logic memWE;
logic outWE;


// 1. Register File
regfile my_regfile(
    .clk(clk),
    .rst_n(rst_n),
    .WE(wrA),
    .selA(selA),
    .selB(selB),
    .dataW(result),
    .dataA(dataA),
    .dataB(dataB)
);


// 2. ALU
alu my_alu(
    .A(dataA),
    .B(dataB),
    .aluOp(aluOp),
    .R(aluResult),
    .CC(CC)
);


// 3. Result Multiplexer
always_comb begin

    case(selR)

        2'b00: result = aluResult;
        2'b01: result = dataB;
        2'b10: result = memResult;
        2'b11: begin
            if(imm == 1'b0)
                result = 8'd1;
            else
                result = 8'hFF;
        end

        default: result = 8'b0;

    endcase

end


// 4. Memory
// Read address comes from dataB
assign memResult = mem[dataB[6:0]];

// Address decoding
assign memWE = ~wrA & ~dataB[7];
assign outWE = ~wrA & dataB[7];

// Write to memory on clock edge
always_ff @(posedge clk) begin

    if(rst_n && memWE)
        mem[dataB[6:0]] <= dataA;

end


// 5. Output Register
always_ff @(posedge clk or negedge rst_n) begin

    if(!rst_n)
        outReg <= 8'b0;

    else if(outWE)
        outReg <= dataA;

end

endmodule