library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ==============================================================================
-- Module: RubidRand (Top Level Scrambler)
-- Description: Integrates the LFSR-based Random Move Generator and the
--              Rubik's Cube Memory Core to produce a 20-move pseudo-random
--              scramble on each RESET pulse.
-- ==============================================================================

entity RubidRand is
    Port (
        Clk   : in  std_logic;
        RESET : in  std_logic;       -- Scramble trigger button
        done  : out std_logic;       -- Scramble finished indicator
        Q_all : out std_logic_vector(71 downto 0)
    );
end RubidRand;

architecture structural of RubidRand is

    -- 1. COMPONENT: Pseudo-Random Move Generator (LFSR + Counter + Decoder)
    component RandMoveGen is
        Port (
            Clk, RESET       : in  std_logic;
            F, R, U, L, B, D : out std_logic;
            Done             : out std_logic
        );
    end component;

    -- 2. COMPONENT: The Rubik's Cube Core (Mark 1)
    component RubidMark1 is
        Port (
            RESET, F, R, U, L, B, D : in std_logic;
            Q   : out std_logic_vector(71 downto 0);
            Clk : in std_logic
        );
    end component;

    -- Internal Logic Wires
    signal sF, sR, sU, sL, sB, sD : std_logic;
    signal sDone  : std_logic;
    signal sQ_all : std_logic_vector(71 downto 0);

    -- Attributes for Vivado ILA Debugging
    attribute mark_debug : string;
    attribute mark_debug of sQ_all : signal is "true";

begin

    -- Instance A: The Random Move Generator (LFSR-based)
    RAND_GEN: RandMoveGen port map(
        Clk   => Clk,
        RESET => RESET,
        F => sF, R => sR, U => sU,
        L => sL, B => sB, D => sD,
        Done  => sDone
    );

    -- Instance B: The Physical Memory (The Cube itself)
    CUBE: RubidMark1 port map(
        RESET => RESET,
        F => sF, R => sR, U => sU,
        L => sL, B => sB, D => sD,
        Q   => sQ_all,
        Clk => Clk
    );

    -- Output Connections
    Q_all <= sQ_all;
    done  <= sDone;

end structural;