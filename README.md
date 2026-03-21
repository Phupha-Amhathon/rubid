ถ้าให้เธอเป้นเสื้อเธอคงเป็นbaby tree 
<pre>
top_rubid_game
├── master_game_controller
│   ├── inputs:
│   │   ├── Time_Is_Zero (from countdown_timer)
│   │   ├── Is_Solved (from RubidMark2)
│   │   └── Scramble_Done (from hardware_scrambler)
│   └── outputs:
│       ├── Game_Active (enables move_controller)
│       ├── Timer_Load (to countdown_timer)
│       ├── Is_Scrambling (to hardware_scrambler, mux)
│       ├── LED_Win / LED_Lose (to LED)
├── button_debouncer (used to clean buttons)
├── videoRubik
├── RubidMark2
│   ├── Rubid
│   │   └── Facelet (24x)
│   │       ├── PIPORegister3bit
│   │       └── MUX8To1_3bit
│   │           └── MUX8To1
│   │               └── MUX2To1
│   └── face_checker (6x)
├── move_controller
│   └── moveEncoder
├── mux_3bit_2to1 (between move_controller/hardware_scrambler and cube)
├── sexy_move_detector
├── one_second_timer
├── countdown_timer
├── seven_segment_controller
├── hardware_scrambler
    ├── machine_reverse
    ├── machine_cut
    ├── machine_shuffle
    ├── machine_poker_deal
    ├── machine_xor_magic
    ├── machine_consecutive_xor
    ├── machine_doce_fleur
    ├── machine_all_in


</pre>
# RubidMark2 Project Component Documentation

---

## 1. top_rubid_game

**Purpose:**  
Top-level integration module that interfaces with hardware controls, connects game logic, display, and input/output peripherals of the digital Rubik's Cube.

**Interface:**  
- Inputs:  
  - `CLK100MHZ`: 100 MHz clock for the system  
  - `CPU_RESETN`: Active-low reset (physical red button)  
  - `BTNC`: Center button (execute move)  
  - `BTNU`: Up button (start new game)  
  - `BTND`: Down button (reset cube colors)  
  - `SW[15:0]`: 16 switches for face/direction/time/game mode  
    - `SW(5:0)`: Face selectors (D, B, L, U, R, F)  
    - `SW(6)`: Direction (0=CW, 1=CCW)  
    - `SW(14:7)`: Start time for challenge mode  
    - `SW(15)`: Game mode (0=free play, 1=challenge)  
- Outputs:  
  - `LED[15:0]`:  
    - `LED(5:0)`: Sequence progress/debug  
    - `LED(14)`: Lose indicator  
    - `LED(15)`: Win indicator  
  - `SEG[6:0]`: 7-segment display signals  
  - `AN[7:0]`: 7-segment digit select signals  
  - `hsync`, `vsync`, `rgb[11:0]`: VGA outputs for display

**Internal wires:**  
- Connect button/switches to controllers
- Route outputs from game logic to LEDs and display
- Connect timer pulses to countdown logic
- Pass cube state (`Q_all`) to VGA and 7-segment display

---

## 2. move_controller

**Purpose:**  
Collects user button/switch actions and encodes them into cube move commands for the Rubid game memory.

**Interface:**  
- Inputs:  
  - `Clk`: System clock  
  - `BTN_Execute`: Button for move execution  
  - `SW_Direction`: Rotation direction  
  - `RESET, F, R, U, L, B, D`: Face selectors/reset
- Outputs:  
  - `S_Out`: 3-bit move command for Rubid  
  - `Face_For_Seq`: 3-bit face code for pattern detection

**Internal wires:**  
- `SW_Face`: Encoded face (from moveEncoder)  
- FSM state signals (`current_state`, `next_state`) for move processing  
- Internal signal assignment for output moves and sequencing
  
---

## 3. RubidMark2

**Purpose:**  
Main cube logic module with built-in victory (solved) detection.

**Interface:**  
- Inputs:  
  - `S`: 3-bit move selector  
  - `Clk`: Clock
- Outputs:  
  - `Q_all`: 72-bit cube sticker color state  
  - `is_solved`: Single bit high if solved

**Internal wires:**  
- `q_internal`: Internal cube state  
- `solid_flags`: Array of per-face "all same" status bits  
- Wires between Rubid core and face_checker units

---

## 4. Rubid

**Purpose:**  
Cube memory module; tracks each sticker’s color and manages updates for moves.

**Interface:**  
- Inputs:  
  - `S`: 3-bit move control  
  - `Clk`: Clock  
- Outputs:  
  - `Q_all`: 72-bit color vector representing all stickers

**Internal wires:**  
- Color signals for each sticker (24 facelet outputs: `s_u0,s_u1,...,s_d3`)  
- Facelet interconnections (wires connecting input for each facelet from neighboring ones)

---

## 5. Facelet

**Purpose:**  
Represents a single sticker/cubie’s color state, updating based on moves or reset.

