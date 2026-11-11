# EIE330 Lab 4 — Simple State Machine

A 640×480@60 VGA screen controller that cycles through three screens
(colour bars → “MUST” → “END” → bars) on one debounced push button, with an
asynchronous reset that returns to the bars from every state.

## Structure

```
Lab_4_1/
├── RTL/                  synthesizable design files, one module per file
│   ├── pll.v             divide-by-2 pixel clock (reused from Lab 3)
│   ├── key_debounce.v    synchroniser + two 20 ms filters + edge detector
│   ├── screen_fsm.v      three-state Moore machine, one-hot
│   ├── vga_ctrl.v        timing engine (reused from Lab 3, unchanged)
│   ├── vga_pic.v         bars / MUST / END pixel generator
│   └── vga_sm_top.v      top level: the six ports of the lab
├── Sim/                  self-checking testbenches and the board model
│   ├── tb_pll.v                    pixel clock, duty, reset
│   ├── tb_vga_ctrl.v               hsync/vsync widths, window, request lead
│   ├── tb_key_debounce.v           bounce, long press, two clicks, reset
│   ├── tb_screen_fsm.v             the three-click cycle and the state reset
│   ├── tb_vga_pic.v                exhaustive 3 × 307,200-pixel sweep
│   ├── tb_vga_sm_top.v             end-to-end cycle + one frame per screen
│   ├── tb_vga_reset.v              reset from every state, mid-click, held
│   ├── tb_no_debounce.v            the same click without debounce (41 transitions)
│   └── board/                      Simple VGA Simulator board model
│       ├── DevelopmentBoard.v      clk/reset/B2 → the design’s ports
│       ├── simulator.cpp           course harness (+ optional SIMCAP hook)
│       └── run_simulation.sh       Verilator + SDL2 build and run
├── scripts/              figure tools (Python, see the AI note below)
│   ├── vcd_util.py       minimal VCD reader
│   ├── screen_model.py   independent model of the three screens
│   ├── wave_tikz.py      VCD → vector TikZ waveform figures
│   ├── make_figures.py   screens comparison + waveform figures
│   └── make_tikz.py      bitmap figure, expected-screen figure
├── doc/                  (kept empty, as the course convention asks)
├── results/              generated: VCDs, logs, captured frames
└── Makefile
```

## Reproduce everything

```sh
make check     # iverilog -Wall, verilator --lint-only -Wall, yosys check + stat + fsm
make sim       # eight testbenches, each self-checking ($fatal on a mismatch)
make figures   # writes the report figures into ../../LaTeX/figures
```

`make sim` takes about two minutes: the debounce test alone simulates 479 ms of
real time (12 M pixel clocks). The VCD files are kept small by dumping only the
signals that carry the evidence and by dumping the counter as its top nine bits.

## The board model

`make board` builds the course’s Simple VGA Simulator with Verilator and SDL2 and
opens the virtual board. The wrapper maps `clk`, `reset`, `B2` (the switching
button), `h_sync`, `v_sync` and `rgb`, and leaves B3–B5 and the LEDs unconnected.

Two harness notes, so that nothing looks like a hidden change:

* The simulator’s buttons are mouse clicks. For an **unattended capture** the
  wrapper can be compiled with `-DAUTO_CLICK`, which drives `key_in` from a
  48 ms period instead of B2; the RTL is untouched. The captures in
  `results/sim_*.png` were taken that way.
* `simulator.cpp` carries a small `SIMCAP` hook that writes the 640×480 VGA
  surface to a BMP once per second. It only saves the surface; it does not
  change what the window displays.

## Notes

* The debounce can only be proven in simulation: the virtual buttons do not
  bounce. `tb_key_debounce.v` injects the bounce itself (0.1 ms toggle period,
  8 ms burst) and `tb_no_debounce.v` measures what the same click does without
  the filter.
* The Python tools under `scripts/` were written with AI assistance (DeepSeek)
  at the team’s specification; the RTL, the testbenches and the verification
  criteria were written and reviewed by the team. See the AI-use statement in
  the report.
