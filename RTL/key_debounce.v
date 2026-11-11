`timescale 1ns / 1ns
// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// File        : key_debounce.v
// Contents    : counter-based push-button debounce plus edge detection
//
// A mechanical button does not close cleanly.  The contacts bounce for
// 5 ms to 10 ms, so the raw level seen by the FPGA is a burst of pulses, and
// edge detection on the raw level would count one click as several presses.
// This module turns the noisy level into exactly one event per click:
//
//   key_in  --[2 FF sync]--> key_sync --[20 ms press filter]--> key_state
//                                     --[20 ms release filter]-->   |
//                                                                   |
//                         key_press = key_state_prev & ~key_state <--+
//
// The debounced level key_state only changes after the synchronised level has
// held the new value for CNT_MAX+1 pixel clocks, so a burst of contact bounce
// restarts the filter and never reaches the output.  key_press is then the
// falling edge of the debounced level: one click gives exactly one pulse,
// however long the button is held (the level stays low and no further edge
// appears) and however much it bounces.
//
// Timing budget (see the report, Section b):
//   debounce time 20 ms  >  worst-case bounce 10 ms  (2x margin)
//   20 ms at 25 MHz = 500,000 clocks  ->  19 bits (2^18 = 262,144 < 500,000
//   <= 2^19 = 524,288).  CNT_MAX = 499,999, so the counter reaches its final
//   value after exactly 500,000 clocks = 20.000 ms.
//
// Reset value of key_state is 0 ("pressed"), not 1 ("released"): a click is
// defined as a released->pressed edge, and a button that is already held when
// reset is released must not fabricate such an edge.  The first confirmed
// release after reset puts the detector into the released state, which costs a
// 20 ms blind window right after reset - far shorter than any human click.
// ============================================================================
`default_nettype none

module key_debounce (
    input  wire vga_clk,      // 25 MHz pixel clock (same domain as the FSM)
    input  wire sys_rst_n,    // asynchronous reset, active low
    input  wire key_in,       // raw button, asynchronous, active low
    output wire key_press     // one-clock pulse: button pressed
);

    // ------------------------------------------------------------------
    // 20 ms at 25 MHz: count 0 .. 499,999.
    // ------------------------------------------------------------------
    localparam [18:0] CNT_MAX = 19'd499_999;

    // ------------------------------------------------------------------
    // Two-flip-flop synchroniser.  The button is asynchronous to vga_clk, so
    // the first flip-flop may go metastable; the second gives the level a
    // full clock to settle before any logic uses it.
    // ------------------------------------------------------------------
    reg key_meta;
    reg key_sync;

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            key_meta <= 1'b1;         // released
            key_sync <= 1'b1;
        end else begin
            key_meta <= key_in;
            key_sync <= key_meta;
        end
    end

    // ------------------------------------------------------------------
    // Press filter: count how long the synchronised level has been low.
    // Any high sample restarts the count, so bounce cannot accumulate.
    // ------------------------------------------------------------------
    reg [18:0] cnt_press;

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_press <= 19'd0;
        else if (key_sync)
            cnt_press <= 19'd0;
        else if (cnt_press != CNT_MAX)
            cnt_press <= cnt_press + 19'd1;
    end

    // ------------------------------------------------------------------
    // Release filter: the mirror image, counting a stable high level.
    // ------------------------------------------------------------------
    reg [18:0] cnt_release;

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_release <= 19'd0;
        else if (!key_sync)
            cnt_release <= 19'd0;
        else if (cnt_release != CNT_MAX)
            cnt_release <= cnt_release + 19'd1;
    end

    // ------------------------------------------------------------------
    // Debounced level.  It only follows the raw level after the matching
    // filter has counted a full 20 ms of stable input.
    // ------------------------------------------------------------------
    reg key_state;

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            key_state <= 1'b0;        // "pressed": see the header note
        else if (!key_sync && (cnt_press == CNT_MAX))
            key_state <= 1'b0;
        else if ( key_sync && (cnt_release == CNT_MAX))
            key_state <= 1'b1;
    end

    // ------------------------------------------------------------------
    // Edge detection on the debounced level.  key_state_prev is one clock
    // behind key_state, so the AND below is high for exactly one clock after
    // a confirmed press.  A long press produces no second pulse because
    // key_state stays low until the release filter has finished.
    // ------------------------------------------------------------------
    reg key_state_prev;

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            key_state_prev <= 1'b0;
        else
            key_state_prev <= key_state;
    end

    assign key_press = key_state_prev & ~key_state;

endmodule

`default_nettype wire
