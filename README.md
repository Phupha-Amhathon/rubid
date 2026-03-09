# Rubid – Rubik's Cube Simulator in VHDL

**Rubid** is a digital hardware project that implements a **Rubik's Cube simulator** using VHDL, designed for FPGA synthesis on the **Nexys A7 100T** board with **Xilinx Vivado 2025.2**.

The design tracks the state of **24 facelets** (4 per face × 6 faces) on a 3×3 Rubik's Cube. This is a **simplified model** that represents only the four **corner facelets** of each face. The center facelet of each face never moves in a real Rubik's Cube (it defines the face colour) and is therefore omitted; the four edge facelets are also not modelled individually. Each tracked facelet is represented by a 3-bit colour code. Users can apply any of the six standard cube moves (Front, Right, Up, Left, Back, Down) via hardware inputs, and the complete 72-bit cube state can be monitored through an on-chip ILA (Integrated Logic Analyzer).

---

## Directory Structure

```
rubid/
├── rubid.xpr                    # Vivado project file
├── rubid.srcs/                  # All design sources
│   ├── sources_1/
│   │   ├── new/                 # VHDL source files (core logic)
│   │   └── ip/ila_0/            # ILA IP core (auto-generated)
│   ├── sim_1/
│   │   └── new/                 # VHDL testbench files
│   ├── constrs_1/
│   │   └── new/                 # Pin constraint files (XDC)
│   └── utils_1/
│       └── imports/synth_1/     # Synthesised design checkpoint (.dcp)
├── rubid.gen/                   # Auto-generated files by Vivado
│   └── sources_1/ip/ila_0/      # Generated ILA IP wrappers and models
├── .gitignore
└── README.md
```

---

## Source Files (`rubid.srcs/sources_1/new/`)

These are the hand-written VHDL files that implement the cube logic, built bottom-up from primitive gates to the full cube.

| File | Description |
|------|-------------|
| `RubidMark1.vhd` | **Top-level module.** Accepts individual move buttons (F, R, U, L, B, D) and RESET, passes them through `moveEncoder` to produce a 3-bit selector, then drives the `Rubid` core. Exposes a 72-bit output `Q`. |
| `Rubid.vhd` | **Core cube module.** Instantiates 24 `Facelet` components (4 corner facelets per face × 6 faces — the centre and edge facelets are not modelled). Concatenates all facelet outputs into the 72-bit signal `Q_all`. |
| `moveEncoder.vhd` | **Priority encoder.** Converts 7 individual move inputs (RESET, F, R, U, L, B, D) into a 3-bit selector signal for the Rubid core. |
| `Facelet.vhd` | **Single facelet unit.** Holds a 3-bit colour value in a `PIPORegister3bit`. Uses a `MUX8To1_3bit` to select which of the eight possible move inputs (RESET + 6 moves + hold) updates its state on each clock edge. |
| `PIPORegister3bit.vhd` | **3-bit PIPO register.** Three `DFlipFlop` instances in parallel. Stores the current colour of one facelet. |
| `DFlipFlop.vhd` | **1-bit D flip-flop.** Behavioural implementation with synchronous Preset/Clear, triggered on the falling clock edge. |
| `DLatch.vhd` | **D latch (gate-level).** SR latch-based building block used by the flip-flop. |
| `MUX8To1_3bit.vhd` | **3-bit 8-to-1 multiplexer.** Stacks three `MUX8To1` instances to handle 3-bit operands. |
| `MUX8To1.vhd` | **1-bit 8-to-1 multiplexer.** Gate-level structural design using a 3-stage tree of `MUX2To1`. |
| `MUX2To1.vhd` | **1-bit 2-to-1 multiplexer.** Gate-level primitive: `Y = (I0 AND NOT S) OR (I1 AND S)`. |
| `3bitMUX8To1.vhd` | Placeholder/stub file (empty architecture). |
| `LFSR6bit.vhd` | **6-bit Fibonacci LFSR.** Structural, built from six `DFlipFlop` instances with one XOR feedback gate. Polynomial x⁶ + x + 1 (taps at bits 5 and 0) gives a maximal-length period of 63. Seeded to `101010` on RESET to avoid the all-zero lock-up state. |
| `Counter5bit.vhd` | **5-bit synchronous up counter.** Gate-level (AND/OR/NOT/XOR + `DFlipFlop`). Counts 0 → 20, then asserts `done` and freezes. Provides the 20-move window for the scrambler. |
| `MoveDecoder.vhd` | **3-bit → one-hot move decoder.** Purely combinational gate-level logic. Maps the lower 3 bits of the LFSR to exactly one of {F, R, U, L, B, D}. Values `000` and `111` are remapped to F and D respectively. All outputs are ANDed with `enable` (= NOT done). |
| `RandMoveGen.vhd` | **Random 20-move generator.** Structural top-level wiring `LFSR6bit` + `Counter5bit` + `MoveDecoder` together. Outputs individual F, R, U, L, B, D signals and a `done` flag. |
| `RubidRand.vhd` | **Complete auto-scrambler.** Structural top-level connecting `RandMoveGen` → `RubidMark1`. Applies 20 pseudo-random moves to the cube starting from the solved state. |

