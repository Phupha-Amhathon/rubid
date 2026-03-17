# ==============================================================================
# Project: Digital Rubik's Cube Game (RubidMark2)
# Hardware: Nexys A7-100T FPGA
# Description: Combined Team Controls + Thermal Chaos Scrambler
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. BITSTREAM & DEBUG OVERRIDES
# ------------------------------------------------------------------------------
# Essential for handling the 72-bit internal Q vector without 72 physical pins
set_property BITSTREAM.Config.UnusedPin PULLDOWN [current_design]
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

# ------------------------------------------------------------------------------
# 2. SYSTEM CLOCK (100 MHz Oscillator)
# ------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports {CLK100MHZ}]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports {CLK100MHZ}]

# ------------------------------------------------------------------------------
# 3. SYSTEM RESET (Physical Red Button)
# ------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports {CPU_RESETN}]

# ------------------------------------------------------------------------------
# 4. PLAYER INPUTS (Buttons)
# ------------------------------------------------------------------------------
# BTNC = Execute Move (Manual Mode)
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports {BTNC}]
# BTNU = Start Game (Master Controller)
set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {BTNU}]
# BTND = RESET CUBE & TRIGGER CHAOS SCRAMBLE
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {BTND}]

# ------------------------------------------------------------------------------
# 5. TEMPERATURE SENSOR ADT7420 (The Chaos Source)
# ------------------------------------------------------------------------------
# These pins provide the thermal noise for your Tangled MUX logic
set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports {TMP_SCL}]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports {TMP_SDA}]

# ------------------------------------------------------------------------------
# 6. PLAYER INPUTS (16 Switches)
# ------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {SW[0]}]  ; # Face D
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {SW[1]}]  ; # Face B
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {SW[2]}]  ; # Face L
set_property -dict {PACKAGE_PIN H6  IOSTANDARD LVCMOS33} [get_ports {SW[3]}]  ; # Face U
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {SW[4]}]  ; # Face R
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {SW[5]}]  ; # Face F
set_property -dict {PACKAGE_PIN U8  IOSTANDARD LVCMOS33} [get_ports {SW[6]}]  ; # Direction (CW/CCW)
set_property -dict {PACKAGE_PIN T8  IOSTANDARD LVCMOS33} [get_ports {SW[7]}]  ; # Timer Bit 0
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {SW[8]}]  ; # Timer Bit 1
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {SW[9]}]  ; # Timer Bit 2
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {SW[10]}] ; # Timer Bit 3
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {SW[11]}] ; # Timer Bit 4
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {SW[12]}] ; # Timer Bit 5
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {SW[13]}] ; # Timer Bit 6
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {SW[14]}] ; # Timer Bit 7
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {SW[15]}] ; # Game Mode (Free/Challenge)

# ------------------------------------------------------------------------------
# 7. PLAYER OUTPUTS (LEDs)
# ------------------------------------------------------------------------------
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {LED[1]}] ; # LOSE Indicator
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {LED[0]}] ; # WIN Indicator

# Optional: Using LED 0 (H17) to show when Chaos Scramble is complete
# Note: In the Top-Level VHDL, you should map the 'done' port to a new output 'LED_DONE'
# set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {LED_DONE}]