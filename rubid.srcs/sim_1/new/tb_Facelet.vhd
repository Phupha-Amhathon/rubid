library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Facelet is
-- Testbench has no ports
end tb_Facelet;

architecture sim of tb_Facelet is
    -- 1. Component Declaration
    component Facelet
        Port ( 
            MD, MB, ML, MU, MR, MF : in STD_LOGIC_VECTOR (2 downto 0);
            load_init : in std_logic_vector(2 downto 0);
            S : in std_logic_vector(2 downto 0);
            Clk : in std_logic; 
            Q : out std_logic_vector(2 downto 0)
        );
    end component;

    -- 2. Internal Signals
    signal t_MD : std_logic_vector(2 downto 0) := "110"; -- Purple-ish
    signal t_MB : std_logic_vector(2 downto 0) := "101"; -- Blue
    signal t_ML : std_logic_vector(2 downto 0) := "100"; -- Yellow
    signal t_MU : std_logic_vector(2 downto 0) := "011"; -- Red
    signal t_MR : std_logic_vector(2 downto 0) := "010"; -- Green
    signal t_MF : std_logic_vector(2 downto 0) := "001"; -- Orange
    signal t_load_init : std_logic_vector(2 downto 0) := "000"; -- White
    signal t_S   : std_logic_vector(2 downto 0) := "000";
    signal t_Clk : std_logic := '0';
    signal t_Q   : std_logic_vector(2 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    -- 3. Port Map
    UUT: Facelet port map (
        MD => t_MD, MB => t_MB, ML => t_ML, 
        MU => t_MU, MR => t_MR, MF => t_MF,
        load_init => t_load_init,
        S => t_S, Clk => t_Clk, Q => t_Q
    );

    -- 4. Clock Generator
    clk_process : process
    begin
        t_Clk <= '0'; wait for CLK_PERIOD/2;
        t_Clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- 5. Stimulus Process
    stim_proc: process
    begin
        -- เริ่มต้นสัญญาณอาจจะเป็น 'U' 
        wait for 15 ns;

        -- [TEST 1] Load Initial Value (S = 111) 
        -- แก้ปัญหา Undefined: ต้องบังคับค่าเข้า Register ก่อน
        report ">>> Testing Load Initial (Reset) <<<";
        t_S <= "111"; 
        t_load_init <= "000"; -- ตั้งเป็นสีขาว
        wait for CLK_PERIOD;

        -- [TEST 2] Hold Value (S = 000)
        report ">>> Testing Hold State <<<";
        t_S <= "000"; 
        wait for CLK_PERIOD * 2;

        -- [TEST 3] Select MF (S = 001)
        report ">>> Testing Move Front Selection <<<";
        t_S <= "001"; 
        wait for CLK_PERIOD;
        
        -- [TEST 4] Select MR (S = 010)
        report ">>> Testing Move Right Selection <<<";
        t_S <= "010"; 
        wait for CLK_PERIOD;

        -- [TEST 5] Select MU (S = 011)
        report ">>> Testing Move Up Selection <<<";
        t_S <= "011"; 
        wait for CLK_PERIOD;

        -- [TEST 6] Select ML (S = 100)
        report ">>> Testing Move Left Selection <<<";
        t_S <= "100"; 
        wait for CLK_PERIOD;

        -- [TEST 7] Select MB (S = 101)
        report ">>> Testing Move Back Selection <<<";
        t_S <= "101"; 
        wait for CLK_PERIOD;

        -- [TEST 8] Select MD (S = 110)
        report ">>> Testing Move Down Selection <<<";
        t_S <= "110"; 
        wait for CLK_PERIOD;

        t_S <= "000"; -- กลับไป Hold
        report "--- Facelet Test Finished ---";
        wait;
    end process;
end sim;