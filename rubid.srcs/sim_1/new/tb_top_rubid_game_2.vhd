library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;         -- NEW: Needed to convert binary time to readable integers
use STD.TEXTIO.ALL;               -- Required for printing to console

entity tb_top_rubid_game_2 is
-- Testbench has no ports
end tb_top_rubid_game_2;

architecture Behavioral of tb_top_rubid_game_2 is

    component top_rubid_game
        Port ( 
            CLK100MHZ : in STD_LOGIC;
            CPU_RESETN: in STD_LOGIC; 
            BTNC      : in STD_LOGIC; 
            BTNU      : in STD_LOGIC; 
            BTND      : in STD_LOGIC; 
            SW        : in STD_LOGIC_VECTOR(15 downto 0); 
            LED       : out STD_LOGIC_VECTOR(15 downto 0);
            DEBUG_CUBE_STATE : out STD_LOGIC_VECTOR(71 downto 0) 
        );
    end component;

    signal CLK100MHZ  : STD_LOGIC := '0';
    signal CPU_RESETN : STD_LOGIC := '1'; 
    signal BTNC       : STD_LOGIC := '0';
    signal BTNU       : STD_LOGIC := '0';
    signal BTND       : STD_LOGIC := '0';
    signal SW         : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal LED        : STD_LOGIC_VECTOR(15 downto 0);
    signal Q_spy      : STD_LOGIC_VECTOR(71 downto 0);

    constant clk_period : time := 10 ns;

    -- ==========================================================
    -- CONSOLE PRINTING HELPER FUNCTIONS
    -- ==========================================================
    
    function get_color_name(val : std_logic_vector(2 downto 0)) return string is
    begin
        case val is
            when "000" => return "W"; -- Up
            when "001" => return "G"; -- Front
            when "010" => return "O"; -- Left
            when "011" => return "R"; -- Right
            when "100" => return "Y"; -- Down
            when "101" => return "B"; -- Back
            when others => return "?";
        end case;
    end function;

    -- NEW: The Master Dashboard Printer
    procedure print_dashboard(q : in std_logic_vector(71 downto 0); move_name : in string; mode_sw : in std_logic; leds : in std_logic_vector(15 downto 0)) is
        variable l : line;
        variable time_left : integer;
        variable u0, u1, u2, u3 : std_logic_vector(2 downto 0);
        variable f0, f1, f2, f3 : std_logic_vector(2 downto 0);
        variable l0, l1, l2, l3 : std_logic_vector(2 downto 0);
        variable r0, r1, r2, r3 : std_logic_vector(2 downto 0);
        variable b0, b1, b2, b3 : std_logic_vector(2 downto 0);
        variable d0, d1, d2, d3 : std_logic_vector(2 downto 0);
    begin
        -- Slice the 72-bit vector
        u0 := q(71 downto 69); u1 := q(68 downto 66); u2 := q(65 downto 63); u3 := q(62 downto 60);
        f0 := q(59 downto 57); f1 := q(56 downto 54); f2 := q(53 downto 51); f3 := q(50 downto 48);
        l0 := q(47 downto 45); l1 := q(44 downto 42); l2 := q(41 downto 39); l3 := q(38 downto 36);
        r0 := q(35 downto 33); r1 := q(32 downto 30); r2 := q(29 downto 27); r3 := q(26 downto 24);
        b0 := q(23 downto 21); b1 := q(20 downto 18); b2 := q(17 downto 15); b3 := q(14 downto 12);
        d0 := q(11 downto  9); d1 := q( 8 downto  6); d2 := q( 5 downto  3); d3 := q( 2 downto  0);

        -- Convert binary LED time to an integer
        time_left := to_integer(unsigned(leds(7 downto 0)));

        -- Print Header
        write(l, string'("==================================================")); writeline(output, l);
        write(l, string'("   SYSTEM REPORT: " & move_name)); writeline(output, l);
        write(l, string'("==================================================")); writeline(output, l);

        -- Print Game Status
        if mode_sw = '0' then
            write(l, string'(" Mode       : FREE PLAY")); writeline(output, l);
        else
            write(l, string'(" Mode       : CHALLENGE")); writeline(output, l);
        end if;

        write(l, string'(" Time Left  : " & integer'image(time_left) & " seconds")); writeline(output, l);

        if leds(15) = '1' then
            write(l, string'(" Game State : WINNER! (Cube Solved)")); writeline(output, l);
        elsif leds(14) = '1' then
            write(l, string'(" Game State : GAME OVER (Time Out)")); writeline(output, l);
        else
            write(l, string'(" Game State : ACTIVE")); writeline(output, l);
        end if;

        write(l, string'("--------------------------------------------------")); writeline(output, l);
        
        -- Print Cube
        write(l, string'("      [ " & get_color_name(u0) & " " & get_color_name(u1) & " ]")); writeline(output, l);
        write(l, string'("      [ " & get_color_name(u2) & " " & get_color_name(u3) & " ]")); writeline(output, l);
        write(l, string'("------------------------------------")); writeline(output, l);
        write(l, string'(get_color_name(l0) & " " & get_color_name(l1) & " | " & get_color_name(f0) & " " & get_color_name(f1) & " | " & get_color_name(r0) & " " & get_color_name(r1) & " | " & get_color_name(b0) & " " & get_color_name(b1))); writeline(output, l);
        write(l, string'(get_color_name(l2) & " " & get_color_name(l3) & " | " & get_color_name(f2) & " " & get_color_name(f3) & " | " & get_color_name(r2) & " " & get_color_name(r3) & " | " & get_color_name(b2) & " " & get_color_name(b3))); writeline(output, l);
        write(l, string'("------------------------------------")); writeline(output, l);
        write(l, string'("      [ " & get_color_name(d0) & " " & get_color_name(d1) & " ]")); writeline(output, l);
        write(l, string'("      [ " & get_color_name(d2) & " " & get_color_name(d3) & " ]")); writeline(output, l);
        write(l, string'("")); writeline(output, l); 
        write(l, string'("")); writeline(output, l); 
    end procedure;

begin

    uut: top_rubid_game port map (
        CLK100MHZ => CLK100MHZ, CPU_RESETN=> CPU_RESETN,
        BTNC => BTNC, BTNU => BTNU, BTND => BTND,
        SW => SW, LED => LED,
        DEBUG_CUBE_STATE => Q_spy
    );

    clk_process :process
    begin
        CLK100MHZ <= '0'; wait for clk_period/2;
        CLK100MHZ <= '1'; wait for clk_period/2;
    end process;

    stim_proc: process
        
        -- =======================================================
        -- AUTOMATION HELPER PROCEDURE (CPU-Optimized)
        -- =======================================================
        procedure execute_move(
            face_char : in character;
            dir       : in std_logic;
            move_name : in string
        ) is
        begin
            SW(5 downto 0) <= "000000";
            
            case face_char is
                when 'D' | 'd' => SW(0) <= '1';
                when 'B' | 'b' => SW(1) <= '1';
                when 'L' | 'l' => SW(2) <= '1';
                when 'U' | 'u' => SW(3) <= '1';
                when 'R' | 'r' => SW(4) <= '1';
                when 'F' | 'f' => SW(5) <= '1';
                when others    => null; 
            end case;
            
            SW(6) <= dir;
            
            -- Pushing the button for just 20 clock cycles!
            BTNC <= '1'; 
            wait for 200 ns; 
            BTNC <= '0';
            
            -- Wait a few clock cycles for the Cube to spin
            wait for 200 ns; 
            
            SW(5 downto 0) <= "000000";
            
            print_dashboard(Q_spy, move_name, SW(15), LED);
            
        end procedure;
        
    begin		
        -- STEP 1: Bootup and Auto-Initialize
        CPU_RESETN <= '0'; 
        wait for 200 ns; 
        CPU_RESETN <= '1';
        wait for 200 ns;
        
        -- =======================================================
        -- SCENARIO A: FREE MODE
        -- =======================================================
        SW(15) <= '0';              -- Set to Free Mode
        SW(5 downto 0) <= "000000"; -- Clear all face switches
        wait for 200 ns;
        
        -- CRITICAL: Press Start (BTNU) to wake up the Game Master!
        BTNU <= '1'; wait for 200 ns; BTNU <= '0'; 
        wait for 200 ns;
        
        print_dashboard(Q_spy, "FREE MODE STARTED", SW(15), LED);
        
        -- Execute Down Face (D is SW0)
        execute_move('D', '0', "DOWN FACE CLOCKWISE (D)");
        execute_move('D', '0', "DOWN FACE CLOCKWISE (D)");
        execute_move('D', '0', "DOWN FACE CLOCKWISE (D)");
        execute_move('D', '0', "DOWN FACE CLOCKWISE (D)");
        execute_move('D', '1', "DOWN FACE COUNTER CLOCKWISE (D)");
        execute_move('D', '1', "DOWN FACE COUNTER CLOCKWISE (D)");
        execute_move('D', '1', "DOWN FACE COUNTER CLOCKWISE (D)");
        execute_move('D', '1', "DOWN FACE COUNTER CLOCKWISE (D)");
        
        execute_move('B', '0', "B CLOCKWISE ");
        execute_move('B', '0', "B CLOCKWISE ");
        execute_move('B', '0', "B CLOCKWISE ");
        execute_move('B', '0', "B CLOCKWISE ");
        execute_move('B', '1', "B COUNTER CLOCKWISE ");
        execute_move('B', '1', "B COUNTER CLOCKWISE ");
        execute_move('B', '1', "B COUNTER CLOCKWISE ");
        execute_move('B', '1', "B COUNTER CLOCKWISE ");
        
        execute_move('L', '0', "L CLOCKWISE ");
        execute_move('L', '0', "L CLOCKWISE ");
        execute_move('L', '0', "L CLOCKWISE ");
        execute_move('L', '0', "L CLOCKWISE ");
        execute_move('L', '1', "L COUNTER CLOCKWISE ");
        execute_move('L', '1', "L COUNTER CLOCKWISE ");
        execute_move('L', '1', "L COUNTER CLOCKWISE ");
        execute_move('L', '1', "L COUNTER CLOCKWISE ");


        execute_move('U', '0', "U CLOCKWISE ");
        execute_move('U', '0', "U CLOCKWISE ");
        execute_move('U', '0', "U CLOCKWISE ");
        execute_move('U', '0', "U CLOCKWISE ");
        execute_move('U', '1', "U COUNTER CLOCKWISE ");
        execute_move('U', '1', "U COUNTER CLOCKWISE ");
        execute_move('U', '1', "U COUNTER CLOCKWISE ");
        execute_move('U', '1', "U COUNTER CLOCKWISE ");


        
        
        execute_move('R', '0', "R FACE CLOCKWISE");
        execute_move('R', '0', "R FACE CLOCKWISE");
        execute_move('R', '0', "R FACE CLOCKWISE");
        execute_move('R', '0', "R FACE CLOCKWISE");
        execute_move('R', '1', "R FACE COUNTER CLOCKWISE");
        execute_move('R', '1', "R FACE COUNTER CLOCKWISE");
        execute_move('R', '1', "R FACE COUNTER CLOCKWISE");
        execute_move('R', '1', "R FACE COUNTER CLOCKWISE");


        execute_move('F', '0', "F FACE CLOCKWISE (D)");
        execute_move('F', '0', "F FACE CLOCKWISE (D)");
        execute_move('F', '0', "F FACE CLOCKWISE (D)");
        execute_move('F', '0', "F FACE CLOCKWISE (D)");
        execute_move('F', '1', "F  COUNTER CLOCKWISE (D)");
        execute_move('F', '1', "F  COUNTER CLOCKWISE (D)");
        execute_move('F', '1', "F  COUNTER CLOCKWISE (D)");
        execute_move('F', '1', "F  COUNTER CLOCKWISE (D)");

        execute_move('F', '1', "F  COUNTER CLOCKWISE (D)");
        execute_move('R', '1', "R FACE COUNTER CLOCKWISE");

        

        
        
        -- =======================================================
        -- SCENARIO B: CHALLENGE MODE
        -- =======================================================
        -- CRITICAL: Free mode plays forever. Hard reset to clear the FSM!
        CPU_RESETN <= '0'; wait for 200 ns; 
        CPU_RESETN <= '1'; wait for 200 ns;
            
        -- Start Challenge Mode with 10 seconds!
        SW(15) <= '1'; 
        SW(14 downto 7) <= "00001010"; -- 10 in binary
        
        -- Press Start to load the timer and wake up Challenge Mode!
        BTNU <= '1'; wait for 200 ns; BTNU <= '0'; 
        wait for 200 ns;
        
        print_dashboard(Q_spy, "CHALLENGE MODE STARTED", SW(15), LED);

        -- Execute Right Face (R is SW4)
        execute_move('F', '0', "MOCK SCRAMBLE 1: F");
        execute_move('R', '1', "MOCK SCRAMBLE 2: R'");
        execute_move('U', '0', "MOCK SCRAMBLE 3: U");
        execute_move('B', '1', "MOCK SCRAMBLE 4: B'");
        execute_move('D', '0', "MOCK SCRAMBLE 5: D");
        print_dashboard(Q_spy, "CHALLENGE MODE READY (SCRAMBLED)", SW(15), LED);
        
        execute_move('R', '0', "sexy move: R");
        execute_move('U', '0', "sexy move: U");
        execute_move('R', '1', "sexy move: R'");
        execute_move('U', '1', "sexy move: U'");


        

        -- Test the Reset Button (Anti-Cheat check)
        -- Because Challenge Mode is active, this gate will physically block the signal.
        BTND <= '1'; wait for 200 ns; BTND <= '0'; 
        wait for 200 ns;
        print_dashboard(Q_spy, "AFTER CHEAT ATTEMPT", SW(15), LED);
        

        report "Simulation Completed Successfully!" severity note;
        wait; 
    end process;

end Behavioral;