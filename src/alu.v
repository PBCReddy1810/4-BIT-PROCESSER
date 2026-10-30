// alu.v
// Simple 4‑bit ALU for the custom 4‑bit processor.
// Supports basic arithmetic and logical operations used by the ISA.
// All operations are performed on 4‑bit inputs and produce a 4‑bit result.
// Added `carry_out` for ADD/Sub to aid future extensions.

module alu (
    input  wire [3:0] a,        // Operand A (e.g., ACC)
    input  wire [3:0] b,        // Operand B (register value)
    input  wire [3:0] opcode,   // Operation selector (4-bit, matches ISA opcodes 4..9)
    output reg  [3:0] result,   // ALU result
    output reg        zero,     // Zero flag (result == 0)
    output reg        carry_out // Carry flag for ADD (useful for extensions)
);

    // ALU operation codes (matching CPU opcode definitions)
    localparam OP_ADD = 4'h4; // ADD
    localparam OP_SUB = 4'h5; // SUB
    localparam OP_AND = 4'h6; // AND
    localparam OP_OR  = 4'h7; // OR
    localparam OP_XOR = 4'h8; // XOR
    localparam OP_NOT = 4'h9; // NOT (unary, ignores operand B)

    always @(*) begin
        case (opcode)
            OP_ADD: begin
                {carry_out, result} = a + b; // capture carry
            end
            OP_SUB: begin
                {carry_out, result} = a - b; // borrow as carry_out
            end
            OP_AND: result = a & b;
            OP_OR:  result = a | b;
            OP_XOR: result = a ^ b;
            OP_NOT: result = ~a;
            default: result = 4'b0000; // NOP or undefined
        endcase
        zero = (result == 4'b0000);
    end

endmodule
