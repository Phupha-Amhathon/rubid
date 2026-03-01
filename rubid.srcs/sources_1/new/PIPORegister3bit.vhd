----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 02:43:48 PM
-- Design Name: 
-- Module Name: PIPORegister3bit - structural
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

entity PIPORegister3bit is
  Port (
    I : in std_logic_vector(2 downto 0);
    Clk : in std_logic;
    Q : out std_logic_vector(2 downto 0)
  );
end PIPORegister3bit;

architecture structural of PIPORegister3bit is
    component DFlipFlop is
      Port ( 
        D   : in  std_logic;
        Clk : in  std_logic;
        Q   : out std_logic;
        nQ  : out std_logic
      );
    end component;
begin
    B2: DFlipFlop port map(
        Clk => Clk, D => I(2), Q => Q(2), nQ => open  
    );
    B1: DFlipFlop port map(
        Clk => Clk, D => I(1), Q => Q(1), nQ => open  
    );
    B0: DFlipFlop port map(
        Clk => Clk, D => I(0), Q => Q(0), nQ => open
    );
end structural;
