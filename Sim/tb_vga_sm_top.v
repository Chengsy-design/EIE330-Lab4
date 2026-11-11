// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// Testbench   : tb_vga_sm_top
// Purpose     : end-to-end test of the whole system at the top-level ports.
//
// Tests       : I1  reset -> colour bars (screen 0)
//               I2  three clicks -> bars, MUST, END, bars (the cycle wraps)
//               I3  one full frame captured per screen, written to
//                   results/screen_0_bars.hex / screen_1_must.hex /
//                   screen_2_end.hex in scan order, one RGB565 word per line
//               I4  pixel probes per screen, read from the top-level rgb port
//               I5  reset while the switching button is held: bars, and the
//                   held button does not switch again after reset release
//               I6  one bouncing click: exactly one screen transition
//               I7  one 120 ms press: exactly one screen transition
//
// Run         : iverilog -g2012 -Wall -s tb_vga_sm_top \
//                          -o results/tb_vga_sm_top.vvp Sim/tb_vga_sm_top.v \
//                          -y RTL && vvp results/tb_vga_sm_top.vvp
// ============================================================================
`timescale 1ns / 1ns

module tb_vga_sm_top;

    reg  sys_clk   = 1'b0;
    reg  sys_rst_n = 1'b1;
    reg  key_in    = 1'b1;                   // released

    wire hsync, vsync;
    wire [15:0] rgb;

    integer errors   = 0;
    integer trans    = 0;                    // screen_sel transitions
    reg [1:0] screen_d = 2'd0;

    integer fd, i, n;
    reg [1:0] scr;

    vga_sm_top dut (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .key_in    (key_in),
        .hsync     (hsync),
        .vsync     (vsync),
        .rgb       (rgb)
    );

    // 50 MHz board clock.
    always #10 sys_clk = ~sys_clk;

    // Count screen transitions on the pixel clock.
    always @(posedge dut.vga_clk) begin
        if (dut.screen_sel !== screen_d) begin
            trans    = trans + 1;
            screen_d = dut.screen_sel;
        end
    end

    // ------------------------------------------------------------------
    // Frame capture: 307,200 visible pixels in scan order.
    // ------------------------------------------------------------------
    task capture_frame(input [8*40:1] name);
        begin
            // Wait for the first visible pixel of a frame.  The pixel on the
            // rgb port now was requested one clock earlier, so its coordinate
            // is the coordinate of the previous clock.
            @(negedge dut.vga_clk);
            while (!(dut.u_vga_ctrl.rgb_valid && (dut.u_vga_ctrl.cnt_h == 10'd144)
                                            && (dut.u_vga_ctrl.cnt_v == 10'd35)))
                @(negedge dut.vga_clk);
            fd = $fopen(name, "w");
            if (fd == 0) begin
                errors = errors + 1;
                $display("FAIL  cannot open %0s", name);
            end else begin
                // rgb already carries pixel (0,0) at this clock: the colour
                // requested one clock earlier, when cnt_h was 143.
                $fwrite(fd, "%04h\n", rgb);
                n = 1;
                while (n < 307200) begin
                    @(negedge dut.vga_clk);
                    if (dut.u_vga_ctrl.rgb_valid) begin
                        $fwrite(fd, "%04h\n", rgb);
                        n = n + 1;
                    end
                end
                $fclose(fd);
                $display("      captured 307200 pixels to %0s", name);
            end
        end
    endtask

    // ------------------------------------------------------------------
    // One visible pixel probe.  The pixel at (x,y) is on rgb when the
    // timing counters are at 144+x and 35+y, because vga_ctrl requests the
    // colour one clock before the pixel is shown.
    // ------------------------------------------------------------------
    task probe(input [9:0] px, input [9:0] py, input [15:0] want,
               input [8*20:1] what);
        begin
            @(negedge dut.vga_clk);
            while (!((dut.u_vga_ctrl.cnt_h == 10'd144 + px) &&
                     (dut.u_vga_ctrl.cnt_v == 10'd35 + py)))
                @(negedge dut.vga_clk);
            if (rgb !== want) begin
                errors = errors + 1;
                $display("FAIL  probe %0s (%0d,%0d): rgb=%h expected %h",
                         what, px, py, rgb, want);
            end else begin
                $display("PASS  probe %0s (%0d,%0d): rgb=%h", what, px, py, rgb);
            end
        end
    endtask

    // Click helpers -----------------------------------------------------
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

    // ------------------------------------------------------------------
    // VCD: the signals that carry the state-machine story.  The pixel
    // counters and rgb are deliberately not dumped (they change every
    // clock); the pixel evidence is in the captured frames instead.
    // ------------------------------------------------------------------
    initial begin
        $dumpfile("results/tb_vga_sm_top.vcd");
        $dumpvars(0, sys_rst_n, key_in, vsync, rgb,
                     dut.key_press, dut.screen_sel, dut.u_screen_fsm.st_cur);
        $dumpoff;
    end

    initial begin
        $timeformat(-9, 0, " ns", 8);
        $display("=== Lab 4 vga_sm_top integration test ===");

        // ---- I1: reset -> bars -------------------------------------------
        #1 sys_rst_n = 1'b0;
        #200;
        if ((dut.screen_sel !== 2'd0) || (dut.u_screen_fsm.st_cur !== 3'b001)) begin
            errors = errors + 1;
            $display("FAIL  after reset: screen_sel=%0d st_cur=%b, expected 0 / 001",
                     dut.screen_sel, dut.u_screen_fsm.st_cur);
        end else begin
            $display("PASS  after reset: screen_sel=0, st_cur=001 (colour bars)");
        end
        sys_rst_n = 1'b1;
        $dumpon;
        wait_ms(25);                     // debounce release filter settles

        probe(10'd0,  10'd0,   16'hF800, "bar 0 (red)");
        probe(10'd64, 10'd240, 16'hFC00, "bar 1 (orange)");
        probe(10'd639,10'd479, 16'hD69A, "bar 9 (gray)");
        capture_frame("results/screen_0_bars.hex");

        // ---- I2: three clicks ---------------------------------------------
        trans = 0;
        clean_click(30);
        if ((dut.screen_sel !== 2'd1) || (trans != 1)) begin
            errors = errors + 1;
            $display("FAIL  click 1: screen_sel=%0d transitions=%0d, expected 1 / 1",
                     dut.screen_sel, trans);
        end else begin
            $display("PASS  click 1: screen_sel=1 (MUST), exactly 1 transition");
        end
        probe(10'd144, 10'd208, 16'hFFFF, "M top-left");
        probe(10'd176, 10'd240, 16'h0000, "M hole");
        probe(10'd224, 10'd240, 16'h0000, "gap after M");
        capture_frame("results/screen_1_must.hex");

        trans = 0;
        clean_click(30);
        if ((dut.screen_sel !== 2'd2) || (trans != 1)) begin
            errors = errors + 1;
            $display("FAIL  click 2: screen_sel=%0d transitions=%0d, expected 2 / 1",
                     dut.screen_sel, trans);
        end else begin
            $display("PASS  click 2: screen_sel=2 (END), exactly 1 transition");
        end
        probe(10'd192, 10'd208, 16'hFFFF, "E top-left");
        probe(10'd431, 10'd271, 16'hFFFF, "D bottom-right");
        probe(10'd448, 10'd240, 16'h0000, "after D");
        capture_frame("results/screen_2_end.hex");

        trans = 0;
        clean_click(30);
        if ((dut.screen_sel !== 2'd0) || (trans != 1)) begin
            errors = errors + 1;
            $display("FAIL  click 3: screen_sel=%0d transitions=%0d, expected 0 / 1",
                     dut.screen_sel, trans);
        end else begin
            $display("PASS  click 3: screen_sel=0 (bars again), cycle wraps");
        end
        probe(10'd0, 10'd0, 16'hF800, "bars after the full cycle");

        // ---- I5: reset while the switching button is held ------------------
        @(posedge sys_clk);
        key_in = 1'b0;                   // hold the switching button
        wait_ms(5);
        sys_rst_n = 1'b0;                // reset in the middle of the press
        #2000;
        if ((dut.screen_sel !== 2'd0) || (dut.u_screen_fsm.st_cur !== 3'b001)) begin
            errors = errors + 1;
            $display("FAIL  reset during press: screen_sel=%0d st_cur=%b",
                     dut.screen_sel, dut.u_screen_fsm.st_cur);
        end else begin
            $display("PASS  reset during press: bars immediately, key held");
        end
        sys_rst_n = 1'b1;
        trans = 0;
        wait_ms(40);                     // still holding the button
        if (trans != 0) begin
            errors = errors + 1;
            $display("FAIL  held button caused %0d transitions after reset", trans);
        end else begin
            $display("PASS  held button: 0 transitions in the 40 ms after reset");
        end
        @(posedge sys_clk);
        key_in = 1'b1;                   // release
        wait_ms(22);

        // ---- I6: bouncing click at the top level ---------------------------
        trans = 0;
        @(posedge sys_clk);
        key_in = 1'b0;
        for (i = 0; i < 40; i = i + 1) begin       // 8 ms of 0.1 ms bounce
            #100000 key_in = 1'b1;
            #100000 key_in = 1'b0;
        end
        wait_ms(22);                              // still pressed, stable
        @(posedge sys_clk);
        key_in = 1'b1;
        for (i = 0; i < 40; i = i + 1) begin
            #100000 key_in = 1'b0;
            #100000 key_in = 1'b1;
        end
        wait_ms(22);
        if ((trans != 1) || (dut.screen_sel !== 2'd1)) begin
            errors = errors + 1;
            $display("FAIL  bouncing click: %0d transitions, screen_sel=%0d",
                     trans, dut.screen_sel);
        end else begin
            $display("PASS  bouncing click: exactly 1 transition, screen_sel=1");
        end

        // ---- I7: long press at the top level -------------------------------
        trans = 0;
        clean_click(120);
        if ((trans != 1) || (dut.screen_sel !== 2'd2)) begin
            errors = errors + 1;
            $display("FAIL  long press: %0d transitions, screen_sel=%0d",
                     trans, dut.screen_sel);
        end else begin
            $display("PASS  long 120 ms press: exactly 1 transition, screen_sel=2");
        end

        $dumpoff;

        if (errors == 0)
            $display("RESULT: PASS (vga_sm_top: cycle, frames, reset, bounce, long press)");
        else
            $display("RESULT: FAIL (%0d errors)", errors);

        if (errors != 0) $fatal(1, "tb_vga_sm_top failed");
        $finish;
    end

endmodule
