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
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity machine_bit_flip is
    Port ( d_in  : in  STD_LOGIC_VECTOR(15 downto 0);
           d_out : out STD_LOGIC_VECTOR(15 downto 0));
end machine_bit_flip;

architecture Structural of machine_bit_flip is
    constant MASK : STD_LOGIC_VECTOR(15 downto 0) := x"5555";
begin
    d_out <= d_in xor MASK;
end Structural;
