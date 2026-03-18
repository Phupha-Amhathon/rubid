library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Chaos_Machine_0 is
    Port ( Reg_In : in std_logic_vector(15 downto 0); 
           Reg_Out : out std_logic_vector(15 downto 0) );
end Chaos_Machine_0;

architecture structure of Chaos_Machine_0 is
begin
    -- Moves data 3 positions to the left every time
    Reg_Out <= Reg_In(12 downto 0) & Reg_In(15 downto 13);
end structure;