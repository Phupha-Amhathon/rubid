-- ==============================================================================
-- Project: Digital Rubik's Cube Game (RubidMark2)
-- Hardware: Nexys A7-100T FPGA
-- Description: Top-level structural wrapper. 
-- ==============================================================================

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- ------------------------------------------------------------------------------
-- 1. THE ENTITY (The Physical Board Connections)
-- ------------------------------------------------------------------------------
ENTITY top_rubid_game IS
    PORT (
        -- SYSTEM CLOCK & RESET
        CLK100MHZ : IN STD_LOGIC; -- The raw 100 million ticks/sec clock
        CPU_RESETN : IN STD_LOGIC; -- The physical red system reset button (Active Low), set to init state 

        -- PLAYER INPUTS (Buttons)
        BTNC : IN STD_LOGIC; -- Center Button: Execute a normal move
        BTNU : IN STD_LOGIC; -- Up Button: Start a new game
        BTND : IN STD_LOGIC; -- NEW: Down Button: Reset the Cube to default colors

        -- PLAYER INPUTS (Switches)
        SW : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- SW(5 downto 0)  : The 6 faces (D, B, L, U, R, F), select face active high
        -- SW(6)           : Direction (0 = Clockwise, 1 = Counter-Clockwise)
        -- SW(14 downto 7) : 8-bit Binary input for starting time (Challenge Mode) -> Max 255 seconds
        -- SW(15)          : Game Mode (0 = Free Play, 1 = Challenge Mode)

        -- PLAYER OUTPUTS (LEDs)
        LED : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); 
         -- -----------------------------
        -- LED(5 downto 0)  : Debug LEDs showing the Sexy Move sequence state --show sexy move progress
        -- LED(13 downto 6)  : unused
        -- LED(14)           : LOSE Indicator
        -- LED(15)           : WIN Indicator 

        -- ---> ADDED FOR 7-SEGMENT <---
        SEG : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- The 7 shapes (A through G)
        AN  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- The 8 digit selector anodes
       
        
        -- VGA OUTPUTS
        hsync   : out STD_LOGIC;
        vsync   : out STD_LOGIC;
        rgb     : out STD_LOGIC_VECTOR(11 downto 0)
        
        -- for test!
--        DEBUG_CUBE_STATE : out STD_LOGIC_VECTOR(71 downto 0) 
    
    
    );
END top_rubid_game;

