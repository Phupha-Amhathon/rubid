library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Scramble_Module is
    Port ( 
        CLK100MHZ     : in std_logic;
        SCRAMBLE_BTN  : in std_logic;
        
        -- NEW: Open the front door for the Temperature Sensor!
        TMP_SCL       : inout std_logic;
        TMP_SDA       : inout std_logic;
        
        -- CUBE_STATE removed from here!
        SCRAMBLE_DONE : out std_logic
    );
end Scramble_Module;

architecture structural of Scramble_Module is

    -- DECLARE the attribute once at the very top!
    attribute mark_debug : string;

    -- Internal signal for the temperature sensor reading
    signal temp_wire : std_logic_vector(15 downto 0);
    attribute mark_debug of temp_wire : signal is "true"; 
    
    -- Internal signals for the Chaos Brain moves
    signal sF, sR, sU, sL, sB, sD, sDone : std_logic;
    
    -- 3-bit selector signal for the Cube Core
    signal sS : std_logic_vector(2 downto 0);

    -- CUBE_STATE is an internal signal
    signal CUBE_STATE : std_logic_vector(71 downto 0);
    attribute mark_debug of CUBE_STATE : signal is "true";

begin

    -- MOVEMENT ENCODER:
    sS <= "000" when sU = '1' else 
          "001" when sF = '1' else 
          "010" when sL = '1' else 
          "011" when sR = '1' else 
          "100" when sD = '1' else 
          "101" when sB = '1' else 
          "111";                   

    -- 1. I2C Temperature Sensor Reader
    READER_INST: entity work.I2C_Reader 
        port map(
            Clk       => CLK100MHZ, 
            RESET     => SCRAMBLE_BTN, 
            SCL       => TMP_SCL, 
            SDA       => TMP_SDA, 
            Temp_Data => temp_wire
        );
    
    -- 2. The Randomness Brain
    BRAIN_INST: entity work.Chaos_Engine 
        port map(
            Clk   => CLK100MHZ, 
            RESET => SCRAMBLE_BTN, 
            Temp  => temp_wire, 
            F => sF, R => sR, U => sU, L => sL, B => sB, D => sD, 
            Done  => sDone
        );
    
    -- 3. The Rubik's Cube Memory Core
    CUBE_INST: entity work.Cube_Core 
        port map(
            S     => sS, 
            Clk   => CLK100MHZ, 
            Q_all => CUBE_STATE -- Now maps to our internal signal
        );
    
    SCRAMBLE_DONE <= sDone;

end structural;