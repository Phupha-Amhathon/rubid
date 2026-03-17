library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 6-bit Fibonacci LFSR
-- Polynomial: x^6 + x + 1  (feedback = Q(5) XOR Q(0), period = 63)
-- Seed on RESET: "101010"  (avoids all-zero lock-up state)
-- Shifts on every falling clock edge (DFlipFlop is triggered on falling_edge).

entity LFSR6bit is
    Port (
        Clk, RESET : in  std_logic;
        Q          : out std_logic_vector(5 downto 0)
    );
end LFSR6bit;

architecture structural of LFSR6bit is
    component DFlipFlop is
        Port ( D, Clk, Pre, Clr : in std_logic; Q, nQ : out std_logic );
    end component;

    signal sQ       : std_logic_vector(5 downto 0);
    signal feedback : std_logic;
begin
    -- Feedback tap: Q(5) XOR Q(0)
    feedback <= sQ(5) xor sQ(0);

    -- Seed "101010": bit 5=1, bit 4=0, bit 3=1, bit 2=0, bit 1=1, bit 0=0
    -- Pre='1' forces Q to '1'; Clr='1' forces Q to '0' (Pre has priority).
    -- When RESET='0': Pre='0', Clr='0' -> normal shift from D.

    -- Q(5) = 1 on reset -> Pre = RESET, Clr = '0'
    FF5: DFlipFlop port map(D => sQ(4),    Clk => Clk, Pre => RESET, Clr => '0',   Q => sQ(5), nQ => open);
    -- Q(4) = 0 on reset -> Pre = '0',   Clr = RESET
    FF4: DFlipFlop port map(D => sQ(3),    Clk => Clk, Pre => '0',   Clr => RESET, Q => sQ(4), nQ => open);
    -- Q(3) = 1 on reset -> Pre = RESET, Clr = '0'
    FF3: DFlipFlop port map(D => sQ(2),    Clk => Clk, Pre => RESET, Clr => '0',   Q => sQ(3), nQ => open);
    -- Q(2) = 0 on reset -> Pre = '0',   Clr = RESET
    FF2: DFlipFlop port map(D => sQ(1),    Clk => Clk, Pre => '0',   Clr => RESET, Q => sQ(2), nQ => open);
    -- Q(1) = 1 on reset -> Pre = RESET, Clr = '0'
    FF1: DFlipFlop port map(D => sQ(0),    Clk => Clk, Pre => RESET, Clr => '0',   Q => sQ(1), nQ => open);
    -- Q(0) = 0 on reset -> Pre = '0',   Clr = RESET
    FF0: DFlipFlop port map(D => feedback, Clk => Clk, Pre => '0',   Clr => RESET, Q => sQ(0), nQ => open);

    Q <= sQ;
end structural;