ARCHITECTURE Structural OF top_rubid_game IS
    
    -- --------------------------------------------------------------------------
    -- 2. COMPONENT DECLARATIONS (The Chip Catalog)
    -- --------------------------------------------------------------------------

    -- human input. Reads the switches and button to output a clean 3-bit move.
    COMPONENT move_controller
        PORT (
            Clk : IN STD_LOGIC;
            BTN_Execute : IN STD_LOGIC; -- execute command
            SW_Direction : IN STD_LOGIC; -- selects CW vs CCW
            RESET, F, R, U, L, B, D : IN STD_LOGIC; -- selects which face to turn
            S_Out : OUT STD_LOGIC_VECTOR (2 DOWNTO 0); -- Encodes the move as 3bit to send to the cube memory, default 000
            Face_For_Seq : OUT STD_LOGIC_VECTOR (2 DOWNTO 0));
    END COMPONENT;

    --  Handles game states, locks controls, and triggers win/loss.
    COMPONENT master_game_controller
        PORT (
            Clk : IN STD_LOGIC;
            Reset : IN STD_LOGIC; 
            BTN_Start : IN STD_LOGIC;       -- for start the game
            SW_Mode : IN STD_LOGIC;         -- select mode
            Time_Is_Zero : IN STD_LOGIC;    --time out flag
            Is_Solved : IN STD_LOGIC;       --solved flag
            Scramble_Done: in STD_LOGIC;    -- connect to scrambler 

            Game_Active : OUT STD_LOGIC;    -- flag to unlock move controller and start the game
            Timer_Load : OUT STD_LOGIC;     -- flag to load the initial time to timer 
            Is_Scrambling: out STD_LOGIC;   -- flag for mux to switch from move controller to scrambler during the scramble phase
            LED_Win : OUT STD_LOGIC;    
            LED_Lose : OUT STD_LOGIC);     
    END COMPONENT;

    -- Holds remaining time, handles math, and prevents overflow.
    COMPONENT countdown_timer
        GENERIC (MAX_TIME : INTEGER := 255);
        PORT (
            Clk : IN STD_LOGIC;
            Load_Enable : IN STD_LOGIC;                -- flag for loading initial time from switch
            Time_In : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- 8-bit input for starting time
            Tick_1Hz : IN STD_LOGIC;                   -- minus one second pulse from the metronome
            Add_Enable : IN STD_LOGIC;                 -- flag for adding bonus time (from sexy move rewards)
            Add_Value : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- how much bonus time to add 

            Time_Out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- current remaining time
            Time_Is_Zero : OUT STD_LOGIC);              -- flag to indicate time has run out 
    END COMPONENT;

    -- The "Metronome". Divides 100MHz down to a clean 1-second pulse.
    COMPONENT one_second_timer
        GENERIC (CLK_FREQ : INTEGER := 100_000_000);
        PORT (
            Clk : IN STD_LOGIC;
            Reset : IN STD_LOGIC; 
            Tick_1Hz : OUT STD_LOGIC); --1 second pulse 
    END COMPONENT;

    -- The sexy move reader. Rewards players for the R-U-R'-U' move.
    COMPONENT sexy_move_detector
        PORT (
            Clk : IN STD_LOGIC;
            BTN_Execute : IN STD_LOGIC; --synced 
            SW_Face : IN STD_LOGIC_VECTOR(2 DOWNTO 0);  -- Face code
            SW_Direction : IN STD_LOGIC;                -- Direction (0 = Clockwise, 1 = Counter-Clockwise) 
            Time_Bonus : OUT STD_LOGIC;                 -- time bonus trigger
            Debug_State : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
            ); 
            --for debugging: outputs the current state of the sequence detector to the LEDs
    END COMPONENT;

    -- The "Memory Core". Your original code wrapped with a win-condition checker.
    COMPONENT RubidMark2
        PORT (
            S : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            Clk : IN STD_LOGIC;
            Q_all : OUT STD_LOGIC_VECTOR (71 DOWNTO 0);
            is_solved : OUT STD_LOGIC);
    END COMPONENT;

    -- -- Cleans up physical button bounces so 1 human press = exactly 1 digital pulse.
    COMPONENT button_debouncer
        PORT (
            Clk : IN STD_LOGIC;
            BTN_In : IN STD_LOGIC;
            BTN_Out : OUT STD_LOGIC);
    END COMPONENT;

    -- VGA Video Controller for displaying the Rubik's Cube
    COMPONENT videoRubik
        PORT (
            clk     : IN  STD_LOGIC;
            reset   : IN  STD_LOGIC;
            Q_all   : IN  STD_LOGIC_VECTOR(71 downto 0);
            hsync   : OUT STD_LOGIC;
            vsync   : OUT STD_LOGIC;
            rgb     : OUT STD_LOGIC_VECTOR(11 downto 0)
        );
    END COMPONENT;
    
    component seven_segment_controller is
    Port (
        Clk      : in STD_LOGIC;
        Reset    : in STD_LOGIC;
        Time_In  : in STD_LOGIC_VECTOR(7 downto 0);  -- The 8-bit binary timer (0 to 255)
        
        -- Physical outputs to the Nexys A7 Board (Active Low)
        SEG      : out STD_LOGIC_VECTOR(6 downto 0); -- A, B, C, D, E, F, G
        AN       : out STD_LOGIC_VECTOR(7 downto 0)  -- The 8 digit Anodes
    );
    end component;

    --for scrambling 
    COMPONENT hardware_scrambler
        PORT ( 
            Clk            : in STD_LOGIC;
            Reset          : in STD_LOGIC;
            Start_Scramble : in STD_LOGIC;
            Moves_Needed   : in STD_LOGIC_VECTOR(3 downto 0);
            S_Out          : out STD_LOGIC_VECTOR(2 downto 0);
            Scramble_Done  : out STD_LOGIC
        );
    END COMPONENT;

    -- The 3-bit Train Track Switch
    COMPONENT mux_3bit_2to1
        PORT (
            Sel : in STD_LOGIC;
            In0 : in STD_LOGIC_VECTOR(2 downto 0);
            In1 : in STD_LOGIC_VECTOR(2 downto 0);
            Y   : out STD_LOGIC_VECTOR(2 downto 0)
        );
    END COMPONENT;

    -- --------------------------------------------------------------------------
    -- 3. INTERNAL SIGNALS (The Copper Traces on the Motherboard)
    -- --------------------------------------------------------------------------

    SIGNAL sys_reset : STD_LOGIC;

    -- Debounced Button Wires
    SIGNAL clean_btn_exec : STD_LOGIC; -- Cleaned center button
    SIGNAL clean_btn_start : STD_LOGIC; -- Cleaned up button
    SIGNAL clean_btn_reset_cube : STD_LOGIC; -- Cleaned down button

    -- Data routing wires
    SIGNAL S_to_Cube : STD_LOGIC_VECTOR(2 DOWNTO 0); ---connect move controller to cube
    SIGNAL face_to_detector : STD_LOGIC_VECTOR(2 DOWNTO 0); --connect move controller to sexy move 

    -- Master Controller state wires
    SIGNAL game_active_wire : STD_LOGIC;
    SIGNAL timer_load_wire : STD_LOGIC;
    SIGNAL tick_1hz_wire : STD_LOGIC;
    SIGNAL time_is_zero_wire : STD_LOGIC;
    SIGNAL time_bonus_wire : STD_LOGIC;
    SIGNAL is_solved_wire : STD_LOGIC;

    -- Security Gate Wires
    SIGNAL secure_btn_exec : STD_LOGIC;
    SIGNAL secure_btn_reset : STD_LOGIC;
    SIGNAL combined_execute : STD_LOGIC;

    SIGNAL cube_memory_out : STD_LOGIC_VECTOR(71 DOWNTO 0);
    SIGNAL auto_boot_reset : STD_LOGIC;

    -- ---> ADDED: Wires for Scrambler and MUX <---
    SIGNAL is_scrambling         : STD_LOGIC;
    SIGNAL scr_done_wire         : STD_LOGIC;
    SIGNAL scr_s_out             : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL move_controller_S_Out : STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- --------------------------------------------

    --sys scramble amout
    signal scramble_moves_needed : STD_LOGIC_VECTOR(3 downto 0):="0010";
    
    -- ---> ADDED FOR 7-SEGMENT <---
    SIGNAL current_time_wire : STD_LOGIC_VECTOR(7 DOWNTO 0); -- Carries the time from the Timer to the Display

