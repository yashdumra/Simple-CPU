# SimpleCPU architecture notes

The project implements a compact **8-bit manually programmed CPU datapath**. It is built in SystemVerilog and was exercised using switches, pushbuttons, LEDs and six seven-segment displays on the DE10-Lite.

## Datapath components

### ALU — `rtl/alu.sv`

Inputs `A` and `B` are 8 bits. The 2-bit `aluOp` chooses **addition (00), subtraction (01), multiplication (10), or bitwise AND (11)**. All results are 8 bits, so large arithmetic results wrap/truncate to that width.

Six condition codes are computed combinationally from the operands and result. In the source:

| Bit | Description |
| --- | --- |
| `CC[0]` | Carry condition |
| `CC[1]` | Borrow condition |
| `CC[2]` | Positive overflow condition |
| `CC[3]` | Negative overflow condition |
| `CC[4]` | Negative result (`R[7]`) |
| `CC[5]` | Zero result (`R == 0`) |

The flags are computed using the supplied logic expressions **regardless of the currently selected ALU operation**. They are not gated to become traditional processor status flags for a particular opcode.

### Register file — `rtl/regfile.sv`

Four independent 8-bit storage registers. `selA` selects the destination register and one read port; `selB` selects the second read port. A rising clock edge with `WE=1` writes `dataW` to register `selA`. An active-low asynchronous reset sets all four registers to zero.

Read outputs `dataA` and `dataB` update combinationally.

### CPU — `rtl/cpu.sv`

The result multiplexer selects one of four sources:

| `selR` | Result source |
| --- | --- |
| `00` | ALU result |
| `01` | `dataB` (register-to-register move) |
| `10` | Data memory `mem[dataB[6:0]]` |
| `11` | Immediate `+1` (0x01) or `−1` (0xFF) |

**Memory:** `mem[0:127]` holds 128 8-bit values. Reading is combinational and memory contents are **not reset or initialized**. LOAD from a location that has never been written does not have defined initial data.

**STORE decoding:** `wrA=0` disables register write-back and enables one of two destinations on the next rising clock edge:
- `dataB[7]=0` -> write `dataA` into `mem[dataB[6:0]]`
- `dataB[7]=1` -> latch `dataA` into `outReg`

The output register holds its last stored value until another output STORE or reset.

### Top-level / display — `rtl/cpu_top.sv`, `rtl/sevenseg.sv`

`cpu_top` is configured for the **DE10-Lite** and selects the `CPU` design via the top-level localparam. It connects switch fields and KEY pushbuttons to the CPU. The seven-segment module maps 4-bit nibbles 0–F onto an active-low display segment pattern.

The top-level declares a 50 MHz board clock signal, but **the implemented CPU clock is the manually triggered `KEY[1]` input**. This matches the step-by-step instruction entry workflow.

## Limitations and extension ideas

- No instruction memory, program counter, or automatic instruction fetch
- No branch/jump instructions or instruction decoder: user switches encode the controls directly
- Manual pushbutton clock instead of automatic pipelined instruction execution
- Data memory is limited to 128 × 8 bits and is uninitialized at reset
- Only a small selection of 8-bit ALU and data movement operations
- A fuller simulator/regression setup and targeted flag tests would be useful

## Design provenance

The five `rtl/` files are the current uploaded source files for the completed lab project, preserved without functional changes. The Quartus `cpu_top.qsf` is a **minimal reconstructed project file** containing only the used DE10-Lite I/O pins and the five sources. The separate testbenches and this documentation were added afterward for the portfolio.
