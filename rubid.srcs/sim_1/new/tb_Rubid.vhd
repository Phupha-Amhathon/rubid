library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Rubid is
-- Testbench has no ports
end tb_Rubid;

architecture sim of tb_Rubid is
    -- 1. Component Declaration (Matches your simplified Rubid entity)
    component Rubid
        Port ( 
            S : in STD_LOGIC_VECTOR (2 downto 0);
            Clk : in STD_LOGIC;
            Q_all : out STD_LOGIC_VECTOR (71 downto 0)
        );
    end component;

    -- 2. Simulation Signals
    signal t_S     : std_logic_vector(2 downto 0) := "000";
    signal t_Clk   : std_logic := '0';
    signal t_Q_all : std_logic_vector(71 downto 0);

    -- Helper Function to translate the 3-bit color code to text
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

    -- Aliases for easier debugging: Mapping the 72-bit vector to faces
    -- Based on your concatenation: s_u0 & s_u1 & s_u2 & s_u3 ...
    signal u0, u1, u2, u3 : std_logic_vector(2 downto 0);
    signal f0, f1, f2, f3 : std_logic_vector(2 downto 0);
    signal l0, l1, l2, l3 : std_logic_vector(2 downto 0);
    signal r0, r1, r2, r3 : std_logic_vector(2 downto 0);
    signal b0, b1, b2, b3 : std_logic_vector(2 downto 0);
    signal d0, d1, d2, d3 : std_logic_vector(2 downto 0);

