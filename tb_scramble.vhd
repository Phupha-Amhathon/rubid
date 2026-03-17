library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_scramble is
end tb_scramble;

architecture sim of tb_scramble is

    -- Component Declaration for the Scramble Top Level
    component RubidRand is
        Port (
            Clk   : in  std_logic;
            RESET : in  std_logic;
            done  : out std_logic;
            Q_all : out std_logic_vector(71 downto 0)
        );
    end component;

    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';
    signal done  : std_logic;
    signal q_bus : std_logic_vector(71 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    -- Color translator for the Tcl Console
    function get_color(val : std_logic_vector(2 downto 0)) return string is
    begin
        case val is
            when "000"  => return "WHT";
            when "001"  => return "GRN";
            when "010"  => return "ORG";
            when "011"  => return "RED";
            when "100"  => return "YLW";
            when "101"  => return "BLU";
            when others => return "???";
        end case;
    end function;

begin

    -- Instantiate the Full Scramble System
    UUT: RubidRand port map(
        Clk   => clk,
        RESET => reset,
        done  => done,
        Q_all => q_bus
    );

    -- 100 MHz Simulation Clock
    clk <= not clk after CLK_PERIOD / 2;

    -- -----------------------------------------------------------------------
    -- TEST STIMULUS (The Player pressing the RESET/Scramble button)
    -- -----------------------------------------------------------------------
    stim_proc: process
    begin
        wait for 100 ns;

        -- TEST 1: First scramble from solved state
        report ">>> TEST 1: First Scramble <<<";
        reset <= '1'; wait for 200 ns; reset <= '0';
        wait until done = '1';

        wait for 200 ns;

        -- TEST 2: Re-scramble (button pressed again)
        report ">>> TEST 2: Re-Scramble <<<";
        reset <= '1'; wait for 200 ns; reset <= '0';
        wait until done = '1';

        wait;
    end process;

    -- -----------------------------------------------------------------------
    -- RESULT MONITOR (Print cube faces when scramble finishes)
    -- -----------------------------------------------------------------------
    monitor: process(done)
        variable u0, u1, u2, u3 : std_logic_vector(2 downto 0);
        variable f0, f1, f2, f3 : std_logic_vector(2 downto 0);
        variable l0, l1, l2, l3 : std_logic_vector(2 downto 0);
        variable r0, r1, r2, r3 : std_logic_vector(2 downto 0);
        variable b0, b1, b2, b3 : std_logic_vector(2 downto 0);
        variable d0, d1, d2, d3 : std_logic_vector(2 downto 0);
    begin
        if rising_edge(done) then
            -- Slicing the 72-bit cube state
            u0 := q_bus(71 downto 69); u1 := q_bus(68 downto 66);
            u2 := q_bus(65 downto 63); u3 := q_bus(62 downto 60);
            f0 := q_bus(59 downto 57); f1 := q_bus(56 downto 54);
            f2 := q_bus(53 downto 51); f3 := q_bus(50 downto 48);
            l0 := q_bus(47 downto 45); l1 := q_bus(44 downto 42);
            l2 := q_bus(41 downto 39); l3 := q_bus(38 downto 36);
            r0 := q_bus(35 downto 33); r1 := q_bus(32 downto 30);
            r2 := q_bus(29 downto 27); r3 := q_bus(26 downto 24);
            b0 := q_bus(23 downto 21); b1 := q_bus(20 downto 18);
            b2 := q_bus(17 downto 15); b3 := q_bus(14 downto 12);
            d0 := q_bus(11 downto  9); d1 := q_bus( 8 downto  6);
            d2 := q_bus( 5 downto  3); d3 := q_bus( 2 downto  0);

            report LF & "SCRAMBLE FINISHED. FINAL CUBE STATE:" & LF &
            "        [ " & get_color(u0) & " " & get_color(u1) & " ]" & LF &
            "        [ " & get_color(u3) & " " & get_color(u2) & " ]" & LF &
            "  ----------------------------------" & LF &
            "  " & get_color(l0) & " " & get_color(l1) & " | " &
                   get_color(f0) & " " & get_color(f1) & " | " &
                   get_color(r0) & " " & get_color(r1) & " | " &
                   get_color(b0) & " " & get_color(b1) & LF &
            "  " & get_color(l3) & " " & get_color(l2) & " | " &
                   get_color(f3) & " " & get_color(f2) & " | " &
                   get_color(r3) & " " & get_color(r2) & " | " &
                   get_color(b3) & " " & get_color(b2) & LF &
            "  ----------------------------------" & LF &
            "        [ " & get_color(d0) & " " & get_color(d1) & " ]" & LF &
            "        [ " & get_color(d3) & " " & get_color(d2) & " ]";
        end if;
    end process;

end sim;
