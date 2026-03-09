----------------------------------------------------------------------------------
-- Company: Khon Kaen University
-- Engineer: Phupha Amhathon
--
-- Create Date: 03/09/2026
-- Design Name: 6-bit Fibonacci LFSR
-- Module Name: LFSR6bit - structural
-- Project Name: rubid
-- Target Devices: Nexys A7 100T
-- Description:
--   6-bit maximal-length Fibonacci LFSR using polynomial x^6 + x + 1.
--   Feedback bit = Q(5) XOR Q(0), giving a period of 63 (all non-zero states).
--   On RESET the register is loaded with seed "101010" (bit5=1, bit3=1, bit1=1)
--   using the synchronous Pre/Clr inputs of each DFlipFlop so the LFSR is never
--   in the all-zero lock-up state.
--
-- Dependencies: DFlipFlop
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity LFSR6bit is
    Port (
        Clk   : in  std_logic;
        RESET : in  std_logic;
        Q     : out std_logic_vector(5 downto 0)
    );
end LFSR6bit;

architecture structural of LFSR6bit is

    component DFlipFlop is
        Port (
            D        : in  std_logic;
            Clk      : in  std_logic;
            Q        : out std_logic;
            nQ       : out std_logic;
            Pre, Clr : in  std_logic
        );
    end component;

    -- Internal state register
    signal sQ       : std_logic_vector(5 downto 0);
    -- Feedback: XOR of bit-5 and bit-0  (polynomial x^6 + x + 1)
    signal feedback : std_logic;

begin
    -- XOR gate: a single combinational gate
    feedback <= sQ(5) xor sQ(0);

    -- Shift register: each flip-flop shifts its neighbour's output.
    -- Seed on RESET = "101010":
    --   bit5 = 1 (Pre=RESET), bit4 = 0 (Clr=RESET)
    --   bit3 = 1 (Pre=RESET), bit2 = 0 (Clr=RESET)
    --   bit1 = 1 (Pre=RESET), bit0 = 0 (Clr=RESET)
    FF5: DFlipFlop port map(
        D => sQ(4), Clk => Clk, Q => sQ(5), nQ => open,
        Pre => RESET, Clr => '0'
    );
    FF4: DFlipFlop port map(
        D => sQ(3), Clk => Clk, Q => sQ(4), nQ => open,
        Pre => '0', Clr => RESET
    );
    FF3: DFlipFlop port map(
        D => sQ(2), Clk => Clk, Q => sQ(3), nQ => open,
        Pre => RESET, Clr => '0'
    );
    FF2: DFlipFlop port map(
        D => sQ(1), Clk => Clk, Q => sQ(2), nQ => open,
        Pre => '0', Clr => RESET
    );
    FF1: DFlipFlop port map(
        D => sQ(0), Clk => Clk, Q => sQ(1), nQ => open,
        Pre => RESET, Clr => '0'
    );
    FF0: DFlipFlop port map(
        D => feedback, Clk => Clk, Q => sQ(0), nQ => open,
        Pre => '0', Clr => RESET
    );

    Q <= sQ;

end structural;
