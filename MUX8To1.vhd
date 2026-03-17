----------------------------------------------------------------------------------
-- Company: Knon Kaen University
-- Engineer: Phupha Amhathon
-- 
-- Create Date: 03/01/2026 01:43:23 PM
-- Design Name: eight to one multiplexer
-- Module Name: MUX8To1 - gate_level
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

entity MUX8To1 is
  Port (
    I7, I6, I5, I4, I3, I2, I1, I0 : in std_logic;
    S2, S1, S0 : in std_logic;
    Y : out std_logic
  );
end MUX8To1;

architecture gate_level of MUX8To1 is
    component MUX2To1 is
      Port (
       I1, I0, S : in std_logic;
       Y: out std_logic 
      );
    end component;
    
    --internal signal 
    signal m0tom4, m1tom4, m2tom5, m3tom5 : std_logic;
    signal m4tom7, m5tom7 : std_logic;
begin
    --stage0 
    MUX0: MUX2To1 port map(I1 => I1, I0 => I0, S => S0, Y => m0tom4);
    MUX1: MUX2To1 port map(I1 => I3, I0 => I2, S => S0, Y => m1tom4);
    MUX2: MUX2To1 port map(I1 => I5, I0 => I4, S => S0, Y => m2tom5);
    MUX3: MUX2To1 port map(I1 => I7, I0 => I6, S => S0, Y => m3tom5);
    --stage1
    MUX4: MUX2To1 port map(I1 => m1tom4, I0 => m0tom4, S => S1, Y => m4tom7);
    MUX5: MUX2To1 port map(I1 => m3tom5, I0 => m2tom5, S => S1, Y => m5tom7);
    --stage2
    MUX6: MUX2To1 port map(I1 => m5tom7, I0 => m4tom7, S => S2, Y => Y);
end gate_level;