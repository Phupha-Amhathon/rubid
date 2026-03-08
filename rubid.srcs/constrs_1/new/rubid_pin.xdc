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
## The ILA (Internal Logic Analyzer) will capture these signals inside the chip.