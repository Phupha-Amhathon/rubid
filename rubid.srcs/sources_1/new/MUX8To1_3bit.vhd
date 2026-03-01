----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 02:13:02 PM
-- Design Name: 
-- Module Name: MUX8To1_3bit - Behavioral
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

entity MUX8To1_3bit is
  Port (
    I7, I6, I5, I4, I3, I2, I1, I0 : in std_logic_vector(2 downto 0);
    S : in std_logic_vector(2 downto 0);
--    Y : out std_logic_vector(2 downto 0)
    Y : out std_logic_vector(2 downto 0)
  );
end MUX8To1_3bit;

architecture Behavioral of MUX8To1_3bit is
    component MUX8To1 is
      Port (
        I7, I6, I5, I4, I3, I2, I1, I0 : in std_logic;
        S2, S1, S0 : in std_logic;
        Y : out std_logic
      );
    end component;
begin
    MUX_BIT0: MUX8To1 port map(
        I7 => I7(0), I6 => I6(0), I5 => I5(0), I4 => I4(0), I3 => I3(0), I2 => I2(0), I1 => I1(0), I0 => I0(0),
        S2 => S(2), S1 => S(1), S0 => S(0),
        Y => Y(0)
    );
    
    MUX_BIT1: MUX8To1 port map(
        I7 => I7(1), I6 => I6(1), I5 => I5(1), I4 => I4(1), I3 => I3(1), I2 => I2(1), I1 => I1(1), I0 => I0(1),
        S2 => S(2), S1 => S(1), S0 => S(0),
        Y => Y(1)
    );
    
    MUX_BIT2: MUX8To1 port map(
        I7 => I7(2), I6 => I6(2), I5 => I5(2), I4 => I4(2), I3 => I3(2), I2 => I2(2), I1 => I1(2), I0 => I0(2),
        S2 => S(2), S1 => S(1), S0 => S(0),
        Y => Y(2)
    );

end Behavioral;