BEGIN
    LED(13 DOWNTO 6) <= "00000000"; -- Unused LEDs turned off
    -- --------------------------------------------------------------------------
    -- 4. HARDWARE LOGIC & SECURITY GATES
    -- --------------------------------------------------------------------------

    -- Invert Nexys A7's active-low CPU_RESETN to active-high for our modules
    sys_reset <= NOT CPU_RESETN;

    -- GATE 1: Normal Execute Button
    -- Only allowed through if the Master FSM says the game is currently active.
    secure_btn_exec <= clean_btn_exec AND game_active_wire;

    -- GATE 2: The Anti-Cheat Reset Cube Button
    -- The player is ONLY allowed to reset the cube if:
    -- 1. The game is active AND
    -- 2. We are in FREE MODE (SW(15) = '0'). 
    -- If they are in Challenge Mode (SW(15) = '1'), this gate physical cuts the wire!
    secure_btn_reset <= clean_btn_reset_cube AND game_active_wire AND (NOT SW(15));
    -- THE AUTO-BOOTLOADER (Your Idea!):
    -- This wire goes high if the human legally presses the Reset Cube button,
    -- OR if the system is booting up (sys_reset).
    auto_boot_reset <= secure_btn_reset OR sys_reset;

    -- GATE 3: The Combined Trigger
    -- Wakes up the Move Controller if a normal move is made, OR if the boot/reset triggers.
    combined_execute <= secure_btn_exec OR auto_boot_reset;

    -- --------------------------------------------------------------------------
    -- 5. PORT MAPPING (Soldering the chips to the board)
    -- --------------------------------------------------------------------------

    --- DEBOUNCERS ---
   U_Debounce_Exec : button_debouncer PORT MAP(
       Clk => CLK100MHZ, BTN_In => BTNC, BTN_Out => clean_btn_exec
   );
   U_Debounce_Start : button_debouncer PORT MAP(
       Clk => CLK100MHZ, BTN_In => BTNU, BTN_Out => clean_btn_start
   );
   U_Debounce_ResetCube : button_debouncer PORT MAP(
       Clk => CLK100MHZ, BTN_In => BTND, BTN_Out => clean_btn_reset_cube
   );
      -- DIRECT CONNECTION FOR SIMULATION ONLY:
        -- clean_btn_exec       <= BTNC;
        -- clean_btn_start      <= BTNU;
        -- clean_btn_reset_cube <= BTND;

    -- --- MOVE CONTROLLER ---
    U_Move_Controller : move_controller PORT MAP(
        Clk => CLK100MHZ,
        BTN_Execute => combined_execute, -- Uses the OR gate trigger
        SW_Direction => SW(6), -- Now safely on SW6
        D => SW(0), B => SW(1), L => SW(2), U => SW(3), R => SW(4), F => SW(5),
        RESET => auto_boot_reset, -- the merged wire so it resets on button press OR system boot!
        
        -- ---> CHANGED: Route output to the MUX wire, not the Cube <---
        S_Out => move_controller_S_Out,
        -- -------------------------------------------------------------
        
        Face_For_Seq => face_to_detector
    );

    -- --- MASTER GAME CONTROLLER ---
    U_Game_Master : master_game_controller PORT MAP(
        Clk => CLK100MHZ,
        Reset => sys_reset,
        BTN_Start => clean_btn_start,
        SW_Mode => SW(15),
        Time_Is_Zero => time_is_zero_wire,
       Is_Solved => is_solved_wire,
        -- Is_Solved => '0', -- by pass for test 
        
        Scramble_Done => scr_done_wire,
        Is_Scrambling => is_scrambling,
        
        Game_Active => game_active_wire,
        Timer_Load => timer_load_wire,
        LED_Win => LED(15),
        LED_Lose => LED(14)
    );

    -- ---> ADDED: The Hardware Scrambler <---
    U_Scrambler : hardware_scrambler PORT MAP(
        Clk            => CLK100MHZ,
        Reset          => sys_reset,
        Start_Scramble => is_scrambling,
        Moves_Needed   => scramble_moves_needed,
        S_Out          => scr_s_out,
        Scramble_Done  => scr_done_wire
    );
    -- ---------------------------------------

    -- ---> ADDED: The Datapath MUX <---
    U_Datapath_Mux : mux_3bit_2to1 PORT MAP(
        Sel => is_scrambling,
        In0 => move_controller_S_Out,
        In1 => scr_s_out,
        Y   => S_to_Cube
    );
    -- ---------------------------------

    -- --- METRONOME ---
    U_Heartbeat : one_second_timer GENERIC MAP(CLK_FREQ => 100_000_000)
    PORT MAP(
        Clk => CLK100MHZ,
        Reset => sys_reset,
        Tick_1Hz => tick_1hz_wire
    );

    -- --- SCOREKEEPER ---
    U_Timer : countdown_timer GENERIC MAP(MAX_TIME => 255)
    PORT MAP(
        Clk          => CLK100MHZ,
        Load_Enable  => timer_load_wire,
        Time_In      => SW(14 DOWNTO 7), 
        Tick_1Hz     => tick_1hz_wire,
        Add_Enable   => time_bonus_wire,
        Add_Value    => "00000101", 
        
        -- ---> CHANGED: Connect to our new wire! <---
        Time_Out     => current_time_wire, 
        
        Time_Is_Zero => time_is_zero_wire
    );

    -- ---> ADDED FOR 7-SEGMENT <---
    U_SevenSeg : seven_segment_controller PORT MAP(
        Clk     => CLK100MHZ,
        Reset   => sys_reset,
        Time_In => current_time_wire, -- Reads the time from the Scorekeeper
        SEG     => SEG,               -- Goes out to the physical board pins
        AN      => AN                 -- Goes out to the physical board pins
    );

    -- --- SEQUENCE DETECTOR ---
    U_Sexy_Detector : sexy_move_detector PORT MAP(
        Clk => CLK100MHZ,
        BTN_Execute => secure_btn_exec, -- Only reads normal moves (ignores resets!)
        SW_Face => face_to_detector,
        SW_Direction => SW(6), -- Updated to SW6
        Time_Bonus => time_bonus_wire,
        Debug_State => LED(5 DOWNTO 0)
    );

    -- --- RUBIK'S CUBE MEMORY ---
    U_Cube : RubidMark2 PORT MAP(
        S => S_to_Cube,
        Clk => CLK100MHZ,
        Q_all => cube_memory_out,
--        Q_all => DEBUG_CUBE_STATE,

        is_solved => is_solved_wire
    );
    
    -- --- VGA VIDEO CONTROLLER ---
    U_Video : videoRubik PORT MAP(
        clk     => CLK100MHZ,
        reset   => sys_reset,
        Q_all   => cube_memory_out,
        hsync   => hsync,
        vsync   => vsync,
        rgb     => rgb
    );
    
--    DEBUG_CUBE_STATE <= cube_memory_out;
END Structural;