library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity moveEncoder is
  Port (
    RESET, F, R, U, L, B, D : in std_logic;
    Y : out std_logic_vector(2 downto 0) 
  );
end moveEncoder;

architecture gate_level of moveEncoder is
    signal nRESET, nF, nR, nU, nL, nB : std_logic;
begin
    nRESET <= not RESET;
    nF <= not F;
    nR <= not R;
    nU <= not U;
    nL <= not L;
    nB <= not B;
--    nD <= not D;
    
    Y(0) <= RESET or ((not RESET) and F) or ((not RESET) and (not F) and (not R) and U) or ((not RESET) and (not F) and (not R) and (not U) and (not L) and B);
    Y(1) <= RESET or 
           (
                (nRESET and nF) and 
                (
                    R or (nR and U) or (nR and nU and nL and nB and D)
                 )
            );
    Y(2) <= RESET or 
            ( 
                ((not RESET) and (not F) and (not R) and (not U)) and 
                (L or ((not L) and B) or ((not L) and (not B) and D)) 
             ); 
end gate_level;
