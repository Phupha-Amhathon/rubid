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
   
    constant MAX_MOVES : integer := 20;
    
    -- Internal State for Chaos Loop
    signal chaos_reg : STD_LOGIC_VECTOR(15 downto 0);
    signal mux1_out, mux2_out : STD_LOGIC_VECTOR(15 downto 0);
    
    signal temp_v1     : STD_LOGIC_VECTOR(15 downto 0);
    signal history_reg : STD_LOGIC_VECTOR(15 downto 0) := x"ACE1";
    
    -- Outputs from all 8 machines
    signal m1, m2, m3, m4, m5, m6, m7, m8 : STD_LOGIC_VECTOR(15 downto 0);

    -- State Machine (เพิ่ม SEND_PULSE แล้ว)
    type state_type is (IDLE, PREPARE_SEED, CALC_CHAOS, LATCH_MOVE, SEND_PULSE, COOLDOWN, CHECK_DONE);
    signal state : state_type := IDLE;

    signal moves_done : integer range 0 to 31 := 0;
    signal timer : integer := 0;
    constant COOLDOWN_MAX : integer := 40_000_000 ; --delay
    
    signal free_counter : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

begin

    -- Group A 
    U1: entity work.machine_reverse         port map(chaos_reg, m1);
    U2: entity work.machine_cut             port map(chaos_reg, m2);
    U3: entity work.machine_shuffle         port map(chaos_reg, m3);
    U4: entity work.machine_poker_deal      port map(chaos_reg, m4);
    
    -- Group B
    U5: entity work.machine_xor_magic       port map(mux1_out,  m5);
    U6: entity work.machine_consecutive_xor port map(mux1_out,  m6);
    U7: entity work.machine_doce_fleur      port map(mux1_out,  m7);
    U8: entity work.machine_all_in          port map(mux1_out,  m8);

    -- 2. THE DUAL-MUX PATHING ROUTER
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

    -- MUX 2: Uses bits 3:2 of current chaos_reg
    process(chaos_reg, m5, m6, m7, m8)
    begin
        case chaos_reg(3 downto 2) is
            when "00" => mux2_out <= m5;
            when "01" => mux2_out <= m6;
            when "10" => mux2_out <= m7;
            when "11" => mux2_out <= m8;
            when others => mux2_out <= m5;
        end case;
    end process;

    -- 3. MAIN CONTROL FSM (The [MAX_MOVES]-Move Loop)
    process(Clk, Reset)
    begin
        if Reset = '1' then
            state <= IDLE;
            S_Out <= "000"; -- เคลียร์ค่าเป็น 000 (สถานะพักเครื่อง)
            Scramble_Done <= '0';
            moves_done <= 0;
            -- history_reg <= x"ACE1";
        elsif rising_edge(Clk) then 
        
        free_counter <= std_logic_vector(unsigned(free_counter) + 1);
        
            case state is
                when IDLE =>
                    Scramble_Done <= '0';
                    S_Out <= "000"; -- รอรับคำสั่งในสถานะพักเครื่อง (000)
                    if Start_Scramble = '1' then
                        temp_v1 <= Temp_Input; 
                        timer <= 0;
                        state <= PREPARE_SEED;
                    end if;
                    
                 when PREPARE_SEED =>
                   
                    if timer < 200000 then
                        timer <= timer + 1;
                    else
                        chaos_reg <= temp_v1 xor Temp_Input xor history_reg xor free_counter;
                        moves_done <= 0;
                        state <= CALC_CHAOS;
                    end if;

                when CALC_CHAOS =>
                    -- The Feedback Loop: Save MUX 2 output back into chaos_reg
                    chaos_reg <= mux2_out;
                    state <= LATCH_MOVE;

                when LATCH_MOVE =>
                    -- เช็คว่าถ้าได้ 000 (0) หรือ 111 (7) ให้กลับไปสุ่มให
                    if unsigned(chaos_reg(2 downto 0)) = 0 or unsigned(chaos_reg(2 downto 0)) = 7 then
                        state <= CALC_CHAOS; 
                    else
                        -- ถ้าได้เลข 1 ถึง 6 ถือว่าผ่าน! ให้ไปยิงสัญญาณได้เลย
                        state <= SEND_PULSE; 
                    end if;

                when SEND_PULSE =>
                    -- ยิงมูฟออกไปให้วงจรหลักเห็นแค่ 1 Clock Cycle
                    S_Out <= chaos_reg(2 downto 0); 
                    timer <= 0;
                    state <= COOLDOWN;

                when COOLDOWN =>
                    -- รีบดึงสายสัญญาณกลับเป็น 000 ทันที เพื่อไม่ให้รูบิคหมุนซ้ำ
                    S_Out <= "000"; 
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
                        history_reg <= chaos_reg; -- last result is seed for next time we play
                        -- Stay here until Start_Scramble is released
                        if Start_Scramble = '0' then 
                            state <= IDLE; 
                        end if;
                    end if;
            end case;
        end if;
    end process;
end Structural;
