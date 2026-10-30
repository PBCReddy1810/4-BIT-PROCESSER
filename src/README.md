# Source Directory Overview

This `src/` folder contains all Verilog source files for the **4‑bit processor** project.

| File | Purpose |
|------|---------|
| `alu.v` | 4‑bit ALU with arithmetic, logic, and a `carry_out` flag for future extensions. |
| `regfile.v` | 8‑register file (`R0`‑`R7`). `R0` is hard‑wired to 0 and acts as the accumulator (ACC). |
| `memory.v` | Simple synchronous 8 × 4‑bit RAM used for both instruction and data memory. |
| `control_unit.v` | Finite‑state machine that implements FETCH → DECODE → EXECUTE and generates control signals. |
| `cpu_top.v` | Top‑level CPU: program counter, instruction‑memory, data‑memory, register file, ALU, and control unit. |
| `testbench.v` | Testbench that drives the clock, reset, and generates a VCD waveform (`cpu.vcd`). |
| `instruction_set.md` | Human‑readable description of the custom ISA (opcode table, registers, memory layout). |
| `README.md` | This file – quick reference for developers working inside the `src/` folder. |

All modules are deliberately tiny and written for educational purposes. Feel free to extend them (e.g., larger memories, pipelining, dedicated accumulator, or a full assembler).
