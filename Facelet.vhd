----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 03:47:28 PM
-- Design Name: 
-- Module Name: Facelet - structural
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

entity Facelet is
    Port ( 
        MD, MB, ML, MU, MR, MF : in STD_LOGIC_VECTOR (2 downto 0); --cndidate entry line, eg move R (MR) shift value from MR line
        load_init : in std_logic_vector( 2 downto 0); --set init color
        S : in std_logic_vector(2 downto 0); -- selector
        Clk : in std_logic; 
        Q : out std_logic_vector( 2 downto 0) --3bit output represent cur color
    );
end Facelet;

architecture structural of Facelet is
    component PIPORegister3bit is
      Port (
        I : in std_logic_vector(2 downto 0);
        Clk : in std_logic;
        Q : out std_logic_vector(2 downto 0);
        Pre, Clr : in std_logic
      );
    end component;
    
    component MUX8To1_3bit is
      Port (
        I7, I6, I5, I4, I3, I2, I1, I0 : in std_logic_vector(2 downto 0);
        S : in std_logic_vector(2 downto 0);
        Y : out std_logic_vector(2 downto 0)
      );
    end component;
    --internal wire
    signal sQ : std_logic_vector(2 downto 0); --for signal output from each flip flop=
    signal sI : std_logic_vector(2 downto 0); --for signal input from multiplexer 
    
begin
--    sQ <= Q;
--    sQ(1) <= Q(1);
--    sQ(2) <= Q(2);
    REG: PIPORegister3bit port map(
        I => sI, 
        Clk => Clk, 
        Q => sQ, 
        Pre => '0',
        Clr => '0'
    );
    
    Q <= sQ;
    
    SEL: MUX8To1_3bit port map(
            I0 => sQ, I1 => MF, I2 => MR, I3 => MU, I4 => ML, I5 => MB, I6 => MD, I7 => load_init, 
            S => S,
            Y => sI 
        );
end structural;