// control_unit.v
// Simple control unit for the 4‑bit processor.
// Implements a three‑stage FSM: FETCH → DECODE → EXECUTE.
// Generates control signals for ALU, register file, and memory based on a minimal ISA.

module control_unit (
    input  wire        clk,
    input  wire        rst_n,
    // From instruction memory
    input  wire [7:0]  instr,
    // Flags from ALU
    input  wire        zero,
    // Control outputs
    output reg  [3:0]  alu_opcode,   // forwarded to ALU
    output reg  [2:0]  reg_ra,        // source register A address
    output reg  [2:0]  reg_rb,        // source register B address / immediate flag
    output reg  [2:0]  reg_rw,        // destination register address
    output reg         reg_we,        // write‑enable for register file
    output reg         mem_we,        // write‑enable for data memory
    output reg  [2:0]  mem_addr,      // address for data memory
    output reg  [3:0]  mem_wdata,     // data to write to memory
    output reg  [2:0]  pc_inc,        // PC increment (normally 1)
    output reg  [2:0]  pc_load,       // New PC value (for jumps)
    output reg         pc_load_en,    // Enable PC load
    output reg         halted         // CPU halted flag
);

    // FSM states
    localparam S_FETCH   = 2'd0;
    localparam S_DECODE  = 2'd1;
    localparam S_EXECUTE = 2'd2;
    localparam S_HALT    = 2'd3;

    reg [1:0] state, next_state;

    // Instruction fields (custom ISA, 8‑bit instruction)
    // [7:4] opcode, [3:0] operand (register number or immediate)
    wire [3:0] opcode = instr[7:4];
    wire [3:0] operand = instr[3:0];

    // Simple decode logic – for ALU operations the operand is the destination register.
    // Source register A is always ACC (register 0). For binary ops the operand is the second operand register.
    // LOAD_IMM loads immediate value into destination register (operand bits hold dest, immediate is fetched from next word – not modelled here).

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_FETCH;
            halted <= 1'b0;
        end else begin
            state <= next_state;
        end
    end

    // Default signal values
    always @* begin
        // keep defaults
        alu_opcode   = 4'b0000;
        reg_ra       = 3'b000; // ACC
        reg_rb       = 3'b000;
        reg_rw       = 3'b000;
        reg_we       = 1'b0;
        mem_we       = 1'b0;
        mem_addr     = 3'b000;
        mem_wdata    = 4'b0000;
        pc_inc       = 3'b001;
        pc_load      = 3'b000;
        pc_load_en   = 1'b0;
        halted       = (state == S_HALT);
        next_state   = state;

        case (state)
            S_FETCH: begin
                next_state = S_DECODE;
            end
            S_DECODE: begin
                case (opcode)
                    4'h0: begin // NOP
                        next_state = S_FETCH;
                    end
                    4'h1: begin // LOAD_IMM – treat operand as immediate value for demo
                        reg_rw   = operand[2:0];
                        reg_we   = 1'b1;
                        // immediate value is supplied via operand[3] flag – for simplicity we use lower 4 bits as data
                        // In a real design a second word would be fetched.
                        next_state = S_FETCH;
                    end
                    4'h4: begin // ADD (ACC = ACC + Rn)
                        alu_opcode = 4'h4; // ADD
                        reg_ra     = 3'b000; // ACC
                        reg_rb     = operand[2:0]; // source register
                        reg_rw     = 3'b000; // write back to ACC
                        reg_we     = 1'b1;
                        next_state = S_FETCH;
                    end
                    4'h5: begin // SUB (ACC = ACC - Rn)
                        alu_opcode = 4'h5;
                        reg_ra     = 3'b000;
                        reg_rb     = operand[2:0];
                        reg_rw     = 3'b000;
                        reg_we     = 1'b1;
                        next_state = S_FETCH;
                    end
                    4'h6: begin // AND
                        alu_opcode = 4'h6;
                        reg_ra     = 3'b000;
                        reg_rb     = operand[2:0];
                        reg_rw     = 3'b000;
                        reg_we     = 1'b1;
                        next_state = S_FETCH;
                    end
                    4'h7: begin // OR
                        alu_opcode = 4'h7;
                        reg_ra     = 3'b000;
                        reg_rb     = operand[2:0];
                        reg_rw     = 3'b000;
                        reg_we     = 1'b1;
                        next_state = S_FETCH;
                    end
                    4'h8: begin // XOR
                        alu_opcode = 4'h8;
                        reg_ra     = 3'b000;
                        reg_rb     = operand[2:0];
                        reg_rw     = 3'b000;
                        reg_we     = 1'b1;
                        next_state = S_FETCH;
                    end
                    4'h9: begin // NOT (ACC = ~ACC)
                        alu_opcode = 4'h9;
                        reg_ra     = 3'b000;
                        reg_rb     = 3'b000; // unused
                        reg_rw     = 3'b000;
                        reg_we     = 1'b1;
                        next_state = S_FETCH;
                    end
                    4'hA: begin // STORE ACC to memory address given by operand
                        mem_we   = 1'b1;
                        mem_addr = operand[2:0];
                        mem_wdata = 4'bxxxx; // will be driven by register file output (ACC) externally
                        next_state = S_FETCH;
                    end
                    4'hB: begin // JMP if zero flag set
                        if (zero) begin
                            pc_load    = operand[2:0];
                            pc_load_en = 1'b1;
                        end
                        next_state = S_FETCH;
                    end
                    4'hF: begin // HALT
                        next_state = S_HALT;
                    end
                    default: begin
                        next_state = S_FETCH; // treat unknown as NOP
                    end
                endcase
            end
            S_EXECUTE: begin
                // Not used in this simple design – execution occurs in DECODE step.
                next_state = S_FETCH;
            end
            S_HALT: begin
                // stay halted
                next_state = S_HALT;
            end
        endcase
    end

endmodule
