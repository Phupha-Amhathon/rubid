library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Chaos_Machine_2 is
    Port ( Reg_In : in std_logic_vector(15 downto 0); 
           Temp : in std_logic_vector(15 downto 0); 
           Reg_Out : out std_logic_vector(15 downto 0) );
end Chaos_Machine_2;

architecture structure of Chaos_Machine_2 is
begin
    Reg_Out <= Reg_In xor Temp;
end structure;