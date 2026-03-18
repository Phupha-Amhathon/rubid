library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Temp_Display is
    Port ( 
        Clk      : in  std_logic;
        Temp_Raw : in  std_logic_vector(15 downto 0);
        Enable   : in  std_logic;
        SEG      : out std_logic_vector(6 downto 0);
        AN       : out std_logic_vector(7 downto 0);
        DP       : out std_logic
    );
end Temp_Display;

architecture Behavioral of Temp_Display is
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');
    signal active_digit    : integer range 0 to 7 := 0;
    
    signal temp_val        : unsigned(12 downto 0);
    signal temp_mult       : unsigned(22 downto 0);
    signal bcd_data        : unsigned(31 downto 0);
    signal current_nibble  : unsigned(3 downto 0);
    
    -- Binary to Base-10 (BCD) Converter Function
    function to_bcd (bin : unsigned) return unsigned is
        variable bcd : unsigned(31 downto 0) := (others => '0');
        variable temp : unsigned(bin'length-1 downto 0) := bin;
    begin
        for i in 0 to bin'length-1 loop
            for j in 0 to 7 loop
                if bcd(j*4+3 downto j*4) > 4 then
                    bcd(j*4+3 downto j*4) := bcd(j*4+3 downto j*4) + 3;
                end if;
            end loop;
            bcd := bcd(30 downto 0) & temp(temp'left);
            temp := temp(temp'left-1 downto 0) & '0';
        end loop;
        return bcd;
    end function;

begin
    -- Extract the data bits (works perfectly for both 13-bit and 16-bit modes)
    temp_val <= unsigned(Temp_Raw(15 downto 3));
    
    -- Multiply to get 4 decimal places (e.g. 25 C = 25.0000)
    temp_mult <= temp_val * to_unsigned(625, 10);
    bcd_data <= to_bcd(temp_mult);

    -- 1kHz refresh rate for the 7-segment multiplexer
    process(Clk)
    begin
        if rising_edge(Clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;
    
    active_digit <= to_integer(refresh_counter(19 downto 17));

    -- Anode (Digit) Selection logic
    process(active_digit, bcd_data, Enable)
    begin
        if Enable = '0' then
            -- Turn off display entirely when button is not held
            AN <= "11111111"; 
            current_nibble <= "0000";
            DP <= '1';
        else
            -- Turn on specific digit
            AN <= "11111111";
            AN(active_digit) <= '0';
            DP <= '1'; -- Decimal Point is off by default
            
            case active_digit is
                when 0 => current_nibble <= bcd_data(3 downto 0);   -- 0.000X
                when 1 => current_nibble <= bcd_data(7 downto 4);   -- 0.00X0
                when 2 => current_nibble <= bcd_data(11 downto 8);  -- 0.0X00
                when 3 => current_nibble <= bcd_data(15 downto 12); -- 0.X000
                when 4 => 
                    current_nibble <= bcd_data(19 downto 16);       -- X.0000
                    DP <= '0';                                      -- TURN ON DECIMAL POINT
                when 5 => current_nibble <= bcd_data(23 downto 20); -- XX.0000
                when 6 => current_nibble <= "1111";                 -- Blank spacer
                when 7 => current_nibble <= "1110";                 -- The letter 'C'
                when others => current_nibble <= "1111";
            end case;
        end if;
    end process;

    -- Map numbers to the physical LED segments
    process(current_nibble)
    begin
        case current_nibble is
            when "0000" => SEG <= "1000000"; -- 0
            when "0001" => SEG <= "1111001"; -- 1
            when "0010" => SEG <= "0100100"; -- 2
            when "0011" => SEG <= "0110000"; -- 3
            when "0100" => SEG <= "0011001"; -- 4
            when "0101" => SEG <= "0010010"; -- 5
            when "0110" => SEG <= "0000010"; -- 6
            when "0111" => SEG <= "1111000"; -- 7
            when "1000" => SEG <= "0000000"; -- 8
            when "1001" => SEG <= "0010000"; -- 9
            when "1110" => SEG <= "1000110"; -- C
            when "1111" => SEG <= "1111111"; -- Blank
            when others => SEG <= "1111111";
        end case;
    end process;
end Behavioral;