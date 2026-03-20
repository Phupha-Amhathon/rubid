library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seg7_display is
    Port (
        clk      : in  STD_LOGIC;
        data_in  : in  STD_LOGIC_VECTOR(15 downto 0);  -- your signal here
        seg      : out STD_LOGIC_VECTOR(6 downto 0);
        dp       : out STD_LOGIC;
        an       : out STD_LOGIC_VECTOR(7 downto 0)
    );
end seg7_display;

architecture Behavioral of seg7_display is

    signal clk_cnt  : INTEGER range 0 to 49999 := 0;
    signal clk_1khz : STD_LOGIC := '0';
    signal sel      : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal nibble   : STD_LOGIC_VECTOR(3 downto 0);

    function to_seg7(n : STD_LOGIC_VECTOR(3 downto 0))
        return STD_LOGIC_VECTOR is
    begin
        case n is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when "1010" => return "0001000"; -- A
            when "1011" => return "0000011"; -- b
            when "1100" => return "1000110"; -- C
            when "1101" => return "0100001"; -- d
            when "1110" => return "0000110"; -- E
            when "1111" => return "0001110"; -- F
            when others => return "1111111";
        end case;
    end function;

begin

    -- Clock divider
    process(clk)
    begin
        if rising_edge(clk) then
            if clk_cnt = 49999 then
                clk_cnt  <= 0;
                clk_1khz <= not clk_1khz;
            else
                clk_cnt <= clk_cnt + 1;
            end if;
        end if;
    end process;

    -- Digit selector
    process(clk_1khz)
    begin
        if rising_edge(clk_1khz) then
            sel <= STD_LOGIC_VECTOR(unsigned(sel) + 1);
        end if;
    end process;

    -- Mux: pick nibble from data_in
    process(sel, data_in)
    begin
        an <= "11111111";
        case sel is
            when "00" => nibble <= data_in(3  downto 0);  an <= "11111110";
            when "01" => nibble <= data_in(7  downto 4);  an <= "11111101";
            when "10" => nibble <= data_in(11 downto 8);  an <= "11111011";
            when "11" => nibble <= data_in(15 downto 12); an <= "11110111";
            when others => nibble <= "0000";
        end case;
    end process;

    -- Decode
    seg <= to_seg7(nibble);
    dp  <= '1';

end Behavioral;