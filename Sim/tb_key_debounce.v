// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// Testbench   : tb_key_debounce
// Purpose     : prove that one physical click produces exactly one key_press
//               pulse, whatever the contact bounce and however long the button
//               is held, and that a button already held at reset produces none.
//
// Checks      : T1  reset: counters cleared, key_state = 0, no pulse
//               T2  clean 30 ms click  -> exactly 1 pulse, 20 ms after the edge
//               T3  long 100 ms press  -> exactly 1 pulse, no repeat
//               T4  bouncing click     -> exactly 1 pulse, counter never near max
//               T5  two clicks         -> exactly 2 pulses
//               T6  reset while pressed: state cleared, no pulse after release
//               T7  release, re-arm, click -> 1 pulse again
// Run         : iverilog -g2012 -Wall -s tb_key_debounce \
//                          -o results/tb_key_debounce.vvp Sim/tb_key_debounce.v \
//                          RTL/key_debounce.v && vvp results/tb_key_debounce.vvp
//
// Time scale  : 1 ns.  The pixel clock is 40 ns, one debounce interval is
//               20 ms = 500,000 clocks, and the whole run is about 400 ms.
// ============================================================================
`timescale 1ns / 1ns

module tb_key_debounce;

    localparam integer CLK_HALF = 20;        // 40 ns period, 25 MHz
    localparam time    DEB_NS   = 20000000;  // 20.000 ms

    reg  vga_clk   = 1'b0;
    reg  sys_rst_n = 1'b1;
    reg  key_in    = 1'b1;                   // active low, released

    wire key_press;

    // The report figure does not need every one of the 19 counter bits: the
    // top 9 bits change every 512 clocks (20.48 us), which is enough to draw
    // the ramp and keeps the VCD small.
    wire [8:0] cnt_press_hi   = dut.cnt_press[18:10];
    wire [8:0] cnt_release_hi = dut.cnt_release[18:10];

    integer errors     = 0;
    integer pulses     = 0;                  // total pulses seen in the run
    integer pulses_t   = 0;                  // pulses in the current test
    time    t_edge     = 0;                  // time of the last key_in falling edge
    time    t_pulse    = 0;                  // time of the last key_press pulse
    reg [18:0] max_cnt    = 19'd0;           // largest cnt_press seen so far
    reg [18:0] bounce_max = 19'd0;           // largest value during the bounce phase

    key_debounce dut (
        .vga_clk   (vga_clk),
        .sys_rst_n (sys_rst_n),
        .key_in    (key_in),
        .key_press (key_press)
    );

    // 25 MHz pixel clock.
    always #CLK_HALF vga_clk = ~vga_clk;

    // Pulse counter: the number of transitions a click would cause.
    always @(posedge key_press) begin
        pulses   = pulses + 1;
        pulses_t = pulses_t + 1;
        t_pulse  = $time;
    end

    // Keep the largest value the press counter reaches.
    always @(posedge vga_clk)
        if (dut.cnt_press > max_cnt)
            max_cnt = dut.cnt_press;

    // ------------------------------------------------------------------
    // Stimulus helpers
    // ------------------------------------------------------------------
    task wait_ms(input integer ms);
        begin
            #(ms * 1000000);
        end
    endtask

    // One click: press for hold_ms, release, then let the release filter
    // finish (22 ms > 20 ms) so the next test starts from a released level.
    task clean_click(input integer hold_ms);
        begin
            @(posedge vga_clk);
            key_in = 1'b0;
            t_edge = $time;
            wait_ms(hold_ms);
            @(posedge vga_clk);
            key_in = 1'b1;
            wait_ms(22);
        end
    endtask

    // One click with contact bounce on both edges.  The level toggles every
    // 0.1 ms for bounce_ms, so no low or high phase is longer than 0.1 ms:
    // exactly the situation the 20 ms filter has to reject.
    //
    // The VCD is enabled for two short windows only: the bounce phase (where
    // the counter keeps restarting) and the confirmation 20 ms later (where
    // the counter reaches its final value).  Dumping the whole 50 ms click
    // would write several hundred megabytes of counter changes.
    task bounce_click(input integer bounce_ms, input integer hold_ms,
                      input integer dump);
        integer i;
        begin
            @(posedge vga_clk);
            key_in = 1'b0;
            t_edge = $time;
            max_cnt = 19'd0;
            for (i = 0; i < bounce_ms * 5; i = i + 1) begin   // 0.2 ms per step
                #100000 key_in = 1'b1;
                #100000 key_in = 1'b0;
            end
            bounce_max = max_cnt;         // evidence: the filter kept restarting
            // Second window: 150 us before and after the confirmation, which
            // is due 20.000 ms after the bounce settles, i.e. 28 ms after the
            // press edge for an 8 ms bounce.
            #((t_edge + hold_ms * 1000000) - $time);   // finish the hold
            @(posedge vga_clk);
            key_in = 1'b1;
            for (i = 0; i < bounce_ms * 5; i = i + 1) begin
                #100000 key_in = 1'b0;
                #100000 key_in = 1'b1;
            end
            wait_ms(22);
        end
    endtask

    // ------------------------------------------------------------------
    // VCD: only the signals of this module are interesting, and the counters
    // are only dumped in the short windows where they carry the evidence.
    // ------------------------------------------------------------------
    initial begin
        $dumpfile("results/tb_key_debounce.vcd");
        // vga_clk is not dumped (it toggles every 20 ns); the counters are
        // dumped as their top 9 bits.  Everything else changes slowly.
        $dumpvars(0, sys_rst_n, key_in, key_press, cnt_press_hi,
                     cnt_release_hi, dut.key_sync, dut.key_state,
                     dut.key_state_prev);
    end

    initial begin
        $timeformat(-9, 0, " ns", 8);
        $display("=== Lab 4 key_debounce test ===");

        // ---- T1: reset ---------------------------------------------------
        #1 sys_rst_n = 1'b0;
        #200;
        if ((dut.cnt_press !== 19'd0) || (dut.cnt_release !== 19'd0) ||
            (dut.key_state !== 1'b0) || (key_press !== 1'b0)) begin
            errors = errors + 1;
            $display("FAIL  reset: cnt_press=%0d cnt_release=%0d key_state=%b pulse=%b",
                     dut.cnt_press, dut.cnt_release, dut.key_state, key_press);
        end else begin
            $display("PASS  reset clears both counters, key_state=0, no pulse");
        end
        sys_rst_n = 1'b1;
        wait_ms(22);                      // release filter settles key_state=1
        if (dut.key_state !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL  key_state=%b after a 22 ms released level, expected 1",
                     dut.key_state);
        end else begin
            $display("PASS  key_state=1 after 22 ms released");
        end

        // ---- T2: clean 30 ms click ---------------------------------------
        pulses_t = 0;
        clean_click(30);
        if (pulses_t !== 1) begin
            errors = errors + 1;
            $display("FAIL  clean click: %0d pulses, expected 1", pulses_t);
        end else if ((t_pulse - t_edge < DEB_NS) ||
                     (t_pulse - t_edge > DEB_NS + 400)) begin
            errors = errors + 1;
            $display("FAIL  clean click: pulse after %0d ns, expected ~20 ms",
                     t_pulse - t_edge);
        end else begin
            $display("PASS  clean 30 ms click: 1 pulse, %0d ns after the edge (expected 20 ms)",
                     t_pulse - t_edge);
        end

        // ---- T3: long press ----------------------------------------------
        pulses_t = 0;
        clean_click(100);
        if (pulses_t !== 1) begin
            errors = errors + 1;
            $display("FAIL  long 100 ms press: %0d pulses, expected 1", pulses_t);
        end else begin
            $display("PASS  long 100 ms press: 1 pulse, no repeat while held");
        end

        // ---- T4: bouncing click ------------------------------------------
        pulses_t = 0;
        bounce_click(8, 30, 1);
        if (pulses_t !== 1) begin
            errors = errors + 1;
            $display("FAIL  bouncing click: %0d pulses, expected 1", pulses_t);
        end else if (bounce_max >= 19'd10000) begin
            errors = errors + 1;
            $display("FAIL  bouncing click: cnt_press reached %0d during the bounce (> 10,000)",
                     bounce_max);
        end else begin
            $display("PASS  bouncing click (8 ms of 0.1 ms toggles): 1 pulse, cnt_press max %0d during bounce",
                     bounce_max);
        end

        // ---- T5: two clicks ----------------------------------------------
        pulses_t = 0;
        clean_click(30);
        clean_click(30);
        if (pulses_t !== 2) begin
            errors = errors + 1;
            $display("FAIL  two clicks: %0d pulses, expected 2", pulses_t);
        end else begin
            $display("PASS  two clicks: 2 pulses, one per click");
        end

        // ---- T6: reset while the button is held ---------------------------
        pulses_t = 0;
        @(posedge vga_clk);
        key_in = 1'b0;                    // press and keep holding
        wait_ms(5);
        sys_rst_n = 1'b0;                 // reset in the middle of the press
        #2000;
        if ((dut.cnt_press !== 19'd0) || (dut.key_state !== 1'b0) ||
            (key_press !== 1'b0)) begin
            errors = errors + 1;
            $display("FAIL  reset during press: cnt=%0d key_state=%b pulse=%b",
                     dut.cnt_press, dut.key_state, key_press);
        end else begin
            $display("PASS  reset during press clears the filter immediately");
        end
        sys_rst_n = 1'b1;
        wait_ms(40);                      // still holding the button
        if (pulses_t !== 0) begin
            errors = errors + 1;
            $display("FAIL  button held through reset produced %0d pulses", pulses_t);
        end else if (key_press !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL  key_press high after reset with the button held");
        end else begin
            $display("PASS  button held through reset: 0 pulses in the 40 ms after release");
        end

        // ---- T7: release, re-arm, click again ----------------------------
        pulses_t = 0;
        @(posedge vga_clk);
        key_in = 1'b1;                    // release the button
        wait_ms(22);
        clean_click(30);
        if (pulses_t !== 1) begin
            errors = errors + 1;
            $display("FAIL  click after re-arm: %0d pulses, expected 1", pulses_t);
        end else begin
            $display("PASS  click after re-arm: 1 pulse (total %0d in the run)", pulses);
        end

        if (errors == 0)
            $display("RESULT: PASS (key_debounce: bounce, long press, reset, re-arm)");
        else
            $display("RESULT: FAIL (%0d errors)", errors);

        if (errors != 0) $fatal(1, "tb_key_debounce failed");
        $finish;
    end

endmodule
