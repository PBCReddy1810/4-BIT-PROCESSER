// cpu_top.v
// Top‑level module for the 4‑bit processor.
// Instantiates PC, instruction memory, data memory, register file, ALU, and control unit.
// The design is deliberately simple for educational purposes.

module cpu_top (
    input  wire clk,
    input  wire rst_n
);
    // Program Counter – 3 bits for 8‑word program memory
    reg [2:0] pc;
    wire [7:0] instr;

    // Instruction memory (holds program)
    memory imem (
        .clk   (clk),
        .addr  (pc),
        .wdata (4'b0000), // never written during execution
        .we    (1'b0),
        .rdata (instr[7:4]) // high nibble will be used for opcode
    );
    // We need full 8‑bit instruction; use two 4‑bit memories (high and low nibble).
    // For simplicity, treat a single 4‑bit memory as 8‑bit by concatenating two reads.
    // In a real design you would use a proper 8‑bit ROM.

    // Low‑nibble fetch (second memory instance)
    memory imem_low (
        .clk   (clk),
        .addr  (pc),
        .wdata (4'b0000),
        .we    (1'b0),
        .rdata (instr[3:0])
    );

    // Data memory for LOAD/STORE operations
    memory dmem (
        .clk   (clk),
        .addr  (ctrl_mem_addr),
        .wdata (ctrl_mem_wdata),
        .we    (mem_we),
        .rdata (dmem_rdata)
    );

    // Register file (8 registers, 4‑bit each)
    wire [3:0] rf_dout_a, rf_dout_b;
    regfile rf (
        .clk   (clk),
        .rst_n (rst_n),
        .ra    (reg_ra),
        .rb    (reg_rb),
        .rw    (reg_rw),
        .wdata (reg_we ? alu_result : 4'b0000), // write data comes from ALU result or store path
        .we    (reg_we),
        .dout_a(rf_dout_a),
        .dout_b(rf_dout_b)
    );

    wire alu_carry_out;
    // ALU
    wire [3:0] alu_result;
    alu alu_inst (
        .a      (rf_dout_a), // ACC is register 0 (hard‑wired zero, but we treat it as read‑only)
        .b      (rf_dout_b),
        .opcode (alu_opcode),
        .result (alu_result),
        .zero   (alu_zero),
        .carry_out (alu_carry_out)
    );


    // Control Unit – produces control signals
    wire [3:0] alu_opcode;
    wire [2:0] reg_ra, reg_rb, reg_rw;
    wire       reg_we, mem_we, pc_load_en, halted;
    wire [2:0] pc_load, pc_inc;
    wire [2:0] ctrl_mem_addr;
    wire [3:0] ctrl_mem_wdata;
    wire       alu_zero;

    control_unit CU (
        .clk        (clk),
        .rst_n      (rst_n),
        .instr      (instr),
        .zero       (alu_zero),
        .alu_opcode (alu_opcode),
        .reg_ra     (reg_ra),
        .reg_rb     (reg_rb),
        .reg_rw     (reg_rw),
        .reg_we     (reg_we),
        .mem_we     (mem_we),
        .mem_addr   (ctrl_mem_addr),
        .mem_wdata  (ctrl_mem_wdata),
        .pc_inc     (pc_inc),
        .pc_load    (pc_load),
        .pc_load_en (pc_load_en),
        .halted     (halted)
    );

    // PC update logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 3'b000;
        end else if (!halted) begin
            if (pc_load_en)
                pc <= pc_load;
            else
                pc <= pc + pc_inc; // default increment 1
        end
    end

    // Connect data‑memory write data (ACC) when STORE is executed.
    // The control unit asserts mem_we and supplies address; data comes from ACC (register 0 output).
    assign dmem_rdata = 4'bz; // not used directly in this simple demo
    assign ctrl_mem_wdata = rf_dout_a; // ACC value

endmodule
