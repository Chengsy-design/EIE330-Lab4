// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// Testbench   : tb_vga_ctrl
// Purpose     : functional and timing verification of the VGA timing engine.
// Checks      : hsync pulse width / period, vsync pulse width / period,
//               first and last addressable pixel, rgb gating outside the
//               valid window, the one-clock lead of pix_data_req, counter
//               wrap, and asynchronous reset in the middle of a frame.
// Run         : iverilog -g2012 -Wall -s tb_vga_ctrl -o results/tb_vga_ctrl.vvp \
//                          Sim/tb_vga_ctrl.v -y RTL && vvp results/tb_vga_ctrl.vvp
//
// Expected numbers (25 MHz pixel clock, 40 ns period):
//   hsync high   96 x 40 ns = 3,840 ns      hsync period 800 x 40 = 32,000 ns
//   vsync high    2 x 32 us = 64,000 ns     vsync period 525 x 32 us = 16.8 ms
//   first pixel  cnt_h=144, cnt_v=35, pix_x=0,   pix_y=0
//   last pixel   cnt_h=783, cnt_v=514, pix_x=639, pix_y=479
// ============================================================================
`timescale 1ns / 1ns

module tb_vga_ctrl;

    reg         vga_clk   = 1'b0;
    reg         sys_rst_n = 1'b1;
    reg  [15:0] pix_data  = 16'hA5A5;   // recognizable test colour
    wire [9:0]  pix_x;
    wire [9:0]  pix_y;
    wire        hsync;
    wire        vsync;
    wire [15:0] rgb;

    wire        rgb_valid;
    wire        pix_data_req;
    assign rgb_valid    = dut.rgb_valid;
    assign pix_data_req = dut.pix_data_req;

    integer errors = 0;

    // Measurements
    time t_h1, t_h2, t_h3, t_v1, t_v2, t_v3;
    time h_high, h_period, v_high, v_period;

    // First / last visible pixel, captured by the monitor.
    reg        seen_valid = 1'b0;
    reg        seen_end   = 1'b0;
    reg [9:0]  first_x, first_y, last_x, last_y;
    reg [9:0]  first_cnt_h, first_cnt_v, last_cnt_h, last_cnt_v;
    reg        first_req, last_req;
    reg        early_seen = 1'b0;
    reg [9:0]  early_x, early_y;
    // Coordinates requested at the previous pixel clock.  vga_pic registers
    // the colour, so the pixel visible in the current clock was requested one
    // clock earlier; these registers recover that request coordinate.
    reg [9:0]  prev_x = 10'd0, prev_y = 10'd0;
    reg [9:0]  prev_cnt_h = 10'd0, prev_cnt_v = 10'd0;

    vga_ctrl dut (
        .vga_clk   (vga_clk),
        .sys_rst_n (sys_rst_n),
        .pix_data  (pix_data),
        .pix_x     (pix_x),
        .pix_y     (pix_y),
        .hsync     (hsync),
        .vsync     (vsync),
        .rgb       (rgb)
    );

    // 25 MHz pixel clock: 40 ns period.
    always #20 vga_clk = ~vga_clk;

    // ------------------------------------------------------------------
    // Per-clock monitor: rgb gating and capture of the valid-window edges.
    // ------------------------------------------------------------------
    // Sampling at the falling edge avoids the non-blocking-assignment race:
    // every combinational output has settled half a pixel clock after the
    // active edge that produced it.
    always @(negedge vga_clk) begin
        if (!sys_rst_n) begin
            if (rgb !== 16'h0000) begin
                errors = errors + 1;
                $display("FAIL  t=%0t  rgb=%h during reset, expected 0000", $time, rgb);
            end
        end else begin
            if (rgb_valid) begin
                if (rgb !== pix_data) begin
                    errors = errors + 1;
                    $display("FAIL  t=%0t  rgb=%h inside valid, expected %h",
                             $time, rgb, pix_data);
                end
                if (!seen_valid) begin
                    seen_valid   = 1'b1;
                    first_x      = prev_x;
                    first_y      = prev_y;
                    first_cnt_h  = prev_cnt_h;
                    first_cnt_v  = prev_cnt_v;
                    first_req    = pix_data_req;
                end
                last_x     = prev_x;
                last_y     = prev_y;
                last_cnt_h = prev_cnt_h;
                last_cnt_v = prev_cnt_v;
                last_req   = pix_data_req;
            end else begin
                if (rgb !== 16'h0000) begin
                    errors = errors + 1;
                    $display("FAIL  t=%0t  rgb=%h outside valid, expected 0000",
                             $time, rgb);
                end
                if (seen_valid && !seen_end)
                    seen_end = 1'b1;
            end

            // pix_data_req must lead rgb_valid by exactly one pixel clock.
            if (pix_data_req && !rgb_valid && !early_seen) begin
                early_seen = 1'b1;
                early_x    = pix_x;
                early_y    = pix_y;
            end

            prev_x     = pix_x;
            prev_y     = pix_y;
            prev_cnt_h = dut.cnt_h;
            prev_cnt_v = dut.cnt_v;
        end
    end

    // ------------------------------------------------------------------
    // Short VCD window around the first addressable line (dumping is turned
    // off for the rest of the 16.8 ms frame to keep the file small).
    // ------------------------------------------------------------------
    initial begin
        $dumpfile("results/tb_vga_ctrl.vcd");
        $dumpvars(0, tb_vga_ctrl);
        $dumpoff;
        wait (dut.cnt_v == 10'd34 && dut.cnt_h == 10'd780);
        $dumpon;
        repeat (1900) @(posedge vga_clk);
        $dumpoff;
    end

    initial begin
        $timeformat(-9, 0, " ns", 8);
        $display("=== Lab 4 vga_ctrl timing test (module reused from Lab 3) ===");

        // Reset from t=0: create a real falling edge at t=1.
        #1 sys_rst_n = 1'b0;
        #124 sys_rst_n = 1'b1;             // release at t = 125 ns

        // ---- hsync: high time and period --------------------------------
        @(negedge hsync);                  // end of the initial sync segment
        @(posedge hsync); t_h1 = $time;
        @(negedge hsync); t_h2 = $time;
        @(posedge hsync); t_h3 = $time;
        h_high   = t_h2 - t_h1;
        h_period = t_h3 - t_h1;
        if ((h_high !== 3840) || (h_period !== 32000)) begin
            errors = errors + 1;
            $display("FAIL  hsync: high=%0d ns (exp 3840), period=%0d ns (exp 32000)",
                     h_high, h_period);
        end else begin
            $display("PASS  hsync: high=%0d ns (96 clocks), period=%0d ns (800 clocks)",
                     h_high, h_period);
        end

        // ---- valid window: first and last pixel -------------------------
        @(posedge rgb_valid);
        @(negedge rgb_valid);
        if ((first_x !== 10'd0) || (first_y !== 10'd0) ||
            (first_cnt_h !== 10'd143) || (first_cnt_v !== 10'd35) ||
            (first_req !== 1'b1)) begin
            errors = errors + 1;
            $display("FAIL  first visible pixel: cnt=(%0d,%0d) pix=(%0d,%0d) req=%b",
                     first_cnt_h, first_cnt_v, first_x, first_y, first_req);
        end else begin
            $display("PASS  first visible pixel: requested at cnt_h=143, shown at cnt_h=144, pix_x=0 pix_y=0");
        end
        // Walk to the last visible line of the frame, then capture its last
        // visible pixel.  rgb_valid falls at the end of every line, so the
        // frame's last pixel must be taken from line 514, not line 35.
        // Wait until the monitor has seen the last line's last pixel; using
        // the monitored value avoids any sampling race with cnt_v.
        while (!((last_x == 10'd639) && (last_y == 10'd479)))
            @(negedge vga_clk);
        if ((last_x !== 10'd639) || (last_y !== 10'd479) ||
            (last_cnt_h !== 10'd782) || (last_cnt_v !== 10'd514) ||
            (last_req !== 1'b0)) begin
            errors = errors + 1;
            $display("FAIL  last visible pixel: cnt=(%0d,%0d) pix=(%0d,%0d) req=%b",
                     last_cnt_h, last_cnt_v, last_x, last_y, last_req);
        end else begin
            $display("PASS  last visible pixel: requested at cnt_h=782, shown at cnt_h=783, pix_x=639 pix_y=479");
        end
        if ((early_x !== 10'd0) || (early_y !== 10'd0)) begin
            errors = errors + 1;
            $display("FAIL  pix_data_req lead: pix=(%0d,%0d), expected (0,0)",
                     early_x, early_y);
        end else begin
            $display("PASS  pix_data_req leads rgb_valid by one clock at pix_x=0");
        end

        // ---- vsync: high time and period --------------------------------
        @(posedge vsync); t_v1 = $time;
        @(negedge vsync); t_v2 = $time;
        @(posedge vsync); t_v3 = $time;
        v_high   = t_v2 - t_v1;
        v_period = t_v3 - t_v1;
        if ((v_high !== 64000) || (v_period !== 16800000)) begin
            errors = errors + 1;
            $display("FAIL  vsync: high=%0d ns (exp 64000), period=%0d ns (exp 16800000)",
                     v_high, v_period);
        end else begin
            $display("PASS  vsync: high=%0d ns (2 lines), period=%0d ns (525 lines, 16.8 ms)",
                     v_high, v_period);
        end

        // ---- asynchronous reset in the middle of the active picture -----
        while (dut.cnt_v != 10'd100)
            @(posedge vga_clk);
        #5 sys_rst_n = 1'b0;               // assert between clock edges
        #1;
        if ((dut.cnt_h !== 10'd0) || (dut.cnt_v !== 10'd0) ||
            (hsync !== 1'b1) || (vsync !== 1'b1) || (rgb !== 16'h0000)) begin
            errors = errors + 1;
            $display("FAIL  mid-frame reset: cnt=(%0d,%0d) hsync=%b vsync=%b rgb=%h",
                     dut.cnt_h, dut.cnt_v, hsync, vsync, rgb);
        end else begin
            $display("PASS  mid-frame reset clears counters and rgb immediately");
        end
        repeat (5) @(posedge vga_clk);
        if ((dut.cnt_h !== 10'd0) || (dut.cnt_v !== 10'd0) || (rgb !== 16'h0000)) begin
            errors = errors + 1;
            $display("FAIL  counters moved while reset was asserted");
        end else begin
            $display("PASS  reset holds cnt_h=0, cnt_v=0 and rgb=0 for 5 clocks");
        end

        // Release and check that the picture restarts at pixel (0,0).
        seen_valid = 1'b0;
        seen_end   = 1'b0;
        #3 sys_rst_n = 1'b1;
        @(posedge rgb_valid);
        @(negedge vga_clk);
        if ((first_x !== 10'd0) || (first_y !== 10'd0) || (rgb !== 16'hA5A5)) begin
            errors = errors + 1;
            $display("FAIL  restart after reset: pix=(%0d,%0d) rgb=%h",
                     first_x, first_y, rgb);
        end else begin
            $display("PASS  picture restarts at pixel (0,0) after reset release");
        end

        if (errors == 0)
            $display("RESULT: PASS (vga_ctrl: all timing and reset checks)");
        else
            $display("RESULT: FAIL (%0d errors)", errors);

        if (errors != 0) $fatal(1, "tb_vga_ctrl failed");
        $finish;
    end

endmodule
