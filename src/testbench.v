// testbench.v
// Simple testbench for the 4‑bit processor.
// Uses Icarus Verilog / VVP to generate a VCD waveform.

`timescale 1ns/1ps

module tb;
    reg clk;
    reg rst_n;

    // Instantiate the top‑level CPU
    cpu_top dut (
        .clk   (clk),
        .rst_n (rst_n)
    );

    // Clock generation – 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset sequence
    initial begin
        rst_n = 0;
        #12;
        rst_n = 1;
    end

    // Load a simple demo program into instruction memory (8 words)
    initial begin
        $readmemh("demo_program.hex", imem.mem);
        $readmemh("demo_program.hex", imem_low.mem);
    end


endmodule
