----------------------------------------------------------------------------------
-- Company: Khon Kaen University
-- Engineer: Phupha Amhathon
--
-- Create Date: 03/09/2026
-- Design Name: 5-bit synchronous up counter
-- Module Name: Counter5bit - gate_level
-- Project Name: rubid
-- Target Devices: Nexys A7 100T
-- Description:
--   5-bit synchronous binary up counter built from DFlipFlop primitives and
--   combinational (AND/OR/NOT/XOR) gate logic.
--
--   The counter starts at 0 after RESET and increments by 1 on every falling
--   clock edge until it reaches 20 (binary 10100), at which point the `done`
--   output is asserted and the counter freezes.  This gives exactly 20 active
--   clock periods (counts 0 .. 19) during which the random moves are valid.
--
--   Gate-level carry chain:
--     D(0) = Q(0) XOR enable
--     D(1) = Q(1) XOR (Q(0) AND enable)
--     D(2) = Q(2) XOR (Q(1) AND Q(0) AND enable)
--     D(3) = Q(3) XOR (Q(2) AND Q(1) AND Q(0) AND enable)
--     D(4) = Q(4) XOR (Q(3) AND Q(2) AND Q(1) AND Q(0) AND enable)
--
--   done   = Q(4) AND NOT Q(3) AND Q(2) AND NOT Q(1) AND NOT Q(0)  -- count=20
--   enable = NOT done
--
-- Dependencies: DFlipFlop
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Counter5bit is
    Port (
        Clk   : in  std_logic;
        RESET : in  std_logic;
        done  : out std_logic
    );
end Counter5bit;

architecture gate_level of Counter5bit is

    component DFlipFlop is
        Port (
            D        : in  std_logic;
            Clk      : in  std_logic;
            Q        : out std_logic;
            nQ       : out std_logic;
            Pre, Clr : in  std_logic
        );
    end component;

    signal sQ     : std_logic_vector(4 downto 0);
    signal sDone  : std_logic;
    signal enable : std_logic;

    -- Carry chain signals
    signal c1, c2, c3, c4 : std_logic;

    -- D-input signals
    signal d0, d1, d2, d3, d4 : std_logic;

    -- Inverted Q bits (for done detection)
    signal nQ3, nQ1, nQ0 : std_logic;

begin

    -- -----------------------------------------------------------------------
    -- done detection: count = 20 = 10100 binary
    --   Q4=1, Q3=0, Q2=1, Q1=0, Q0=0
    -- -----------------------------------------------------------------------
    nQ3   <= not sQ(3);
    nQ1   <= not sQ(1);
    nQ0   <= not sQ(0);
    sDone <= sQ(4) and nQ3 and sQ(2) and nQ1 and nQ0;
    done  <= sDone;

    -- enable = NOT done  (counter halts once all 20 moves have been issued)
    enable <= not sDone;

    -- -----------------------------------------------------------------------
    -- Carry chain (gate level)
    -- -----------------------------------------------------------------------
    c1 <= sQ(0) and enable;
    c2 <= sQ(1) and c1;
    c3 <= sQ(2) and c2;
    c4 <= sQ(3) and c3;

    -- -----------------------------------------------------------------------
    -- Next-state logic  D(i) = Q(i) XOR T(i), where T(i) is the toggle term
    -- -----------------------------------------------------------------------
    d0 <= sQ(0) xor enable;
    d1 <= sQ(1) xor c1;
    d2 <= sQ(2) xor c2;
    d3 <= sQ(3) xor c3;
    d4 <= sQ(4) xor c4;

    -- -----------------------------------------------------------------------
    -- Flip-flops: all cleared to 0 on RESET
    -- -----------------------------------------------------------------------
    B4: DFlipFlop port map(
        D => d4, Clk => Clk, Q => sQ(4), nQ => open,
        Pre => '0', Clr => RESET
    );
    B3: DFlipFlop port map(
        D => d3, Clk => Clk, Q => sQ(3), nQ => open,
        Pre => '0', Clr => RESET
    );
    B2: DFlipFlop port map(
        D => d2, Clk => Clk, Q => sQ(2), nQ => open,
        Pre => '0', Clr => RESET
    );
    B1: DFlipFlop port map(
        D => d1, Clk => Clk, Q => sQ(1), nQ => open,
        Pre => '0', Clr => RESET
    );
    B0: DFlipFlop port map(
        D => d0, Clk => Clk, Q => sQ(0), nQ => open,
        Pre => '0', Clr => RESET
    );

end gate_level;
