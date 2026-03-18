library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Chaos_Machine_3_InvertBit is
    Port ( Reg_In : in std_logic_vector(15 downto 0); 
           Reg_Out : out std_logic_vector(15 downto 0) );
end Chaos_Machine_3_InvertBit;

architecture structure of Chaos_Machine_3_InvertBit is
begin
    Reg_Out <= not (Reg_In(0) & Reg_In(15 downto 1)) xor x"5555";
end structure;