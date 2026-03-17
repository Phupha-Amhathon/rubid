----------------------------------------------------------------------------------
-- Company: Knon Kaen University
-- Engineer: Phupha Amhathon
-- 
-- Create Date: 03/01/2026 01:43:23 PM
-- Design Name: two to one multiplexer
-- Module Name: MUX2To1 - gate_level
-- Project Name: rubid
-- Target Devices: nexty A7 100T
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

entity MUX2To1 is
  Port (
   I1, I0, S : in std_logic;
   Y: out std_logic 
  );
end MUX2To1;

architecture gate_level of MUX2To1 is
    signal notS : std_logic;
begin
    notS <= not S; 
    Y <= (I0 AND notS) OR (I1 AND S);
end gate_level;
