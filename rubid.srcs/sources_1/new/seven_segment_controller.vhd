library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_segment_controller is
    Port (
        Clk      : in STD_LOGIC;
        Reset    : in STD_LOGIC;
        Time_In  : in STD_LOGIC_VECTOR(7 downto 0);  -- The 8-bit binary timer (0 to 255)
        
        -- Physical outputs to the Nexys A7 Board (Active Low)
        SEG      : out STD_LOGIC_VECTOR(6 downto 0); -- A, B, C, D, E, F, G
        AN       : out STD_LOGIC_VECTOR(7 downto 0)  -- The 8 digit Anodes
    );
end seven_segment_controller;

architecture Behavioral of seven_segment_controller is
    -- BCD Math Variables
    signal bcd_hun : integer range 0 to 9;
    signal bcd_ten : integer range 0 to 9;
    signal bcd_one : integer range 0 to 9;

    -- Multiplexer Variables
    signal refresh_counter : unsigned(19 downto 0) := (others => '0');
    signal active_digit    : std_logic_vector(2 downto 0);
    signal current_val     : integer range 0 to 9;
    signal seg_out         : std_logic_vector(6 downto 0);

begin

    -- ----------------------------------------------------------------------
    -- 1. BINARY TO DECIMAL CONVERTER
    -- Converts 8-bit binary (max 255) into three separate digits
    -- ----------------------------------------------------------------------
    process(Time_In)
        variable temp : integer;
    begin
        temp := to_integer(unsigned(Time_In));
        bcd_hun <= temp / 100;
        bcd_ten <= (temp / 10) mod 10;
        bcd_one <= temp mod 10;
    end process;

    -- ----------------------------------------------------------------------
    -- 2. THE MULTIPLEXER CLOCK (The Optical Illusion)
    -- ----------------------------------------------------------------------
    process(Clk, Reset)
    begin
        if Reset = '1' then
            refresh_counter <= (others => '0');
        elsif rising_edge(Clk) then
            refresh_counter <= refresh_counter + 1;
        end if;
    end process;

    -- Use the top 3 bits of a 20-bit counter. 
    -- At 100MHz, this creates a perfectly smooth ~95Hz refresh rate for the screen.
    active_digit <= std_logic_vector(refresh_counter(19 downto 17));

    -- ----------------------------------------------------------------------
    -- 3. ANODE SELECTOR (Choosing which physical digit to turn on)
    -- ----------------------------------------------------------------------
    process(active_digit, bcd_hun, bcd_ten, bcd_one)
    begin
        -- Default: Turn ALL digits OFF (Nexys A7 uses "Active Low" logic, so '1' is OFF)
        AN <= "11111111"; 
        current_val <= 0;

        case active_digit is
            when "000" =>
                AN <= "11111110"; -- Turn on the far-right digit (Ones)
                current_val <= bcd_one;
            when "001" =>
                AN <= "11111101"; -- Turn on the middle digit (Tens)
                current_val <= bcd_ten;
            when "010" =>
                AN <= "11111011"; -- Turn on the left digit (Hundreds)
                current_val <= bcd_hun;
            when others =>
                -- The Nexys A7 has 5 more unused digits on the left. Leave them OFF.
                AN <= "11111111"; 
                current_val <= 0; 
        end case;
    end process;

    -- ----------------------------------------------------------------------
    -- 4. CATHODE DECODER (Painting the actual shape of the number)
    -- ----------------------------------------------------------------------
    process(current_val)
    begin
        -- "Active Low": '0' turns a segment ON, '1' turns it OFF.
        -- Segment order: GFEDCBA
        case current_val is
            when 0 => seg_out <= "1000000"; -- 0
            when 1 => seg_out <= "1111001"; -- 1
            when 2 => seg_out <= "0100100"; -- 2
            when 3 => seg_out <= "0110000"; -- 3
            when 4 => seg_out <= "0011001"; -- 4
            when 5 => seg_out <= "0010010"; -- 5
            when 6 => seg_out <= "0000010"; -- 6
            when 7 => seg_out <= "1111000"; -- 7
            when 8 => seg_out <= "0000000"; -- 8
            when 9 => seg_out <= "0010000"; -- 9
            when others => seg_out <= "1111111"; -- Blank
        end case;
    end process;

    -- ----------------------------------------------------------------------
    -- 5. LEADING ZERO BLANKING (Pro-Level Polish)
    -- If the time is "45" seconds, this prevents it from displaying "045".
    -- ----------------------------------------------------------------------
    process(active_digit, bcd_hun, bcd_ten, seg_out)
    begin
        -- If we are drawing the Hundreds place, and it's a 0, turn it completely off!
        if active_digit = "010" and bcd_hun = 0 then
            SEG <= "1111111";
            
        -- If we are drawing the Tens place, and BOTH Hundreds and Tens are 0 (e.g., 9 seconds left), turn it off!
        elsif active_digit = "001" and bcd_hun = 0 and bcd_ten = 0 then
            SEG <= "1111111";
            
        else
            -- Otherwise, draw the normal number
            SEG <= seg_out;
        end if;
    end process;

end Behavioral;