library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity hardware_scrambler is
    Port ( 
        Clk            : in STD_LOGIC;
        Reset          : in STD_LOGIC;
        Start_Scramble : in STD_LOGIC;                      
        Moves_Needed   : in STD_LOGIC_VECTOR(3 downto 0);   
        
        S_Out          : out STD_LOGIC_VECTOR(2 downto 0);  
        Scramble_Done  : out STD_LOGIC                      
    );
end hardware_scrambler;

architecture Behavioral of hardware_scrambler is

    -- Entropy source sampled when Start_Scramble rises
    signal free_counter : unsigned(15 downto 0) := (others => '0');
    signal chaos_reg    : std_logic_vector(15 downto 0) := (others => '0');
    signal mux1_out     : std_logic_vector(15 downto 0);
    signal mux2_out     : std_logic_vector(15 downto 0);
    signal random_face  : std_logic_vector(2 downto 0);

    -- Outputs from all 8 chaos machines
    signal m1, m2, m3, m4, m5, m6, m7, m8 : std_logic_vector(15 downto 0);

    type state_type is (IDLE, CALC_CHAOS, LATCH_MOVE, HOLD_PULSE, COOLDOWN, CHECK_DONE);
    signal state : state_type := IDLE;
    signal start_prev : std_logic := '0';

    signal moves_completed : unsigned(3 downto 0) := (others => '0');
    
    signal timer : integer := 0;
    constant PULSE_WIDTH  : integer := 10;      
    constant COOLDOWN_MAX : integer := 100_000; 

begin

    U1: entity work.machine_reverse   port map(chaos_reg, m1);
    U2: entity work.machine_rotate_7  port map(chaos_reg, m2);
    U3: entity work.machine_shuffle   port map(chaos_reg, m3);
    U4: entity work.machine_gray      port map(chaos_reg, m4);

    U5: entity work.machine_xor_magic port map(mux1_out,  m5);
    U6: entity work.machine_bit_flip  port map(mux1_out,  m6);
    U7: entity work.machine_byte_swap port map(mux1_out,  m7);
    U8: entity work.machine_neighbor  port map(mux1_out,  m8);

    process(chaos_reg, m1, m2, m3, m4)
    begin
        case chaos_reg(1 downto 0) is
            when "00" => mux1_out <= m1;
            when "01" => mux1_out <= m2;
            when "10" => mux1_out <= m3;
            when others => mux1_out <= m4;
        end case;
    end process;

    process(chaos_reg, m5, m6, m7, m8)
    begin
        case chaos_reg(15 downto 14) is
            when "00" => mux2_out <= m5;
            when "01" => mux2_out <= m6;
            when "10" => mux2_out <= m7;
            when others => mux2_out <= m8;
        end case;
    end process;

    process(Clk)
    begin
        if rising_edge(Clk) then
            free_counter <= free_counter + 1;
        end if;
    end process;
    
    process(chaos_reg)
        variable move_idx : integer range 1 to 6;
    begin
        move_idx := (to_integer(unsigned(chaos_reg(2 downto 0))) mod 6) + 1;
        random_face <= std_logic_vector(to_unsigned(move_idx, 3));
    end process;

    -- ----------------------------------------------------------------------
    -- 2. THE TIMING PIPELINE 
    -- ----------------------------------------------------------------------
    process(Clk, Reset)
    begin
        if Reset = '1' then
            state <= IDLE;
            moves_completed <= (others => '0');
            S_Out <= "000"; 
            Scramble_Done <= '0';
            timer <= 0;
            chaos_reg <= (others => '0');
            start_prev <= '0';
            
        elsif rising_edge(Clk) then
            start_prev <= Start_Scramble;
            case state is
                
                when IDLE =>
                    Scramble_Done <= '0';
                    S_Out <= "000";
                    moves_completed <= (others => '0');
                    
                    if Start_Scramble = '1' and start_prev = '0' then
                        if unsigned(Moves_Needed) > 0 then
                            chaos_reg <= std_logic_vector(free_counter);
                            state <= CALC_CHAOS;
                        else
                            Scramble_Done <= '1'; 
                        end if;
                    end if;
                    
                when CALC_CHAOS =>
                    chaos_reg <= mux2_out;
                    state <= LATCH_MOVE;

                when LATCH_MOVE =>
                    S_Out <= random_face;
                    timer <= 0;
                    state <= HOLD_PULSE;

                when HOLD_PULSE =>
                    if timer < PULSE_WIDTH then
                        timer <= timer + 1;
                    else
                        S_Out <= "000";
                        timer <= 0;
                        state <= COOLDOWN;
                    end if;

                when COOLDOWN =>
                    if timer < COOLDOWN_MAX then
                        timer <= timer + 1;
                    else
                        state <= CHECK_DONE;
                    end if;

                when CHECK_DONE =>
                    moves_completed <= moves_completed + 1;
                    
                    if (moves_completed + 1) < unsigned(Moves_Needed) then
                        state <= CALC_CHAOS; 
                    else
                        Scramble_Done <= '1'; 
                        if Start_Scramble = '0' then
                            state <= IDLE;    
                        end if;
                    end if;

            end case;
        end if;
    end process;

end Behavioral;
