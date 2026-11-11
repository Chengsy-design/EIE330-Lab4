// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// Testbench   : tb_no_debounce
// Purpose     : show what the same bouncing click does to a design that has
//               no debounce block - the comparison used in the discussion.
//
// The raw button level is edge-detected and fed straight into screen_fsm.
// Nothing else changes: the same 8 ms of 0.1 ms contact bounce that produces
// exactly one transition in the real design produces one transition per
// falling edge here, so the screen lands on an arbitrary one of the three.
//
// Run         : iverilog -g2012 -Wall -s tb_no_debounce \
//                          -o results/tb_no_debounce.vvp Sim/tb_no_debounce.v \
//                          RTL/screen_fsm.v && vvp results/tb_no_debounce.vvp
// ============================================================================
`timescale 1ns / 1ns

module tb_no_debounce;

    reg        vga_clk   = 1'b0;
    reg        sys_rst_n = 1'b1;
    reg        key_in    = 1'b1;
    reg        key_prev  = 1'b1;
    wire       key_press = key_prev & ~key_in;   // raw falling edge
    wire [1:0] screen_sel;

    integer trans = 0;
    integer i;
    reg [1:0] screen_d = 2'd0;

    screen_fsm dut (
        .vga_clk    (vga_clk),
        .sys_rst_n  (sys_rst_n),
        .key_press  (key_press),
        .screen_sel (screen_sel)
    );

    always #20 vga_clk = ~vga_clk;

    always @(posedge vga_clk) begin
        key_prev <= key_in;
        if (screen_sel !== screen_d) begin
            trans    = trans + 1;
            screen_d = screen_sel;
        end
    end

    initial begin
        $dumpfile("results/tb_no_debounce.vcd");
        $dumpvars(0, vga_clk, sys_rst_n, key_in, key_press, screen_sel);
        $dumpoff;

        $timeformat(-9, 0, " ns", 8);
        $display("=== Lab 4 un-debounced click (comparison only) ===");

        #1 sys_rst_n = 1'b0;
        #200 sys_rst_n = 1'b1;
        #1000;

        // The same bouncing click as tb_key_debounce: 8 ms of 0.1 ms toggles,
        // then the button stays pressed for 22 ms, then a clean release.
        key_in = 1'b0;
        for (i = 0; i < 40; i = i + 1) begin
            #100000 key_in = 1'b1;
            #100000 key_in = 1'b0;
        end
        #22000000;
        key_in = 1'b1;
        #22000000;

        $display("      one bouncing click, no debounce: %0d screen transitions, final screen_sel=%0d",
                 trans, screen_sel);
        if (trans <= 1) begin
            $display("FAIL  expected many transitions without debounce, saw %0d", trans);
            $fatal(1, "tb_no_debounce: the demonstration did not reproduce");
        end
        $display("RESULT: PASS (demonstration: %0d transitions for one click)", trans);
        $finish;
    end

endmodule
