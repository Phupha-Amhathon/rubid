----------------------------------------------------------------------------------
-- Company: Computer Engineering @Khon Kaen University
-- Engineer: Puwadon Puchamni
-- 
-- Create Date: 03/20/2026 12:06:44 AM
-- Design Name: 
-- Module Name: TempTop - Behavioral
-- Project Name: Copter_Scramble_Rubik
-- Target Devices: nexys A7 100t
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hardware_scrambler is
    Port ( 
        Clk            : in  STD_LOGIC;
        Reset          : in  STD_LOGIC;
        Start_Scramble : in  STD_LOGIC;                      
        Temp_Input     : in  STD_LOGIC_VECTOR(15 downto 0); -- From ADT7420
        S_Out          : out STD_LOGIC_VECTOR(2 downto 0);  
        Scramble_Done  : out STD_LOGIC                      
    );
end hardware_scrambler;

architecture Structural of hardware_scrambler is
    -- Constant for fixed 20 moves
    constant MAX_MOVES : integer := 20;
    
    -- Internal State for Chaos Loop
    signal chaos_reg : STD_LOGIC_VECTOR(15 downto 0);
    signal mux1_out, mux2_out : STD_LOGIC_VECTOR(15 downto 0);
    
    -- Outputs from all 8 machines
    signal m1, m2, m3, m4, m5, m6, m7, m8 : STD_LOGIC_VECTOR(15 downto 0);

    -- State Machine
    type state_type is (IDLE, CALC_CHAOS, LATCH_MOVE, COOLDOWN, CHECK_DONE);
    signal state : state_type := IDLE;

    signal moves_done : integer range 0 to 31 := 0;
    signal timer : integer := 0;
    constant COOLDOWN_MAX : integer := 100_000; -- Delay to create a clean pulse

begin

    -- ======================================================================
    -- 1. INSTANTIATE ALL 8 CHAOS MACHINES
    -- ======================================================================
    -- Group A (Mux 1 - Diffusion)
    U1: entity work.machine_reverse   port map(chaos_reg, m1);
    U2: entity work.machine_rotate_7  port map(chaos_reg, m2);
    U3: entity work.machine_shuffle   port map(chaos_reg, m3);
    U4: entity work.machine_gray      port map(chaos_reg, m4);
    
    -- Group B (Mux 2 - Confusion) - Fed by the output of Mux 1
    U5: entity work.machine_xor_magic port map(mux1_out,  m5);
    U6: entity work.machine_bit_flip  port map(mux1_out,  m6);
    U7: entity work.machine_byte_swap port map(mux1_out,  m7);
    U8: entity work.machine_neighbor  port map(mux1_out,  m8);

    -- ======================================================================
    -- 2. THE DUAL-MUX PATHING ROUTER
    -- ======================================================================
    -- MUX 1: Uses bits 1:0 of current chaos_reg
    process(chaos_reg, m1, m2, m3, m4)
    begin
        case chaos_reg(1 downto 0) is
            when "00" => mux1_out <= m1;
            when "01" => mux1_out <= m2;
            when "10" => mux1_out <= m3;
            when "11" => mux1_out <= m4;
            when others => mux1_out <= m1;
        end case;
    end process;

    -- MUX 2: Uses bits 15:14 of current chaos_reg
    process(chaos_reg, m5, m6, m7, m8)
    begin
        case chaos_reg(15 downto 14) is
            when "00" => mux2_out <= m5;
            when "01" => mux2_out <= m6;
            when "10" => mux2_out <= m7;
            when "11" => mux2_out <= m8;
            when others => mux2_out <= m5;
        end case;
    end process;

    -- ======================================================================
    -- 3. MAIN CONTROL FSM (The 20-Move Loop)
    -- ======================================================================
    process(Clk, Reset)
    begin
        if Reset = '1' then
            state <= IDLE;
            S_Out <= "000";
            Scramble_Done <= '0';
            moves_done <= 0;
        elsif rising_edge(Clk) then
            case state is
                when IDLE =>
                    Scramble_Done <= '0';
                    S_Out <= "000";
                    if Start_Scramble = '1' then
                        chaos_reg <= Temp_Input; -- SEED with the raw temperature!
                        moves_done <= 0;
                        state <= CALC_CHAOS;
                    end if;

                when CALC_CHAOS =>
                    -- The Feedback Loop: Save MUX 2 output back into chaos_reg
                    chaos_reg <= mux2_out;
                    state <= LATCH_MOVE;

                when LATCH_MOVE =>
                    -- Pick Move: Extract bits 2:0 to act as the 3-bit Move Code
                    -- Prevent 110 (6) and 111 (7) from being sent
                    if unsigned(chaos_reg(2 downto 0)) > 5 then
                        S_Out <= std_logic_vector(unsigned(chaos_reg(2 downto 0)) - 2);
                    else
                        S_Out <= chaos_reg(2 downto 0);
                    end if;
                    
                    timer <= 0;
                    state <= COOLDOWN;

                when COOLDOWN =>
                    S_Out <= "000"; -- Pull the move signal low (create a pulse)
                    if timer < COOLDOWN_MAX then
                        timer <= timer + 1;
                    else
                        state <= CHECK_DONE;
                    end if;

                when CHECK_DONE =>
                    moves_done <= moves_done + 1;
                    
                    if moves_done < (MAX_MOVES - 1) then 
                        state <= CALC_CHAOS; -- Loop back for the next move
                    else
                        Scramble_Done <= '1';
                        -- Stay here until the human releases the button
                        if Start_Scramble = '0' then 
                            state <= IDLE; 
                        end if;
                    end if;
            end case;
        end if;
    end process;
end Structural;