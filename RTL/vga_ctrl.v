`timescale 1ns / 1ns
// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// File        : vga_ctrl.v
// Contents    : VGA timing engine for 640x480@60 (VESA DMT segment counts)
//
// The module is reused unchanged from the lecture example: timing control is
// independent of picture content.  Two counters walk through the six timing
// segments of a line and of a field.  The pixel colour is supplied by
// vga_pic through pix_data and is registered there, so this module requests
// the colour one pixel clock early (pix_data_req) and gates the output with
// rgb_valid.
//
//   line : sync 96 + back porch 40 + left border 8 + video 640
//          + right border 8 + front porch 8 = 800 pixel clocks
//   field: sync 2 + back porch 25 + top border 8 + video 480
//          + bottom border 8 + front porch 2 = 525 lines
// ============================================================================
`default_nettype none

module vga_ctrl (
    input  wire        vga_clk,       // VGA pixel clock, 25 MHz
    input  wire        sys_rst_n,     // asynchronous reset, active low
    input  wire [15:0] pix_data,      // RGB565 colour from vga_pic
    output wire [9:0]  pix_x,         // x coordinate of the requested pixel
    output wire [9:0]  pix_y,         // y coordinate of the requested pixel
    output wire        hsync,         // line sync, active high
    output wire        vsync,         // field sync, active high
    output wire [15:0] rgb            // RGB565 data of the visible pixel
);

    // ------------------------------------------------------------------
    // VESA DMT 640x480@60 segment counts (one pixel clock per H unit and
    // one complete line per V unit).
    // ------------------------------------------------------------------
    localparam [9:0] H_SYNC  = 10'd96;
    localparam [9:0] H_BACK  = 10'd40;
    localparam [9:0] H_LEFT  = 10'd8;
    localparam [9:0] H_VALID = 10'd640;
    localparam [9:0] H_RIGHT = 10'd8;
    localparam [9:0] H_FRONT = 10'd8;
    localparam [9:0] H_TOTAL = H_SYNC + H_BACK + H_LEFT + H_VALID
                             + H_RIGHT + H_FRONT;          // 800

    localparam [9:0] V_SYNC  = 10'd2;
    localparam [9:0] V_BACK  = 10'd25;
    localparam [9:0] V_TOP   = 10'd8;
    localparam [9:0] V_VALID = 10'd480;
    localparam [9:0] V_BOTTOM= 10'd8;
    localparam [9:0] V_FRONT = 10'd2;
    localparam [9:0] V_TOTAL = V_SYNC + V_BACK + V_TOP + V_VALID
                             + V_BOTTOM + V_FRONT;         // 525

    // First pixel-clock count of the addressable window, and of the request
    // window (which is one clock earlier).
    localparam [9:0] H_ACTIVE_FIRST = H_SYNC + H_BACK + H_LEFT;        // 144
    localparam [9:0] H_REQ_FIRST    = H_SYNC + H_BACK + H_LEFT - 10'd1;// 143
    localparam [9:0] V_ACTIVE_FIRST = V_SYNC + V_BACK + V_TOP;         // 35

    reg [9:0] cnt_h;   // 0 .. 799, pixel position in one line
    reg [9:0] cnt_v;   // 0 .. 524, line position in one field

    // ------------------------------------------------------------------
    // Horizontal counter: one line scan cycle.
    // ------------------------------------------------------------------
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_h <= 10'd0;
        else if (cnt_h == H_TOTAL - 10'd1)
            cnt_h <= 10'd0;
        else
            cnt_h <= cnt_h + 10'd1;
    end

    // ------------------------------------------------------------------
    // Vertical counter: one field scan cycle, advanced at the end of a line.
    // ------------------------------------------------------------------
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            cnt_v <= 10'd0;
        else if ((cnt_v == V_TOTAL - 10'd1) && (cnt_h == H_TOTAL - 10'd1))
            cnt_v <= 10'd0;
        else if (cnt_h == H_TOTAL - 10'd1)
            cnt_v <= cnt_v + 10'd1;
        else
            cnt_v <= cnt_v;
    end

    // ------------------------------------------------------------------
    // Sync pulses: high during the sync segment.
    // ------------------------------------------------------------------
    assign hsync = (cnt_h <= H_SYNC - 10'd1) ? 1'b1 : 1'b0;
    assign vsync = (cnt_v <= V_SYNC - 10'd1) ? 1'b1 : 1'b0;

    // ------------------------------------------------------------------
    // Addressable window: the intersection of the horizontal and vertical
    // video segments.  Only here may rgb carry picture data.
    // ------------------------------------------------------------------
    wire rgb_valid;
    assign rgb_valid =
        (cnt_h >= H_ACTIVE_FIRST) &&
        (cnt_h <  H_ACTIVE_FIRST + H_VALID) &&
        (cnt_v >= V_ACTIVE_FIRST) &&
        (cnt_v <  V_ACTIVE_FIRST + V_VALID);

    // ------------------------------------------------------------------
    // Colour request: the same window, but starting one pixel clock early.
    // vga_pic registers its colour, so this lead makes pix_data available at
    // the first visible pixel instead of one pixel later.
    // ------------------------------------------------------------------
    wire pix_data_req;
    assign pix_data_req =
        (cnt_h >= H_REQ_FIRST) &&
        (cnt_h <  H_REQ_FIRST + H_VALID) &&
        (cnt_v >= V_ACTIVE_FIRST) &&
        (cnt_v <  V_ACTIVE_FIRST + V_VALID);

    // Coordinates of the pixel being generated.  Outside the request window
    // the coordinates are forced to 1023, which is outside every character
    // box, so vga_pic outputs the background colour.
    assign pix_x = (pix_data_req == 1'b1)
                 ? (cnt_h - H_REQ_FIRST) : 10'h3ff;
    assign pix_y = (pix_data_req == 1'b1)
                 ? (cnt_v - V_ACTIVE_FIRST) : 10'h3ff;

    // Outside the addressable window the monitor must receive black.
    assign rgb = (rgb_valid == 1'b1) ? pix_data : 16'h0000;

endmodule

`default_nettype wire