### Colour Encoding (3-bit)

| Code | Colour |
|------|--------|
| `000` | White  |
| `001` | Green  |
| `010` | Yellow |
| `011` | Red    |
| `100` | Blue   |
| `101` | Orange |

---

## Testbench Files (`rubid.srcs/sim_1/new/`)

| File | Description |
|------|-------------|
| `tb_RubidMark1.vhd` | Tests the full top-level `RubidMark1` module by stimulating the seven individual move buttons. |
| `tb_Rubid.vhd` | Tests the core `Rubid` module directly using a 3-bit selector stimulus. Includes colour aliases for all 24 facelets (u0–u3, f0–f3, etc.). |
| `tb_Facelet.vhd` | Unit test for a single `Facelet` component. |
| `tb_moveEncoder.vhd` | Unit test for the `moveEncoder` priority encoder. |
| `tb_RandMoveGen.vhd` | Tests `RandMoveGen` + `RubidMark1` together. Verifies that exactly 20 pseudo-random moves are generated and applied to the cube, printing each move name and the resulting cube diagram. |

---

## Constraints (`rubid.srcs/constrs_1/new/rubid_pin.xdc`)

- **Clock**: 100 MHz on FPGA pin `E3`
- **Move inputs** (`S[0:2]`): Mapped to pins `U10`, `U11`, `U12`
- **Cube state output** (`Q_all`, 72 bits): Routed through the ILA core for on-chip debugging (too many bits for direct I/O pins)

---

## Design Architecture

### Cube simulator

```
RubidMark1  (Top-level – FPGA I/O)
├── moveEncoder  (F, R, U, L, B, D + RESET → 3-bit selector)
└── Rubid  (Core cube logic)
    └── 24× Facelet  (one per coloured square)
        ├── PIPORegister3bit  (stores current colour)
        │   └── 3× DFlipFlop
        │       └── DLatch
        └── MUX8To1_3bit  (selects move input)
            └── 3× MUX8To1
                └── 3-stage tree of MUX2To1
```

### Auto-scrambler (random 20 moves)

```
RubidRand  (Top-level auto-scrambler)
├── RandMoveGen  (pseudo-random move sequencer)
│   ├── LFSR6bit      (6-bit Fibonacci LFSR, seed=101010, poly x⁶+x+1)
│   ├── Counter5bit   (5-bit up counter, stops at 20 → done=1)
│   └── MoveDecoder   (LFSR[2:0] → one-hot {F,R,U,L,B,D}, gated by enable)
└── RubidMark1  (cube simulator, same as above)
```

---

## Technology

| Item | Detail |
|------|--------|
| Language | VHDL (IEEE.STD_LOGIC_1164) |
| FPGA | Xilinx Artix-7 `xc7a100tcsg324-1` (Nexys A7 100T) |
| Tool | Xilinx Vivado 2025.2 |
| Simulation | XSim (Vivado built-in) |
| Debug | Xilinx ILA (Integrated Logic Analyzer) |

