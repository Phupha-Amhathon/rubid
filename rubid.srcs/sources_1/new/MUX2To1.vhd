
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
