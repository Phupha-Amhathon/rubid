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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Facelet is
    Port ( 
        W3, W2, W1, W0 : in STD_LOGIC_VECTOR (2 downto 0);
        Pre : in std_logic_vector( 2 downto 0);
        S : in std_logic_vector(2 downto 0);
        Clk : in std_logic;
        Q : out std_logic_vector( 2 downto 0)
    );
end Facelet;

architecture structural of Facelet is
    component PIPORegister3bit is
      Port (
        I : in std_logic_vector(2 downto 0);
        Clk : in std_logic;
        Q : out std_logic_vector(2 downto 0)
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
        Q => sQ
    );
    
    Q <= sQ;
    
    SEL: MUX8To1_3bit port map(
            I0 => sQ, I1 => W0, I2 => W1, I3 => W2, I4 => W3, I5 => sQ, I6 => sQ, I7 => Pre, 
            S => S,
            Y => sI 
        );
        

end structural;
