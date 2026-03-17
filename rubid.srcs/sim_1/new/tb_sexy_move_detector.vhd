library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_sexy_move_detector is
-- Testbench has no ports
end tb_sexy_move_detector;

architecture Behavioral of tb_sexy_move_detector is

    component sexy_move_detector
        Port (
            Clk          : in STD_LOGIC;
            BTN_Execute  : in STD_LOGIC;
            SW_Face      : in STD_LOGIC_VECTOR(2 downto 0);
            SW_Direction : in STD_LOGIC;
            Time_Bonus   : out STD_LOGIC;
            Debug_State  : out STD_LOGIC_VECTOR(2 downto 0) 
        );
    end component;

    signal Clk          : STD_LOGIC := '0';
    signal BTN_Execute  : STD_LOGIC := '0';
    signal SW_Face      : STD_LOGIC_VECTOR(2 downto 0) := "000";
    signal SW_Direction : STD_LOGIC := '0';
    signal Time_Bonus   : STD_LOGIC;
    signal Debug_State  : STD_LOGIC_VECTOR(2 downto 0);     

    constant clk_period : time := 10 ns;

begin

    uut: sexy_move_detector Port map (
        Clk          => Clk,
        BTN_Execute  => BTN_Execute,
        SW_Face      => SW_Face,
        SW_Direction => SW_Direction,
        Time_Bonus   => Time_Bonus,
        Debug_State  => Debug_State   
    );

    clk_process :process
    begin
        Clk <= '0';
        wait for clk_period/2;
        Clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus Process (Constant, predictable timing)
    stim_proc: process
    begin		
        -- Wait 25ns to align all input changes with the RISING edge of the clock.
        -- This gives the FALLING edge FSM a perfect 5ns setup time to read the inputs.
        wait for 30 ns;	

        -- ==========================================================
        -- SCENARIO 1: The Perfect Combo (R -> U -> R' -> U')
        -- ==========================================================
        -- Move 1: R 
        SW_Face <= "010"; SW_Direction <= '0';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;

        -- Move 2: U 
        SW_Face <= "011"; SW_Direction <= '0';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;

        -- Move 3: R' 
        SW_Face <= "010"; SW_Direction <= '1';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;

        -- Move 4: U' 
        SW_Face <= "011"; SW_Direction <= '1';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; 
        
        -- Wait extra time to observe the Time_Bonus pulse
        wait for 60 ns; 

        -- ==========================================================
        -- SCENARIO 2: The Fumbled Combo (R -> U -> F)
        -- ==========================================================
        -- Move 1: R 
        SW_Face <= "010"; SW_Direction <= '0';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;

        -- Move 2: U 
        SW_Face <= "011"; SW_Direction <= '0';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;

        -- Move 3: F (Wrong Move)
        SW_Face <= "001"; SW_Direction <= '0';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; 
        
        wait for 60 ns;

        -- ==========================================================
        -- SCENARIO 3: The Stutter (R -> U -> R -> U -> R' -> U')
        -- ==========================================================
        -- Move 1: R
        SW_Face <= "010"; SW_Direction <= '0';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;

        -- Move 2: U 
        SW_Face <= "011"; SW_Direction <= '0';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;

        -- Move 3: R (Stutter - restarts combo logic)
        SW_Face <= "010"; SW_Direction <= '0';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;
        
        -- Move 4: U 
        SW_Face <= "011"; SW_Direction <= '0';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;

        -- Move 5: R' 
        SW_Face <= "010"; SW_Direction <= '1';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; wait for 20 ns;

        -- Move 6: U' 
        SW_Face <= "011"; SW_Direction <= '1';
        BTN_Execute <= '1'; wait for 20 ns; 
        BTN_Execute <= '0'; 

        wait for 60 ns;

        wait; 
    end process;

end Behavioral;