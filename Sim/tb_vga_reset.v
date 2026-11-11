// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// Testbench   : tb_vga_reset
// Purpose     : the reset contract from Section 1 of the handout - the reset
//               button brings the colour bars back from every screen, at any
//               moment, including in the middle of a click.
//
// Tests       : R1  reset from MUST  -> bars, immediately, while a clock stops
//               R2  reset from END   -> bars
//               R3  reset in the middle of a click (before the debounce has
//                   finished) -> bars, and no transition when the click ends
//               R4  after every reset the picture restarts at (0,0) with the
//                   first colour bar
//               R5  reset while the switching button is held -> bars stay bars
//
// The VCD keeps only the signals of the reset story: the pixel counters and
// rgb change every clock and are represented by rgb_zero.
//
// Run         : iverilog -g2012 -Wall -s tb_vga_reset \
//                          -o results/tb_vga_reset.vvp Sim/tb_vga_reset.v \
//                          -y RTL && vvp results/tb_vga_reset.vvp
// ============================================================================
`timescale 1ns / 1ns

module tb_vga_reset;

    reg  sys_clk   = 1'b0;
    reg  sys_rst_n = 1'b1;
    reg  key_in    = 1'b1;

    wire hsync, vsync;
    wire [15:0] rgb;

    wire rgb_zero = (rgb == 16'h0000);   // picture is black / blanked

    integer errors = 0;
    time    t_rst, t_state;

    vga_sm_top dut (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .key_in    (key_in),
        .hsync     (hsync),
        .vsync     (vsync),
        .rgb       (rgb)
    );

    always #10 sys_clk = ~sys_clk;

    // Record the instant the state machine leaves its current state.
    always @(dut.u_screen_fsm.st_cur) begin
        if (t_rst != 0)
            t_state = $time;
    end

    task wait_ms(input integer ms);
        begin
            #(ms * 1000000);
        end
    endtask

    task clean_click(input integer hold_ms);
        begin
            @(posedge sys_clk);
            key_in = 1'b0;
            wait_ms(hold_ms);
            @(posedge sys_clk);
            key_in = 1'b1;
            wait_ms(22);
        end
    endtask

    // Assert reset, check the state is bars, release, check it stays bars.
    task reset_to_bars(input [8*24:1] what);
        begin
            @(posedge sys_clk);
            t_rst = $time;
            sys_rst_n = 1'b0;
            #100;                              // asynchronous: no clock needed
            if ((dut.u_screen_fsm.st_cur !== 3'b001) || (dut.screen_sel !== 2'd0)) begin
                errors = errors + 1;
                $display("FAIL  %0s: st_cur=%b screen_sel=%0d after reset",
                         what, dut.u_screen_fsm.st_cur, dut.screen_sel);
            end else begin
                $display("PASS  %0s: bars asserted %0d ns after the reset edge (asynchronous)",
                         what, t_state - t_rst);
            end
            #2000;
            if (rgb !== 16'h0000) begin
                errors = errors + 1;
                $display("FAIL  %0s: rgb=%h during reset, expected 0000",
                         what, rgb);
            end
            sys_rst_n = 1'b1;
            #100;
            if ((dut.u_screen_fsm.st_cur !== 3'b001) || (dut.screen_sel !== 2'd0)) begin
                errors = errors + 1;
                $display("FAIL  %0s: state moved after reset release", what);
            end else begin
                $display("PASS  %0s: bars remain after reset release", what);
            end
            t_rst = 0;
            wait_ms(25);
        end
    endtask

    initial begin
        $dumpfile("results/tb_vga_reset.vcd");
        $dumpvars(0, sys_rst_n, key_in, hsync, vsync, rgb_zero,
                     dut.key_press, dut.screen_sel, dut.u_screen_fsm.st_cur);
        $dumpoff;

        $timeformat(-9, 0, " ns", 8);
        $display("=== Lab 4 reset test ===");

        #1 sys_rst_n = 1'b0;
        #200 sys_rst_n = 1'b1;
        wait_ms(25);

        // ---- R1: reset from MUST ------------------------------------------
        clean_click(30);
        if (dut.screen_sel !== 2'd1) begin
            errors = errors + 1;
            $display("FAIL  could not reach the MUST screen (screen_sel=%0d)",
                     dut.screen_sel);
        end
        $dumpon;
        reset_to_bars("reset from MUST");
        $dumpoff;

        // ---- R2: reset from END -------------------------------------------
        clean_click(30);
        clean_click(30);
        if (dut.screen_sel !== 2'd2) begin
            errors = errors + 1;
            $display("FAIL  could not reach the END screen (screen_sel=%0d)",
                     dut.screen_sel);
        end
        $dumpon;
        reset_to_bars("reset from END");
        $dumpoff;

        // ---- R3: reset in the middle of a click ----------------------------
        // Press, wait only 5 ms (the debounce needs 20 ms), then reset.  The
        // press must not survive the reset: after the release the screen must
        // still be bars.
        clean_click(30);                       // MUST
        clean_click(30);                       // END
        @(posedge sys_clk);
        key_in = 1'b0;                         // click starts
        wait_ms(5);                            // still inside the debounce
        $dumpon;
        t_rst = $time;
        sys_rst_n = 1'b0;
        #100;
        if (dut.screen_sel !== 2'd0) begin
            errors = errors + 1;
            $display("FAIL  mid-click reset: screen_sel=%0d, expected 0", dut.screen_sel);
        end else begin
            $display("PASS  mid-click reset: bars, the pending click is cancelled");
        end
        sys_rst_n = 1'b1;
        #300000;
        $dumpoff;
        if (dut.screen_sel !== 2'd0) begin
            errors = errors + 1;
            $display("FAIL  mid-click reset: the cancelled click still switched the screen");
        end else begin
            $display("PASS  mid-click reset: no transition after the reset");
        end
        t_rst = 0;

        // ---- R4: the picture restarts at (0,0) ----------------------------
        @(negedge dut.vga_clk);
        while (!((dut.u_vga_ctrl.cnt_h == 10'd144) && (dut.u_vga_ctrl.cnt_v == 10'd35)))
            @(negedge dut.vga_clk);
        if (rgb !== 16'hF800) begin
            errors = errors + 1;
            $display("FAIL  first visible pixel after reset: rgb=%h, expected F800", rgb);
        end else begin
            $display("PASS  first visible pixel after reset is (0,0) = F800");
        end

        // ---- R5: reset while the button is held ----------------------------
        @(posedge sys_clk);
        key_in = 1'b1;                          // release first
        wait_ms(25);
        @(posedge sys_clk);
        key_in = 1'b0;                          // hold
        wait_ms(5);
        $dumpon;
        sys_rst_n = 1'b0;
        #2000;
        sys_rst_n = 1'b1;
        wait_ms(40);                            // still holding
        $dumpoff;
        if (dut.screen_sel !== 2'd0) begin
            errors = errors + 1;
            $display("FAIL  held button through reset: screen_sel=%0d, expected 0",
                     dut.screen_sel);
        end else begin
            $display("PASS  held button through reset: bars stay bars");
        end

        if (errors == 0)
            $display("RESULT: PASS (reset: every screen, mid-click, held button)");
        else
            $display("RESULT: FAIL (%0d errors)", errors);

        if (errors != 0) $fatal(1, "tb_vga_reset failed");
        $finish;
    end

endmodule
