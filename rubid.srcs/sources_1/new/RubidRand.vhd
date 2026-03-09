----------------------------------------------------------------------------------
-- Company: Khon Kaen University
-- Engineer: Phupha Amhathon
--
-- Create Date: 03/09/2026
-- Design Name: Rubik's Cube auto-scrambler
-- Module Name: RubidRand - structural
-- Project Name: rubid
-- Target Devices: Nexys A7 100T
-- Description:
--   Top-level module that connects the gate-level random move generator
--   (RandMoveGen) to the existing Rubik's Cube simulator (RubidMark1).
--
--   On RESET the cube is initialised to the solved state and the LFSR is
--   seeded.  After RESET deasserts, 20 pseudo-random moves (F/R/U/L/B/D)
--   are applied one per falling clock edge and the cube state Q[71:0] is
--   updated accordingly.  The `done` output goes high after all 20 moves.
--
-- Dependencies: RandMoveGen, RubidMark1
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RubidRand is
    Port (
        Clk   : in  std_logic;
        RESET : in  std_logic;
        Q     : out std_logic_vector(71 downto 0);
        done  : out std_logic
    );
end RubidRand;

architecture structural of RubidRand is

    component RandMoveGen is
        Port (
            Clk   : in  std_logic;
            RESET : in  std_logic;
            F, R, U, L, B, D : out std_logic;
            done  : out std_logic
        );
    end component;

    component RubidMark1 is
        Port (
            RESET : in  std_logic;
            F     : in  std_logic;
            R     : in  std_logic;
            U     : in  std_logic;
            L     : in  std_logic;
            B     : in  std_logic;
            D     : in  std_logic;
            Q     : out std_logic_vector(71 downto 0);
            Clk   : in  std_logic
        );
    end component;

    signal sF, sR, sU, sL, sB, sD : std_logic;
    signal sDone : std_logic;

begin

    GEN: RandMoveGen port map(
        Clk   => Clk,
        RESET => RESET,
        F     => sF,
        R     => sR,
        U     => sU,
        L     => sL,
        B     => sB,
        D     => sD,
        done  => sDone
    );

    CUBE: RubidMark1 port map(
        RESET => RESET,
        F     => sF,
        R     => sR,
        U     => sU,
        L     => sL,
        B     => sB,
        D     => sD,
        Q     => Q,
        Clk   => Clk
    );

    done <= sDone;

end structural;
