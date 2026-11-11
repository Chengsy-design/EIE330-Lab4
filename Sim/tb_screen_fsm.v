// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// Testbench   : tb_screen_fsm
// Purpose     : verify the three-state Moore machine on its own, without the
//               debounce block, so that a failure can only be the FSM.
//
// Checks      : F1  reset -> BARS, one-hot code 001
//               F2  three pulses -> MUST, END, BARS (the cycle wraps)
//               F3  one-hot invariant after every transition
//               F4  reset from MUST and from END -> BARS
//               F5  a pulse while reset is asserted does nothing
// Run         : iverilog -g2012 -Wall -s tb_screen_fsm \
//                          -o results/tb_screen_fsm.vvp Sim/tb_screen_fsm.v \
//                          RTL/screen_fsm.v && vvp results/tb_screen_fsm.vvp
// ============================================================================
`timescale 1ns / 1ns

module tb_screen_fsm;

    reg        vga_clk   = 1'b0;
    reg        sys_rst_n = 1'b1;
    reg        key_press = 1'b0;
    wire [1:0] screen_sel;

    integer errors = 0;
    reg [2:0] st_prev;
    integer   ones;

    screen_fsm dut (
        .vga_clk    (vga_clk),
        .sys_rst_n  (sys_rst_n),
        .key_press  (key_press),
        .screen_sel (screen_sel)
    );

    always #20 vga_clk = ~vga_clk;      // 40 ns pixel clock

    // ------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------
    function integer popcount(input [2:0] v);
        integer k;
        begin
            popcount = 0;
            for (k = 0; k < 3; k = k + 1)
                popcount = popcount + v[k];
        end
    endfunction

    // One clock-wide pulse, driven between clock edges.
    task pulse;
        begin
            @(negedge vga_clk); key_press = 1'b1;
            @(negedge vga_clk); key_press = 1'b0;
        end
    endtask

    // Check the state code, the screen code and the one-hot invariant.
    task check_state(input [2:0] exp_state, input [1:0] exp_screen,
                     input [8*40:1] what);
        begin
            #1;
            if ((dut.st_cur !== exp_state) || (screen_sel !== exp_screen)) begin
                errors = errors + 1;
                $display("FAIL  %0s: st_cur=%b screen_sel=%0d, expected %b / %0d",
                         what, dut.st_cur, screen_sel, exp_state, exp_screen);
            end else if (popcount(dut.st_cur) !== 1) begin
                errors = errors + 1;
                $display("FAIL  %0s: st_cur=%b is not one-hot", what, dut.st_cur);
            end else begin
                $display("PASS  %0s: st_cur=%b screen_sel=%0d (one-hot)",
                         what, dut.st_cur, screen_sel);
            end
            st_prev = dut.st_cur;
        end
    endtask

    initial begin
        $dumpfile("results/tb_screen_fsm.vcd");
        $dumpvars(0, vga_clk, sys_rst_n, key_press, screen_sel, dut.st_cur);

        $timeformat(-9, 0, " ns", 8);
        $display("=== Lab 4 screen_fsm test ===");

        st_prev = 3'b000;

        // ---- F1: reset ---------------------------------------------------
        #1 sys_rst_n = 1'b0;
        #100;
        check_state(3'b001, 2'd0, "reset");
        #1 sys_rst_n = 1'b1;
        #100;

        // ---- F2: the three-click cycle -----------------------------------
        pulse(); check_state(3'b010, 2'd1, "click 1 (MUST)");
        pulse(); check_state(3'b100, 2'd2, "click 2 (END)");
        pulse(); check_state(3'b001, 2'd0, "click 3 (BARS)");

        // ---- F3: the cycle is repeatable ---------------------------------
        pulse(); check_state(3'b010, 2'd1, "click 4 (MUST)");
        pulse(); check_state(3'b100, 2'd2, "click 5 (END)");

        // ---- F4: reset from END and from MUST ----------------------------
        #1 sys_rst_n = 1'b0;
        #100;
        check_state(3'b001, 2'd0, "reset from END");
        #1 sys_rst_n = 1'b1;
        #100;
        pulse(); check_state(3'b010, 2'd1, "click after reset");
        #1 sys_rst_n = 1'b0;
        #100;
        check_state(3'b001, 2'd0, "reset from MUST");

        // ---- F5: a pulse during reset is ignored -------------------------
        pulse();
        #100;
        check_state(3'b001, 2'd0, "pulse during reset ignored");
        #1 sys_rst_n = 1'b1;
        #100;
        check_state(3'b001, 2'd0, "state after reset release");

        if (errors == 0)
            $display("RESULT: PASS (screen_fsm: cycle, one-hot, reset)");
        else
            $display("RESULT: FAIL (%0d errors)", errors);

        if (errors != 0) $fatal(1, "tb_screen_fsm failed");
        $finish;
    end

endmodule
