`timescale 1ns / 1ns
// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// File        : DevelopmentBoard.v  (Simple VGA Simulator board model)
// Purpose     : map the simulator's board signals onto the lab design.
//
//   board signal      module port     note
//   ------------      -----------     ------------------------------------
//   clk               sys_clk         50 MHz virtual oscillator
//   reset             sys_rst_n       active-low reset button ("a")
//   B2                key_in          active-low switching button ("s")
//   h_sync            hsync
//   v_sync            vsync
//   rgb[15:0]         rgb             RGB565
//   led1..led5        unconnected     not used by this design
//
// Define AUTO_CLICK when the window is captured without a mouse (the
// simulator's buttons are driven by mouse clicks, and the capture script has
// no mouse).  The RTL is not changed: only the source of key_in is.
// ============================================================================
`default_nettype none

module DevelopmentBoard (
    input  wire        clk,        // 50 MHz
    input  wire        reset,      // active-low reset button
    input  wire        B2,         // active-low switching button
    input  wire        B3,
    input  wire        B4,
    input  wire        B5,
    output wire        h_sync,
    output wire        v_sync,
    output wire [15:0] rgb,
    output wire        led1,
    output wire        led2,
    output wire        led3,
    output wire        led4,
    output wire        led5
);

`ifdef AUTO_CLICK
    // ------------------------------------------------------------------
    // Scripted click source, used only to photograph the window: one click
    // every 48 ms of simulated time (28 ms pressed, 20 ms released), which
    // the debounce turns into exactly one transition per period.  The clock
    // is 50 MHz, the debounce runs on the 25 MHz pixel clock.
    // ------------------------------------------------------------------
    reg [27:0] div = 28'd0;
    reg        key_auto = 1'b1;

    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            div      <= 28'd0;
            key_auto <= 1'b1;
        end else begin
            div <= div + 28'd1;
            if (div == 28'd1_000_000)       // 20 ms at 50 MHz
                key_auto <= 1'b0;
            else if (div == 28'd2_400_000) begin
                key_auto <= 1'b1;
                div      <= 28'd0;
            end
        end
    end

    wire key_in = key_auto;
`else
    wire key_in = B2;
`endif

    vga_sm_top u_vga_sm_top (
        .sys_clk   (clk),
        .sys_rst_n (reset),
        .key_in    (key_in),
        .hsync     (h_sync),
        .vsync     (v_sync),
        .rgb       (rgb)
    );

    assign led1 = 1'b0;
    assign led2 = 1'b0;
    assign led3 = 1'b0;
    assign led4 = 1'b0;
    assign led5 = 1'b0;

endmodule

`default_nettype wire
