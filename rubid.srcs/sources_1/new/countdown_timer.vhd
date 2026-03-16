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

    signal current_time : integer range 0 to MAX_TIME := 0;

begin

    process(Clk)
        variable bonus_int : integer;
    begin
        if falling_edge(Clk) then
            
            -- Priority 1: Load a brand new game time
            if Load_Enable = '1' then
                current_time <= to_integer(unsigned(Time_In));
                
            -- Priority 2: Game is running
            elsif current_time > 0 then
                
                -- Convert the incoming bonus vector to an integer for easy math
                bonus_int := to_integer(unsigned(Add_Value));
                
                -- SCENARIO A: Collision! Tick and Add happen on the exact same cycle
                if Tick_1Hz = '1' and Add_Enable = '1' then
                    if (current_time - 1 + bonus_int) > MAX_TIME then
                        current_time <= MAX_TIME;
                    else
                        current_time <= current_time - 1 + bonus_int;
                    end if;
                    
                -- SCENARIO B: Normal 1-second countdown
                elsif Tick_1Hz = '1' then
                    current_time <= current_time - 1;
                    
                -- SCENARIO C: Adding the bonus time
                elsif Add_Enable = '1' then
                    if (current_time + bonus_int) > MAX_TIME then
                        current_time <= MAX_TIME; 
                    else
                        current_time <= current_time + bonus_int;
                    end if;
                end if;
                
            end if;
        end if;
    end process;

    Time_Out <= std_logic_vector(to_unsigned(current_time, 8));
    Time_Is_Zero <= '1' when current_time = 0 else '0';

end Behavioral;