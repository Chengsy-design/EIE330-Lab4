`timescale 1ns / 1ns
// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// File        : screen_fsm.v
// Contents    : three-state Moore machine - which screen is displayed
//
// State set and transitions (one click = one transition):
//
//      reset            key_press          key_press          key_press
//        |                  |                  |                  |
//        v                  v                  v                  |
//   +---------+        +---------+        +---------+             |
//   |  BARS   |------->|  MUST   |------->|   END   |-------------+
//   +---------+        +---------+        +---------+
//
// Input  : key_press, the one-clock pulse from key_debounce.
// Output : screen_sel, a Moore output that depends on the state only.
//
// Encoding: one-hot (3 flip-flops).  The lecture's state-machine part warns
// that a register whose several flip-flops change on the same edge passes
// through undefined intermediate codes, and that the remedy is to make only
// one flip-flop change per transition.  A three-state cycle cannot be Gray
// coded at all - a cycle of odd length does not exist on a hypercube - so no
// encoding of this machine can change one bit on every step.  What an encoding
// can do is make the invalid codes harmless, and one-hot does it best here:
// each screen owns one state bit, the screen decode is a per-bit decode with no
// comparator, and every unused code (000 and the three two-bit codes) falls
// into the default branch, which shows the colour-bar screen.  A transient
// during a two-bit change can therefore only flash the bars for one pixel
// clock, never show a wrong word.  Cost: one flip-flop more than a 2-bit binary
// code (3 instead of 2).  Yosys's automatic encoding chooses one-hot for this
// machine as well (see the report, Section d).
//
// Three blocks, following the coding style taught in the lecture:
//   1. state register        (sequential, non-blocking, asynchronous reset)
//   2. next-state function   (combinational, blocking, default assignment)
//   3. output decode         (combinational Moore output)
// ============================================================================
`default_nettype none

module screen_fsm (
    input  wire       vga_clk,      // 25 MHz pixel clock
    input  wire       sys_rst_n,    // asynchronous reset, active low
    input  wire       key_press,    // one-clock pulse from key_debounce
    output reg  [1:0] screen_sel    // 0 = bars, 1 = MUST, 2 = END
);

    // ------------------------------------------------------------------
    // State encoding (one-hot) and the screen code presented to vga_pic.
    // ------------------------------------------------------------------
    localparam [2:0] S_BARS = 3'b001;
    localparam [2:0] S_MUST = 3'b010;
    localparam [2:0] S_END  = 3'b100;

    localparam [1:0] SCREEN_BARS = 2'd0;
    localparam [1:0] SCREEN_MUST = 2'd1;
    localparam [1:0] SCREEN_END  = 2'd2;

    reg [2:0] st_cur;    // current state
    reg [2:0] st_next;   // next state

    // ------------------------------------------------------------------
    // 2. Next-state function.  Every branch assigns st_next, and the default
    // branch covers the five unused one-hot codes, so the function is
    // complete and no latch can be inferred.  A state without a click is its
    // own next state: the machine holds until the next event.
    // ------------------------------------------------------------------
    always @(*) begin
        case (st_cur)
            S_BARS:  st_next = key_press ? S_MUST : S_BARS;
            S_MUST:  st_next = key_press ? S_END  : S_MUST;
            S_END:   st_next = key_press ? S_BARS : S_END;
            default: st_next = S_BARS;          // unused code: recover
        endcase
    end

    // ------------------------------------------------------------------
    // 1. State register.  Reset puts the machine in the colour-bar state
    // from any state, which is the reset requirement of the lab.
    // ------------------------------------------------------------------
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            st_cur <= S_BARS;
        else
            st_cur <= st_next;
    end

    // ------------------------------------------------------------------
    // 3. Moore output decode.  The output depends on the state only; the
    // picture therefore cannot change in the middle of a click.
    // ------------------------------------------------------------------
    always @(*) begin
        case (st_cur)
            S_MUST:  screen_sel = SCREEN_MUST;
            S_END:   screen_sel = SCREEN_END;
            default: screen_sel = SCREEN_BARS;
        endcase
    end

endmodule

`default_nettype wire
