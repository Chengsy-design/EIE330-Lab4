`timescale 1ns / 1ns
// ============================================================================
// EIE330 FPGA-based System Design - Lab 4  Simple State Machine
// File        : vga_pic.v
// Contents    : pixel generator for the three screens, selected by screen_sel
//
// One pixel pipeline serves all three screens.  The screen select chooses
// between two content generators:
//
//   screen_sel = 0  BARS : ten vertical colour bars, 64 pixels each
//   screen_sel = 1  MUST : the word M U S T, 4 glyphs, white on black
//   screen_sel = 2  END  : the word E N D,   3 glyphs, white on black
//
// Layout of the text screens (screen coordinates, 640 x 480 area):
//
//   y = 208  +------+ 32 +------+ 32 +------+ 32 +------+
//            |  M   |    |  U   |    |  S   |    |  T   |      pitch 96
//            | 64x64|    | 64x64|    | 64x64|    | 64x64|
//   y = 271  +------+    +------+    +------+    +------+
//           x=144     240        336        432
//
//   y = 208  +------+ 32 +------+ 32 +------+
//            |  E   |    |  N   |    |  D   |                  pitch 96
//   y = 271  +------+    +------+    +------+
//           x=192     288        384
//
// Both words are centred (four glyphs span 144..495, three span 192..447,
// centres 319.5 and 319.5) and both use the same 32-pixel inter-letter gap.
// A glyph is an 8x8 bitmap whose cells are scaled by 8, so one glyph is
// 64x64 pixels and the low three bits of the in-glyph offset select the
// sub-pixel inside one scaled cell.  bit 7 of a row constant is the leftmost
// pixel, so the bitmap column index is 7 - gx[5:3].
//
// The colour bars are 64 pixels wide, so the bar index is pix_x[9:6]: the
// division is a wiring slice, exactly like the glyph column slice above.
//
// Colours are RGB565: R[15:11], G[10:5], B[4:0].
// ============================================================================
`default_nettype none

