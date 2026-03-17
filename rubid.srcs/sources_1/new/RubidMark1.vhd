----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/09/2026 01:33:05 AM
-- Design Name: 
-- Module Name: RubidMark1 - Structural
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RubidMark1 is
    Port ( RESET : in STD_LOGIC;
           F : in STD_LOGIC;
           R : in STD_LOGIC;
           U : in STD_LOGIC;
           L : in STD_LOGIC;
           B : in STD_LOGIC;
           D : in STD_LOGIC;
           Q : out STD_LOGIC_VECTOR (71 downto 0);
           Clk : in std_logic
           );
           
end RubidMark1;

architecture Structural of RubidMark1 is
    component Rubid is
    Port ( S : in STD_LOGIC_VECTOR (2 downto 0);
           Clk : in STD_LOGIC;
           Q_all : out STD_LOGIC_VECTOR (71 downto 0)
           );
    end component;
    
    component moveEncoder is
    Port (
        RESET, F, R, U, L, B, D : in std_logic;
        Y : out std_logic_vector(2 downto 0) 
     );
    end component;
    
    signal sY : std_logic_vector(2 downto 0);
begin
    Controller: moveEncoder port map(
        RESET => RESET, 
        F => F,
        R => R,
        U => U, 
        L => L,
        B => B, 
        D => D, 
        Y => sY 
    );
    
    Rubid1: Rubid port map(
        S => sY, 
        Clk => Clk, 
        Q_all => Q
    );
end Structural;
