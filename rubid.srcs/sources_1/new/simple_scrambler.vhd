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

    -- ---> BUG FIX 1: The wheel must start at 1 ("001") <---
    signal fast_counter : unsigned(2 downto 0) := "001";
    signal random_face  : std_logic_vector(2 downto 0);

    type state_type is (IDLE, LATCH_MOVE, HOLD_PULSE, COOLDOWN, CHECK_DONE);
    signal state : state_type := IDLE;

    signal moves_completed : unsigned(3 downto 0) := (others => '0');
    
    signal timer : integer := 0;
    constant PULSE_WIDTH  : integer := 10;      
    constant COOLDOWN_MAX : integer := 100_000; 

begin

    -- ----------------------------------------------------------------------
    -- 1. THE ROULETTE WHEEL
    -- ----------------------------------------------------------------------
    process(Clk)
    begin
        if rising_edge(Clk) then
            -- ---> BUG FIX 2: Count 1 to 6 ("001" to "110"), avoiding "000" and "111" <---
            if fast_counter = "110" then
                fast_counter <= "001";
            else
                fast_counter <= fast_counter + 1;
            end if;
        end if;
    end process;

    random_face <= std_logic_vector(fast_counter);

    -- ----------------------------------------------------------------------
    -- 2. THE TIMING PIPELINE 
    -- ----------------------------------------------------------------------
    process(Clk, Reset)
    begin
        if Reset = '1' then
            state <= IDLE;
            moves_completed <= (others => '0');
            -- ---> BUG FIX 3: "000" is the true HOLD/IDLE state <---
            S_Out <= "000"; 
            Scramble_Done <= '0';
            timer <= 0;
            
        elsif rising_edge(Clk) then
            case state is
                
                when IDLE =>
                    Scramble_Done <= '0';
                    S_Out <= "000"; -- ---> BUG FIX 3 <---
                    moves_completed <= (others => '0');
                    
                    if Start_Scramble = '1' then
                        if unsigned(Moves_Needed) > 0 then
                            state <= LATCH_MOVE;
                        else
                            Scramble_Done <= '1'; 
                        end if;
                    end if;

                when LATCH_MOVE =>
                    S_Out <= random_face;
                    timer <= 0;
                    state <= HOLD_PULSE;

                when HOLD_PULSE =>
                    if timer < PULSE_WIDTH then
                        timer <= timer + 1;
                    else
                        S_Out <= "000"; -- ---> BUG FIX 3 <---
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
                        state <= LATCH_MOVE; 
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