library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Chaos_Machine_1 is
    Port ( Reg_In : in std_logic_vector(15 downto 0); 
           Reg_Out : out std_logic_vector(15 downto 0) );
end Chaos_Machine_1;

architecture structure of Chaos_Machine_1 is
begin
    Reg_Out <= Reg_In(0) & Reg_In(8) & Reg_In(1) & Reg_In(9) & 
               Reg_In(2) & Reg_In(10) & Reg_In(3) & Reg_In(11) &
               Reg_In(4) & Reg_In(12) & Reg_In(5) & Reg_In(13) &
               Reg_In(6) & Reg_In(14) & Reg_In(7) & Reg_In(15);
end structure;