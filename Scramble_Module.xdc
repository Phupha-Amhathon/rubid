## 100 MHz System Clock (Pin E3)
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports CLK100MHZ]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports CLK100MHZ]

## Scramble Button (Pin P18 is the Bottom Button "BTND")
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports SCRAMBLE_BTN]

## Scramble Done Indicator (Mapped to LED0 so you know when it finishes)
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports SCRAMBLE_DONE]

## Onboard Temperature Sensor I2C Pins (With PULLUPs!)
set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33   PULLUP true } [get_ports { TMP_SCL }];
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33   PULLUP true } [get_ports { TMP_SDA }];

## -------------------------------------------------------------------------
## NEW: 7-Segment Display Segments & Decimal Point
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { SEG[0] }]; # CA
set_property -dict { PACKAGE_PIN R10   IOSTANDARD LVCMOS33 } [get_ports { SEG[1] }]; # CB
set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { SEG[2] }]; # CC
set_property -dict { PACKAGE_PIN K13   IOSTANDARD LVCMOS33 } [get_ports { SEG[3] }]; # CD
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { SEG[4] }]; # CE
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { SEG[5] }]; # CF
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { SEG[6] }]; # CG
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { DP }];     # Decimal Point

## -------------------------------------------------------------------------
## NEW: 7-Segment Display Anodes (Digit Selectors)
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN J17   IOSTANDARD LVCMOS33 } [get_ports { AN[0] }]; 
set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVCMOS33 } [get_ports { AN[1] }]; 
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { AN[2] }]; 
set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { AN[3] }]; 
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33 } [get_ports { AN[4] }]; 
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33 } [get_ports { AN[5] }]; 
set_property -dict { PACKAGE_PIN K2    IOSTANDARD LVCMOS33 } [get_ports { AN[6] }]; 
set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { AN[7] }]; 


## -------------------------------------------------------------------------
## VIVADO AUTO-GENERATED ILA DEBUG CORES (DO NOT MODIFY)
## -------------------------------------------------------------------------
create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list CLK100MHZ_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {temp_wire[0]} {temp_wire[1]} {temp_wire[2]} {temp_wire[3]} {temp_wire[4]} {temp_wire[5]} {temp_wire[6]} {temp_wire[7]} {temp_wire[8]} {temp_wire[9]} {temp_wire[10]} {temp_wire[11]} {temp_wire[12]} {temp_wire[13]} {temp_wire[14]} {temp_wire[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 72 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {CUBE_STATE[0]} {CUBE_STATE[1]} {CUBE_STATE[2]} {CUBE_STATE[3]} {CUBE_STATE[4]} {CUBE_STATE[5]} {CUBE_STATE[6]} {CUBE_STATE[7]} {CUBE_STATE[8]} {CUBE_STATE[9]} {CUBE_STATE[10]} {CUBE_STATE[11]} {CUBE_STATE[12]} {CUBE_STATE[13]} {CUBE_STATE[14]} {CUBE_STATE[15]} {CUBE_STATE[16]} {CUBE_STATE[17]} {CUBE_STATE[18]} {CUBE_STATE[19]} {CUBE_STATE[20]} {CUBE_STATE[21]} {CUBE_STATE[22]} {CUBE_STATE[23]} {CUBE_STATE[24]} {CUBE_STATE[25]} {CUBE_STATE[26]} {CUBE_STATE[27]} {CUBE_STATE[28]} {CUBE_STATE[29]} {CUBE_STATE[30]} {CUBE_STATE[31]} {CUBE_STATE[32]} {CUBE_STATE[33]} {CUBE_STATE[34]} {CUBE_STATE[35]} {CUBE_STATE[36]} {CUBE_STATE[37]} {CUBE_STATE[38]} {CUBE_STATE[39]} {CUBE_STATE[40]} {CUBE_STATE[41]} {CUBE_STATE[42]} {CUBE_STATE[43]} {CUBE_STATE[44]} {CUBE_STATE[45]} {CUBE_STATE[46]} {CUBE_STATE[47]} {CUBE_STATE[48]} {CUBE_STATE[49]} {CUBE_STATE[50]} {CUBE_STATE[51]} {CUBE_STATE[52]} {CUBE_STATE[53]} {CUBE_STATE[54]} {CUBE_STATE[55]} {CUBE_STATE[56]} {CUBE_STATE[57]} {CUBE_STATE[58]} {CUBE_STATE[59]} {CUBE_STATE[60]} {CUBE_STATE[61]} {CUBE_STATE[62]} {CUBE_STATE[63]} {CUBE_STATE[64]} {CUBE_STATE[65]} {CUBE_STATE[66]} {CUBE_STATE[67]} {CUBE_STATE[68]} {CUBE_STATE[69]} {CUBE_STATE[70]} {CUBE_STATE[71]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list SCRAMBLE_DONE_OBUF]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets CLK100MHZ_IBUF_BUFG]