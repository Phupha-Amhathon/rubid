library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_countdown_timer is
-- Testbench has no ports
end tb_countdown_timer;

architecture Behavioral of tb_countdown_timer is

    -- 1. Declare the Unit Under Test (UUT)
    component countdown_timer
        Generic (
            MAX_TIME : integer := 255
        );
        Port ( 
            Clk          : in STD_LOGIC;
            Load_Enable  : in STD_LOGIC;
            Time_In      : in STD_LOGIC_VECTOR(7 downto 0);
            Tick_1Hz     : in STD_LOGIC;
            Add_Enable   : in STD_LOGIC;
            Add_Value    : in STD_LOGIC_VECTOR(7 downto 0);
            Time_Out     : out STD_LOGIC_VECTOR(7 downto 0);
            Time_Is_Zero : out STD_LOGIC
        );
    end component;

    -- 2. Internal Signals
    signal Clk          : STD_LOGIC := '0';
    signal Load_Enable  : STD_LOGIC := '0';
    signal Time_In      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal Tick_1Hz     : STD_LOGIC := '0';
    signal Add_Enable   : STD_LOGIC := '0';
    signal Add_Value    : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal Time_Out     : STD_LOGIC_VECTOR(7 downto 0);
    signal Time_Is_Zero : STD_LOGIC;

    -- 100 MHz clock period
    constant clk_period : time := 10 ns;

begin

    -- 3. Instantiate the UUT
    uut: countdown_timer 
    Port map (
        Clk          => Clk,
        Load_Enable  => Load_Enable,
        Time_In      => Time_In,
        Tick_1Hz     => Tick_1Hz,
        Add_Enable   => Add_Enable,
        Add_Value    => Add_Value,
        Time_Out     => Time_Out,
        Time_Is_Zero => Time_Is_Zero
    );

    -- 4. Clock Generation Process
    clk_process :process
    begin
        Clk <= '0';
        wait for clk_period/2;
        Clk <= '1';
        wait for clk_period/2;
    end process;

    -- 5. Stimulus Process
    stim_proc: process
    begin		
        -- Align inputs to the rising edge (5ns setup time for the falling edge)
        wait for 25 ns;	

        -- ==========================================================
        -- SCENARIO 1: Load Initial Time (e.g., 10 seconds)
        -- ==========================================================
        Time_In <= "00001010"; -- Binary for 10
        Load_Enable <= '1';
        wait for 10 ns;        -- Pulse for exactly 1 clock cycle
        Load_Enable <= '0';
        wait for 30 ns;

        -- ==========================================================
        -- SCENARIO 2: Normal Countdown (Tick arrives)
        -- Expected: Time drops from 10 to 9
        -- ==========================================================
        Tick_1Hz <= '1';
        wait for 10 ns;
        Tick_1Hz <= '0';
        wait for 30 ns;

        -- ==========================================================
        -- SCENARIO 3: Add Bonus Time (Add 5 seconds)
        -- Expected: Time jumps from 9 to 14
        -- ==========================================================
        Add_Value <= "00000101"; -- Binary for 5
        Add_Enable <= '1';
        wait for 10 ns;
        Add_Enable <= '0';
        wait for 30 ns;

        -- ==========================================================
        -- SCENARIO 4: The Collision! (Tick and Add at exact same time)
        -- Adding 3 seconds, but losing 1 second to the tick.
        -- Expected: Time goes from 14 to 16
        -- ==========================================================
        Add_Value <= "00000011"; -- Binary for 3
        Tick_1Hz <= '1';
        Add_Enable <= '1';
        wait for 10 ns;
        Tick_1Hz <= '0';
        Add_Enable <= '0';
        wait for 30 ns;

        -- ==========================================================
        -- SCENARIO 5: Overflow Protection
        -- Let's load 250 seconds, then try to add 10 seconds.
        -- Expected: Time caps at 255 (all 1s) and does not roll over.
        -- ==========================================================
        Time_In <= "11111010"; -- Binary for 250
        Load_Enable <= '1';
        wait for 10 ns;
        Load_Enable <= '0';
        wait for 30 ns;
        
        Add_Value <= "00001010"; -- Binary for 10
        Add_Enable <= '1';
        wait for 10 ns;
        Add_Enable <= '0';
        wait for 30 ns;

        -- ==========================================================
        -- SCENARIO 6: Reaching Zero
        -- Load 2 seconds, tick twice, check the Game Over flag.
        -- ==========================================================
        Time_In <= "00000010"; -- Binary for 2
        Load_Enable <= '1';
        wait for 10 ns;
        Load_Enable <= '0';
        wait for 30 ns;
        
        -- Tick 1 (Drops to 1)
        Tick_1Hz <= '1'; wait for 10 ns; Tick_1Hz <= '0'; wait for 30 ns;
        
        -- Tick 2 (Drops to 0 -> Time_Is_Zero should instantly go HIGH)
        Tick_1Hz <= '1'; wait for 10 ns; Tick_1Hz <= '0'; wait for 30 ns;

        wait; -- End simulation
    end process;

end Behavioral;