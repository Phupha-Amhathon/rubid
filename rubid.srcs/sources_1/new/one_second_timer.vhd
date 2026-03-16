library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity one_second_timer is
    Generic (
        -- 100 MHz clock frequency for Nexys A7
        CLK_FREQ : integer := 100_000_000 
    );
    Port ( 
        Clk      : in  STD_LOGIC;
        Reset    : in  STD_LOGIC; -- To restart the timer when a new game starts
        Tick_1Hz : out STD_LOGIC  -- The 1-clock-cycle pulse every second
    );
end one_second_timer;

architecture Behavioral of one_second_timer is

    -- We need a counter big enough to hold 99,999,999
    signal counter : integer range 0 to CLK_FREQ - 1 := 0;

begin

    process(Clk)
    begin
        -- Keeping your strict falling edge requirement!
        if falling_edge(Clk) then
            
            if Reset = '1' then
                -- When the Master FSM says reset, clear everything instantly
                counter <= 0;
                Tick_1Hz <= '0';
                
            else
                -- Normal counting operation
                if counter = CLK_FREQ - 1 then
                    counter <= 0;       -- Reset the counter
                    Tick_1Hz <= '1';    -- Fire the 1-second pulse!
                else
                    counter <= counter + 1; -- Keep counting
                    Tick_1Hz <= '0';        -- Keep pulse low
                end if;
            end if;
            
        end if;
    end process;

end Behavioral;