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

entity machine_shuffle is
    Port ( d_in  : in  STD_LOGIC_VECTOR(15 downto 0);
           d_out : out STD_LOGIC_VECTOR(15 downto 0));
end machine_shuffle;

architecture Structural of machine_shuffle is
begin
-- do faro shuffle in circuit lol
-- 7 - 0 zig zag with 15 - 8
    d_out(0)  <= d_in(0);   d_out(1)  <= d_in(8);
    d_out(2)  <= d_in(1);   d_out(3)  <= d_in(9);
    d_out(4)  <= d_in(2);   d_out(5)  <= d_in(10);
    d_out(6)  <= d_in(3);   d_out(7)  <= d_in(11);
    d_out(8)  <= d_in(4);   d_out(9)  <= d_in(12);
    d_out(10) <= d_in(5);   d_out(11) <= d_in(13);
    d_out(12) <= d_in(6);   d_out(13) <= d_in(14);
    d_out(14) <= d_in(7);   d_out(15) <= d_in(15);
end Structural;
