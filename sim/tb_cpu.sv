// Portfolio smoke test for the supplied SimpleCPU RTL.
// New testbench authored for repository documentation; not yet run in a simulator.

`timescale 1ns/1ps

module tb_cpu;
    logic clk = 0;
    logic rst_n = 1;
    logic wrA = 0;
    logic [1:0] selA = 0, selB = 0, aluOp = 0, selR = 0;
    logic imm = 0;
    logic [7:0] dataA, outReg, result;
    logic [5:0] CC;

    cpu dut (
        .clk(clk), .rst_n(rst_n), .wrA(wrA),
        .selA(selA), .selB(selB), .aluOp(aluOp),
        .imm(imm), .selR(selR),
        .dataA(dataA), .outReg(outReg), .result(result), .CC(CC)
    );

    task automatic step_clock;
        #5 clk = 1;
        #5 clk = 0;
        #2;
    endtask

    task automatic expect_byte(
        input string description,
        input logic [7:0] observed,
        input logic [7:0] expected
    );
        if (observed !== expected) begin
            $error("%s: expected 0x%02h, got 0x%02h", description, expected, observed);
            $fatal(1);
        end
        $display("PASS: %s = 0x%02h", description, observed);
    endtask

    initial begin
        // Give the asynchronous reset a real falling edge.
        #2 rst_n = 0;
        #2 rst_n = 1;

        // MOV R0, +1
        wrA = 1; selA = 0; selR = 2'b11; imm = 0;
        step_clock();
        expect_byte("R0 initialized", dataA, 8'd1);

        // MOV R1, +1
        selA = 1;
        step_clock();
        expect_byte("R1 initialized", dataA, 8'd1);

        // ADD R1, R0  -> R1=2
        selR = 2'b00; aluOp = 2'b00; selA = 1; selB = 0;
        step_clock();
        expect_byte("R1 after ADD", dataA, 8'd2);

        // ADD R0, R1 -> R0=3
        selA = 0; selB = 1;
        step_clock();
        expect_byte("R0 after ADD", dataA, 8'd3);

        // STORE R0, [R1] -> mem[2] = 3
        wrA = 0; selA = 0; selB = 1;
        step_clock();

        // LOAD R2, [R1] -> R2 = 3
        wrA = 1; selA = 2; selB = 1; selR = 2'b10;
        step_clock();
        expect_byte("R2 loaded from memory", dataA, 8'd3);

        // MOV R3, -1 -> 0xFF (high bit selects memory-mapped output)
        selA = 3; selR = 2'b11; imm = 1;
        step_clock();
        expect_byte("R3 output address", dataA, 8'hFF);

        // STORE R2, [R3] -> outReg = 3
        wrA = 0; selA = 2; selB = 3;
        step_clock();
        expect_byte("Memory-mapped output register", outReg, 8'd3);

        // SUB R0, R1 -> 1
        wrA = 1; selA = 0; selB = 1; selR = 2'b00; aluOp = 2'b01;
        step_clock();
        expect_byte("R0 after SUB", dataA, 8'd1);

        // MUL R0, R1 -> 2
        aluOp = 2'b10;
        step_clock();
        expect_byte("R0 after MUL", dataA, 8'd2);

        // AND R0, R1 -> 2
        aluOp = 2'b11;
        step_clock();
        expect_byte("R0 after AND", dataA, 8'd2);

        // MOV R0, R2 -> 3
        selB = 2; selR = 2'b01;
        step_clock();
        expect_byte("R0 after MOV", dataA, 8'd3);
        expect_byte("outReg remains latched", outReg, 8'd3);

        $display("All SimpleCPU smoke-test assertions passed.");
        $finish;
    end

    initial begin
        #1000;
        $fatal(1, "Testbench timeout");
    end
endmodule
