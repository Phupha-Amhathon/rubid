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

---

## Constraints (`rubid.srcs/constrs_1/new/rubid_pin.xdc`)

- **Clock**: 100 MHz on FPGA pin `E3`
- **Move inputs** (`S[0:2]`): Mapped to pins `U10`, `U11`, `U12`
- **Cube state output** (`Q_all`, 72 bits): Routed through the ILA core for on-chip debugging (too many bits for direct I/O pins)

---

## Design Architecture

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

---

## Technology

| Item | Detail |
|------|--------|
| Language | VHDL (IEEE.STD_LOGIC_1164) |
| FPGA | Xilinx Artix-7 `xc7a100tcsg324-1` (Nexys A7 100T) |
| Tool | Xilinx Vivado 2025.2 |
| Simulation | XSim (Vivado built-in) |
| Debug | Xilinx ILA (Integrated Logic Analyzer) |
