/*
One-Chan: A hardware based chess engine
*/

`default_nettype none
`timescale 1ns / 1ps


/*
Each 8-bit board position looks like:

pos.piece = 6 bit; // holds the piece in one-hot encoding
pos.color = 2 bit; // holds the color in one-hot encoding
*/
typedef logic [7:0] board_pos_t;
// board pos is 8 bits, extract data using macros
`define piece(board_pos) (board_pos[5:0])
`define color(board_pos) (board_pos[7:6])



/*
Each 16-bit move on stack looks like:

mov.src = 6 bit;
mov.dst = 6 bit;
mov.meta = 4 bit; // holds the taken piece
*/
typedef logic [15:0] stack_mov_t;

`define src(stack_mov) (stack_mov[15:10])
`define dst(stack_mov) (stack_mov[9:4])
`define meta(stack_mov) (stack_mov[3:0])





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
    logic old_clean_down, old_clean_up;

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
    assign led[15:3] = sw[15:3];
    // row is incremented by 1 if btnu is pressed, and decremented by 1 if btnd is pressed
    logic [2:0] row_ind;
    assign led[2:0] = row_ind;

    always_ff @(posedge clk_in) begin
        if (grst) begin
            row_ind <= 3'b000;
        end else begin
            old_clean_down <= clean_down;
            old_clean_up <= clean_up;
            // falling edge
            if (old_clean_down && !clean_down) begin
                row_ind <= row_ind + 3'b001;
            end else if (old_clean_up && !clean_up) begin
                row_ind <= row_ind - 3'b001;
            end
        end
    end
    localparam EMPTY     = 6'b111111;
    localparam KING      = 6'b000001;
    localparam QUEEN     = 6'b000010;
    localparam ROOK      = 6'b000100;
    localparam KNIGHT    = 6'b001000;
    localparam BISHOP    = 6'b010000;
    localparam PAWN      = 6'b100000;

    localparam WHITE     = 2'b01;
    localparam BLACK     = 2'b10;
     

    logic [7:0] INIT_BOARD[63:0];
        assign INIT_BOARD[0] = {WHITE, ROOK};
        assign INIT_BOARD[1] = {WHITE, KNIGHT};
        assign INIT_BOARD[2] = {WHITE, BISHOP};
        assign INIT_BOARD[3] = {WHITE, QUEEN};
        assign INIT_BOARD[4] = {WHITE, KING};
        assign INIT_BOARD[5] = {WHITE, BISHOP};
        assign INIT_BOARD[6] = {WHITE, KNIGHT};
        assign INIT_BOARD[7] = {WHITE, ROOK};
        assign INIT_BOARD[8] = {WHITE, PAWN};
        assign INIT_BOARD[9] = {WHITE, PAWN};
        assign INIT_BOARD[10] = {WHITE, PAWN};
        assign INIT_BOARD[11] = {WHITE, PAWN};
        assign INIT_BOARD[12] = {WHITE, PAWN};
        assign INIT_BOARD[13] = {WHITE, PAWN};
        assign INIT_BOARD[14] = {WHITE, PAWN};
        assign INIT_BOARD[15] = {WHITE, PAWN};
        assign INIT_BOARD[16] = {WHITE, EMPTY};
        assign INIT_BOARD[17] = {WHITE, EMPTY};
        assign INIT_BOARD[18] = {WHITE, EMPTY};
        assign INIT_BOARD[19] = {WHITE, EMPTY};
        assign INIT_BOARD[20] = {WHITE, EMPTY};
        assign INIT_BOARD[21] = {WHITE, EMPTY};
        assign INIT_BOARD[22] = {WHITE, EMPTY};
        assign INIT_BOARD[23] = {WHITE, EMPTY};
        assign INIT_BOARD[24] = {WHITE, EMPTY};
        assign INIT_BOARD[25] = {WHITE, EMPTY};
        assign INIT_BOARD[26] = {WHITE, EMPTY};
        assign INIT_BOARD[27] = {WHITE, EMPTY};
        assign INIT_BOARD[28] = {WHITE, EMPTY};
        assign INIT_BOARD[29] = {WHITE, EMPTY};
        assign INIT_BOARD[30] = {WHITE, EMPTY};
        assign INIT_BOARD[31] = {WHITE, EMPTY};
        assign INIT_BOARD[32] = {WHITE, EMPTY};
        assign INIT_BOARD[33] = {WHITE, EMPTY};
        assign INIT_BOARD[34] = {WHITE, EMPTY};
        assign INIT_BOARD[35] = {WHITE, EMPTY};
        assign INIT_BOARD[36] = {WHITE, EMPTY};
        assign INIT_BOARD[37] = {WHITE, EMPTY};
        assign INIT_BOARD[38] = {WHITE, EMPTY};
        assign INIT_BOARD[39] = {WHITE, EMPTY};
        assign INIT_BOARD[40] = {WHITE, EMPTY};
        assign INIT_BOARD[41] = {WHITE, EMPTY};
        assign INIT_BOARD[42] = {WHITE, EMPTY};
        assign INIT_BOARD[43] = {WHITE, EMPTY};
        assign INIT_BOARD[44] = {WHITE, EMPTY};
        assign INIT_BOARD[45] = {WHITE, EMPTY};
        assign INIT_BOARD[46] = {WHITE, EMPTY};
        assign INIT_BOARD[47] = {WHITE, EMPTY};
        assign INIT_BOARD[48] = {BLACK, PAWN};
        assign INIT_BOARD[49] = {BLACK, PAWN};
        assign INIT_BOARD[50] = {BLACK, PAWN};
        assign INIT_BOARD[51] = {BLACK, PAWN};
        assign INIT_BOARD[52] = {BLACK, PAWN};
        assign INIT_BOARD[53] = {BLACK, PAWN};
        assign INIT_BOARD[54] = {BLACK, PAWN};
        assign INIT_BOARD[55] = {BLACK, PAWN};
        assign INIT_BOARD[56] = {BLACK, ROOK};
        assign INIT_BOARD[57] = {BLACK, KNIGHT};
        assign INIT_BOARD[58] = {BLACK, BISHOP};
        assign INIT_BOARD[59] = {BLACK, QUEEN};
        assign INIT_BOARD[60] = {BLACK, KING};
        assign INIT_BOARD[61] = {BLACK, BISHOP};
        assign INIT_BOARD[62] = {BLACK, KNIGHT};
        assign INIT_BOARD[63] = {BLACK, ROOK};



    

    logic [7:0] row_to_show [7:0];

    logic [7:0] board [63:0];
    always_ff @(posedge clk_in) begin
        if(grst) begin
            for (int i = 0; i < 64; i++) begin
                board[i] <= INIT_BOARD[i];
            end
        end else begin
            for (int i = 0; i < 8; i++) begin
                row_to_show[i] <= board[row_ind << 3 | i];
            end
        end
    end

     
    seven_seg seven_seg_inst(
        .clk(clk_in),
        .rst(grst),
        .row(row_to_show),

        .cat_out({cg, cf, ce, cd, cc, cb, ca}),
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