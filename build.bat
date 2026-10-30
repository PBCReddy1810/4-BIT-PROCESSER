@echo off
rem Build script for the 4-bit processor using Icarus Verilog

setlocal

rem ------------------------------------------------------------
rem Ensure Icarus Verilog (iverilog) is on PATH
rem ------------------------------------------------------------
where iverilog >nul 2>&1
if errorlevel 1 (
    echo ERROR: iverilog not found in PATH. Install Icarus Verilog first.
    exit /b 1
)

rem ------------------------------------------------------------
rem Compile all Verilog files and the testbench
rem ------------------------------------------------------------
iverilog -g2012 -o cpu_sim *.v
if errorlevel 1 (
    echo Compilation failed. Check the Verilog sources.
    exit /b 1
)

rem ------------------------------------------------------------
rem Run the simulation (produces cpu.vcd)
rem ------------------------------------------------------------
vvp cpu_sim
if errorlevel 1 (
    echo Simulation error.
    exit /b 1
)

rem ------------------------------------------------------------
rem Open waveform viewer (GTKWave) if available
rem ------------------------------------------------------------
where gtkwave >nul 2>&1
if not errorlevel 1 (
    start gtkwave cpu.vcd
) else (
    echo GTKWave not found – you can open cpu.vcd manually.
)

endlocal
