library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_RubidMark1 is
-- Testbench has no ports
end tb_RubidMark1;

architecture sim of tb_RubidMark1 is
    -- 1. Component Declaration
    component RubidMark1
        Port ( 
            RESET, F, R, U, L, B, D : in STD_LOGIC;
            Q : out STD_LOGIC_VECTOR (71 downto 0);
            Clk : in STD_LOGIC
        );
    end component;

    -- 2. Simulation Signals
    signal t_RESET, t_F, t_R, t_U, t_L, t_B, t_D : std_logic := '0';
    signal t_Clk : std_logic := '0';
    signal t_Q   : std_logic_vector(71 downto 0);

    -- Helper Function for TCL Console Visualization
    function get_color_name(val : std_logic_vector(2 downto 0)) return string is
    begin
        case val is
            when "000" => return "WHT"; -- White
            when "001" => return "GRN"; -- Green
            when "010" => return "YLW"; -- Yellow
            when "011" => return "RED"; -- Red
            when "100" => return "BLU"; -- Blue
            when "101" => return "ORG"; -- Orange
            when others => return "???";
        end case;
    end function;

    constant CLK_PERIOD : time := 10 ns;

    -- Aliases for Cube Mapping (71 downto 0)
    -- Mapping each face based on your s_q_all concatenation order
    signal u0, u1, u2, u3 : std_logic_vector(2 downto 0);
    signal f0, f1, f2, f3 : std_logic_vector(2 downto 0);
    signal l0, l1, l2, l3 : std_logic_vector(2 downto 0);
    signal r0, r1, r2, r3 : std_logic_vector(2 downto 0);
    signal b0, b1, b2, b3 : std_logic_vector(2 downto 0);
    signal d0, d1, d2, d3 : std_logic_vector(2 downto 0);

begin

    -- Slicing the 72-bit output for the Monitor
    u0 <= t_Q(71 downto 69); u1 <= t_Q(68 downto 66); u2 <= t_Q(65 downto 63); u3 <= t_Q(62 downto 60);
    f0 <= t_Q(59 downto 57); f1 <= t_Q(56 downto 54); f2 <= t_Q(53 downto 51); f3 <= t_Q(50 downto 48);
    l0 <= t_Q(47 downto 45); l1 <= t_Q(44 downto 42); l2 <= t_Q(41 downto 39); l3 <= t_Q(38 downto 36);
    r0 <= t_Q(35 downto 33); r1 <= t_Q(32 downto 30); r2 <= t_Q(29 downto 27); r3 <= t_Q(26 downto 24);
    b0 <= t_Q(23 downto 21); b1 <= t_Q(20 downto 18); b2 <= t_Q(17 downto 15); b3 <= t_Q(14 downto 12);
    d0 <= t_Q(11 downto  9); d1 <= t_Q(8  downto  6); d2 <= t_Q(5  downto  3); d3 <= t_Q(2  downto  0);

    -- 3. Instantiate Top Level
    UUT: RubidMark1 port map (
        RESET => t_RESET, F => t_F, R => t_R, U => t_U,
        L => t_L, B => t_B, D => t_D, Q => t_Q, Clk => t_Clk
    );

    -- 4. Clock Generator
    clk_process : process
    begin
        t_Clk <= '0'; wait for CLK_PERIOD/2;
        t_Clk <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- 5. Stimulus Process (Simulating Button Presses)
    stim_proc: process
    begin
        -- Initial State
        wait for 20 ns;

        -- Step 1: Initialize Cube (Hold RESET button)
        report ">>> ACTION: Pressing RESET Button <<<";
        t_RESET <= '1'; wait for CLK_PERIOD * 2;
        t_RESET <= '0'; wait for CLK_PERIOD * 2;

        -- Step 2: Move Front (Press F)
        report ">>> ACTION: Pressing F Button <<<";
        t_F <= '1'; wait for CLK_PERIOD; -- 1 Clock cycle move
        t_F <= '0'; wait for CLK_PERIOD * 3;

        -- Step 3: Move Up (Press U)
        report ">>> ACTION: Pressing U Button <<<";
        t_U <= '1'; wait for CLK_PERIOD;
        t_U <= '0'; wait for CLK_PERIOD * 3;

        -- Step 4: Priority Test (Press F and R together - F should win)
        report ">>> ACTION: Pressing F and R together (Priority Check) <<<";
        t_F <= '1'; t_R <= '1'; wait for CLK_PERIOD;
        t_F <= '0'; t_R <= '0'; wait for CLK_PERIOD * 3;
        
        report ">>> ACTION: Pressing RESET Button <<<";
        t_RESET <= '1'; wait for CLK_PERIOD * 2;
        t_RESET <= '0'; wait for CLK_PERIOD * 2;
        
        report ">>> ACTION: Pressing F and R together (Priority Check) <<<";
        t_F <= '1'; t_R <= '1'; wait for CLK_PERIOD;
        t_F <= '0'; t_R <= '0'; wait for CLK_PERIOD * 3;
        report ">>> ACTION: Pressing F and R together (Priority Check) <<<";
        t_F <= '1'; t_R <= '1'; wait for CLK_PERIOD;
        t_F <= '0'; t_R <= '0'; wait for CLK_PERIOD * 3;
        report ">>> ACTION: Pressing F and R together (Priority Check) <<<";
        t_F <= '1'; t_R <= '1'; wait for CLK_PERIOD;
        t_F <= '0'; t_R <= '0'; wait for CLK_PERIOD * 3;
        report ">>> ACTION: Pressing F and R together (Priority Check) <<<";
        t_F <= '1'; t_R <= '1'; wait for CLK_PERIOD;
        t_F <= '0'; t_R <= '0'; wait for CLK_PERIOD * 3;

        report "--- TOP LEVEL SIMULATION FINISHED ---";
        wait for 100 ns;
        wait;
    end process;

    -- 6. Monitor: Visualization
    monitor: process(t_Clk)
    begin
        if falling_edge(t_Clk) then
            report LF & 
              "      [ " & get_color_name(u0) & " " & get_color_name(u1) & " ]" & LF &
              "      [ " & get_color_name(u3) & " " & get_color_name(u2) & " ]" & LF &
              "------------------------------------" & LF &
              get_color_name(l0) & " " & get_color_name(l1) & " | " &
              get_color_name(f0) & " " & get_color_name(f1) & " | " &
              get_color_name(r0) & " " & get_color_name(r1) & " | " &
              get_color_name(b0) & " " & get_color_name(b1) & LF &
              
              get_color_name(l3) & " " & get_color_name(l2) & " | " &
              get_color_name(f3) & " " & get_color_name(f2) & " | " &
              get_color_name(r3) & " " & get_color_name(r2) & " | " &
              get_color_name(b3) & " " & get_color_name(b2) & LF &
              "------------------------------------" & LF &
              "      [ " & get_color_name(d0) & " " & get_color_name(d1) & " ]" & LF &
              "      [ " & get_color_name(d3) & " " & get_color_name(d2) & " ]" & LF;
        end if;
    end process;

end sim;