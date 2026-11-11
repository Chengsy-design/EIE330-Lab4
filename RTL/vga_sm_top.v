`timescale 1ns / 1ns
// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// File        : vga_sm_top.v
// Contents    : top level - the interface required by the lab
//
//     inputs : sys_clk (50 MHz), sys_rst_n (active-low reset),
//              key_in (switching button, active low)
//     outputs: hsync, vsync, rgb[15:0] (RGB565)
//
// Structure (see the report, Figure 3):
//
//   sys_clk --[pll]--> vga_clk --+--> key_debounce --> key_press
//                                |                          |
//                                |                    screen_fsm --> screen_sel
//                                |                          |
//                                +--> vga_ctrl <--pix_data-- vga_pic <--+
//
//   vga_ctrl is the Lab 3 timing engine, reused unchanged;
//   vga_pic is the Lab 3 pixel generator extended with the two text screens;
//   key_debounce and screen_fsm are the new blocks of this lab.
// ============================================================================
`default_nettype none

module vga_sm_top (
    input  wire        sys_clk,      // 50 MHz board clock
    input  wire        sys_rst_n,    // asynchronous reset, active low
    input  wire        key_in,       // switching button, active low
    output wire        hsync,        // VGA line sync
    output wire        vsync,        // VGA field sync
    output wire [15:0] rgb           // RGB565 pixel data
);

    wire        vga_clk;             // 25 MHz pixel clock
    wire        key_press;           // one-clock pulse per click
    wire [1:0]  screen_sel;          // 0 = bars, 1 = MUST, 2 = END
    wire [9:0]  pix_x;               // current pixel x coordinate
    wire [9:0]  pix_y;               // current pixel y coordinate
    wire [15:0] pix_data;            // registered colour from vga_pic

    // Pixel clock: 50 MHz / 2 = 25 MHz.
    pll u_pll (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .vga_clk   (vga_clk)
    );

    // Button: synchronise, debounce (20 ms) and detect one edge per click.
    key_debounce u_key_debounce (
        .vga_clk   (vga_clk),
        .sys_rst_n (sys_rst_n),
        .key_in    (key_in),
        .key_press (key_press)
    );

    // State machine: which screen is shown.
    screen_fsm u_screen_fsm (
        .vga_clk    (vga_clk),
        .sys_rst_n  (sys_rst_n),
        .key_press  (key_press),
        .screen_sel (screen_sel)
    );

    // Timing engine, reused from Lab 3.
    vga_ctrl u_vga_ctrl (
        .vga_clk   (vga_clk),
        .sys_rst_n (sys_rst_n),
        .pix_data  (pix_data),
        .pix_x     (pix_x),
        .pix_y     (pix_y),
        .hsync     (hsync),
        .vsync     (vsync),
        .rgb       (rgb)
    );

    // Picture source: colour bars, MUST, END.
    vga_pic u_vga_pic (
        .vga_clk    (vga_clk),
        .sys_rst_n  (sys_rst_n),
        .screen_sel (screen_sel),
        .pix_x      (pix_x),
        .pix_y      (pix_y),
        .pix_data   (pix_data)
    );

endmodule

`default_nettype wire
