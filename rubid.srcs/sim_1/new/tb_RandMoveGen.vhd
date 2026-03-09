----------------------------------------------------------------------------------
-- Company: Khon Kaen University
-- Engineer: Phupha Amhathon
--
-- Create Date: 03/09/2026
-- Design Name: Testbench for RandMoveGen + RubidMark1
-- Module Name: tb_RandMoveGen - sim
-- Project Name: rubid
-- Description:
--   Simulates the full auto-scramble flow:
--     1. RESET the cube and seed the LFSR.
--     2. Wait for RandMoveGen to issue 20 pseudo-random moves.
--     3. Print each active move to the Tcl console.
--     4. Display the cube face diagram after every falling clock edge.
--
--   Expected 20-move sequence (seed = "101010"):
--     R  B  U  D  L  F  U  D  B  U
--     D  D  B  U  D  B  R  L  F  R
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_RandMoveGen is
end tb_RandMoveGen;

architecture sim of tb_RandMoveGen is

    -- -----------------------------------------------------------------------
    -- Component declarations
    -- -----------------------------------------------------------------------
    component RandMoveGen is
        Port (
            Clk   : in  std_logic;
            RESET : in  std_logic;
            F, R, U, L, B, D : out std_logic;
            done  : out std_logic
        );
    end component;

    component RubidMark1 is
        Port (
            RESET : in  std_logic;
            F     : in  std_logic;
            R     : in  std_logic;
            U     : in  std_logic;
            L     : in  std_logic;
            B     : in  std_logic;
            D     : in  std_logic;
            Q     : out std_logic_vector(71 downto 0);
            Clk   : in  std_logic
        );
    end component;

    -- -----------------------------------------------------------------------
    -- Simulation signals
    -- -----------------------------------------------------------------------
    signal t_Clk   : std_logic := '0';
    signal t_RESET : std_logic := '0';
    signal t_F, t_R, t_U, t_L, t_B, t_D : std_logic;
    signal t_done  : std_logic;
    signal t_Q     : std_logic_vector(71 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    -- Cube face aliases
    signal u0, u1, u2, u3 : std_logic_vector(2 downto 0);
    signal f0, f1, f2, f3 : std_logic_vector(2 downto 0);
    signal l0, l1, l2, l3 : std_logic_vector(2 downto 0);
    signal r0, r1, r2, r3 : std_logic_vector(2 downto 0);
    signal b0, b1, b2, b3 : std_logic_vector(2 downto 0);
    signal d0, d1, d2, d3 : std_logic_vector(2 downto 0);

    -- -----------------------------------------------------------------------
    -- Helper function: 3-bit colour code → text
    -- -----------------------------------------------------------------------
    function get_color_name(val : std_logic_vector(2 downto 0)) return string is
    begin
        case val is
            when "000"  => return "WHT";
            when "001"  => return "GRN";
            when "010"  => return "YLW";
            when "011"  => return "RED";
            when "100"  => return "BLU";
            when "101"  => return "ORG";
            when others => return "???";
        end case;
    end function;

    -- -----------------------------------------------------------------------
    -- Helper function: active move → text
    -- -----------------------------------------------------------------------
    function get_move_name(
        f_in, r_in, u_in, l_in, b_in, d_in : std_logic) return string is
    begin
        if    f_in = '1' then return "F";
        elsif r_in = '1' then return "R";
        elsif u_in = '1' then return "U";
        elsif l_in = '1' then return "L";
        elsif b_in = '1' then return "B";
        elsif d_in = '1' then return "D";
        else                   return "-";
        end if;
    end function;

begin

    -- -----------------------------------------------------------------------
    -- Cube-output slicing
    -- -----------------------------------------------------------------------
    u0 <= t_Q(71 downto 69); u1 <= t_Q(68 downto 66);
    u2 <= t_Q(65 downto 63); u3 <= t_Q(62 downto 60);
    f0 <= t_Q(59 downto 57); f1 <= t_Q(56 downto 54);
    f2 <= t_Q(53 downto 51); f3 <= t_Q(50 downto 48);
    l0 <= t_Q(47 downto 45); l1 <= t_Q(44 downto 42);
    l2 <= t_Q(41 downto 39); l3 <= t_Q(38 downto 36);
    r0 <= t_Q(35 downto 33); r1 <= t_Q(32 downto 30);
    r2 <= t_Q(29 downto 27); r3 <= t_Q(26 downto 24);
    b0 <= t_Q(23 downto 21); b1 <= t_Q(20 downto 18);
    b2 <= t_Q(17 downto 15); b3 <= t_Q(14 downto 12);
    d0 <= t_Q(11 downto  9); d1 <= t_Q( 8 downto  6);
    d2 <= t_Q( 5 downto  3); d3 <= t_Q( 2 downto  0);

    -- -----------------------------------------------------------------------
    -- DUT instantiation
    -- -----------------------------------------------------------------------
    GEN: RandMoveGen port map(
        Clk   => t_Clk,
        RESET => t_RESET,
        F     => t_F, R => t_R, U => t_U,
        L     => t_L, B => t_B, D => t_D,
        done  => t_done
    );

    CUBE: RubidMark1 port map(
        RESET => t_RESET,
        F => t_F, R => t_R, U => t_U,
        L => t_L, B => t_B, D => t_D,
        Q => t_Q, Clk => t_Clk
    );

    -- -----------------------------------------------------------------------
    -- Clock generator (10 ns period)
    -- -----------------------------------------------------------------------
    clk_proc: process
    begin
        t_Clk <= '0'; wait for CLK_PERIOD / 2;
        t_Clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    -- -----------------------------------------------------------------------
    -- Stimulus: hold RESET for 2 clock cycles, then let the scrambler run
    -- -----------------------------------------------------------------------
    stim_proc: process
    begin
        wait for 20 ns;

        report ">>> RESET: initialising cube and seeding LFSR <<<";
        t_RESET <= '1';
        wait for CLK_PERIOD * 2;
        t_RESET <= '0';

        -- Wait long enough for all 20 moves plus a few idle cycles
        wait for CLK_PERIOD * 25;

        report "--- SCRAMBLE COMPLETE ---";
        wait;
    end process;

    -- -----------------------------------------------------------------------
    -- Monitor: print move and cube diagram on every falling clock edge
    -- -----------------------------------------------------------------------
    monitor: process(t_Clk)
        variable move_num : integer := 0;
    begin
        if falling_edge(t_Clk) then
            if t_RESET = '0' then
                if t_done = '0' then
                    move_num := move_num + 1;
                    report "Move " & integer'image(move_num) &
                           ": " & get_move_name(t_F, t_R, t_U, t_L, t_B, t_D) &
                           "  [done=" & std_logic'image(t_done) & "]" & LF &
                           "        [ " & get_color_name(u0) & " " & get_color_name(u1) & " ]" & LF &
                           "        [ " & get_color_name(u3) & " " & get_color_name(u2) & " ]" & LF &
                           "  ----------------------------------" & LF &
                           "  " & get_color_name(l0) & " " & get_color_name(l1) & " | " &
                           get_color_name(f0) & " " & get_color_name(f1) & " | " &
                           get_color_name(r0) & " " & get_color_name(r1) & " | " &
                           get_color_name(b0) & " " & get_color_name(b1) & LF &
                           "  " & get_color_name(l3) & " " & get_color_name(l2) & " | " &
                           get_color_name(f3) & " " & get_color_name(f2) & " | " &
                           get_color_name(r3) & " " & get_color_name(r2) & " | " &
                           get_color_name(b3) & " " & get_color_name(b2) & LF &
                           "  ----------------------------------" & LF &
                           "        [ " & get_color_name(d0) & " " & get_color_name(d1) & " ]" & LF &
                           "        [ " & get_color_name(d3) & " " & get_color_name(d2) & " ]";
                elsif move_num > 0 then
                    report "All 20 moves applied.  done=" & std_logic'image(t_done);
                    move_num := 0;
                end if;
            end if;
        end if;
    end process;

end sim;
