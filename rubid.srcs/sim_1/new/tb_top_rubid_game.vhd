library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.TEXTIO.ALL;               -- Required for printing to console

entity tb_visual_cube is
-- Testbench has no ports
end tb_visual_cube;

architecture Behavioral of tb_visual_cube is

    -- 1. Declare the Motherboard
    component top_rubid_game
        Port ( 
            CLK100MHZ : in STD_LOGIC;
            CPU_RESETN: in STD_LOGIC; 
            BTNC      : in STD_LOGIC; 
            BTNU      : in STD_LOGIC; 
            BTND      : in STD_LOGIC; 
            SW        : in STD_LOGIC_VECTOR(15 downto 0); 
            LED       : out STD_LOGIC_VECTOR(15 downto 0);
            DEBUG_CUBE_STATE : out STD_LOGIC_VECTOR(71 downto 0) -- The temporary spyhole
        );
    end component;

    -- 2. Physical Signals
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
    
    -- Maps your 3-bit binary to a readable string (Assumes standard colors)
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

    -- The master printing procedure using your exact formatting
    procedure print_cube(q : in std_logic_vector(71 downto 0); move_name : in string) is
        variable l : line;
        variable u0, u1, u2, u3 : std_logic_vector(2 downto 0);
        variable f0, f1, f2, f3 : std_logic_vector(2 downto 0);
        variable l0, l1, l2, l3 : std_logic_vector(2 downto 0);
        variable r0, r1, r2, r3 : std_logic_vector(2 downto 0);
        variable b0, b1, b2, b3 : std_logic_vector(2 downto 0);
        variable d0, d1, d2, d3 : std_logic_vector(2 downto 0);
    begin
        -- Slice the 72-bit vector exactly how your RubidMark2 concatenated it
        u0 := q(71 downto 69); u1 := q(68 downto 66); u2 := q(65 downto 63); u3 := q(62 downto 60);
        f0 := q(59 downto 57); f1 := q(56 downto 54); f2 := q(53 downto 51); f3 := q(50 downto 48);
        l0 := q(47 downto 45); l1 := q(44 downto 42); l2 := q(41 downto 39); l3 := q(38 downto 36);
        r0 := q(35 downto 33); r1 := q(32 downto 30); r2 := q(29 downto 27); r3 := q(26 downto 24);
        b0 := q(23 downto 21); b1 := q(20 downto 18); b2 := q(17 downto 15); b3 := q(14 downto 12);
        d0 := q(11 downto  9); d1 := q( 8 downto  6); d2 := q( 5 downto  3); d3 := q( 2 downto  0);

        write(l, string'("=== CURRENT CUBE STATE: " & move_name & " ===")); writeline(output, l);
        write(l, string'("      [ " & get_color_name(u0) & " " & get_color_name(u1) & " ]")); writeline(output, l);
        write(l, string'("      [ " & get_color_name(u3) & " " & get_color_name(u2) & " ]")); writeline(output, l);
        write(l, string'("------------------------------------")); writeline(output, l);
        write(l, string'(get_color_name(l0) & " " & get_color_name(l1) & " | " & get_color_name(f0) & " " & get_color_name(f1) & " | " & get_color_name(r0) & " " & get_color_name(r1) & " | " & get_color_name(b0) & " " & get_color_name(b1))); writeline(output, l);
        write(l, string'(get_color_name(l3) & " " & get_color_name(l2) & " | " & get_color_name(f3) & " " & get_color_name(f2) & " | " & get_color_name(r3) & " " & get_color_name(r2) & " | " & get_color_name(b3) & " " & get_color_name(b2))); writeline(output, l);
        write(l, string'("------------------------------------")); writeline(output, l);
        write(l, string'("      [ " & get_color_name(d0) & " " & get_color_name(d1) & " ]")); writeline(output, l);
        write(l, string'("      [ " & get_color_name(d3) & " " & get_color_name(d2) & " ]")); writeline(output, l);
        write(l, string'("")); writeline(output, l); -- Blank line for spacing
    end procedure;

begin

    -- 3. Instantiate the UUT
    uut: top_rubid_game port map (
        CLK100MHZ => CLK100MHZ, CPU_RESETN=> CPU_RESETN,
        BTNC => BTNC, BTNU => BTNU, BTND => BTND,
        SW => SW, LED => LED,
        DEBUG_CUBE_STATE => Q_spy
    );

    -- 4. Clock Generation
    clk_process :process
    begin
        CLK100MHZ <= '0'; wait for clk_period/2;
        CLK100MHZ <= '1'; wait for clk_period/2;
    end process;

    -- 5. The Interactive Stimulus Process
    stim_proc: process
    begin		
        -- STEP 1: Bootup and Auto-Initialize
        -- Our auto-bootloader will see this and format the cube to default colors
        CPU_RESETN <= '0'; 
        wait for 1 ms;        CPU_RESETN <= '1';
        wait for 1 ms;
        
        -- Start Free Mode
        SW(15) <= '0'; 
        BTNU <= '1'; wait for 15 ms; BTNU <= '0'; -- Hold long enough for debouncer!
        wait for 1 ms;
        
        -- Print initial state
        print_cube(Q_spy, "INITIALIZED (ALL SOLVED)");

        -- STEP 2: Execute Right Clockwise (R)
        SW(4) <= '1'; -- Right Face
        SW(6) <= '0'; -- Clockwise
        
        BTNC <= '1'; wait for 15 ms; BTNC <= '0'; -- Press Execute
        wait for 1 ms; -- Wait for the move controller to finish spinning it
        SW(4) <= '0'; -- Turn switch off
        
        print_cube(Q_spy, "AFTER RIGHT (R) MOVE");

        -- STEP 3: Execute Up Clockwise (U)
        SW(3) <= '1'; -- Up Face
        SW(6) <= '0'; -- Clockwise
        
        BTNC <= '1'; wait for 15 ms; BTNC <= '0'; -- Press Execute
        wait for 1 ms;
        SW(3) <= '0';
        
        print_cube(Q_spy, "AFTER UP (U) MOVE");
        
        -- STEP 4: Test the Reset Button (Anti-Cheat check)
        BTND <= '1'; wait for 15 ms; BTND <= '0'; -- Press the Cube Reset button
        wait for 1 ms;
        
        print_cube(Q_spy, "AFTER RESET BUTTON PRESSED");

        report "Simulation Completed Successfully!" severity note;
        wait; -- End simulation
    end process;

end Behavioral;