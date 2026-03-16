## --- BITSTREAM OVERRIDES (Essential for unmapped 72-bit Q_all) ---
set_property BITSTREAM.Config.UnusedPin Termination [current_design]
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

## --- CLOCK (Nexys A7 100MHz) ---
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { Clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { Clk }];

## --- INPUTS (Your custom Button pins) ---
set_property -dict { PACKAGE_PIN U10   IOSTANDARD LVCMOS33 } [get_ports { S[0] }]; 
set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { S[1] }]; 
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { S[2] }]; 

## --- NOTE ON Q_all ---
## We are NOT assigning Q_all to physical pins because there aren't 72 pins available.
## The ILA (Internal Logic Analyzer) will capture these signals inside the chip.# ==============================================================================
# Project: Digital Rubik's Cube Game (RubidMark2)
# Hardware: Nexys A7-100T FPGA Constraint File
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. SYSTEM CLOCK (100 MHz)
# ------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {CLK100MHZ}]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports {CLK100MHZ}]

# ------------------------------------------------------------------------------
# 2. SYSTEM RESET (Physical Red Button)
# ------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports {CPU_RESETN}]

# ------------------------------------------------------------------------------
# 3. PLAYER INPUTS (Buttons)
# ------------------------------------------------------------------------------
# BTNC = Execute Move
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {BTNC}]
# BTNU = Start Game
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {BTNU}]
# BTND = Reset Cube (Anti-Cheat)
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {BTND}]

# ------------------------------------------------------------------------------
# 4. PLAYER INPUTS (16 Switches)
# ------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {SW[0]}]  ; # Face D
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {SW[1]}]  ; # Face B
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {SW[2]}]  ; # Face L
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {SW[3]}]  ; # Face U
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {SW[4]}]  ; # Face R
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {SW[5]}]  ; # Face F
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {SW[6]}]  ; # Direction (CW/CCW)
set_property -dict {PACKAGE_PIN T8 IOSTANDARD LVCMOS33} [get_ports {SW[7]}]  ; # Timer Bit 0
set_property -dict {PACKAGE_PIN R13  IOSTANDARD LVCMOS33} [get_ports {SW[8]}]  ; # Timer Bit 1
set_property -dict {PACKAGE_PIN U18  IOSTANDARD LVCMOS33} [get_ports {SW[9]}]  ; # Timer Bit 2
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {SW[10]}] ; # Timer Bit 3
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {SW[11]}] ; # Timer Bit 4
set_property -dict {PACKAGE_PIN R15  IOSTANDARD LVCMOS33} [get_ports {SW[12]}] ; # Timer Bit 5
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {SW[13]}] ; # Timer Bit 6
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {SW[14]}] ; # Timer Bit 7
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {SW[15]}] ; # Game Mode (Free/Challenge)

# ------------------------------------------------------------------------------
# 5. PLAYER OUTPUTS (16 LEDs)
# ------------------------------------------------------------------------------
#set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {LED[0]}]  ; # Time Out Bit 0
#set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {LED[1]}]  ; # Time Out Bit 1
#set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {LED[2]}]  ; # Time Out Bit 2
#set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {LED[3]}]  ; # Time Out Bit 3
#set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {LED[4]}]  ; # Time Out Bit 4
#set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {LED[5]}]  ; # Time Out Bit 5
#set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {LED[6]}]  ; # Time Out Bit 6
#set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {LED[7]}]  ; # Time Out Bit 7
#set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {LED[8]}]  ; # Sequence Debug 0
#set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {LED[9]}]  ; # Sequence Debug 1
#set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {LED[10]}] ; # Sequence Debug 2
#set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {LED[11]}] ; # Unused
#set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {LED[12]}] ; # Unused
#set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {LED[13]}] ; # Unused
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {LED[1]}] ; # LOSE Indicator
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {LED[0]}] ; # WIN Indicator

# Optional: Allow unconstrained ports (Useful while testing before VGA is added)
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]