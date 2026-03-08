library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_moveEncoder is
-- Testbench has no ports
end tb_moveEncoder;

architecture sim of tb_moveEncoder is
    -- 1. Component Declaration
    component moveEncoder
        Port (
            RESET, F, R, U, L, B, D : in std_logic;
            Y : out std_logic_vector(2 downto 0) 
        );
    end component;

    -- 2. Internal Signals
    signal t_RESET : std_logic := '0';
    signal t_F     : std_logic := '0';
    signal t_R     : std_logic := '0';
    signal t_U     : std_logic := '0';
    signal t_L     : std_logic := '0';
    signal t_B     : std_logic := '0';
    signal t_D     : std_logic := '0';
    signal t_Y     : std_logic_vector(2 downto 0);

    constant WAIT_TIME : time := 20 ns;

begin
    -- 3. Instantiate Unit Under Test (UUT)
    UUT: moveEncoder port map (
        RESET => t_RESET, F => t_F, R => t_R, 
        U => t_U, L => t_L, B => t_B, D => t_D,
        Y => t_Y
    );

    -- 4. Stimulus Process
    stim_proc: process
    begin
        -- Initial State: No buttons pressed (Hold state)
        report "--- Starting Test: moveEncoder ---";
        t_RESET <= '0'; t_F <= '0'; t_R <= '0'; t_U <= '0'; t_L <= '0'; t_B <= '0'; t_D <= '0';
        wait for WAIT_TIME;
        assert (t_Y = "000") report "Error: Hold state failed" severity error;

        -- Test Case 1: Individual Buttons (Single Press)
        report "Test 1: Single Press Tests";
        
        t_F <= '1'; wait for WAIT_TIME; t_F <= '0'; -- Expected Y = 001
        t_R <= '1'; wait for WAIT_TIME; t_R <= '0'; -- Expected Y = 010
        t_U <= '1'; wait for WAIT_TIME; t_U <= '0'; -- Expected Y = 011
        t_L <= '1'; wait for WAIT_TIME; t_L <= '0'; -- Expected Y = 100
        t_B <= '1'; wait for WAIT_TIME; t_B <= '0'; -- Expected Y = 101
        t_D <= '1'; wait for WAIT_TIME; t_D <= '0'; -- Expected Y = 110
        t_RESET <= '1'; wait for WAIT_TIME; t_RESET <= '0'; -- Expected Y = 111

        -- Test Case 2: Priority Check (Pressing multiple buttons)
        report "Test 2: Priority Logic Check";
        
        -- Case: F and R both high (F has higher priority, should result in 001)
        t_F <= '1'; t_R <= '1'; 
        wait for WAIT_TIME;
        t_F <= '0'; t_R <= '0';

        -- Case: RESET and everything else high (RESET should win, result in 111)
        t_RESET <= '1'; t_F <= '1'; t_B <= '1'; t_D <= '1';
        wait for WAIT_TIME;
        t_RESET <= '0'; t_F <= '0'; t_B <= '0'; t_D <= '0';

        -- Test Case 3: Mixed Logic (B and D)
        t_B <= '1'; t_D <= '1';
        wait for WAIT_TIME;
        t_B <= '0'; t_D <= '0';

        report "--- All encoder tests finished ---";
        wait;
    end process;
end sim;