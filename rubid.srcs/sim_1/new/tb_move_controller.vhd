library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_move_controller is
-- Testbench entities are always empty
end tb_move_controller;

architecture Behavioral of tb_move_controller is

    -- 1. Declare the Unit Under Test (UUT)
    component move_controller
        Port ( 
           Clk          : in STD_LOGIC;
           BTN_Execute  : in STD_LOGIC;
           SW_Direction : in STD_LOGIC;
           SW_Face      : in STD_LOGIC_VECTOR (2 downto 0);
           S_Out        : out STD_LOGIC_VECTOR (2 downto 0)
        );
    end component;

    -- 2. Declare internal signals to connect to the UUT
    signal Clk          : STD_LOGIC := '0';
    signal BTN_Execute  : STD_LOGIC := '0';
    signal SW_Direction : STD_LOGIC := '0';
    signal SW_Face      : STD_LOGIC_VECTOR (2 downto 0) := "000";
    signal S_Out        : STD_LOGIC_VECTOR (2 downto 0);

    -- 100 MHz clock period for the Nexys A7
    constant clk_period : time := 10 ns;

begin

    -- 3. Instantiate the UUT
    uut: move_controller Port map (
          Clk          => Clk,
          BTN_Execute  => BTN_Execute,
          SW_Direction => SW_Direction,
          SW_Face      => SW_Face,
          S_Out        => S_Out
        );

    -- 4. Generate the 100 MHz Clock
    clk_process :process
    begin
        Clk <= '0';
        wait for clk_period/2;
        Clk <= '1';
        wait for clk_period/2;
    end process;

    -- 5. Stimulus Process (The Test Scenarios)
    stim_proc: process
    begin		
        -- Let the system initialize
        wait for 20 ns;	

        -- ==========================================================
        -- SCENARIO 1: Clockwise Turn (Should pulse for 1 clock cycle)
        -- ==========================================================
        SW_Face <= "011";      -- Select 'Up' face
        SW_Direction <= '0';   -- Set Direction to Clockwise
        wait for clk_period;
        
        BTN_Execute <= '1';    -- Press the button
        wait for 40 ns;        -- Hold it down for a bit
        BTN_Execute <= '0';    -- Release the button
        
        wait for 50 ns;        -- Wait to see the system settle back to IDLE

        -- ==========================================================
        -- SCENARIO 2: Counter-Clockwise Turn (Should pulse for 3 clock cycles)
        -- ==========================================================
        SW_Face <= "100";      -- Select 'Left' face
        SW_Direction <= '1';   -- Set Direction to Counter-Clockwise
        wait for clk_period;
        
        BTN_Execute <= '1';    -- Press the button
        wait for 60 ns;        -- Hold it down long enough for the 3 states
        BTN_Execute <= '0';    -- Release the button
        
        wait for 50 ns;

        -- ==========================================================
        -- SCENARIO 3: Infinite Spin Test (Button held down entirely too long)
        -- ==========================================================
        SW_Face <= "001";      -- Select 'Front' face
        SW_Direction <= '0';   -- Set Direction to Clockwise
        wait for clk_period;
        
        BTN_Execute <= '1';    -- Press the button...
        wait for 150 ns;       -- ...and hold it down for 15 full clock cycles
        BTN_Execute <= '0';    -- Finally let go
        
        wait for 50 ns;

        -- End simulation
        wait;
    end process;

end Behavioral;