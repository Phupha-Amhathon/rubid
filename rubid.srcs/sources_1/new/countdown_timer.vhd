library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity countdown_timer is
    Generic (
        MAX_TIME : integer := 255 -- Max value an 8-bit vector can hold
    );
    Port ( 
        Clk          : in STD_LOGIC;
        
        -- Game Setup Ports
        Load_Enable  : in STD_LOGIC;                      -- FSM says: "Load the starting time!"
        Time_In      : in STD_LOGIC_VECTOR(7 downto 0);   -- The starting time from the switches
        
        -- Countdown Port
        Tick_1Hz     : in STD_LOGIC;                      -- The 1-second subtract pulse
        
        -- Bonus Time Ports (Controlled by the outside world)
        Add_Enable   : in STD_LOGIC;                      -- Pulse high to add time
        Add_Value    : in STD_LOGIC_VECTOR(7 downto 0);   -- How much time to add
        
        -- Outputs
        Time_Out     : out STD_LOGIC_VECTOR(7 downto 0);  -- Sent to the 7-segment displays
        Time_Is_Zero : out STD_LOGIC                      -- Sent to Master FSM to end game
    );
end countdown_timer;

architecture Behavioral of countdown_timer is

    -- Changed to unsigned for bit-level manipulation
    signal current_time : unsigned(7 downto 0) := (others => '0');

begin

    process(Clk)
        variable bonus_uns : unsigned(7 downto 0);
        -- Variables to act as gates for Scenario B
        variable borrow    : std_logic_vector(8 downto 0);
        variable next_time : unsigned(7 downto 0);
    begin
        if falling_edge(Clk) then
            
            -- Priority 1: Load a brand new game time
            if Load_Enable = '1' then
                current_time <= unsigned(Time_In);
                
            -- Priority 2: Game is running
            elsif current_time > 0 then
                
                bonus_uns := unsigned(Add_Value);
                
                -- SCENARIO A: Collision! (Tick and Add)
                if Tick_1Hz = '1' and Add_Enable = '1' then
                    -- High-level addition/subtraction used here for complexity management
                    if (current_time + bonus_uns - 1) > MAX_TIME then
                        current_time <= to_unsigned(MAX_TIME, 8);
                    else
                        current_time <= current_time + bonus_uns - 1;
                    end if;
                    
                -- SCENARIO B: Normal 1-second countdown (GATE LEVEL)
                elsif Tick_1Hz = '1' then
                    borrow(0) := '1'; -- We want to subtract 1
                    for i in 0 to 7 loop
                        -- XOR Gate for Difference
                        next_time(i) := current_time(i) xor borrow(i);
                        -- NOT + AND Gate for Borrow
                        borrow(i+1)  := (not current_time(i)) and borrow(i);
                    end loop;
                    current_time <= next_time;
                    
                -- SCENARIO C: Adding the bonus time
                elsif Add_Enable = '1' then
                    if (current_time + bonus_uns) > MAX_TIME then
                        current_time <= to_unsigned(MAX_TIME, 8); 
                    else
                        current_time <= current_time + bonus_uns;
                    end if;
                end if;
                
            end if;
        end if;
    end process;

    Time_Out <= std_logic_vector(current_time);
    Time_Is_Zero <= '1' when current_time = 0 else '0';

end Behavioral;