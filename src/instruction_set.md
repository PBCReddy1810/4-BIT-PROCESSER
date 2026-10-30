# instruction_set.md

## 4‑bit Processor Custom ISA

The processor works with **8‑bit instructions** split into two 4‑bit nibbles:

| Bits | Name      | Description |
|------|-----------|-------------|
|7:4   | **Opcode**| Determines the operation (see table below). |
|3:0   | **Operand**| Register index or immediate value (depending on opcode). |

### Opcode Table
| Opcode (hex) | Mnemonic | Description |
|---|----------|-------------------------|
| `0x0` | `NOP` | No operation; simply advance PC. |
| `0x1` | `LOAD_IMM rd, imm` | Load a 4‑bit immediate into destination register `rd`. The operand nibble encodes `rd` in bits `[2:0]`; the immediate value is taken from the lower 4 bits of the next word in a real implementation. For this simple demo we treat the operand itself as the immediate value. |
| `0x4` | `ADD rd` | `ACC = ACC + R[rd]`. `ACC` is register 0 (hard‑wired zero in this demo). |
| `0x5` | `SUB rd` | `ACC = ACC - R[rd]`. |
| `0x6` | `AND rd` | Bitwise AND between `ACC` and `R[rd]`. |
| `0x7` | `OR rd`  | Bitwise OR. |
| `0x8` | `XOR rd` | Bitwise XOR. |
| `0x9` | `NOT`    | One‑operand NOT: `ACC = ~ACC`. |
| `0xA` | `STORE rd` | Store `ACC` into data memory address `rd`. |
| `0xB` | `JMP addr` | Conditional jump to `addr` if the Zero flag from the ALU is set. |
| `0xF` | `HALT`   | Stop execution. |

### Register File
- 8 registers `R0`‑`R7`, each 4 bits wide.
- `R0` is hard‑wired to `0` (read‑only). The accumulator (`ACC`) is logically `R0`.

### Memory
- 8 × 4‑bit RAM used for both instruction and data memory in this minimal design.
- Addresses are 3‑bit, giving 8 locations.

### Execution Flow
The processor follows a **three‑stage FSM** inside `control_unit.v`:
1. **FETCH** – read instruction from instruction memory using the program counter (PC).
2. **DECODE** – decode the opcode/operand and generate control signals.
3. **EXECUTE** – ALU, register‑file, and memory actions happen combinationally; next PC is selected.

The design is intentionally simple for educational purposes and can be extended with larger memories, pipelining, or a proper accumulator register.
