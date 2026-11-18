// Portfolio ALU smoke test; not yet run in a simulator.

`timescale 1ns/1ps

module tb_alu;
    logic [7:0] A, B, R;
    logic [1:0] aluOp;
    logic [5:0] CC;

    alu dut(.A(A), .B(B), .aluOp(aluOp), .R(R), .CC(CC));

    task automatic check(
        input logic [1:0] op,
        input logic [7:0] lhs, rhs, expected
    );
        aluOp = op; A = lhs; B = rhs;
        #2;
        if (R !== expected) begin
            $error("ALU op %b: %h and %h -> %h (expected %h)",
                   op, lhs, rhs, R, expected);
            $fatal(1);
        end
        if (CC[4] !== R[7] || CC[5] !== (R == 0)) begin
            $error("Negative/zero flags mismatch for R = %h", R);
            $fatal(1);
        end
        $display("PASS op=%b A=%h B=%h result=%h CC=%b", op, lhs, rhs, R, CC);
    endtask

    initial begin
        check(2'b00, 8'd5, 8'd3, 8'd8);    // add
        check(2'b01, 8'd5, 8'd3, 8'd2);    // subtract
        check(2'b10, 8'd5, 8'd3, 8'd15);   // multiply
        check(2'b11, 8'hAC, 8'h0F, 8'h0C); // bitwise AND
        check(2'b01, 8'd1, 8'd1, 8'd0);    // zero flag
        check(2'b01, 8'd1, 8'd2, 8'hFF);   // negative flag
        $display("All ALU smoke-test assertions passed.");
        $finish;
    end
endmodule
