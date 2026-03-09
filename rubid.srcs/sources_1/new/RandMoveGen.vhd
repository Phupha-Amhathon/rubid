----------------------------------------------------------------------------------
-- Company: Khon Kaen University
-- Engineer: Phupha Amhathon
--
-- Create Date: 03/09/2026
-- Design Name: Randomized 20-move generator
-- Module Name: RandMoveGen - structural
-- Project Name: rubid
-- Target Devices: Nexys A7 100T
-- Description:
--   Gate-level pseudo-random Rubik's Cube move sequencer.
--
--   Architecture overview:
--
--     LFSR6bit  ─── Q[2:0] ──► MoveDecoder ─── F,R,U,L,B,D ──► (outputs)
--                                    ▲
--     Counter5bit ─── done ──► enable (NOT done)
--
--   Operation:
--     1. Assert RESET for at least one full clock period.
--        - LFSR is loaded with seed "101010" (never all-zero).
--        - Counter is cleared to 0.
--     2. After RESET deasserts, on every falling clock edge:
--        a. The LFSR advances one step (new pseudo-random 6-bit value).
--        b. The counter increments.
--        c. MoveDecoder converts LFSR[2:0] → one active move signal.
--     3. After 20 falling edges, the counter reaches 20 (binary 10100),
--        `done` is asserted, and all move outputs are driven low.
--
--   The resulting 20-move sequence (for seed 101010) is:
--     R, B, U, D, L, F, U, D, B, U, D, D, B, U, D, B, R, L, F, R
--
-- Dependencies: LFSR6bit, Counter5bit, MoveDecoder
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RandMoveGen is
    Port (
        Clk   : in  std_logic;
        RESET : in  std_logic;
        F, R, U, L, B, D : out std_logic;
        done  : out std_logic
    );
end RandMoveGen;

architecture structural of RandMoveGen is

    component LFSR6bit is
        Port (
            Clk   : in  std_logic;
            RESET : in  std_logic;
            Q     : out std_logic_vector(5 downto 0)
        );
    end component;

    component Counter5bit is
        Port (
            Clk   : in  std_logic;
            RESET : in  std_logic;
            done  : out std_logic
        );
    end component;

    component MoveDecoder is
        Port (
            rand_in : in  std_logic_vector(2 downto 0);
            enable  : in  std_logic;
            F, R, U, L, B, D : out std_logic
        );
    end component;

    signal sLFSR   : std_logic_vector(5 downto 0);
    signal sDone   : std_logic;
    signal sEnable : std_logic;

begin

    LFSR: LFSR6bit port map(
        Clk   => Clk,
        RESET => RESET,
        Q     => sLFSR
    );

    CNT: Counter5bit port map(
        Clk   => Clk,
        RESET => RESET,
        done  => sDone
    );

    -- enable = NOT done  (one AND-gate equivalent)
    sEnable <= not sDone;
    done    <= sDone;

    DEC: MoveDecoder port map(
        rand_in => sLFSR(2 downto 0),
        enable  => sEnable,
        F => F, R => R, U => U, L => L, B => B, D => D
    );

end structural;
