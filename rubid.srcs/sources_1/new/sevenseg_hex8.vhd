----------------------------------------------------------------------------------
-- Company: Computer Engineering @Khon Kaen University
-- Engineer: Puwadon Puchamni
-- 
-- Create Date: 03/20/2026 12:06:44 AM
-- Design Name: 
-- Module Name: TempTop - Behavioral
-- Project Name: Copter_Scramble_Rubik
-- Target Devices: nexys A7 100t
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 8-Digit Seven-Segment Display Controller
-- Supports Hex/BCD display and configurable Decimal Point
entity sevenseg_hex8 is
    Port (
        clk    : in  STD_LOGIC;                    -- 100 MHz System Clock
        value  : in  STD_LOGIC_VECTOR(31 downto 0); -- 32-bit value (8 BCD digits)
        
        -- Segment outputs (Active Low)
        CA, CB, CC, CD, CE, CF, CG : out STD_LOGIC;
        DP     : out STD_LOGIC;                    -- Decimal Point
        AN     : out STD_LOGIC_VECTOR(7 downto 0)   -- Digit Selectors (Active Low)
    );
end sevenseg_hex8;

architecture Behavioral of sevenseg_hex8 is
    -- Clock divider for ~1 kHz refresh rate
    constant DIV_MAX    : integer := 100_000;
    signal div_cnt      : integer range 0 to DIV_MAX := 0;
    signal refresh_clk  : STD_LOGIC := '0';

    -- Multiplexing signals
    signal digit_idx      : unsigned(2 downto 0) := "000";
    signal current_nibble : STD_LOGIC_VECTOR(3 downto 0);
    signal seg_bits       : STD_LOGIC_VECTOR(6 downto 0); 

begin
    -- Generate refresh clock for switching digits
    process(clk)
    begin
        if rising_edge(clk) then
            if div_cnt = DIV_MAX - 1 then
                div_cnt <= 0;
                refresh_clk <= not refresh_clk;
            else
                div_cnt <= div_cnt + 1;
            end if;
        end if;
    end process;

    -- Increment digit index on every refresh clock pulse
    process(refresh_clk)
    begin
        if rising_edge(refresh_clk) then
            digit_idx <= digit_idx + 1;
        end if;
    end process;

    -- Multiplexer: Select which BCD digit to show and handle Decimal Point
    process(digit_idx, value)
    begin
        AN <= "11111111"; -- Default: All digits OFF
        current_nibble <= x"0";
        DP <= '1';        -- Default: Decimal Point OFF (Active Low)

        case digit_idx is
            when "000" => -- Rightmost digit (4th decimal place)
                AN <= "11111110";
                current_nibble <= value(3 downto 0);
            when "001" => -- 3rd decimal place
                AN <= "11111101";
                current_nibble <= value(7 downto 4);
            when "010" => -- 2nd decimal place
                AN <= "11111011";
                current_nibble <= value(11 downto 8);
            when "011" => -- 1st decimal place
                AN <= "11110111";
                current_nibble <= value(15 downto 12);
            when "100" => -- Units digit (with Decimal Point!)
                AN <= "11101111";
                current_nibble <= value(19 downto 16);
                DP <= '0'; -- Turn ON decimal point (Active Low)
            when "101" => -- Tens digit
                AN <= "11011111";
                current_nibble <= value(23 downto 20);
            when others =>
                AN <= "11111111"; -- Other digits off
                current_nibble <= x"0";
        end case;
    end process;

    -- Hex/BCD to 7-Segment Decoder (Active Low)
    process(current_nibble)
    begin
        case current_nibble is
            -- Segments: (g, f, e, d, c, b, a)
            when x"0" => seg_bits <= "1000000";
            when x"1" => seg_bits <= "1111001";
            when x"2" => seg_bits <= "0100100";
            when x"3" => seg_bits <= "0110000";
            when x"4" => seg_bits <= "0011001";
            when x"5" => seg_bits <= "0010010";
            when x"6" => seg_bits <= "0000010";
            when x"7" => seg_bits <= "1111000";
            when x"8" => seg_bits <= "0000000";
            when x"9" => seg_bits <= "0010000";
            when others => seg_bits <= "1111111";
        end case;
    end process;

    -- Map internal segment bits to output ports
    CA <= seg_bits(0); CB <= seg_bits(1); CC <= seg_bits(2);
    CD <= seg_bits(3); CE <= seg_bits(4); CF <= seg_bits(5);
    CG <= seg_bits(6);

end Behavioral;