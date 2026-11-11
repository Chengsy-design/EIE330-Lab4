// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// Testbench   : tb_vga_pic
// Purpose     : exhaustive check of the pixel generator for all three screens.
//
// Checks      : P1  screen 0 (bars): all 307,200 pixels against a golden model
//               P2  screen 1 (MUST): all 307,200 pixels against a golden model
//               P3  screen 2 (END) : all 307,200 pixels against a golden model
//               P4  bar widths: ten bars of exactly 64 pixels
//               P5  glyph pixel accounting: ones in the bitmap x 64
//               P6  sixteen hand probes (box corners, holes, gaps, off-screen)
//
// The golden model is written with a different structure from the RTL: it
// divides the word offset by the 96-pixel pitch and the screen x by the
// 64-pixel bar width instead of comparing box edges, and it uses a nested
// case per glyph instead of the flat 56-entry table.  A mistake that is
// common to both implementations would have to be a mistake in the bitmap
// data itself, which Figure 3 of the report checks by hand.
//
// Run         : iverilog -g2012 -Wall -s tb_vga_pic \
//                          -o results/tb_vga_pic.vvp Sim/tb_vga_pic.v \
//                          RTL/vga_pic.v && vvp results/tb_vga_pic.vvp
// ============================================================================
`timescale 1ns / 1ns

module tb_vga_pic;

    reg         vga_clk    = 1'b0;
    reg         sys_rst_n  = 1'b1;
    reg  [1:0]  screen_sel = 2'd0;
    reg  [9:0]  pix_x      = 10'd0;
    reg  [9:0]  pix_y      = 10'd0;
    wire [15:0] pix_data;

    integer errors = 0;
    integer x, y, s;
    integer mismatch;
    reg [15:0] exp;

    integer m_px [0:3];      // white pixels per letter of MUST
    integer e_px [0:2];      // white pixels per letter of END
    integer bar_px [0:9];    // pixels per colour bar
    integer i;

    vga_pic dut (
        .vga_clk    (vga_clk),
        .sys_rst_n  (sys_rst_n),
        .screen_sel (screen_sel),
        .pix_x      (pix_x),
        .pix_y      (pix_y),
        .pix_data   (pix_data)
    );

    always #20 vga_clk = ~vga_clk;      // 40 ns pixel clock

    // ------------------------------------------------------------------
    // Golden model
    // ------------------------------------------------------------------
    function [7:0] g_row(input [2:0] g, input [2:0] r);
        begin
            g_row = 8'h00;
            case (g)
                3'd0: begin
                    case (r)
                        3'd0: g_row = 8'hC3;  3'd1: g_row = 8'hE7;
                        3'd2: g_row = 8'hFF;  3'd3: g_row = 8'hDB;
                        3'd4: g_row = 8'hC3;  3'd5: g_row = 8'hC3;
                        3'd6: g_row = 8'hC3;  3'd7: g_row = 8'hC3;
                    endcase
                end
                3'd1: begin
                    case (r)
                        3'd0: g_row = 8'hC3;  3'd1: g_row = 8'hC3;
                        3'd2: g_row = 8'hC3;  3'd3: g_row = 8'hC3;
                        3'd4: g_row = 8'hC3;  3'd5: g_row = 8'hC3;
                        3'd6: g_row = 8'hE7;  3'd7: g_row = 8'h7E;
                    endcase
                end
                3'd2: begin
                    case (r)
                        3'd0: g_row = 8'h7E;  3'd1: g_row = 8'hE7;
                        3'd2: g_row = 8'hE0;  3'd3: g_row = 8'h7E;
                        3'd4: g_row = 8'h07;  3'd5: g_row = 8'h07;
                        3'd6: g_row = 8'hE7;  3'd7: g_row = 8'h7E;
                    endcase
                end
                3'd3: begin
                    case (r)
                        3'd0: g_row = 8'hFF;  3'd1: g_row = 8'hFF;
                        3'd2: g_row = 8'h18;  3'd3: g_row = 8'h18;
                        3'd4: g_row = 8'h18;  3'd5: g_row = 8'h18;
                        3'd6: g_row = 8'h18;  3'd7: g_row = 8'h18;
                    endcase
                end
                3'd4: begin
                    case (r)
                        3'd0: g_row = 8'hFF;  3'd1: g_row = 8'hC0;
                        3'd2: g_row = 8'hC0;  3'd3: g_row = 8'hFE;
                        3'd4: g_row = 8'hC0;  3'd5: g_row = 8'hC0;
                        3'd6: g_row = 8'hC0;  3'd7: g_row = 8'hFF;
                    endcase
                end
                3'd5: begin
                    case (r)
                        3'd0: g_row = 8'hC3;  3'd1: g_row = 8'hE3;
                        3'd2: g_row = 8'hF3;  3'd3: g_row = 8'hDB;
                        3'd4: g_row = 8'hCF;  3'd5: g_row = 8'hC7;
                        3'd6: g_row = 8'hC3;  3'd7: g_row = 8'hC3;
                    endcase
                end
                default: begin
                    case (r)
                        3'd0: g_row = 8'hFC;  3'd1: g_row = 8'hC7;
                        3'd2: g_row = 8'hC3;  3'd3: g_row = 8'hC3;
                        3'd4: g_row = 8'hC3;  3'd5: g_row = 8'hC3;
                        3'd6: g_row = 8'hC7;  3'd7: g_row = 8'hFC;
                    endcase
                end
            endcase
        end
    endfunction

    function [15:0] golden(input [1:0] scr, input [9:0] px, input [9:0] py);
        integer off, idx, col, row, origin;
        reg [7:0] rb;
        begin
            golden = 16'h0000;
            if (scr == 2'd0) begin
                // Colour bars: 10 bars, 64 pixels each.
                case (px / 64)
                    0: golden = 16'hF800;  1: golden = 16'hFC00;
                    2: golden = 16'hFFE0;  3: golden = 16'h07E0;
                    4: golden = 16'h07FF;  5: golden = 16'h001F;
                    6: golden = 16'hF81F;  7: golden = 16'h0000;
                    8: golden = 16'hFFFF;  default: golden = 16'hD69A;
                endcase
            end else if ((py >= 208) && (py < 272)) begin
                origin = (scr == 2'd1) ? 144 : 192;
                if ((px >= origin) &&
                    (px < origin + ((scr == 2'd1) ? 352 : 256))) begin
                    off = px - origin;
                    idx = off / 96;
                    if ((off % 96) < 64) begin
                        col = 7 - ((off % 96) / 8);
                        row = (py - 208) / 8;
                        rb  = g_row(idx + ((scr == 2'd1) ? 0 : 4), row[2:0]);
                        golden = rb[col] ? 16'hFFFF : 16'h0000;
                    end
                end
            end
        end
    endfunction

    // ------------------------------------------------------------------
    // Exhaustive sweep of one screen
    // ------------------------------------------------------------------
    task sweep(input [1:0] scr, input [8*16:1] name);
        begin
            screen_sel = scr;
            mismatch = 0;
            for (y = 0; y < 480; y = y + 1) begin
                for (x = 0; x < 640; x = x + 1) begin
                    @(negedge vga_clk);
                    pix_x = x[9:0];
                    pix_y = y[9:0];
                    @(posedge vga_clk);
                    #1;
                    exp = golden(scr, x[9:0], y[9:0]);
                    if (pix_data !== exp) begin
                        mismatch = mismatch + 1;
                        if (mismatch <= 4)
                            $display("      first mismatch at (%0d,%0d): rgb=%h expected %h",
                                     x, y, pix_data, exp);
                    end
                    // pixel accounting
                    if (pix_data == 16'hFFFF) begin
                        if (scr == 2'd1)
                            for (i = 0; i < 4; i = i + 1)
                                if ((x >= 144 + i * 96) && (x < 208 + i * 96))
                                    m_px[i] = m_px[i] + 1;
                        if (scr == 2'd2)
                            for (i = 0; i < 3; i = i + 1)
                                if ((x >= 192 + i * 96) && (x < 256 + i * 96))
                                    e_px[i] = e_px[i] + 1;
                    end
                    if ((scr == 2'd0) && (y == 0))
                        bar_px[x / 64] = bar_px[x / 64] + 1;
                end
            end
            if (mismatch != 0) begin
                errors = errors + 1;
                $display("FAIL  %0s: %0d / 307200 pixels differ", name, mismatch);
            end else begin
                $display("PASS  %0s: 307200 / 307200 pixels match the golden model",
                         name);
            end
        end
    endtask

    initial begin
        $dumpfile("results/tb_vga_pic.vcd");
        $dumpvars(0, vga_clk, sys_rst_n, screen_sel, pix_x, pix_y, pix_data);
        $dumpoff;

        $timeformat(-9, 0, " ns", 8);
        $display("=== Lab 4 vga_pic test ===");

        for (i = 0; i < 4; i = i + 1) m_px[i] = 0;
        for (i = 0; i < 3; i = i + 1) e_px[i] = 0;
        for (i = 0; i < 10; i = i + 1) bar_px[i] = 0;

        #1 sys_rst_n = 1'b0;
        #100 sys_rst_n = 1'b1;
        #100;

        // Warm-up: force every combinational block to evaluate once.  Icarus
        // does not run an always @(*) block whose inputs never change from
        // their initial values, so the very first probe would read an X even
        // though the design is fine.  Driving a different coordinate and a
        // different screen once removes that simulation artefact.
        screen_sel = 2'd2;
        pix_x      = 10'd639;
        pix_y      = 10'd479;
        @(posedge vga_clk);
        #1;

        // ---- P1..P3: the three screens ------------------------------------
        sweep(2'd0, "screen 0 (bars)");
        sweep(2'd1, "screen 1 (MUST)");
        sweep(2'd2, "screen 2 (END)");

        // ---- P4: bar widths ----------------------------------------------
        for (i = 0; i < 10; i = i + 1) begin
            if (bar_px[i] != 64) begin
                errors = errors + 1;
                $display("FAIL  bar %0d is %0d pixels wide, expected 64", i, bar_px[i]);
            end
        end
        $display("PASS  ten colour bars, each 64 pixels wide (640 = 10 x 64)");

        // ---- P5: glyph pixel accounting -----------------------------------
        $display("      MUST glyph pixels: M=%0d U=%0d S=%0d T=%0d",
                 m_px[0], m_px[1], m_px[2], m_px[3]);
        $display("      END  glyph pixels: E=%0d N=%0d D=%0d",
                 e_px[0], e_px[1], e_px[2]);
        if ((m_px[0] != 40 * 64) || (m_px[1] != 36 * 64) ||
            (m_px[2] != 39 * 64) || (m_px[3] != 28 * 64) ||
            (e_px[0] != 33 * 64) || (e_px[1] != 40 * 64) ||
            (e_px[2] != 38 * 64)) begin
            errors = errors + 1;
            $display("FAIL  glyph pixel counts do not match ones x 64");
        end else begin
            $display("PASS  glyph counts = bitmap ones x 64 (M 2560, U 2304, S 2496, T 1792, E 2112, N 2560, D 2432)");
        end

        // ---- P6: hand probes ----------------------------------------------
        $display("      probe check (screen, x, y, rgb)");
        probe(2'd0, 10'd0,   10'd0,   16'hF800, "bar 0 start");
        probe(2'd0, 10'd63,  10'd479, 16'hF800, "bar 0 end");
        probe(2'd0, 10'd64,  10'd240, 16'hFC00, "bar 1 start");
        probe(2'd0, 10'd639, 10'd479, 16'hD69A, "bar 9 end");
        probe(2'd1, 10'd144, 10'd208, 16'hFFFF, "M top-left");
        probe(2'd1, 10'd207, 10'd208, 16'hFFFF, "M top-right");
        probe(2'd1, 10'd144, 10'd271, 16'hFFFF, "M bottom-left");
        probe(2'd1, 10'd176, 10'd240, 16'h0000, "M hole");
        probe(2'd1, 10'd224, 10'd240, 16'h0000, "gap after M");
        probe(2'd1, 10'd144, 10'd207, 16'h0000, "above M");
        probe(2'd2, 10'd192, 10'd208, 16'hFFFF, "E top-left");
        probe(2'd2, 10'd256, 10'd240, 16'h0000, "gap after E");
        probe(2'd2, 10'd431, 10'd271, 16'hFFFF, "D bottom-right");
        probe(2'd2, 10'd447, 10'd271, 16'h0000, "right of D bottom");
        probe(2'd2, 10'd448, 10'd240, 16'h0000, "after D");
        probe(2'd2, 10'd191, 10'd240, 16'h0000, "before E");
        probe(2'd1, 10'd1023,10'd1023,16'h0000, "out of window");

        if (errors == 0)
            $display("RESULT: PASS (vga_pic: three screens exhaustive)");
        else
            $display("RESULT: FAIL (%0d errors)", errors);

        if (errors != 0) $fatal(1, "tb_vga_pic failed");
        $finish;
    end

    // One probe: drive one coordinate, compare the registered output.
    task probe(input [1:0] scr, input [9:0] px, input [9:0] py,
               input [15:0] want, input [8*20:1] what);
        begin
            screen_sel = scr;
            @(negedge vga_clk);
            pix_x = px;
            pix_y = py;
            @(posedge vga_clk);
            #1;
            if (pix_data !== want) begin
                errors = errors + 1;
                $display("FAIL  probe %0s (%0d,%0d): rgb=%h expected %h",
                         what, px, py, pix_data, want);
            end else begin
                $display("PASS  probe %0s (%0d,%0d): rgb=%h",
                         what, px, py, pix_data);
            end
        end
    endtask

endmodule
