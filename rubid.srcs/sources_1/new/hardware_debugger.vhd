library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity hardware_debugger is
    Port ( 
        CLK100MHZ  : in STD_LOGIC;
        CPU_RESETN : in STD_LOGIC; -- Your T13 Switch
        BTNC       : in STD_LOGIC; 
        BTNU       : in STD_LOGIC; 
        BTND       : in STD_LOGIC; 
        SW         : in STD_LOGIC_VECTOR(15 downto 0); 
        LED        : out STD_LOGIC_VECTOR(15 downto 0)
    );
end hardware_debugger;

architecture Behavioral of hardware_debugger is
begin

    -- 1. Test the regular switches (SW 0 to 11)
    -- If you flip SW(0), LED(0) turns on. If you flip SW(10), LED(10) turns on.
    LED(11 downto 0) <= SW(11 downto 0);

    -- 2. Test the Buttons
    -- Pressing the buttons will light up LEDs 12, 13, and 14
    LED(12) <= BTNC;
    LED(13) <= BTNU;
    LED(14) <= BTND;

    -- 3. Test your Custom Reset Switch (T13)
    -- Flipping your reset switch will light up the final LED(15)
    LED(15) <= CPU_RESETN;

end Behavioral;