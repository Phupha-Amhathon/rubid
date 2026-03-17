library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 5-bit synchronous up counter built from DFlipFlops and carry-chain gate logic.
-- Counts 0 -> 20, then asserts done='1' and holds.
-- RESET='1' clears all bits to 0 synchronously on the falling clock edge
-- (DFlipFlop uses synchronous Clr triggered on falling_edge).
--
-- done = Q(4) AND NOT Q(3) AND Q(2) AND NOT Q(1) AND NOT Q(0)  -- count = 20 = "10100"
-- enable = NOT done

entity Counter5bit is
    Port (
        Clk, RESET : in  std_logic;
        done       : out std_logic
    );
end Counter5bit;

architecture structural of Counter5bit is
    component DFlipFlop is
        Port ( D, Clk, Pre, Clr : in std_logic; Q, nQ : out std_logic );
    end component;

    signal sQ                   : std_logic_vector(4 downto 0);
    signal sDone, enable        : std_logic;
    signal c0, c1, c2, c3      : std_logic;  -- carry chain
    signal d0, d1, d2, d3, d4  : std_logic;  -- D inputs
    signal nQ3, nQ1, nQ0       : std_logic;
begin
    -- done logic (count = 20 = "10100")
    nQ3   <= not sQ(3);
    nQ1   <= not sQ(1);
    nQ0   <= not sQ(0);
    sDone <= sQ(4) and nQ3 and sQ(2) and nQ1 and nQ0;
    enable <= not sDone;

    -- Carry chain (synchronous up counter)
    c0 <= sQ(0) and enable;
    c1 <= c0    and sQ(1);
    c2 <= c1    and sQ(2);
    c3 <= c2    and sQ(3);

    -- Next-state logic
    d0 <= sQ(0) xor enable;
    d1 <= sQ(1) xor c0;
    d2 <= sQ(2) xor c1;
    d3 <= sQ(3) xor c2;
    d4 <= sQ(4) xor c3;

    -- Flip-flops: RESET clears all bits to 0
    FF0: DFlipFlop port map(D => d0, Clk => Clk, Pre => '0', Clr => RESET, Q => sQ(0), nQ => open);
    FF1: DFlipFlop port map(D => d1, Clk => Clk, Pre => '0', Clr => RESET, Q => sQ(1), nQ => open);
    FF2: DFlipFlop port map(D => d2, Clk => Clk, Pre => '0', Clr => RESET, Q => sQ(2), nQ => open);
    FF3: DFlipFlop port map(D => d3, Clk => Clk, Pre => '0', Clr => RESET, Q => sQ(3), nQ => open);
    FF4: DFlipFlop port map(D => d4, Clk => Clk, Pre => '0', Clr => RESET, Q => sQ(4), nQ => open);

    done <= sDone;
end structural;
