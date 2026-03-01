----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/01/2026 02:43:48 PM
-- Design Name: 
-- Module Name: DFlipFlop - structural
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

---HOW TO WRITE THIS THING IN GSTE LEVEL 
--entity DFlipFlop is
--  Port ( 
--    D   : in  std_logic;
--    Clk : in  std_logic;
--    Q   : out std_logic;
--    nQ  : out std_logic
--  );
--end DFlipFlop;

--architecture structural of DFlipFlop is
--    component DLatch is
--      Port (
--        En, D : in std_logic;
--        Q, nQ : out std_logic
--       );
--    end component;
--    signal masterQ, nClk : std_logic;
--begin
--    nClk <= not Clk;
--    MASTER: Dlatch port map(
--        En => Clk, D => D, Q => masterQ, nQ => open 
--    );
    
--    SLAVE: DLatch port map(
--        En => nClk, D => masterQ, Q => Q, nQ => nQ
--    );

--end structural;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DFlipFlop is
    Port ( 
        D   : in  std_logic;
        Clk : in  std_logic;
        Q   : out std_logic;
        nQ  : out std_logic
    );
end DFlipFlop;

architecture behavioral of DFlipFlop is
begin
    process(Clk)
    begin
        -- Falling Edge
        if falling_edge(Clk) then
            Q  <= D;
            nQ <= not D;
        end if;
    end process;
end behavioral;