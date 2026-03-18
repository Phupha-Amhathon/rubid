library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Facelet_Unit is
    Port ( 
        MD, MB, ML, MU, MR, MF : in std_logic_vector(2 downto 0);
        init : in std_logic_vector(2 downto 0);
        S : in std_logic_vector(2 downto 0);
        Clk : in std_logic; 
        Q : out std_logic_vector(2 downto 0)
    );
end Facelet_Unit;

architecture structural of Facelet_Unit is
    signal sQ : std_logic_vector(2 downto 0) := "000"; -- INITIALIZED to prevent 'U'
    signal sI : std_logic_vector(2 downto 0);
begin
    process(Clk) begin
        if falling_edge(Clk) then sQ <= sI; end if;
    end process;
    Q <= sQ;

    sI <= sQ   when S = "000" else MF when S = "001" else
          MR   when S = "010" else MU when S = "011" else
          ML   when S = "100" else MB when S = "101" else
          MD   when S = "110" else init; -- S = "111" selects init
end structural;