----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 02:43:48 PM
-- Design Name: 
-- Module Name: DLatch - gate_level
-- Project Name: 
-- Target Devices: 
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

entity DLatch is
  Port (
    En, D : in std_logic;
    Q, nQ : out std_logic
   );
end DLatch;

architecture gate_level of DLatch is
    signal S, R : std_logic;
    signal s_Q, s_nQ : std_logic;
begin   
    S <= D and En;
    R <= (not D) and En;
    
    s_Q <= S nor s_nQ;
    s_nQ <= R nor s_Q;
    
    Q <= s_Q;
    nQ <= s_nQ;
    
end gate_level;
