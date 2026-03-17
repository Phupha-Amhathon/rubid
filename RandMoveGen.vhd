library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ==============================================================================
-- Module: RandMoveGen (Random Move Generator)
-- Description: Structural top-level that wires together the LFSR6bit,
--              Counter5bit, and MoveDecoder to produce exactly 20 pseudo-random
--              cube moves from {F, R, U, L, B, D} then asserts Done.
--
-- Architecture:
--   LFSR6bit  -> Q[2:0] -> MoveDecoder -> F,R,U,L,B,D
--   Counter5bit -> done -> enable (NOT done) -> MoveDecoder
-- ==============================================================================

entity RandMoveGen is
    Port (
        Clk, RESET       : in  std_logic;
        F, R, U, L, B, D : out std_logic;
        Done             : out std_logic
    );
end RandMoveGen;

architecture structural of RandMoveGen is
    component LFSR6bit is
        Port ( Clk, RESET : in std_logic; Q : out std_logic_vector(5 downto 0) );
    end component;

    component Counter5bit is
        Port ( Clk, RESET : in std_logic; done : out std_logic );
    end component;

    component MoveDecoder is
        Port ( Q2, Q1, Q0, enable : in std_logic; F, R, U, L, B, D : out std_logic );
    end component;

    signal lfsr_q : std_logic_vector(5 downto 0);
    signal s_done : std_logic;
    signal enable : std_logic;
begin
    enable <= not s_done;

    LFSR: LFSR6bit port map(
        Clk => Clk, RESET => RESET,
        Q   => lfsr_q
    );

    CNT: Counter5bit port map(
        Clk   => Clk,
        RESET => RESET,
        done  => s_done
    );

    DEC: MoveDecoder port map(
        Q2     => lfsr_q(2),
        Q1     => lfsr_q(1),
        Q0     => lfsr_q(0),
        enable => enable,
        F => F, R => R, U => U, L => L, B => B, D => D
    );

    Done <= s_done;
end structural;
