library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ==============================================================================
-- Module: RubidRand (Top Level Scrambler)
-- Description: Connects RandMoveGen (LFSR + Counter + Decoder) to RubidMark1.
--              Applies exactly 20 pseudo-random moves starting from the solved
--              state, then asserts done='1'.
-- ==============================================================================

entity RubidRand is
    Port (
        Clk   : in  std_logic;
        RESET : in  std_logic;        -- Center Button (BTNC)
        done  : out std_logic;        -- Scramble Finished LED
        Q_all : out std_logic_vector(71 downto 0)
    );
end RubidRand;

architecture structural of RubidRand is

    -- 1. COMPONENT: Pseudo-random 20-move generator
    component RandMoveGen is
        Port (
            Clk, RESET       : in  std_logic;
            F, R, U, L, B, D : out std_logic;
            done             : out std_logic
        );
    end component;

    -- 2. COMPONENT: The Rubik's Cube Core (Mark 1)
    component RubidMark1 is
        Port (
            RESET, F, R, U, L, B, D : in  std_logic;
            Q                       : out std_logic_vector(71 downto 0);
            Clk                     : in  std_logic
        );
    end component;

    -- Internal wires
    signal sF, sR, sU, sL, sB, sD : std_logic;
    signal sDone                   : std_logic;

    -- Attributes for Vivado ILA Debugging (Optional but recommended)
    attribute mark_debug : string;
    attribute mark_debug of sDone : signal is "true";

begin

    -- Instance A: The random move sequencer
    GEN: RandMoveGen port map(
        Clk   => Clk,
        RESET => RESET,
        F => sF, R => sR, U => sU,
        L => sL, B => sB, D => sD,
        done  => sDone
    );

    -- Instance B: The Rubik's Cube memory core
    CUBE: RubidMark1 port map(
        RESET => RESET,
        F => sF, R => sR, U => sU,
        L => sL, B => sB, D => sD,
        Q   => Q_all,
        Clk => Clk
    );

    done <= sDone;

end structural;