/*
One-Chan: A hardware based chess engine
*/

`default_nettype none
`timescale 1ns / 1ps






module top_level(
    input wire clk_in,
    input wire [15:0] sw,
    input wire btnc,
    input wire btnd,
    input wire btnu,

    output logic[15:0]    led,
    output logic ca, cb, cc, cd, ce, cf, cg, dp,
    output logic [7:0] an
);
    logic grst;
    assign grst = btnc;
    logic clean_down, clean_up;

    debouncer up_cleaner(
        .clk_in(clk_in),
        .rst_in(grst),
        .dirty_in(btnu),
        .clean_out(clean_up)
    );

    debouncer down_cleaner(
        .clk_in(clk_in),
        .rst_in(grst),
        .dirty_in(btnd),
        .clean_out(clean_down)
    );

    // for now, bind sw to led
    assign led = sw;
    // row is incremented by 1 if btnu is pressed, and decremented by 1 if btnd is pressed
    logic [2:0] row_ind;

    always_ff @(posedge clk_in) begin
        if (grst) begin
            row_ind <= 3'b000;
        end else begin
            if (clean_up) begin
                row_ind <= row_ind + 3'b001;
            end else if (clean_down) begin
                row_ind <= row_ind - 3'b001;
            end
        end
    end
    

    board_pos_t INIT_BOARD[63:0];
        assign INIT_BOARD[0] = {ROOK, WHITE};
        assign INIT_BOARD[1] = {KNIGHT, WHITE};
        assign INIT_BOARD[2] = {BISHOP, WHITE};
        assign INIT_BOARD[3] = {QUEEN, WHITE};
        assign INIT_BOARD[4] = {KING, WHITE};
        assign INIT_BOARD[5] = {BISHOP, WHITE};
        assign INIT_BOARD[6] = {KNIGHT, WHITE};
        assign INIT_BOARD[7] = {ROOK, WHITE};
        assign INIT_BOARD[8] = {PAWN, WHITE};
        assign INIT_BOARD[9] = {PAWN, WHITE};
        assign INIT_BOARD[10] = {PAWN, WHITE};
        assign INIT_BOARD[11] = {PAWN, WHITE};
        assign INIT_BOARD[12] = {PAWN, WHITE};
        assign INIT_BOARD[13] = {PAWN, WHITE};
        assign INIT_BOARD[14] = {PAWN, WHITE};
        assign INIT_BOARD[15] = {PAWN, WHITE};
        assign INIT_BOARD[16] = {EMPTY, WHITE};
        assign INIT_BOARD[17] = {EMPTY, WHITE};
        assign INIT_BOARD[18] = {EMPTY, WHITE};
        assign INIT_BOARD[19] = {EMPTY, WHITE};
        assign INIT_BOARD[20] = {EMPTY, WHITE};
        assign INIT_BOARD[21] = {EMPTY, WHITE};
        assign INIT_BOARD[22] = {EMPTY, WHITE};
        assign INIT_BOARD[23] = {EMPTY, WHITE};
        assign INIT_BOARD[24] = {EMPTY, WHITE};
        assign INIT_BOARD[25] = {EMPTY, WHITE};
        assign INIT_BOARD[26] = {EMPTY, WHITE};
        assign INIT_BOARD[27] = {EMPTY, WHITE};
        assign INIT_BOARD[28] = {EMPTY, WHITE};
        assign INIT_BOARD[29] = {EMPTY, WHITE};
        assign INIT_BOARD[30] = {EMPTY, WHITE};
        assign INIT_BOARD[31] = {EMPTY, WHITE};
        assign INIT_BOARD[32] = {EMPTY, WHITE};
        assign INIT_BOARD[33] = {EMPTY, WHITE};
        assign INIT_BOARD[34] = {EMPTY, WHITE};
        assign INIT_BOARD[35] = {EMPTY, WHITE};
        assign INIT_BOARD[36] = {EMPTY, WHITE};
        assign INIT_BOARD[37] = {EMPTY, WHITE};
        assign INIT_BOARD[38] = {EMPTY, WHITE};
        assign INIT_BOARD[39] = {EMPTY, WHITE};
        assign INIT_BOARD[40] = {EMPTY, WHITE};
        assign INIT_BOARD[41] = {EMPTY, WHITE};
        assign INIT_BOARD[42] = {EMPTY, WHITE};
        assign INIT_BOARD[43] = {EMPTY, WHITE};
        assign INIT_BOARD[44] = {EMPTY, WHITE};
        assign INIT_BOARD[45] = {EMPTY, WHITE};
        assign INIT_BOARD[46] = {EMPTY, WHITE};
        assign INIT_BOARD[47] = {EMPTY, WHITE};
        assign INIT_BOARD[48] = {PAWN, BLACK};
        assign INIT_BOARD[49] = {PAWN, BLACK};
        assign INIT_BOARD[50] = {PAWN, BLACK};
        assign INIT_BOARD[51] = {PAWN, BLACK};
        assign INIT_BOARD[52] = {PAWN, BLACK};
        assign INIT_BOARD[53] = {PAWN, BLACK};
        assign INIT_BOARD[54] = {PAWN, BLACK};
        assign INIT_BOARD[55] = {PAWN, BLACK};
        assign INIT_BOARD[56] = {ROOK, BLACK};
        assign INIT_BOARD[57] = {KNIGHT, BLACK};
        assign INIT_BOARD[58] = {BISHOP, BLACK};
        assign INIT_BOARD[59] = {QUEEN, BLACK};
        assign INIT_BOARD[60] = {KING, BLACK};
        assign INIT_BOARD[61] = {BISHOP, BLACK};
        assign INIT_BOARD[62] = {KNIGHT, BLACK};
        assign INIT_BOARD[63] = {ROOK, BLACK};



    

    logic [7:0] row_to_show [7:0];

    always_comb begin
        for (int i = 0; i < 8; i++) begin
            row_to_show[i] = INIT_BOARD[row_ind << 3 + i];
        end
    end

    
    seven_seg seven_seg_inst(
        .clk(clk_in),
        .rst(grst),
        .row()

        .cat_out({cg, cf, ce, cd, cc, cb, ca})
        .dot_out(dp),
        .an_out(an)
    );


endmodule



module debouncer #(parameter CLK_PERIOD_NS = 10,
                   parameter DEBOUNCE_TIME_MS = 5)(
                  input wire clk_in,
                  input wire rst_in,
                  input wire dirty_in,
                  output logic clean_out);
  parameter COUNTER_SIZE = int'($ceil(DEBOUNCE_TIME_MS*1_000_000/CLK_PERIOD_NS));
  parameter COUNTER_WIDTH = $clog2(COUNTER_SIZE);

  logic [COUNTER_WIDTH-1:0] counter;
  logic old_dirty_in;

  always_ff @(posedge clk_in) begin: DINSHIFT
    old_dirty_in <= dirty_in;
  end

  always_ff @(posedge clk_in) begin: MAINDEBOUNCE
    if (rst_in) begin
      counter <= 0;
      clean_out <= dirty_in;
    end else begin
      if (dirty_in != old_dirty_in) begin
        counter <= 0;
      end else if (counter == COUNTER_SIZE)begin
        clean_out <= dirty_in;
      end else begin
        counter <= counter + 1;
      end
    end
  end
endmodule

`default_nettype wire