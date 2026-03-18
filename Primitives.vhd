library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFlipFlop is
    Port ( D, Clk, Pre, Clr : in std_logic; Q : out std_logic );
end DFlipFlop;

architecture behavioral of DFlipFlop is
begin
    process(Clk) begin
        if falling_edge(Clk) then
            if Pre = '1' then Q <= '1';
            elsif Clr = '1' then Q <= '0';
            else Q <= D; end if;
        end if;
    end process;
end behavioral;