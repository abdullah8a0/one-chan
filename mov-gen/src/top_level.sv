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
    input wire btnr,

    output logic ca, cb, cc, cd, ce, cf, cg, dp,
    output logic [7:0] an
);
    logic grst;
    assign grst = btnc;
    logic clean_down, clean_up, clean_right;
    logic old_clean_down, old_clean_up, old_clean_right;

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

    debouncer right_cleaner(
        .clk_in(clk_in),
        .rst_in(grst),
        .dirty_in(btnr),
        .clean_out(clean_right)
    );



    always_ff @(posedge clk_in) begin
        if (grst) begin
            row_ind <= 3'b000;
        end else begin
            old_clean_down <= clean_down;
            old_clean_up <= clean_up;
            old_clean_right <= clean_right;
            // falling edge
            if (old_clean_down && !clean_down) begin
                row_ind <= row_ind - 3'b001;
            end else if (old_clean_up && !clean_up) begin
                row_ind <= row_ind + 3'b001;
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

    logic [2:0] row_ind;
    logic [7:0] row_to_show [7:0];

    logic [7:0] board [63:0];
    always_ff @(posedge clk_in) begin
        if(grst) begin
        end else begin
            for (int i = 0; i < 8; i++) begin
                row_to_show[i] <= board[row_ind << 3 | i];
            end
        end
    end

    logic [2:0] _sp;
    logic [11:0] _stack_head;

    board_rep board_inst (
        .clk(clk_in),
        .rst(grst),
        .sp(_sp),
        .stack_head({_stack_head, 4'b0000}),
        .board(board)
    );

    always_ff @(posedge clk_in) begin
        if (old_clean_right && !clean_right) begin
           _sp = sw[15:13];
           _stack_head = sw[12:0];      
        end else begin
            _sp = _sp;
            _stack_head = _stack_head;
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
  localparam COUNTER_SIZE = int'($ceil(DEBOUNCE_TIME_MS*1_000_000/CLK_PERIOD_NS));
  localparam COUNTER_WIDTH = $clog2(COUNTER_SIZE);

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