begin

    -- Extracting 3-bit slices from the 72-bit vector
    u0 <= t_Q_all(71 downto 69); u1 <= t_Q_all(68 downto 66); 
    u2 <= t_Q_all(65 downto 63); u3 <= t_Q_all(62 downto 60);
    
    f0 <= t_Q_all(59 downto 57); f1 <= t_Q_all(56 downto 54); 
    f2 <= t_Q_all(53 downto 51); f3 <= t_Q_all(50 downto 48);
    
    l0 <= t_Q_all(47 downto 45); l1 <= t_Q_all(44 downto 42); 
    l2 <= t_Q_all(41 downto 39); l3 <= t_Q_all(38 downto 36);
    
    r0 <= t_Q_all(35 downto 33); r1 <= t_Q_all(32 downto 30); 
    r2 <= t_Q_all(29 downto 27); r3 <= t_Q_all(26 downto 24);
    
    b0 <= t_Q_all(23 downto 21); b1 <= t_Q_all(20 downto 18); 
    b2 <= t_Q_all(17 downto 15); b3 <= t_Q_all(14 downto 12);
    
    d0 <= t_Q_all(11 downto 9);  d1 <= t_Q_all(8 downto 6); 
    d2 <= t_Q_all(5 downto 3);   d3 <= t_Q_all(2 downto 0);

    -- 3. Port Map
    UUT: Rubid port map (
        S => t_S, 
        Clk => t_Clk,
        Q_all => t_Q_all
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
        wait for 20 ns;
        
        -- [CASE 1] RESET/INITIALIZE
        t_S <= "111"; wait for CLK_PERIOD * 2;
        report ">>> CASE 1: RESET ALL FACES (S=111) <<<";

        -- [CASE 2] HOLD
        t_S <= "000"; wait for CLK_PERIOD * 4;
        report ">>> CASE 2: HOLD STATE (S=000) <<<";

        -- [CASE 3] ROTATION F
        t_S <= "001"; wait for CLK_PERIOD * 1; 
        t_S <= "000"; wait for CLK_PERIOD * 4;
        report ">>> CASE 3: MOVE FRONT (S=001) <<<";

        -- [CASE 4] ROTATION R
        t_S <= "010"; wait for CLK_PERIOD * 1;
        t_S <= "000"; wait for CLK_PERIOD * 4;
                report ">>> CASE 4: MOVE RIGHT (S=010) <<<";

        t_S <= "111"; wait for CLK_PERIOD * 1;
        t_S <= "000"; wait for CLK_PERIOD * 4;
                report ">>> CASE 5: reset (111) <<<";

        t_S <= "001"; wait for CLK_PERIOD * 1;
        t_S <= "000"; wait for CLK_PERIOD * 4;
                report ">>> CASE 6: up (111) <<<";

        t_S <= "010"; wait for CLK_PERIOD * 1;
        t_S <= "000"; wait for CLK_PERIOD * 4;
                report ">>> CASE 7: side (111) <<<";

        t_S <= "011"; wait for CLK_PERIOD * 1;
        t_S <= "000"; wait for CLK_PERIOD * 4;
                report ">>> CASE 8: down (111) <<<";

        t_S <= "100"; wait for CLK_PERIOD * 1;
        t_S <= "000"; wait for CLK_PERIOD * 4;
                report ">>> CASE 9: round (111) <<<";

        t_S <= "101"; wait for CLK_PERIOD * 1;
        t_S <= "000"; wait for CLK_PERIOD * 4;
                report ">>> CASE 10: and (111) <<<";

        t_S <= "110"; wait for CLK_PERIOD * 1;
        t_S <= "000"; wait for CLK_PERIOD * 4;
                report ">>> CASE 11: round (111) <<<";

        
        t_S <= "110"; wait for CLK_PERIOD * 1;
        t_S <= "110"; wait for CLK_PERIOD * 1;
        t_S <= "110"; wait for CLK_PERIOD * 1;
                report ">>> CASE 11: in (111) <<<";

        t_S <= "101"; wait for CLK_PERIOD * 1;
        t_S <= "101"; wait for CLK_PERIOD * 1;
        t_S <= "101"; wait for CLK_PERIOD * 1;
                report ">>> CASE 10: side (111) <<<";

        t_S <= "100"; wait for CLK_PERIOD * 1;
        t_S <= "100"; wait for CLK_PERIOD * 1;
        t_S <= "100"; wait for CLK_PERIOD * 1;
                report ">>> CASE 9: round (111) <<<";

        t_S <= "011"; wait for CLK_PERIOD * 1;
        t_S <= "011"; wait for CLK_PERIOD * 1;
        t_S <= "011"; wait for CLK_PERIOD * 1;
                report ">>> CASE 8: down (111) <<<";

        

        t_S <= "010"; wait for CLK_PERIOD * 1;
        t_S <= "010"; wait for CLK_PERIOD * 1;
        t_S <= "010"; wait for CLK_PERIOD * 1;
                report ">>> CASE 7: side (111) <<<";
                
        t_S <= "001"; wait for CLK_PERIOD * 1;
        t_S <= "001"; wait for CLK_PERIOD * 1;
        t_S <= "001"; wait for CLK_PERIOD * 1;
                report ">>> CASE 6: up (111) <<<";
                report ">>> CASE 6: up (111) <<<";

        report "--- ALL TEST CASES FINISHED ---";
        wait;
    end process;

    -- 6. Monitor: Visualizes the cube in the Tcl Console
    monitor: process(t_Q_all)
    begin
        report LF & 
          "      [ " & get_color_name(u0) & " " & get_color_name(u1) & " ]" & LF &
          "      [ " & get_color_name(u2) & " " & get_color_name(u3) & " ]" & LF &
          "------------------------------------" & LF &
          get_color_name(l0) & " " & get_color_name(l1) & " | " &
          get_color_name(f0) & " " & get_color_name(f1) & " | " &
          get_color_name(r0) & " " & get_color_name(r1) & " | " &
          get_color_name(b0) & " " & get_color_name(b1) & LF &
          
          get_color_name(l2) & " " & get_color_name(l3) & " | " &
          get_color_name(f2) & " " & get_color_name(f3) & " | " &
          get_color_name(r2) & " " & get_color_name(r3) & " | " &
          get_color_name(b2) & " " & get_color_name(b3) & LF &
          "------------------------------------" & LF &
          "      [ " & get_color_name(d0) & " " & get_color_name(d1) & " ]" & LF &
          "      [ " & get_color_name(d2) & " " & get_color_name(d3) & " ]" & LF;
    end process;

end sim;