---

## Randomised 20-Move Scrambler (Gate Level)

### Problem

Generate 20 pseudo-random Rubik's Cube moves {F, R, U, L, B, D} entirely from combinational and sequential gate primitives.

### Solution: LFSR-based move sequencer

The scrambler is built from three collaborating gate-level modules:

```
LFSR6bit ─── Q[2:0] ──► MoveDecoder ─── F,R,U,L,B,D ──►
                              ▲
Counter5bit ─── done ──► enable (NOT done)
```

#### 1 — `LFSR6bit` — pseudo-random bit source

A **6-bit Fibonacci LFSR** (Linear Feedback Shift Register) built from six `DFlipFlop` instances and one XOR gate.

```
Feedback = Q(5) XOR Q(0)          ← polynomial x⁶ + x + 1, period = 63

Shift at every falling clock edge:
  Q(5) ← Q(4) ← Q(3) ← Q(2) ← Q(1) ← Q(0) ← feedback
```

Seed on RESET = **`101010`** (loaded via the synchronous Pre/Clr pins of each DFF).  This avoids the all-zero lock-up state.

#### 2 — `Counter5bit` — 20-move window

A **5-bit synchronous up counter** built entirely from DFlipFlops and carry-chain gate logic. It counts 0 → 20, then asserts `done` and holds.

```
done   = Q(4) AND NOT Q(3) AND Q(2) AND NOT Q(1) AND NOT Q(0)   -- count = 20
enable = NOT done
```

#### 3 — `MoveDecoder` — LFSR bits → move signal

A purely combinational gate-level decoder maps the lower 3 bits of the LFSR to one-hot {F, R, U, L, B, D}:

| LFSR Q\[2:0\] | Move |
|:---:|:---:|
| 000 | F *(remapped)* |
| 001 | F |
| 010 | R |
| 011 | U |
| 100 | L |
| 101 | B |
| 110 | D |
| 111 | D *(remapped)* |

```vhdl
F <= (NOT Q2 AND NOT Q1)                         AND enable;
R <= (NOT Q2 AND Q1 AND NOT Q0)                  AND enable;
U <= (NOT Q2 AND Q1 AND Q0)                      AND enable;
L <= (Q2 AND NOT Q1 AND NOT Q0)                  AND enable;
B <= (Q2 AND NOT Q1 AND Q0)                      AND enable;
D <= (Q2 AND Q1)                                 AND enable;
```

#### 4 — `RandMoveGen` — structural top-level

Wires LFSR6bit + Counter5bit + MoveDecoder.  Outputs: F, R, U, L, B, D, done.

#### 5 — `RubidRand` — complete auto-scrambler

Connects RandMoveGen → RubidMark1.  A single module you can drop into a design that needs a scrambled cube.

### Resulting 20-move sequence (seed `101010`)

| # | Move | # | Move |
|--:|:----:|--:|:----:|
| 1 | R | 11 | D |
| 2 | B | 12 | D |
| 3 | U | 13 | B |
| 4 | D | 14 | U |
| 5 | L | 15 | D |
| 6 | F | 16 | B |
| 7 | U | 17 | R |
| 8 | D | 18 | L |
| 9 | B | 19 | F |
|10 | U | 20 | R |

### Timing diagram

```
Clock   : __↓__↓__↓__↓__↓__↓__↓__↓__↓__↓__↓__↓__↓__ ...
RESET   : ‾‾‾‾‾‾__|___________________ ...  (2 cycles)
Counter : 0    0    1    2    3    4   ...  19   20
done    : 0    0    0    0    0    0   ...   0    1
Move    : -    -    R    B    U    D   ...   R    -
```

### How to simulate

Open `tb_RandMoveGen.vhd` in Vivado Simulation.  The testbench:
1. Asserts RESET for 2 clock cycles.
2. Prints each of the 20 moves to the Tcl console with the cube state diagram.
3. Halts after move 20 is confirmed.
