library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ==============================================================================
-- Module: RubidRand (Top Level Scrambler)
-- Description: Integrates I2C Temperature Sensing, Tangled Chaos Engine, 
--              and the Rubik's Cube Memory Core.
-- ==============================================================================

entity RubidRand is
    Port (
        Clk      : in    std_logic;
        RESET    : in    std_logic;       -- Center Button (BTNC)
        TMP_SCL  : out   std_logic;       -- I2C Clock Pin
        TMP_SDA  : inout std_logic;       -- I2C Data Pin
        done     : out   std_logic;       -- Scramble Finished LED
        
        -- The 72-bit Cube State (DNA of the colors)
        -- This goes to your Testbench and your friend's VGA
        Q_all    : out   std_logic_vector(71 downto 0)
    );
end RubidRand;

architecture structural of RubidRand is

    -- 1. COMPONENT: Real-time Temperature Reader
    component I2C_Temp_Reader is
        Port ( 
            Clk, RESET : in std_logic; 
            SCL        : out std_logic; 
            SDA        : inout std_logic; 
            Temp_Data  : out std_logic_vector(15 downto 0) 
        );
    end component;

    -- 2. COMPONENT: The Tangled MUX Chaos Engine
    component Tangled_Chaos_Engine is
        Port ( 
            Clk, RESET : in std_logic; 
            Live_Temp  : in std_logic_vector(15 downto 0); 
            F, R, U, L, B, D : out std_logic; 
            Done       : out std_logic 
        );
    end component;

    -- 3. COMPONENT: The Rubik's Cube Core (Mark 1)
    component RubidMark1 is
        Port ( 
            RESET, F, R, U, L, B, D : in std_logic; 
            Q   : out std_logic_vector(71 downto 0); 
            Clk : in std_logic 
        );
    end component;

    -- Internal Logic Wires
    signal sF, sR, sU, sL, sB, sD : std_logic;
    signal sDone     : std_logic;
    signal live_temp : std_logic_vector(15 downto 0);
    signal sQ_all    : std_logic_vector(71 downto 0);

    -- Attributes for Vivado ILA Debugging (Optional but recommended)
    attribute mark_debug : string;
    attribute mark_debug of sQ_all : signal is "true";
    attribute mark_debug of live_temp : signal is "true";

begin

    -- Instance A: The Chaos Source (ADT7420 Sensor)
    TEMP: I2C_Temp_Reader port map(
        Clk => Clk, 
        RESET => RESET, 
        SCL => TMP_SCL, 
        SDA => TMP_SDA, 
        Temp_Data => live_temp
    );

    -- Instance B: The Brain (MUX Matrix Chaos)
    CHOS: Tangled_Chaos_Engine port map(
        Clk => Clk, 
        RESET => RESET, 
        Live_Temp => live_temp, 
        F => sF, R => sR, U => sU, 
        L => sL, B => sB, D => sD, 
        Done => sDone
    );

    -- Instance C: The Physical Memory (The Cube itself)
    CUBE: RubidMark1 port map(
        RESET => RESET, 
        F => sF, R => sR, U => sU, 
        L => sL, B => sB, D => sD, 
        Q => sQ_all, 
        Clk => Clk
    );

    -- Output Connections
    Q_all <= sQ_all;
    done  <= sDone;

end structural;