**Interface:**  
- Inputs:  
  - `MD, MB, ML, MU, MR, MF`: Neighboring color inputs (down, back, left, up, right, front)  
  - `load_init`: Initial color for reset  
  - `S`: Selector for operation/move  
  - `Clk`: Clock  
- Output:  
  - `Q`: Current color code

**Internal wires:**  
- `sQ`: Storage register output  
- `sI`: Selected input from multiplexer for update

---

## 6. sexy_move_detector

**Purpose:**  
Detects the "sexy move" (R U R' U') for bonus/time logic, monitors player move input stream.

**Interface:**  
- Inputs:  
  - `Clk`: Clock  
  - `BTN_Execute`: Move button  
  - `SW_Face`: Face code input  
  - `SW_Direction`: Direction input
- Outputs:  
  - `Time_Bonus`: High pulse when sequence detected  
  - `Debug_State`: 6-bit FSM state for LEDs/debugging

**Internal wires:**  
- FSM state signal for move sequence tracking  
- Wires for face code and direction from input

---

## 7. one_second_timer

**Purpose:**  
Divides system clock to generate a 1Hz time pulse for countdowns or triggering events.

**Interface:**  
- Generics:  
  - `CLK_FREQ`: System frequency
- Inputs:  
  - `Clk`: Clock  
  - `Reset`: Reset
- Output:  
  - `Tick_1Hz`: Single bit, asserted once per second

**Internal wires:**  
- Counter (integer)  
- Wire from counter to output (pulse logic)

---

## 8. button_debouncer

**Purpose:**  
Removes button press noise/false triggers; ensures only one pulse per press.

**Interface:**  
- Inputs:  
  - `Clk`: Clock  
  - `BTN_In`: Button input
- Output:  
  - `BTN_Out`: Clean, debounced signal

**Internal wires:**  
- Debouncer state signal  
- Wire tracking last button state

---

## 9. videoRubik

**Purpose:**  
Renders cube state on VGA monitor, using RGB and sync signals.

**Interface:**  
- Inputs:  
  - `clk`: Clock  
  - `reset`: Reset
  - `Q_all`: Cube state vector
- Outputs:  
  - `hsync`, `vsync`: VGA synchronization signals  
  - `rgb`: 12-bit RGB video output

**Internal wires:**  
- VGA timing counters  
- Wire mapping cube sticker colors to screen regions

---

## 10. seven_segment_controller

**Purpose:**  
Drives the 7-segment 8-digit display, showing timer or score.

**Interface:**  
- Inputs:  
  - `Clk`: Clock  
  - `Reset`: Reset  
  - `Time_In`: 8-bit time/count input
- Outputs:  
  - `SEG`: Segment signals (A-G)  
  - `AN`: Digit selector (anode signals)

**Internal wires:**  
- Multiplexing signal to cycle active digit  
- Wire to segment decoder

---

## 11. hardware_scrambler

**Purpose:**  
Automatically generates a pseudo-random sequence of moves to scramble the cube for new games.

**Interface:**  
- Inputs:  
  - `Clk`: Clock  
  - `Reset`: Reset  
  - `Start_Scramble`: Start trigger  
  - `Moves_Needed`: How many moves to output
- Outputs:  
  - `S_Out`: 3-bit move code per step  
  - `Scramble_Done`: High when scramble finished

**Internal wires:**  
- FSM state signal for scrambling
- Move step counter
- Output wire for each generated move sequence

---

## master_game_controller

**Purpose:**  
Manages the overall game state and flow. Handles mode selection (free vs challenge), controls game start, triggers scrambles, monitors win/loss, and enables or locks user actions based on the state.

**Interface:**  
- Inputs:  
  - `Clk`: System clock  
  - `Reset`: Synchronous system/game reset  
  - `BTN_Start`: Button signal to begin a game  
  - `SW_Mode`: Switch to select free (0) or challenge (1) mode  
  - `Time_Is_Zero`: High when timer expires (from countdown_timer)  
  - `Is_Solved`: High when cube is solved (from RubidMark2)  
  - `Scramble_Done`: High when hardware_scrambler finishes scramble  
- Outputs:  
  - `Game_Active`: High when player is allowed to move cube  
  - `Timer_Load`: Pulse to reload countdown timer from switch value  
  - `Is_Scrambling`: High to trigger or indicate scrambling process  
  - `LED_Win`: High for Win (LED output, e.g. LED(15))  
  - `LED_Lose`: High for Lose (LED output, e.g. LED(14))

**Internal wires/signals:**  
- `current_state`, `next_state` (enumerated type): Tracks game state (INIT, FREE_MODE, CHALLENGE_LOAD, CHALLENGE_SCRAMBLE, CHALLENGE_PLAY, GAME_OVER_WIN, GAME_OVER_LOSE)
- Logic between state, timer, RubidMark2, scramble, and control outputs
- Signals to/from state machine for initialization, in-game, game-over, and control interlocks
