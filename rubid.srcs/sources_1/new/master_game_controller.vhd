library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity master_game_controller is
    Port ( 
        Clk          : in STD_LOGIC;
        Reset        : in STD_LOGIC;                      -- System reset (returns to INIT state)
        BTN_Start    : in STD_LOGIC;                      -- Player presses to begin game, start counting time, and allow move controls
        SW_Mode      : in STD_LOGIC;                      -- '0' = Free Mode, '1' = Challenge Mode
        
        -- Inputs from other modules
        Time_Is_Zero : in STD_LOGIC;                      -- From the Countdown Timer
        Is_Solved    : in STD_LOGIC;                      -- From RubidMark2
        Scramble_Done: in STD_LOGIC;
        
        -- Control Outputs to other modules
        Game_Active  : out STD_LOGIC;                     -- Enables the Move Controller
        Timer_Load   : out STD_LOGIC;                     -- Tells the Timer to grab switch values
        Is_Scrambling: out STD_LOGIC;               -- NEW: Tells the Scrambler to start scrambling (Challenge Mode only)   
        
        -- LED Status Flags
        LED_Win      : out STD_LOGIC;
        LED_Lose     : out STD_LOGIC
    );
end master_game_controller;

    architecture Behavioral of master_game_controller is

    type game_state_type is (
        INIT, 
        FREE_MODE, 
        CHALLENGE_LOAD, 
        CHALLENGE_SCRAMBLE,
        CHALLENGE_PLAY, 
        GAME_OVER_WIN, 
        GAME_OVER_LOSE
    );
    signal current_state, next_state : game_state_type := INIT;

begin

    -- ==========================================
    -- 1. Synchronous State Register (Falling Edge)
    -- ==========================================
    process(Clk)
    begin
        if falling_edge(Clk) then
            if Reset = '1' then
                current_state <= INIT;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;

    -- ==========================================
    -- 2. Combinatorial Next State & Output Logic
    -- ==========================================
    process(current_state, BTN_Start, SW_Mode, Time_Is_Zero, Is_Solved)
    begin
        -- Default output states (prevents latches)
        next_state  <= current_state;
        Game_Active <= '0';
        Timer_Load  <= '0';
        Is_Scrambling <= '0';
        LED_Win     <= '0';
        LED_Lose    <= '0';

        case current_state is
            
            -- --------------------------------------
            -- THE TRUNK: Waiting for player to start
            -- --------------------------------------
            when INIT =>
                -- Wait for the player to press Start
                if BTN_Start = '1' then
                    if SW_Mode = '0' then
                        next_state <= FREE_MODE;
                    else
                        next_state <= CHALLENGE_LOAD;
                    end if;
                end if;

            -- --------------------------------------
            -- BRANCH A: Free Play Sandbox
            -- --------------------------------------
            when FREE_MODE =>
                Game_Active <= '1'; -- Unlock the cube controls
                -- Notice we ignore Time_Is_Zero here. Play forever!
                -- We only leave this state if the user hits the physical Reset button.
                
                -- Optional: If they solve it in free mode, light up the win LED anyway!
                if Is_Solved = '1' then
                    LED_Win <= '1';
                end if;

            -- --------------------------------------
            -- BRANCH B: Challenge Mode
            -- --------------------------------------
            when CHALLENGE_LOAD =>
                Timer_Load <= '1';            -- Send exactly one pulse to Scorekeeper
                next_state <= CHALLENGE_SCRAMBLE; -- Immediately jump to gameplay

            when CHALLENGE_SCRAMBLE =>
                Is_Scrambling <= '1'; -- Tells the MUX to switch tracks and Scrambler to start
                Game_Active   <= '0'; -- Ensure the player's buttons stay locked
                
                -- Wait here until the scrambler chip finishes its job
                if Scramble_Done = '1' then
                    next_state <= CHALLENGE_PLAY;
                end if;

            when CHALLENGE_PLAY =>
                Game_Active <= '1'; -- Unlock the cube controls
                
                -- Check for Win Condition FIRST (Priority)
                if Is_Solved = '1' then
                    next_state <= GAME_OVER_WIN;
                    
                -- Check for Lose Condition SECOND
                elsif Time_Is_Zero = '1' then
                    next_state <= GAME_OVER_LOSE;
                end if;

            -- --------------------------------------
            -- ENDGAMES: Lock the board and display LEDs
            -- --------------------------------------
            when GAME_OVER_WIN =>
                Game_Active <= '0'; -- Lock the cube controls!
                LED_Win     <= '1'; -- Turn on the green LED
                -- Wait here until the player hits Reset

            when GAME_OVER_LOSE =>
                Game_Active <= '0'; -- Lock the cube controls!
                LED_Lose    <= '1'; -- Turn on the red LED
                -- Wait here until the player hits Reset

        end case;
    end process;

end Behavioral;