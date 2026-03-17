library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity move_controller is
    Port ( 
           Clk          : in STD_LOGIC;
           BTN_Execute  : in STD_LOGIC;                      
           SW_Direction : in STD_LOGIC;                      
           RESET, F, R, U, L, B, D : in std_logic;
           
           S_Out        : out STD_LOGIC_VECTOR (2 downto 0); -- sent to rubid 
           Face_For_Seq : out STD_LOGIC_VECTOR (2 downto 0)  -- Sent to the Sequence Detector
           );
end move_controller;

architecture Behavioral of move_controller is

    component moveEncoder is
      Port (
        RESET, F, R, U, L, B, D : in std_logic;
        Y : out std_logic_vector(2 downto 0) --  000 means hold , 111 means reset 
      );
    end component;
    
    type state_type is (IDLE, EXECUTE_1, EXECUTE_2, EXECUTE_3, WAIT_RELEASE);
    signal current_state, next_state : state_type := IDLE;
    signal SW_Face : std_logic_vector(2 downto 0);

begin

    EN: moveEncoder port map(
      RESET => RESET, F => F, R => R, U => U, L => L, B => B, D => D, Y => SW_Face
    );
        
    -- Constantly output the chosen face so the Sequence Detector can read it
    Face_For_Seq <= SW_Face;
        
    process(Clk)
    begin
        if falling_edge(Clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, BTN_Execute, SW_Direction, SW_Face)
    begin
        -- The brilliant default: "000" means do absolutely nothing!
        S_Out <= "000"; 
        next_state <= current_state; 

        case current_state is
            
            when IDLE =>
                if BTN_Execute = '1' then
                    next_state <= EXECUTE_1;
                end if;

            when EXECUTE_1 =>
                S_Out <= SW_Face; 
                if SW_Direction = '0' then 
                    next_state <= WAIT_RELEASE;
                else                       
                    next_state <= EXECUTE_2; 
                end if;

            when EXECUTE_2 =>
                S_Out <= SW_Face; 
                next_state <= EXECUTE_3;

            when EXECUTE_3 =>
                S_Out <= SW_Face; 
                next_state <= WAIT_RELEASE;

            when WAIT_RELEASE =>
                if BTN_Execute = '0' then
                    next_state <= IDLE;
                end if;

            when others =>
                next_state <= IDLE;
                
        end case;
    end process;

end Behavioral;