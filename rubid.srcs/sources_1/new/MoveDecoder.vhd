----------------------------------------------------------------------------------
-- Company: Khon Kaen University
-- Engineer: Phupha Amhathon
--
-- Create Date: 03/09/2026
-- Design Name: 3-bit to one-hot move decoder
-- Module Name: MoveDecoder - gate_level
-- Project Name: rubid
-- Target Devices: Nexys A7 100T
-- Description:
--   Purely combinational, gate-level decoder.
--   Maps the lower 3 bits of the LFSR output to one of the six Rubik's Cube
--   moves { F, R, U, L, B, D }, outputs as one-hot signals.
--
--   Mapping (rand_in = LFSR Q[2:0]):
--     000 → F  (remapped; avoids the all-zero "no-move" state)
--     001 → F
--     010 → R
--     011 → U
--     100 → L
--     101 → B
--     110 → D
--     111 → D  (remapped; avoids the all-one collision with RESET code)
--
--   Simplified boolean equations:
--     F = NOT(2) AND NOT(1)       -- covers 000 and 001
--     R = NOT(2) AND    (1) AND NOT(0)
--     U = NOT(2) AND    (1) AND    (0)
--     L =    (2) AND NOT(1) AND NOT(0)
--     B =    (2) AND NOT(1) AND    (0)
--     D =    (2) AND    (1)        -- covers 110 and 111
--
--   All outputs are ANDed with the `enable` input (= NOT done) so that after
--   the 20th move every output is driven low.
--
-- Dependencies: none
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MoveDecoder is
    Port (
        rand_in : in  std_logic_vector(2 downto 0);
        enable  : in  std_logic;
        F, R, U, L, B, D : out std_logic
    );
end MoveDecoder;

architecture gate_level of MoveDecoder is

    signal n0, n1, n2 : std_logic;

    signal F_raw, R_raw, U_raw, L_raw, B_raw, D_raw : std_logic;

begin

    -- Invert each input bit
    n0 <= not rand_in(0);
    n1 <= not rand_in(1);
    n2 <= not rand_in(2);

    -- Decode: gate-level AND/OR/NOT
    F_raw <= n2 and n1;                            -- 000, 001
    R_raw <= n2 and rand_in(1) and n0;             -- 010
    U_raw <= n2 and rand_in(1) and rand_in(0);     -- 011
    L_raw <= rand_in(2) and n1 and n0;             -- 100
    B_raw <= rand_in(2) and n1 and rand_in(0);     -- 101
    D_raw <= rand_in(2) and rand_in(1);            -- 110, 111

    -- Gate all outputs with enable (= NOT done)
    F <= F_raw and enable;
    R <= R_raw and enable;
    U <= U_raw and enable;
    L <= L_raw and enable;
    B <= B_raw and enable;
    D <= D_raw and enable;

end gate_level;
