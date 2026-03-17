library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux_3bit_2to1 is
    Port ( 
        Sel : in STD_LOGIC;                               -- The track switch (0 = Human, 1 = Scrambler)
        In0 : in STD_LOGIC_VECTOR(2 downto 0);            -- Track 0: From Move Controller
        In1 : in STD_LOGIC_VECTOR(2 downto 0);            -- Track 1: From Hardware Scrambler
        Y   : out STD_LOGIC_VECTOR(2 downto 0)            -- Output: To Rubik's Cube Memory
    );
end mux_3bit_2to1;

architecture Behavioral of mux_3bit_2to1 is
begin
    -- If Sel is 1, route In1. Otherwise, route In0.
    Y <= In1 when Sel = '1' else In0;
end Behavioral;