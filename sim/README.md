# Verification notes

The original project was reported as functioning on a DE10-Lite board. The two small **portfolio smoke tests** included here were written after the project files were collected; they have **not been run in this environment** because Quartus/Questa/other SystemVerilog simulators are unavailable here.

- **\`tb_alu.sv\`:** Verifies ADD, SUB, MUL, AND result values and negative/zero flags
- **\`tb_cpu.sv\`:** Exercises reset, immediate writes, arithmetic instructions, STORE, LOAD, memory-mapped output, and MOV

These are **not** an exhaustive test suite. In particular, the ALU carry/borrow/overflow flag equations have not been independently exhaustively validated by these tests.

## Run using Questa / ModelSim

From the repository root, in a shell with the Questa tools configured:

\`\`\`tcl
vlib work
vlog -sv rtl/alu.sv rtl/regfile.sv rtl/cpu.sv sim/tb_alu.sv sim/tb_cpu.sv
vsim -c tb_alu -do "run -all; quit -f"
vsim -c tb_cpu -do "run -all; quit -f"
\`\`\`

The tests instantiate the ALU or CPU modules directly; the board-specific top module and pin-assignments are not required for simulation.

## Board testing checklist

1. Confirm \`KEY[0]\` resets the four 8-bit registers and output register
2. Manually enter a \`MOV +1\` instruction on the switches and release \`KEY[1]\` to clock it
3. Use \`SW[8:7]\` to inspect each register through \`HEX5:HEX4\`
4. Verify arithmetic operations and result display on \`HEX1:HEX0\`
5. Exercise \`STORE\` into an address below 128 and \`LOAD\` from that address
6. Exercise a \`STORE\` to an address with bit 7 set, and inspect \`HEX3:HEX2\`

Data memory is not initialized or reset by the supplied design, so don't test LOAD from unwritten memory.
