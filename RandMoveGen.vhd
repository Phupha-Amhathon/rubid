library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Structural top-level: wires LFSR6bit + Counter5bit + MoveDecoder.
-- Generates exactly 20 pseudo-random Rubik's Cube moves, then asserts done='1'.

entity RandMoveGen is
    Port (
        Clk, RESET       : in  std_logic;
        F, R, U, L, B, D : out std_logic;
        done             : out std_logic
    );
end RandMoveGen;

architecture structural of RandMoveGen is
    component LFSR6bit is
        Port (
            Clk, RESET : in  std_logic;
            Q          : out std_logic_vector(5 downto 0)
        );
    end component;

    component Counter5bit is
        Port (
            Clk, RESET : in  std_logic;
            done       : out std_logic
        );
    end component;

    component MoveDecoder is
        Port (
            Q2, Q1, Q0       : in  std_logic;
            enable           : in  std_logic;
            F, R, U, L, B, D : out std_logic
        );
    end component;

    signal sQ      : std_logic_vector(5 downto 0);
    signal sDone   : std_logic;
    signal sEnable : std_logic;
begin
    sEnable <= not sDone;

    LFSR: LFSR6bit port map(
        Clk   => Clk,
        RESET => RESET,
        Q     => sQ
    );

    CNT: Counter5bit port map(
        Clk   => Clk,
        RESET => RESET,
        done  => sDone
    );

    DEC: MoveDecoder port map(
        Q2     => sQ(2),
        Q1     => sQ(1),
        Q0     => sQ(0),
        enable => sEnable,
        F => F, R => R, U => U,
        L => L, B => B, D => D
    );

    done <= sDone;
end structural;
