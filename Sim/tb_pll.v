// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// Testbench   : tb_pll
// Purpose     : check the pixel clock produced by the divide-by-2 block.
// Checks      : 40 ns period, 20 ns high (50 % duty), output cleared by reset.
// Run         : iverilog -g2012 -Wall -s tb_pll -o results/tb_pll.vvp \
//                          Sim/tb_pll.v RTL/pll.v && vvp results/tb_pll.vvp
// ============================================================================
`timescale 1ns / 1ns

module tb_pll;

    reg  sys_clk   = 1'b0;
    reg  sys_rst_n = 1'b1;
    wire vga_clk;

    integer errors = 0;
    time t1, t2, t3;

    pll dut (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .vga_clk   (vga_clk)
    );

    // 50 MHz board clock: 20 ns period.
    always #10 sys_clk = ~sys_clk;

    initial begin
        $dumpfile("results/tb_pll.vcd");
        $dumpvars(0, tb_pll);

        $timeformat(-9, 0, " ns", 8);
        $display("=== Lab 4 pll test ===");

        // Reset from t = 0: make a real falling edge at t = 1 ns.
        #1 sys_rst_n = 1'b0;
        #83;
        if (vga_clk !== 1'b0) begin
            errors = errors + 1;
            $display("FAIL  vga_clk=%b while reset is asserted, expected 0", vga_clk);
        end else begin
            $display("PASS  vga_clk held at 0 while reset is asserted");
        end

        #1 sys_rst_n = 1'b1;          // release at t = 85 ns

        // Measure three periods and two high times.
        @(posedge vga_clk); t1 = $time;
        @(posedge vga_clk); t2 = $time;
        @(posedge vga_clk); t3 = $time;
        if ((t2 - t1 !== 40) || (t3 - t2 !== 40)) begin
            errors = errors + 1;
            $display("FAIL  vga_clk period %0d / %0d ns, expected 40 ns",
                     t2 - t1, t3 - t2);
        end else begin
            $display("PASS  vga_clk period = 40 ns (25.000 MHz)");
        end

        @(negedge vga_clk);
        if (($time - t3) !== 20) begin
            errors = errors + 1;
            $display("FAIL  vga_clk high time %0d ns, expected 20 ns", $time - t3);
        end else begin
            $display("PASS  vga_clk high time = 20 ns (50 %% duty)");
        end

        if (errors == 0)
            $display("RESULT: PASS (pll: period, duty and reset)");
        else
            $display("RESULT: FAIL (%0d errors)", errors);

        if (errors != 0) $fatal(1, "tb_pll failed");
        $finish;
    end

endmodule
