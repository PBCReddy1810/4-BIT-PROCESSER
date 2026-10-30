// regfile.v
// Simple 4-bit Register File for the custom 4‑bit processor.
// Contains 8 general‑purpose registers (R0‑R7) each 4‑bits wide.
// R0 is hard‑wired to 0 (read‑only) and serves as the accumulator (ACC).
// Write enables are controlled by the CPU control unit.

module regfile (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [2:0]  ra,      // Read address A
    input  wire [2:0]  rb,      // Read address B
    input  wire [2:0]  rw,      // Write address
    input  wire [3:0]  wdata,   // Data to write
    input  wire        we,      // Write enable
    output wire [3:0]  dout_a,  // Data out A
    output wire [3:0]  dout_b   // Data out B
);

    // 8 registers, each 4‑bit
    reg [3:0] regs [0:7];

    // Asynchronous reset – clear all registers except R0 (which stays 0)
    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 8; i = i + 1) begin
                regs[i] <= 4'b0000;
            end
        end else begin
            if (we && (rw != 3'b000)) begin // R0 is read‑only zero
                regs[rw] <= wdata;
            end
        end
    end

    // Read ports (combinational)
    assign dout_a = (ra == 3'b000) ? 4'b0000 : regs[ra];
    assign dout_b = (rb == 3'b000) ? 4'b0000 : regs[rb];

endmodule