module vga_pic (
    input  wire        vga_clk,      // 25 MHz pixel clock
    input  wire        sys_rst_n,    // asynchronous reset, active low
    input  wire [1:0]  screen_sel,   // 0 = bars, 1 = MUST, 2 = END
    input  wire [9:0]  pix_x,        // x coordinate from vga_ctrl
    input  wire [9:0]  pix_y,        // y coordinate from vga_ctrl
    output reg  [15:0] pix_data      // RGB565 colour of the requested pixel
);

    // ------------------------------------------------------------------
    // Screen codes, shared with screen_fsm.
    // ------------------------------------------------------------------
    localparam [1:0] SCREEN_BARS = 2'd0;
    localparam [1:0] SCREEN_MUST = 2'd1;
    localparam [1:0] SCREEN_END  = 2'd2;

    // ------------------------------------------------------------------
    // Text layout: one 64-pixel box per letter, 96-pixel pitch, top at 208.
    // ------------------------------------------------------------------
    localparam [9:0] TEXT_Y0   = 10'd208;
    localparam [9:0] TEXT_SIZE = 10'd64;
    // MUST: four boxes, pitch 96; END: three boxes, pitch 96.
    localparam [9:0] MUST_X0 = 10'd144;
    localparam [9:0] MUST_X1 = 10'd240;
    localparam [9:0] MUST_X2 = 10'd336;
    localparam [9:0] MUST_X3 = 10'd432;
    localparam [9:0] END_X0  = 10'd192;
    localparam [9:0] END_X1  = 10'd288;
    localparam [9:0] END_X2  = 10'd384;

    // Bitmap column of each box = (box left edge / 8) mod 8.  The boxes start
    // at multiples of 8, so this is a slice of the layout constant and it
    // follows the layout automatically.
    localparam [2:0] MUST_COL0 = MUST_X0[5:3];
    localparam [2:0] MUST_COL1 = MUST_X1[5:3];
    localparam [2:0] MUST_COL2 = MUST_X2[5:3];
    localparam [2:0] MUST_COL3 = MUST_X3[5:3];
    localparam [2:0] END_COL0  = END_X0[5:3];
    localparam [2:0] END_COL1  = END_X1[5:3];
    localparam [2:0] END_COL2  = END_X2[5:3];
    localparam [2:0] TEXT_ROW0 = TEXT_Y0[5:3];   // bitmap row of y = 208

    // ------------------------------------------------------------------
    // Palette.  The bar colours are the ten bars of the lecture's colour-bar
    // example, kept in the same order; the text screens use white on black,
    // as the lab asks.
    // ------------------------------------------------------------------
    localparam [15:0] C_RED    = 16'hF800;
    localparam [15:0] C_ORANGE = 16'hFC00;
    localparam [15:0] C_YELLOW = 16'hFFE0;
    localparam [15:0] C_GREEN  = 16'h07E0;
    localparam [15:0] C_CYAN   = 16'h07FF;
    localparam [15:0] C_BLUE   = 16'h001F;
    localparam [15:0] C_PURPLE = 16'hF81F;
    localparam [15:0] C_BLACK  = 16'h0000;
    localparam [15:0] C_WHITE  = 16'hFFFF;
    localparam [15:0] C_GRAY   = 16'hD69A;

    // ------------------------------------------------------------------
    // Glyph bitmaps: one compile-time constant per bitmap row, 1 = ink.
    // M, U, S, T are the Lab 3 bitmaps, reused unchanged; E, N, D are new
    // and drawn on the same 8x8 grid with the same 2-cell stroke.
    // ------------------------------------------------------------------
    localparam [7:0] M_ROW_0 = 8'b1100_0011;
    localparam [7:0] M_ROW_1 = 8'b1110_0111;
    localparam [7:0] M_ROW_2 = 8'b1111_1111;
    localparam [7:0] M_ROW_3 = 8'b1101_1011;
    localparam [7:0] M_ROW_4 = 8'b1100_0011;
    localparam [7:0] M_ROW_5 = 8'b1100_0011;
    localparam [7:0] M_ROW_6 = 8'b1100_0011;
    localparam [7:0] M_ROW_7 = 8'b1100_0011;

    localparam [7:0] U_ROW_0 = 8'b1100_0011;
    localparam [7:0] U_ROW_1 = 8'b1100_0011;
    localparam [7:0] U_ROW_2 = 8'b1100_0011;
    localparam [7:0] U_ROW_3 = 8'b1100_0011;
    localparam [7:0] U_ROW_4 = 8'b1100_0011;
    localparam [7:0] U_ROW_5 = 8'b1100_0011;
    localparam [7:0] U_ROW_6 = 8'b1110_0111;
    localparam [7:0] U_ROW_7 = 8'b0111_1110;

    localparam [7:0] S_ROW_0 = 8'b0111_1110;
    localparam [7:0] S_ROW_1 = 8'b1110_0111;
    localparam [7:0] S_ROW_2 = 8'b1110_0000;
    localparam [7:0] S_ROW_3 = 8'b0111_1110;
    localparam [7:0] S_ROW_4 = 8'b0000_0111;
    localparam [7:0] S_ROW_5 = 8'b0000_0111;
    localparam [7:0] S_ROW_6 = 8'b1110_0111;
    localparam [7:0] S_ROW_7 = 8'b0111_1110;

    localparam [7:0] T_ROW_0 = 8'b1111_1111;
    localparam [7:0] T_ROW_1 = 8'b1111_1111;
    localparam [7:0] T_ROW_2 = 8'b0001_1000;
    localparam [7:0] T_ROW_3 = 8'b0001_1000;
    localparam [7:0] T_ROW_4 = 8'b0001_1000;
    localparam [7:0] T_ROW_5 = 8'b0001_1000;
    localparam [7:0] T_ROW_6 = 8'b0001_1000;
    localparam [7:0] T_ROW_7 = 8'b0001_1000;

    localparam [7:0] E_ROW_0 = 8'b1111_1111;
    localparam [7:0] E_ROW_1 = 8'b1100_0000;
    localparam [7:0] E_ROW_2 = 8'b1100_0000;
    localparam [7:0] E_ROW_3 = 8'b1111_1110;
    localparam [7:0] E_ROW_4 = 8'b1100_0000;
    localparam [7:0] E_ROW_5 = 8'b1100_0000;
    localparam [7:0] E_ROW_6 = 8'b1100_0000;
    localparam [7:0] E_ROW_7 = 8'b1111_1111;

    localparam [7:0] N_ROW_0 = 8'b1100_0011;
    localparam [7:0] N_ROW_1 = 8'b1110_0011;
    localparam [7:0] N_ROW_2 = 8'b1111_0011;
    localparam [7:0] N_ROW_3 = 8'b1101_1011;
    localparam [7:0] N_ROW_4 = 8'b1100_1111;
    localparam [7:0] N_ROW_5 = 8'b1100_0111;
    localparam [7:0] N_ROW_6 = 8'b1100_0011;
    localparam [7:0] N_ROW_7 = 8'b1100_0011;

    localparam [7:0] D_ROW_0 = 8'b1111_1100;
    localparam [7:0] D_ROW_1 = 8'b1100_0111;
    localparam [7:0] D_ROW_2 = 8'b1100_0011;
    localparam [7:0] D_ROW_3 = 8'b1100_0011;
    localparam [7:0] D_ROW_4 = 8'b1100_0011;
    localparam [7:0] D_ROW_5 = 8'b1100_0011;
    localparam [7:0] D_ROW_6 = 8'b1100_0111;
    localparam [7:0] D_ROW_7 = 8'b1111_1100;

    // ------------------------------------------------------------------
    // 1. Colour-bar generator: bar index = pix_x / 64 = pix_x[9:6].
    // ------------------------------------------------------------------
    reg [15:0] bar_color;

    always @(*) begin
        case (pix_x[9:6])
            4'd0:    bar_color = C_RED;
            4'd1:    bar_color = C_ORANGE;
            4'd2:    bar_color = C_YELLOW;
            4'd3:    bar_color = C_GREEN;
            4'd4:    bar_color = C_CYAN;
            4'd5:    bar_color = C_BLUE;
            4'd6:    bar_color = C_PURPLE;
            4'd7:    bar_color = C_BLACK;
            4'd8:    bar_color = C_WHITE;
            4'd9:    bar_color = C_GRAY;
            default: bar_color = C_GRAY;      // 10..15 never occur at 640 wide
        endcase
    end

    // ------------------------------------------------------------------
    // 2. Text box decode: which glyph, and where its box starts.
    //    Every output is assigned before the case, so no latch is inferred.
    // ------------------------------------------------------------------
    reg        in_glyph;      // scan position is inside a letter box
    reg [2:0]  glyph;         // 0=M 1=U 2=S 3=T 4=E 5=N 6=D
    reg [2:0]  glyph_col;     // box left edge / 8 (see the note below)

    always @(*) begin
        in_glyph  = 1'b0;
        glyph     = 3'd0;
        glyph_col = 3'd0;

        if ((screen_sel != SCREEN_BARS) &&
            (pix_y >= TEXT_Y0) && (pix_y < TEXT_Y0 + TEXT_SIZE)) begin
            case (screen_sel)
                SCREEN_MUST: begin
                    if ((pix_x >= MUST_X0) && (pix_x < MUST_X0 + TEXT_SIZE)) begin
                        in_glyph = 1'b1; glyph = 3'd0; glyph_col = MUST_COL0;
                    end else if ((pix_x >= MUST_X1) &&
                                 (pix_x <  MUST_X1 + TEXT_SIZE)) begin
                        in_glyph = 1'b1; glyph = 3'd1; glyph_col = MUST_COL1;
                    end else if ((pix_x >= MUST_X2) &&
                                 (pix_x <  MUST_X2 + TEXT_SIZE)) begin
                        in_glyph = 1'b1; glyph = 3'd2; glyph_col = MUST_COL2;
                    end else if ((pix_x >= MUST_X3) &&
                                 (pix_x <  MUST_X3 + TEXT_SIZE)) begin
                        in_glyph = 1'b1; glyph = 3'd3; glyph_col = MUST_COL3;
                    end
                end
                SCREEN_END: begin
                    if ((pix_x >= END_X0) && (pix_x < END_X0 + TEXT_SIZE)) begin
                        in_glyph = 1'b1; glyph = 3'd4; glyph_col = END_COL0;
                    end else if ((pix_x >= END_X1) &&
                                 (pix_x <  END_X1 + TEXT_SIZE)) begin
                        in_glyph = 1'b1; glyph = 3'd5; glyph_col = END_COL1;
                    end else if ((pix_x >= END_X2) &&
                                 (pix_x <  END_X2 + TEXT_SIZE)) begin
                        in_glyph = 1'b1; glyph = 3'd6; glyph_col = END_COL2;
                    end
                end
                default: ;                       // bars: no glyph
            endcase
        end
    end

    // ------------------------------------------------------------------
    // 3. Bitmap lookup.  Row = in-glyph y / 8, column = 7 - in-glyph x / 8.
    // ------------------------------------------------------------------
    // The in-glyph offset is x - box_left, and only its bits [5:3] are used:
    // the low three bits are the sub-pixel inside a scaled cell and must not
    // change the colour.  Every box is 64 pixels wide and starts at a
    // multiple of 8, so the three-bit subtraction below gives exactly the
    // bitmap column without a wide subtractor and without a borrow.
    wire [2:0] bmp_col = 3'd7 - (pix_x[5:3] - glyph_col);
    wire [2:0] bmp_row = pix_y[5:3] - TEXT_ROW0;

    reg  [7:0] row_bits;

    always @(*) begin
        case ({glyph, bmp_row})
            {3'd0, 3'd0}: row_bits = M_ROW_0;
            {3'd0, 3'd1}: row_bits = M_ROW_1;
            {3'd0, 3'd2}: row_bits = M_ROW_2;
            {3'd0, 3'd3}: row_bits = M_ROW_3;
            {3'd0, 3'd4}: row_bits = M_ROW_4;
            {3'd0, 3'd5}: row_bits = M_ROW_5;
            {3'd0, 3'd6}: row_bits = M_ROW_6;
            {3'd0, 3'd7}: row_bits = M_ROW_7;

            {3'd1, 3'd0}: row_bits = U_ROW_0;
            {3'd1, 3'd1}: row_bits = U_ROW_1;
            {3'd1, 3'd2}: row_bits = U_ROW_2;
            {3'd1, 3'd3}: row_bits = U_ROW_3;
            {3'd1, 3'd4}: row_bits = U_ROW_4;
            {3'd1, 3'd5}: row_bits = U_ROW_5;
            {3'd1, 3'd6}: row_bits = U_ROW_6;
            {3'd1, 3'd7}: row_bits = U_ROW_7;

            {3'd2, 3'd0}: row_bits = S_ROW_0;
            {3'd2, 3'd1}: row_bits = S_ROW_1;
            {3'd2, 3'd2}: row_bits = S_ROW_2;
            {3'd2, 3'd3}: row_bits = S_ROW_3;
            {3'd2, 3'd4}: row_bits = S_ROW_4;
            {3'd2, 3'd5}: row_bits = S_ROW_5;
            {3'd2, 3'd6}: row_bits = S_ROW_6;
            {3'd2, 3'd7}: row_bits = S_ROW_7;

            {3'd3, 3'd0}: row_bits = T_ROW_0;
            {3'd3, 3'd1}: row_bits = T_ROW_1;
            {3'd3, 3'd2}: row_bits = T_ROW_2;
            {3'd3, 3'd3}: row_bits = T_ROW_3;
            {3'd3, 3'd4}: row_bits = T_ROW_4;
            {3'd3, 3'd5}: row_bits = T_ROW_5;
            {3'd3, 3'd6}: row_bits = T_ROW_6;
            {3'd3, 3'd7}: row_bits = T_ROW_7;

            {3'd4, 3'd0}: row_bits = E_ROW_0;
            {3'd4, 3'd1}: row_bits = E_ROW_1;
            {3'd4, 3'd2}: row_bits = E_ROW_2;
            {3'd4, 3'd3}: row_bits = E_ROW_3;
            {3'd4, 3'd4}: row_bits = E_ROW_4;
            {3'd4, 3'd5}: row_bits = E_ROW_5;
            {3'd4, 3'd6}: row_bits = E_ROW_6;
            {3'd4, 3'd7}: row_bits = E_ROW_7;

            {3'd5, 3'd0}: row_bits = N_ROW_0;
            {3'd5, 3'd1}: row_bits = N_ROW_1;
            {3'd5, 3'd2}: row_bits = N_ROW_2;
            {3'd5, 3'd3}: row_bits = N_ROW_3;
            {3'd5, 3'd4}: row_bits = N_ROW_4;
            {3'd5, 3'd5}: row_bits = N_ROW_5;
            {3'd5, 3'd6}: row_bits = N_ROW_6;
            {3'd5, 3'd7}: row_bits = N_ROW_7;

            {3'd6, 3'd0}: row_bits = D_ROW_0;
            {3'd6, 3'd1}: row_bits = D_ROW_1;
            {3'd6, 3'd2}: row_bits = D_ROW_2;
            {3'd6, 3'd3}: row_bits = D_ROW_3;
            {3'd6, 3'd4}: row_bits = D_ROW_4;
            {3'd6, 3'd5}: row_bits = D_ROW_5;
            {3'd6, 3'd6}: row_bits = D_ROW_6;
            {3'd6, 3'd7}: row_bits = D_ROW_7;

            default:      row_bits = 8'h00;
        endcase
    end

    // ------------------------------------------------------------------
    // 4. Colour selection and the single output register.
    // ------------------------------------------------------------------
    reg [15:0] pix_next;

    always @(*) begin
        case (screen_sel)
            SCREEN_BARS: pix_next = bar_color;
            SCREEN_MUST: pix_next = (in_glyph && row_bits[bmp_col])
                                   ? C_WHITE : C_BLACK;
            SCREEN_END:  pix_next = (in_glyph && row_bits[bmp_col])
                                   ? C_WHITE : C_BLACK;
            default:     pix_next = bar_color;
        endcase
    end

    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            pix_data <= 16'h0000;
        else
            pix_data <= pix_next;
    end

endmodule

`default_nettype wire
