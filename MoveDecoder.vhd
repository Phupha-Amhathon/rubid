library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Combinational gate-level decoder.
-- Maps the lower 3 bits of the LFSR to exactly one of {F, R, U, L, B, D}.
-- All outputs are ANDed with enable (= NOT done).
--
-- Q[2:0] | Move
-- -------+------
--   000  | F  (000 and 001 both map to F so that all 6 moves share the 8
--   001  | F   available codes as evenly as possible: F and D each cover 2)
--   010  | R
--   011  | U
--   100  | L
--   101  | B
--   110  | D  (110 and 111 both map to D for the same reason)
--   111  | D

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

    F <= (nQ2 and nQ1)          and enable;  -- 000 or 001
    R <= (nQ2 and Q1  and nQ0)  and enable;  -- 010
    U <= (nQ2 and Q1  and Q0)   and enable;  -- 011
    L <= (Q2  and nQ1 and nQ0)  and enable;  -- 100
    B <= (Q2  and nQ1 and Q0)   and enable;  -- 101
    D <= (Q2  and Q1)           and enable;  -- 110 or 111
end gate_level;
