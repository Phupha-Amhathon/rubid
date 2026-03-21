----------------------------------------------------------------------------------
-- Company: Computer Engineering @Khon Kaen University
-- Engineer: Puwadon Puchamni
-- 
-- Create Date: 03/20/2026 12:06:44 AM
-- Design Name: 
-- Module Name: TempTop - Behavioral
-- Project Name: Copter_Scramble_Rubik
-- Target Devices: nexys A7 100t
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
-------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity machine_doce_fleur is
    Port ( d_in  : in  STD_LOGIC_VECTOR(15 downto 0);
           d_out : out STD_LOGIC_VECTOR(15 downto 0));
end machine_doce_fleur;

architecture GateLevel of machine_doce_fleur is
    signal b12 : STD_LOGIC; 
begin

    b12 <= d_in(12);
    
    d_out(0)  <= d_in(15) xor b12;
    d_out(1)  <= d_in(14) xor b12;
    d_out(2)  <= d_in(13) xor b12;
    d_out(3)  <= d_in(11) xor b12; 
    d_out(4)  <= d_in(10) xor b12;
    d_out(5)  <= d_in(9)  xor b12;
    d_out(6)  <= d_in(8)  xor b12;
    d_out(7)  <= d_in(7)  xor b12;
    
    d_out(8)  <= d_in(6)  xor b12;
    d_out(9)  <= d_in(5)  xor b12;
    d_out(10) <= d_in(4)  xor b12;
    d_out(11) <= d_in(3)  xor b12;
    d_out(12) <= d_in(0)  xor b12; 
    d_out(13) <= d_in(1)  xor b12;
    d_out(14) <= d_in(2)  xor b12;
    
    d_out(15) <= b12;

end GateLevel;
