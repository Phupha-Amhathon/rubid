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
        Scramble_Done: in STD_LOGIC;                      -- from scrambler 
        
        -- Control Outputs to other modules
        Game_Active  : out STD_LOGIC;                     -- Enables the Move Controller
        Timer_Load   : out STD_LOGIC;                     -- Tells the Timer to grab switch values
        Is_Scrambling: out STD_LOGIC;                     -- connect to mux 
        
        -- LED Status Flags
        LED_Win      : out STD_LOGIC;
        LED_Lose     : out STD_LOGIC
    );
end master_game_controller;

architecture Gate_Level of master_game_controller is
    component DFlipFlop is
    Port ( 
        D   : in  std_logic;
        Clk : in  std_logic;
        Q   : out std_logic;
        nQ  : out std_logic;
        Pre, Clr: in std_logic
    );
    end component;

    -- Current State 
    signal q2, q1, q0 : std_logic;
    signal nq2, nq1, nq0 : std_logic;

    -- Next State 
    signal d2, d1, d0 : std_logic;

    -- Edge Detector Wires
    signal start_prev : std_logic;

    -- Incoming/Internal Wires
    signal start, mode, timeout, isSolved, scrambleDone: std_logic;
    signal n_timeout, n_mode : std_logic;

begin

    -- ==========================================
    -- 1. Input Mapping & Inverters (CRITICAL FIX)
    -- ==========================================
    nq2 <= not q2;
    nq1 <= not q1;
    nq0 <= not q0;
    
    mode <= SW_Mode;
    n_mode <= not mode;
    
    timeout <= Time_Is_Zero;
    n_timeout <= not timeout;
    
    isSolved <= Is_Solved;
    scrambleDone <= Scramble_Done;

    -- ==========================================
    -- 2. Edge Detector for Start Button
    -- ==========================================
    U_Start_Edge: DFlipFlop port map(
        D   => BTN_Start,
        Clk => Clk,
        Q   => start_prev, 
        nQ  => open, 
        Pre => '0',
        Clr => Reset
    );
    -- 'start' is only high for exactly ONE clock cycle
    start <= BTN_Start and (not start_prev); 

    -- ==========================================
    -- 3. Next State Combinational Logic
    -- ==========================================
    d2 <= (nq2 and q1 and q0) or (q2 and nq1 and nq0) or (q2 and nq1 and q0) or (q2 and q1 and nq0) or (q2 and q1 and q0);
    
    d1 <= (nq2 and nq1 and nq0 and start and mode) or 
          (nq2 and q1 and nq0) or 
          (q2 and nq1 and q0 and timeout) or 
          (q2 and nq1 and q0 and n_timeout and isSolved) or 
          (q2 and q1 and nq0) or 
          (q2 and q1 and q0);
          
    d0 <= (nq2 and nq1 and nq0 and start and n_mode) or 
          (nq2 and nq1 and q0) or 
          (nq2 and q1 and nq0 and start) or 
          (q2 and nq1 and nq0 and scrambleDone) or 
          (q2 and nq1 and q0 and n_timeout) or 
          (q2 and q1 and q0); 

    -- ==========================================
    -- 4. Output Logic (With Async Reset Masking)
    -- ==========================================
    Game_Active   <= ((nq2 and nq1 and q0) or (q2 and nq1 and q0)) and (not Reset);
    Timer_Load    <= ((nq2 and q1 and nq0) or (nq2 and q1 and q0)) and (not Reset);
    Is_Scrambling <= (q2 and nq1 and nq0) and (not Reset);
    LED_Win       <= (q2 and q1 and q0) and (not Reset);
    LED_Lose      <= (q2 and q1 and nq0) and (not Reset);

    -- ==========================================
    -- 5. State Register Flip-Flops
    -- ==========================================
    U_Q2: DFlipFlop port map(
        D   => d2, Clk => Clk, Q => q2, nQ => open, Pre => '0', Clr => Reset
    );
    
    U_Q1: DFlipFlop port map(
        D   => d1, Clk => Clk, Q => q1, nQ => open, Pre => '0', Clr => Reset
    );

    U_Q0: DFlipFlop port map(
        D   => d0, Clk => Clk, Q => q0, nQ => open, Pre => '0', Clr => Reset
    );

end Gate_Level;