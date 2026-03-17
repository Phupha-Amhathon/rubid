library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sexy_move_detector is
    Port (
        Clk          : in STD_LOGIC;
        BTN_Execute  : in STD_LOGIC;                      
        SW_Face      : in STD_LOGIC_VECTOR(2 downto 0);   
        SW_Direction : in STD_LOGIC;                      
        Time_Bonus   : out STD_LOGIC;                     
        
        -- for debugging 
        Debug_State  : out STD_LOGIC_VECTOR(5 downto 0)   
    );
end sexy_move_detector;

architecture Behavioral of sexy_move_detector is

    type state_type is (IDLE, GOT_R, GOT_U, GOT_R_PRIME, GOT_U_PRIME);
    signal current_state, next_state : state_type := IDLE;

    -- execute button is press button, so it can remain 1 for multiple cycles. We only want to trigger on the transition from 0 to 1, so we need to store the previous state of the button.
    signal btn_prev  : STD_LOGIC := '0';
    signal move_tick : STD_LOGIC := '0';

begin

    -- for debugging:
    with current_state select
        Debug_State <= "000001" when IDLE,          -- 0 LEDs: Waiting for start
                       "000010" when GOT_R,         -- 1 LED:  R is successful
                       "000100" when GOT_U,         -- 2 LEDs: U is successful (binary 2)
                       "001000" when GOT_R_PRIME,   -- 3 LEDs: R' is successful (binary 3)
                       "010000" when GOT_U_PRIME,   -- 1 LED:  U' successful! (binary 4)
                       "100000" when others;        -- Error state indicator

    -- ==========================================
    -- 1. Synchronous Process
    -- ==========================================
    --ensure one click one exicute 
    process(Clk)
    begin
        if falling_edge(Clk) then
            btn_prev <= BTN_Execute;          
            current_state <= next_state;      
        end if;
    end process;

    move_tick <= BTN_Execute and (not btn_prev);

    -- ==========================================
    -- 2. Combinatorial Next State Logic
    -- ==========================================
    process(current_state, move_tick, SW_Face, SW_Direction)
    begin
        next_state <= current_state;
        Time_Bonus <= '0'; 

        case current_state is
            
            when IDLE =>
                if move_tick = '1' then
                    if SW_Face = "010" and SW_Direction = '0' then 
                        next_state <= GOT_R;
                    end if;
                end if;

            when GOT_R =>
                if move_tick = '1' then
                    if SW_Face = "011" and SW_Direction = '0' then 
                        next_state <= GOT_U; 
                    elsif SW_Face = "010" and SW_Direction = '0' then 
                        next_state <= GOT_R; 
                    else
                        next_state <= IDLE;  
                    end if;
                end if;

            when GOT_U =>
                if move_tick = '1' then
                    if SW_Face = "010" and SW_Direction = '1' then 
                        next_state <= GOT_R_PRIME; 
                    elsif SW_Face = "010" and SW_Direction = '0' then 
                        next_state <= GOT_R;       
                    else
                        next_state <= IDLE;        
                    end if;
                end if;

            when GOT_R_PRIME =>
                if move_tick = '1' then
                    if SW_Face = "011" and SW_Direction = '1' then 
                        next_state <= GOT_U_PRIME; 
                    elsif SW_Face = "010" and SW_Direction = '0' then 
                        next_state <= GOT_R;       
                    else
                        next_state <= IDLE;        
                    end if;
                end if;

            when GOT_U_PRIME =>
                Time_Bonus <= '1'; 
                next_state <= IDLE;

        end case;
    end process;

end Behavioral;