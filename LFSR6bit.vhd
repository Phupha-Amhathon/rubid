library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ==============================================================================
-- Module: LFSR6bit
-- Description: 6-bit Fibonacci LFSR, polynomial x^6 + x + 1 (period 63).
--              Seed "101010" loaded synchronously on RESET (falling-edge DFF).
--              Feedback tap: Q(5) XOR Q(0).
-- ==============================================================================

entity LFSR6bit is
    Port (
        Clk   : in  std_logic;
        RESET : in  std_logic;
        Q     : out std_logic_vector(5 downto 0)
    );
end LFSR6bit;

architecture structural of LFSR6bit is
    component DFlipFlop is
        Port ( D, Clk, Pre, Clr : in std_logic; Q, nQ : out std_logic );
    end component;

    signal q5, q4, q3, q2, q1, q0 : std_logic;
    signal fb : std_logic;
begin
    -- Feedback: polynomial x^6 + x + 1 => taps at Q(5) and Q(0)
    fb <= q5 xor q0;

    -- Seed "101010": bits 5,3,1 = '1' (Pre=RESET), bits 4,2,0 = '0' (Clr=RESET)
    FF5: DFlipFlop port map(D => q4, Clk => Clk, Q => q5, nQ => open, Pre => RESET, Clr => '0');
    FF4: DFlipFlop port map(D => q3, Clk => Clk, Q => q4, nQ => open, Pre => '0',   Clr => RESET);
    FF3: DFlipFlop port map(D => q2, Clk => Clk, Q => q3, nQ => open, Pre => RESET, Clr => '0');
    FF2: DFlipFlop port map(D => q1, Clk => Clk, Q => q2, nQ => open, Pre => '0',   Clr => RESET);
    FF1: DFlipFlop port map(D => q0, Clk => Clk, Q => q1, nQ => open, Pre => RESET, Clr => '0');
    FF0: DFlipFlop port map(D => fb, Clk => Clk, Q => q0, nQ => open, Pre => '0',   Clr => RESET);

    Q <= q5 & q4 & q3 & q2 & q1 & q0;
end structural;
