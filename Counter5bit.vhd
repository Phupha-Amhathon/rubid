library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ==============================================================================
-- Module: Counter5bit
-- Description: 5-bit synchronous up-counter built from DFlipFlops and an
--              AND/XOR carry chain.  Counts 0 -> 20 (binary "10100"), then
--              asserts 'done' and freezes (enable = NOT done).
--              All flip-flops reset to '0' synchronously on RESET.
-- ==============================================================================

entity Counter5bit is
    Port (
        Clk   : in  std_logic;
        RESET : in  std_logic;
        done  : out std_logic
    );
end Counter5bit;

architecture structural of Counter5bit is
    component DFlipFlop is
        Port ( D, Clk, Pre, Clr : in std_logic; Q, nQ : out std_logic );
    end component;

    signal c4, c3, c2, c1, c0   : std_logic;
    signal carry0, carry1, carry2, carry3 : std_logic;
    signal n_c3, n_c1, n_c0     : std_logic;
    signal s_done, en            : std_logic;
    signal c0_D, c1_D, c2_D, c3_D, c4_D : std_logic;
begin
    -- done = count equals 20 = "10100"
    n_c3   <= not c3;
    n_c1   <= not c1;
    n_c0   <= not c0;
    s_done <= c4 and n_c3 and c2 and n_c1 and n_c0;
    done   <= s_done;

    -- Counter enabled while not done
    en <= not s_done;

    -- Carry chain (ripple-carry adder structure)
    carry0 <= c0 and en;
    carry1 <= c1 and carry0;
    carry2 <= c2 and carry1;
    carry3 <= c3 and carry2;

    -- Next-state XOR logic
    c0_D <= c0 xor en;
    c1_D <= c1 xor carry0;
    c2_D <= c2 xor carry1;
    c3_D <= c3 xor carry2;
    c4_D <= c4 xor carry3;

    -- All bits reset to '0' (Pre='0', Clr=RESET)
    FF0: DFlipFlop port map(D => c0_D, Clk => Clk, Q => c0, nQ => open, Pre => '0', Clr => RESET);
    FF1: DFlipFlop port map(D => c1_D, Clk => Clk, Q => c1, nQ => open, Pre => '0', Clr => RESET);
    FF2: DFlipFlop port map(D => c2_D, Clk => Clk, Q => c2, nQ => open, Pre => '0', Clr => RESET);
    FF3: DFlipFlop port map(D => c3_D, Clk => Clk, Q => c3, nQ => open, Pre => '0', Clr => RESET);
    FF4: DFlipFlop port map(D => c4_D, Clk => Clk, Q => c4, nQ => open, Pre => '0', Clr => RESET);
end structural;
