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
    -- Priority flag wires (Active only if no higher-priority button is pressed)
    signal p_F, p_R, p_U, p_L, p_B, p_D : std_logic;

begin
    nRESET <= not RESET;
    nF     <= not F;
    nR     <= not R;
    nU     <= not U;
    nL     <= not L;
    nB     <= not B;

    p_F <= nRESET and F;
    p_R <= nRESET and nF and R;
    p_U <= nRESET and nF and nR and U;
    p_L <= nRESET and nF and nR and nU and L;
    p_B <= nRESET and nF and nR and nU and nL and B;
    p_D <= nRESET and nF and nR and nU and nL and nB and D;

    
    Y(0) <= RESET or p_F or p_U or p_B;
    Y(1) <= RESET or p_R or p_U or p_D;
    Y(2) <= RESET or p_L or p_B or p_D;

end gate_level;