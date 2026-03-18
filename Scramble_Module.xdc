## 100 MHz System Clock (Pin E3)
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { CLK100MHZ }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {CLK100MHZ}];

## Scramble Button (Pin P18 is the Bottom Button "BTND")
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { SCRAMBLE_BTN }];

## Onboard Temperature Sensor I2C Pins
set_property -dict { PACKAGE_PIN C14   IOSTANDARD LVCMOS33 } [get_ports { TMP_SCL }];
set_property -dict { PACKAGE_PIN C15   IOSTANDARD LVCMOS33 } [get_ports { TMP_SDA }];

## Scramble Done Indicator (Mapped to LED0 so you know when it finishes)
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { SCRAMBLE_DONE }];

set_property PULLUP [get_ports { TMP_SDA }];
