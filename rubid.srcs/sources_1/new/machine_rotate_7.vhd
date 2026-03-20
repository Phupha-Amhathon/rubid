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

entity machine_rotate_7 is
    Port ( d_in  : in  STD_LOGIC_VECTOR(15 downto 0);
           d_out : out STD_LOGIC_VECTOR(15 downto 0));
end machine_rotate_7;

architecture Structural of machine_rotate_7 is
begin
    -- Shift left by 7. 
    -- Bits 8 down to 0 shift up, Bits 15 down to 9 wrap around to the bottom.
    d_out <= d_in(8 downto 0) & d_in(15 downto 9);
end Structural;