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
#set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {LED[0]}]  ; # debugging sexy move: Start/Idle Indicator
#set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {LED[1]}]  ; # debugging sexy move: R move successful Indicator
#set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {LED[2]}]  ; # debugging sexy move: U move successful Indicator
#set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {LED[3]}]  ; # debugging sexy move: R' move successful Indicator
#set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {LED[4]}]  ; # debugging sexy move: U' move successful Indicator
#set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {LED[5]}]  ; # debugging sexy move: other
#set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {LED[6]}]  ; # Unused
#set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {LED[7]}]  ; # Unused
#set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {LED[8]}]  ; # Unused
#set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {LED[9]}]  ; # Unused
#set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {LED[10]}] ; # Unused
#set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {LED[11]}] ; # Unused
#set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {LED[12]}] ; # Unused
#set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {LED[13]}] ; # Unused
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {LED[14]}] ; # LOSE Indicator
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {LED[15]}] ; # WIN Indicator

# Optional: Allow unconstrained ports (Useful while testing before VGA is added)
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

# -----------------------------------------------------------------------------
# 6. VGA OUTPUTS (Nexys A7 VGA Connector)
# -----------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { rgb[0] }]; #IO_L8N_T1_AD14N_35 Sch=vga_r[0]
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { rgb[1] }]; #IO_L7N_T1_AD6N_35 Sch=vga_r[1]
set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { rgb[2] }]; #IO_L1N_T0_AD4N_35 Sch=vga_r[2]
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { rgb[3] }]; #IO_L8P_T1_AD14P_35 Sch=vga_r[3]
set_property -dict { PACKAGE_PIN C6    IOSTANDARD LVCMOS33 } [get_ports { rgb[4] }]; #IO_L1P_T0_AD4P_35 Sch=vga_g[0]
set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports { rgb[5] }]; #IO_L3N_T0_DQS_AD5N_35 Sch=vga_g[1]
set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { rgb[6] }]; #IO_L2N_T0_AD12N_35 Sch=vga_g[2]
set_property -dict { PACKAGE_PIN A6    IOSTANDARD LVCMOS33 } [get_ports { rgb[7] }]; #IO_L3P_T0_DQS_AD5P_35 Sch=vga_g[3]
set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { rgb[8] }]; #IO_L2P_T0_AD12P_35 Sch=vga_b[0]
set_property -dict { PACKAGE_PIN C7    IOSTANDARD LVCMOS33 } [get_ports { rgb[9] }]; #IO_L4N_T0_35 Sch=vga_b[1]
set_property -dict { PACKAGE_PIN D7    IOSTANDARD LVCMOS33 } [get_ports { rgb[10] }]; #IO_L6N_T0_VREF_35 Sch=vga_b[2]
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports { rgb[11] }]; #IO_L4P_T0_35 Sch=vga_b[3]
set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { hsync }]; #IO_L4P_T0_15 Sch=vga_hs
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { vsync }]; #IO_L3N_T0_DQS_AD1N_15 Sch=vga_vs

# ------------------------------------------------------------------------------
# 6. 7-SEGMENT DISPLAY
# ------------------------------------------------------------------------------
# Segments (Active Low: 0 = ON) - Order is GFEDCBA
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {SEG[0]}] ; # CA
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {SEG[1]}] ; # CB
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {SEG[2]}] ; # CC
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {SEG[3]}] ; # CD
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {SEG[4]}] ; # CE
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {SEG[5]}] ; # CF
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {SEG[6]}] ; # CG

# Anodes (Active Low: 0 = ON) - Selects which of the 8 digits is currently active
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {AN[7]}] ; # AN0 (Right-most)
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {AN[6]}] ; # AN1
set_property -dict {PACKAGE_PIN T9  IOSTANDARD LVCMOS33} [get_ports {AN[5]}] ; # AN2
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {AN[4]}] ; # AN3
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {AN[3]}] ; # AN4
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {AN[2]}] ; # AN5
set_property -dict {PACKAGE_PIN K2  IOSTANDARD LVCMOS33} [get_ports {AN[1]}] ; # AN6
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {AN[0]}] ; # AN7 (Left-most)