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

entity TempTop is
    port(
        CLK100MHZ : in  STD_LOGIC;
        
        -- I2C Pins (Connected to ADT7420 sensor)
        SDA       : inout STD_LOGIC; 
        SCL       : out STD_LOGIC;   
        
        -- 7-Segment Pins (Displaying Temperature XX.XXXX)
        CA, CB, CC, CD, CE, CF, CG, DP : out STD_LOGIC; 
        AN        : out STD_LOGIC_VECTOR (7 downto 0);        
        
        -- Button to trigger the Chaos Scrambler test
        BTNC      : in  STD_LOGIC; 
        
        -- Debug LEDs (Showing Done / !Done states)
        LED       : out STD_LOGIC_VECTOR (15 downto 0)       
    );
end TempTop;

architecture Structural of TempTop is

    -- Temperature signals
    signal i2c_busy    : STD_LOGIC;
    signal i2c_error   : STD_LOGIC;
    signal temp_raw    : STD_LOGIC_VECTOR(15 downto 0);
    signal temp_scaled : integer; 
    
    -- 7-Segment Digit signals
    signal d10, d1, df1, df2, df3, df4 : integer;
    signal bcd_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    -- Scrambler signals for Vivado ILA Debugging
    signal scramble_move : STD_LOGIC_VECTOR(2 downto 0);
    signal scramble_done_flag : STD_LOGIC;
    
    -- =========================================================
    -- VIVADO ILA DEBUG ATTRIBUTES (Add these lines!)
    -- =========================================================
    attribute mark_debug : string;
    attribute mark_debug of temp_raw           : signal is "true"; -- Watch the seed!
    attribute mark_debug of scramble_move      : signal is "true"; -- Watch the 3-bit moves!
    attribute mark_debug of scramble_done_flag : signal is "true"; -- Watch the Done signal!
    attribute mark_debug of BTNC               : signal is "true"; -- Watch your button press!

begin

    -- =========================================================
    -- Section 1: Temperature Math for XX.XXXX format
    -- =========================================================
    temp_scaled <= to_integer(signed(temp_raw)) * 625 / 8; 

    process(temp_scaled)
        variable val : integer;
    begin
        val := abs(temp_scaled);
        df4 <= val mod 10;            -- Decimal pos 4
        df3 <= (val / 10) mod 10;     -- Decimal pos 3
        df2 <= (val / 100) mod 10;    -- Decimal pos 2
        df1 <= (val / 1000) mod 10;   -- Decimal pos 1
        d1  <= (val / 10000) mod 10;  -- Unit digit
        d10 <= (val / 100000) mod 10; -- Tens digit
    end process;

    bcd_data <= x"00" & -- Padding for the first 2 unused digits
                std_logic_vector(to_unsigned(d10, 4)) & 
                std_logic_vector(to_unsigned(d1,  4)) & 
                std_logic_vector(to_unsigned(df1, 4)) & 
                std_logic_vector(to_unsigned(df2, 4)) & 
                std_logic_vector(to_unsigned(df3, 4)) & 
                std_logic_vector(to_unsigned(df4, 4));

    -- =========================================================
    -- Section 2: Component Instantiations
    -- =========================================================

    -- I2C Reader Module
    I2C_Reader: entity work.adt7420_i2c_reader
        port map (
            clk        => CLK100MHZ, 
            reset_n    => '1',       
            SDA        => SDA,       
            SCL        => SCL,      
            temp_data  => temp_raw,  
            busy       => i2c_busy,  
            error_flag => i2c_error  
        );
    
    -- 7-Segment Display Controller
    Display: entity work.sevenseg_hex8
        port map (
            clk   => CLK100MHZ,
            value => bcd_data, 
            CA=>CA, CB=>CB, CC=>CC, CD=>CD, CE=>CE, CF=>CF, CG=>CG, DP=>DP, AN=>AN
        );

    -- The Chaos Scrambler Module
    Scrambler: entity work.hardware_scrambler
        port map (
            Clk            => CLK100MHZ,
            Reset          => '0',
            Start_Scramble => BTNC,          -- Push middle button to test
            Temp_Input     => temp_raw,      -- Seed from raw temperature
           -- Moves_Needed   => "0010",        -- Fixed to 2 moves for quick testing
            S_Out          => scramble_move, -- View this in Vivado Debug!
            Scramble_Done  => scramble_done_flag
        );

    -- =========================================================
    -- Section 3: Simple LED Status Indicators
    -- =========================================================
    LED(15) <= scramble_done_flag;       -- DONE Indicator
    LED(14) <= not scramble_done_flag;   -- NOT DONE (Busy/Idle) Indicator
    
    -- Turn off all other unused LEDs
    LED(13 downto 0) <= (others => '0');

end Structural;