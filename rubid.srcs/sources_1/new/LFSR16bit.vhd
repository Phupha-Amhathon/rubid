library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LFSR16bit is
    Port (
        Clk   : in  std_logic;
        RESET : in  std_logic;
        Seed  : in  std_logic_vector(15 downto 0);
        Q     : out std_logic_vector(15 downto 0)
    );
end LFSR16bit;

architecture structural of LFSR16bit is
    component DFlipFlop is
        Port (
            D, Clk, Pre, Clr : in std_logic;
            Q, nQ : out std_logic
        );
    end component;

    signal sQ : std_logic_vector(15 downto 0);
    signal feedback : std_logic;
    signal p, c : std_logic_vector(15 downto 0);
begin
    -- 16-bit Fibonacci Taps: 16, 15, 13, 4
    feedback <= sQ(15) xor sQ(14) xor sQ(12) xor sQ(3);

    -- Generate Pre/Clr logic for all 16 bits
    gen_bits: for i in 0 to 15 generate
        p(i) <= RESET and Seed(i);
        c(i) <= RESET and (not Seed(i));
        
        -- The first Flip-Flop gets the feedback
        bit0: if i = 0 generate
            FF0: DFlipFlop port map(D => feedback, Clk => Clk, Q => sQ(0), nQ => open, Pre => p(0), Clr => c(0));
        end generate;
        
        -- Every other Flip-Flop gets the previous Q (Shift Register)
        bitN: if i > 0 generate
            FFN: DFlipFlop port map(D => sQ(i-1), Clk => Clk, Q => sQ(i), nQ => open, Pre => p(i), Clr => c(i));
        end generate;
    end generate;

    Q <= sQ;
end structural;