`timescale 1ns / 1ns
// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// File        : pll.v
// Contents    : divide-by-2 pixel-clock generator
//
// The board clock is 50 MHz.  One 640x480@60 line needs 800 pixel clocks and
// one frame needs 525 lines, so the pixel clock must be about 25 MHz:
//     800 x 525 x 60 = 25,200,000 Hz  ->  50 MHz / 2 = 25 MHz.
//
// The lecture calls this block "pll" because it plays the role of a PLL: it
// produces the clock frequency the VGA controller needs.  It is a plain
// toggle register, not a real PLL; the report discusses that difference.
// ============================================================================
`default_nettype none

module pll (
    input  wire sys_clk,      // system clock, 50 MHz
    input  wire sys_rst_n,    // asynchronous reset, active low
    output reg  vga_clk       // VGA pixel clock, 25 MHz
);

    // Toggle on every rising edge of the 50 MHz clock: the output period is
    // two system-clock periods, i.e. 40 ns, i.e. 25 MHz, with a 50 % duty.
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            vga_clk <= 1'b0;
        else
            vga_clk <= ~vga_clk;
    end

endmodule

`default_nettype wire
