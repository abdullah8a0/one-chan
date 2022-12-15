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
// typedef logic [7:0] board_pos_t;
// board pos is 8 bits, extract data using macros
`define piece(board_pos) (board_pos[5:0])
`define color(board_pos) (board_pos[7:6])



/*
Each 16-bit move on stack looks like:

mov.src = 6 bit;
mov.dst = 6 bit;
mov.meta = 4 bit; // holds the taken piece
*/
// typedef logic [15:0] stack_mov_t;

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
    input wire btnl,

    output logic ca, cb, cc, cd, ce, cf, cg, dp,
    output logic [7:0] an,
    //leds
    output logic [15:0] led
);

    logic grst;
    logic start_calc;
    assign grst = btnc;
    logic clean_down, clean_up, clean_right, clean_left;
    logic old_clean_down, old_clean_up, old_clean_right, old_clean_left;

    logic [11:0] move_in;
    logic [3:0] meta_in;
    assign move_in = sw[11:0];
    assign meta_in = sw[15:12];

    debouncer up_cleaner( // scroll up
        .clk_in(clk_in),
        .rst_in(grst),
        .dirty_in(btnu),
        .clean_out(clean_up)
    );

    debouncer down_cleaner( // scroll down
        .clk_in(clk_in),
        .rst_in(grst),
        .dirty_in(btnd),
        .clean_out(clean_down)
    );

    debouncer right_cleaner( // push stack
        .clk_in(clk_in),
        .rst_in(grst),
        .dirty_in(btnr),
        .clean_out(clean_right)
    );

    debouncer left_cleaner( // pop stack
        .clk_in(clk_in),
        .rst_in(grst),
        .dirty_in(btnl),
        .clean_out(clean_left)
    );

    logic [2:0] row_ind;

    always_ff @(posedge clk_in) begin : DRIVE_BUTTONS
        if (grst) begin
            row_ind <= 3'b000;
        end else begin
            old_clean_down <= clean_down;
            old_clean_up <= clean_up;
            old_clean_right <= clean_right;
            old_clean_left <= clean_left;
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

    logic [7:0] row_to_show [7:0];
    logic [1:0] col_to_mov;

    logic [7:0] board [63:0];
    always_ff @(posedge clk_in) begin : DRIVE_IO
        if(grst) begin
        end else begin
            for (int i = 0; i < 8; i++) begin
                row_to_show[i] <= board[row_ind << 3 | i];
            end
        end
    end

    logic [2:0] sp_out;
    logic [21:0] stack_data_in, stack_data_out;


    logic force_move;
    logic [15:0] forced_board_move;

    board_rep board_inst (
        .clk(clk_in),
        .rst(grst),
        .force_move(force_move),
        .forced_board_move(forced_board_move),
        .sp(sp_out),
        .stack_head(stack_data_out[15:0]),
        .board(board),
        .color_to_move(col_to_mov)
    );



    moves mov_inst (
        .clk(clk_in),
        .rst(grst),

        // board interface
        .board(board),
        .top_col(col_to_mov),

        // mov-gen interface 
        .step(trav_inst.step || start_calc),
        // .step(start_calc),
        .spray(trav_inst.spray),

        // stack interface
        // .stack_top(16'b0000000000000000),
        // .delta(6'b111111),
        .stack_top((start_calc)? 16'b0 : stack_data_out[15:0]),
        .delta((start_calc)? 6'b111111: stack_data_out[21:16]),
        .sp(sp_out)
    );
    traverse trav_inst (
        .clk(0),
        .rst(grst),

        // mov-gen interface 
        .move_in_valid(mov_inst.move_out_valid),
        .move_in(mov_inst.move_out),
        .no_move(mov_inst.no_move),
        .delta_in(mov_inst.delta_out),


        // stack interface
        .stack_head(stack_data_out[15:0]),
        .sp(sp_out),
        .stack_move_out(stack_data_in),

        
        .best_move_out()//led)// TODO add led output
    );

    sender send_inst

    stack stack_inst (
        .clk(clk_in),
        .rst(grst),
        .push(trav_inst.push),
        .pop(trav_inst.pop),
        .data_in(stack_data_in),
        .data_out(stack_data_out),
        .sp(sp_out) 
    );




    localparam META_NONE = 4'b1111; 
    localparam META_PAWN = 4'b0000;
    localparam META_KNIGHT = 4'b0001;
    localparam META_BISHOP = 4'b0010;
    localparam META_ROOK = 4'b0011;
    localparam META_QUEEN = 4'b0100;
    localparam META_KING = 4'b0101;

    logic [3:0] meta_at_pos;
    always_comb begin : META_FROM_BOARD
        case (`piece(board[move_in[5:0]])) // piece at dst
            KING: meta_at_pos = META_KING;
            QUEEN: meta_at_pos = META_QUEEN;
            ROOK: meta_at_pos = META_ROOK;
            KNIGHT: meta_at_pos = META_KNIGHT;
            BISHOP: meta_at_pos = META_BISHOP;
            PAWN: meta_at_pos = META_PAWN;
            default: meta_at_pos = META_NONE;
        endcase
    end

    always_ff @(posedge clk_in) begin : DRIVE_MOVE
        if (old_clean_right && !clean_right) begin
            start_calc <= 1'b1;
            force_move <= 1'b0;
            // push
            // stack_data_in <= {sw[12:0], meta_at_pos}; 
            // push_in <= 1'b1;
        end else if (old_clean_left && !clean_left) begin
            // // pop
            // pop_in <= 1'b1;
            force_move <= 1'b1;
            start_calc <= 1'b0;
            forced_board_move <= {sw[11:0], meta_at_pos};

        end else begin
            start_calc <= 1'b0;
            force_move <= 1'b0;
            // push_in <= 1'b0;
            // pop_in <= 1'b0;
        end
    end
    extender ext_start (
        .clk(clk_in),
        .rst(grst),
        .in(start_calc)
    );
    extender ext_force (
        .clk(clk_in),
        .rst(grst),
        .in(force_move)
    );
    extender ext_move (
        .clk(clk_in),
        .rst(grst),
        .in(mov_inst.move_out_valid)
    );



    assign led[15] = col_to_mov;
    assign led[14] = ext_start.ext_out;
    assign led[13] = ext_force.ext_out;
    assign led[12] = ext_move.ext_out;
    assign led[11:0] = mov_inst.move_out;

    seven_seg seven_seg_inst(
        .clk(clk_in),
        .rst(grst),
        .row(row_to_show),

        .cat_out({cg, cf, ce, cd, cc, cb, ca}),
        .dot_out(dp),
        .an_out(an)
    );


endmodule


module sender (
    input wire clk,
    input wire rst,
    input wire [7:0] board [63:0],
    input wire [5:0] move,
    input wire move_valid,
    input wire no_move
    );

    logic load_iv;
    logic [7:0] load_id;

    logic [1:0] state;

    logic [7:0] move_buf [255:0];
    localparam IDLE = 2'b00; // fills board
    localparam MOV_RCV = 2'b01; // buffers move
    localparam MOV_SEND = 2'b10; // sends move


    spi_host spi_host_inst(
        .clk(clk),
        .nrst(~rst),
        .load_iv(load_iv),
        .load_id(load_id),
    
        .clk_out(),
        .sel_out(),
        .data_out()
    );

    logic [10:0] cnt;
    // fill the load_id with the board in idle state
    always_ff @(posedge clk ) begin
        if (rst) begin
            load_id <= 8'b00000000;
            load_iv <= 1'b0;
            state <= IDLE;
            cnt <= 0;
        end else begin
            case (state)
                IDLE: begin
                    load_id <= board[cnt];
                    load_iv <= 1'b1;
                    if (cnt == 63) begin
                        state <= MOV_RCV;
                        cnt <= 0;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end
                MOV_RCV: begin // put moves in buffer untill we get no_move, then send them
                    if (move_valid) begin
                        move_buf[cnt] <= move;
                        cnt <= cnt + 1;
                    end else if (no_move) begin
                        state <= MOV_SEND;
                        cnt <= 0;
                    end
                end
                MOV_SEND: begin
                    load_id <= move_buf[cnt];
                    load_iv <= 1'b1;
                    if (cnt == 255) begin
                        state <= IDLE;
                        cnt <= 0;
                    end else begin
                        cnt <= cnt + 1;
                    end
                end
            endcase
        end
    end

endmodule


module debouncer #(parameter CLK_PERIOD_NS = 10,
                   parameter DEBOUNCE_TIME_MS = 5)(
                  input wire clk_in,
                  input wire rst_in,
                  input wire dirty_in,
                  output logic clean_out);
  localparam COUNTER_SIZE = int'($ceil(DEBOUNCE_TIME_MS*1/CLK_PERIOD_NS));// TODO: 1_000_000
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

// takes a 10ns clk cycle pulse and generates a 0.5 s pulse
module extender
(
    input wire clk,
    input wire rst,
    input wire in,
    output logic ext_out
);
    localparam COUNTER_SIZE = 50_000_000;
    localparam COUNTER_WIDTH = $clog2(COUNTER_SIZE);

    logic [COUNTER_WIDTH-1:0] counter;
    logic old_sig_in;

    always_ff @(posedge clk) begin: DINSHIFT
        old_sig_in <= in;
    end

    always_ff @(posedge clk) begin: MAINDEBOUNCE
        if (in) begin
            counter <= 0;
            ext_out <= 1'b0;
        end else begin
            if (in != old_sig_in) begin
                counter <= COUNTER_SIZE;
                ext_out <= 1'b1;
            end else if (counter == 0)begin
                ext_out <= 1'b0;
            end else begin
                counter <= counter - 1;
            end
        end
    end
endmodule




`default_nettype wire