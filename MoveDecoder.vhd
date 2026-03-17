library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ==============================================================================
-- Module: MoveDecoder
-- Description: Combinational gate-level decoder.
--              Maps the lower 3 bits of the LFSR to one-hot {F,R,U,L,B,D}.
--              All outputs are gated by 'enable' (= NOT done).
--
--   Q[2:1:0] | Move
--   ---------+-----
--    00x      |  F   (000 or 001)
--    010      |  R
--    011      |  U
--    100      |  L
--    101      |  B
--    11x      |  D   (110 or 111)
-- ==============================================================================

entity MoveDecoder is
    Port (
        Q2, Q1, Q0 : in  std_logic;
        enable     : in  std_logic;
        F, R, U, L, B, D : out std_logic
    );
end MoveDecoder;

architecture gate_level of MoveDecoder is
    signal nQ2, nQ1, nQ0 : std_logic;
begin
    nQ2 <= not Q2;
    nQ1 <= not Q1;
    nQ0 <= not Q0;

    F <= nQ2 and nQ1          and enable;  -- 000, 001
    R <= nQ2 and Q1  and nQ0  and enable;  -- 010
    U <= nQ2 and Q1  and Q0   and enable;  -- 011
    L <= Q2  and nQ1 and nQ0  and enable;  -- 100
    B <= Q2  and nQ1 and Q0   and enable;  -- 101
    D <= Q2  and Q1           and enable;  -- 110, 111
end gate_level;
