// memory.v
// Simple synchronous 8×4‑bit RAM (used for both instruction and data memory).
// Write occurs on rising edge of clk when we is asserted.

module memory (
    input  wire        clk,
    input  wire [2:0]  addr,   // 3‑bit address → 8 locations
    input  wire [3:0]  wdata,  // Write data
    input  wire        we,     // Write enable
    output reg  [3:0]  rdata   // Read data (combinational output)
);

    reg [3:0] mem [0:7];

    // Write on clock edge
    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= wdata;
        end
    end

    // Read (combinational)
    always @(*) begin
        rdata = mem[addr];
    end

endmodule
