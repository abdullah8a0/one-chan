`timescale 1ns / 1ps
`default_nettype none




// clear macros

`define print_stack_element(element) 
`define print_board_element(element)
`define print

`define piece(board_pos) (board_pos[5:0])
`define color(board_pos) (board_pos[7:6])

`define src(stack_mov) (stack_mov[15:10])
`define dst(stack_mov) (stack_mov[9:4])
`define meta(stack_mov) (stack_mov[3:0])


/*
Stateful chess board, with 64 8-bit cells.

Syncs with the stack, and updates the board based on the moves.
*/
module board_rep #(parameter DEPTH=3) (
    input wire clk,
    input wire rst,
    input wire [DEPTH-1:0] sp,
    input wire [15:0] stack_head,
    input wire force_move,
    input wire [15:0] forced_board_move,
    output logic [7:0] board [63:0],
    output logic [1:0] color_to_move
    );
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
        // assign INIT_BOARD[0] = {WHITE, ROOK};
        // assign INIT_BOARD[1] = {WHITE, KNIGHT};
        // assign INIT_BOARD[2] = {WHITE, BISHOP};
        // assign INIT_BOARD[3] = {WHITE, QUEEN};
        // assign INIT_BOARD[4] = {WHITE, KING};
        // assign INIT_BOARD[5] = {WHITE, BISHOP};
        // assign INIT_BOARD[6] = {WHITE, KNIGHT};
        // assign INIT_BOARD[7] = {WHITE, ROOK};
        // assign INIT_BOARD[8] = {WHITE, PAWN};
        // assign INIT_BOARD[9] = {WHITE, PAWN};
        // assign INIT_BOARD[10] = {WHITE, PAWN};
        // assign INIT_BOARD[11] = {WHITE, PAWN};
        // assign INIT_BOARD[12] = {WHITE, PAWN};
        // assign INIT_BOARD[13] = {WHITE, PAWN};
        // assign INIT_BOARD[14] = {WHITE, PAWN};
        // assign INIT_BOARD[15] = {WHITE, PAWN};
        // assign INIT_BOARD[16] = {WHITE, EMPTY};
        // assign INIT_BOARD[17] = {WHITE, EMPTY};
        // assign INIT_BOARD[18] = {WHITE, EMPTY};
        // assign INIT_BOARD[19] = {WHITE, EMPTY};
        // assign INIT_BOARD[20] = {WHITE, EMPTY};
        // assign INIT_BOARD[21] = {WHITE, EMPTY};
        // assign INIT_BOARD[22] = {WHITE, EMPTY};
        // assign INIT_BOARD[23] = {WHITE, EMPTY};
        // assign INIT_BOARD[24] = {WHITE, EMPTY};
        // assign INIT_BOARD[25] = {WHITE, EMPTY};
        // assign INIT_BOARD[26] = {WHITE, EMPTY};
        // assign INIT_BOARD[27] = {WHITE, EMPTY};
        // assign INIT_BOARD[28] = {WHITE, EMPTY};
        // assign INIT_BOARD[29] = {WHITE, EMPTY};
        // assign INIT_BOARD[30] = {WHITE, EMPTY};
        // assign INIT_BOARD[31] = {WHITE, EMPTY};
        // assign INIT_BOARD[32] = {WHITE, EMPTY};
        // assign INIT_BOARD[33] = {WHITE, EMPTY};
        // assign INIT_BOARD[34] = {WHITE, EMPTY};
        // assign INIT_BOARD[35] = {WHITE, EMPTY};
        // assign INIT_BOARD[36] = {WHITE, EMPTY};
        // assign INIT_BOARD[37] = {WHITE, EMPTY};
        // assign INIT_BOARD[38] = {WHITE, EMPTY};
        // assign INIT_BOARD[39] = {WHITE, EMPTY};
        // assign INIT_BOARD[40] = {WHITE, EMPTY};
        // assign INIT_BOARD[41] = {WHITE, EMPTY};
        // assign INIT_BOARD[42] = {WHITE, EMPTY};
        // assign INIT_BOARD[43] = {WHITE, EMPTY};
        // assign INIT_BOARD[44] = {WHITE, EMPTY};
        // assign INIT_BOARD[45] = {WHITE, EMPTY};
        // assign INIT_BOARD[46] = {WHITE, EMPTY};
        // assign INIT_BOARD[47] = {WHITE, EMPTY};
        // assign INIT_BOARD[48] = {BLACK, PAWN};
        // assign INIT_BOARD[49] = {BLACK, PAWN};
        // assign INIT_BOARD[50] = {BLACK, PAWN};
        // assign INIT_BOARD[51] = {BLACK, PAWN};
        // assign INIT_BOARD[52] = {BLACK, PAWN};
        // assign INIT_BOARD[53] = {BLACK, PAWN};
        // assign INIT_BOARD[54] = {BLACK, PAWN};
        // assign INIT_BOARD[55] = {BLACK, PAWN};
        // assign INIT_BOARD[56] = {BLACK, ROOK};
        // assign INIT_BOARD[57] = {BLACK, KNIGHT};
        // assign INIT_BOARD[58] = {BLACK, BISHOP};
        // assign INIT_BOARD[59] = {BLACK, QUEEN};
        // assign INIT_BOARD[60] = {BLACK, KING};
        // assign INIT_BOARD[61] = {BLACK, BISHOP};
        // assign INIT_BOARD[62] = {BLACK, KNIGHT};
        // assign INIT_BOARD[63] = {BLACK, ROOK};



        assign INIT_BOARD[0] = {WHITE, EMPTY};
        assign INIT_BOARD[1] = {WHITE, EMPTY};
        assign INIT_BOARD[2] = {WHITE, EMPTY};
        assign INIT_BOARD[3] = {WHITE, EMPTY};
        assign INIT_BOARD[4] = {WHITE, EMPTY};
        assign INIT_BOARD[5] = {WHITE, EMPTY};
        assign INIT_BOARD[6] = {WHITE, EMPTY};
        assign INIT_BOARD[7] = {WHITE, EMPTY};
        assign INIT_BOARD[8] = {WHITE, EMPTY};
        assign INIT_BOARD[9] = {WHITE, EMPTY};
        assign INIT_BOARD[10] = {WHITE, EMPTY};
        assign INIT_BOARD[11] = {WHITE, EMPTY};
        assign INIT_BOARD[12] = {WHITE, EMPTY};
        assign INIT_BOARD[13] = {WHITE, EMPTY};
        assign INIT_BOARD[14] = {WHITE, EMPTY};
        assign INIT_BOARD[15] = {WHITE, EMPTY};
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
        assign INIT_BOARD[29] = {WHITE, ROOK};
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
        assign INIT_BOARD[48] = {WHITE, EMPTY};
        assign INIT_BOARD[49] = {WHITE, EMPTY};
        assign INIT_BOARD[50] = {WHITE, EMPTY};
        assign INIT_BOARD[51] = {WHITE, EMPTY};
        assign INIT_BOARD[52] = {WHITE, EMPTY};
        assign INIT_BOARD[53] = {WHITE, EMPTY};
        assign INIT_BOARD[54] = {WHITE, EMPTY};
        assign INIT_BOARD[55] = {WHITE, EMPTY};
        assign INIT_BOARD[56] = {WHITE, EMPTY};
        assign INIT_BOARD[57] = {WHITE, EMPTY};
        assign INIT_BOARD[58] = {WHITE, EMPTY};
        assign INIT_BOARD[59] = {WHITE, EMPTY};
        assign INIT_BOARD[60] = {WHITE, EMPTY};
        assign INIT_BOARD[61] = {WHITE, EMPTY};
        assign INIT_BOARD[62] = {WHITE, EMPTY};
        assign INIT_BOARD[63] = {WHITE, EMPTY};

    logic [DEPTH-1:0] old_sp;
    logic [15:0] old_stack_head;

    logic [1:0] current_color; // stores the current color of the player to move

    // turn stack meta data into board meta data. color can be inferred from the taking
    // meta = 4 bits -> piece = 6 bits OH: find how this works fancy macro
    function logic [5:0] piece_that_was_taken(logic [3:0] meta);
        case(meta)
            4'b0000: return PAWN;
            4'b0001: return KNIGHT;
            4'b0010: return BISHOP;
            4'b0011: return ROOK;
            4'b0100: return QUEEN;
            4'b0101: return KING;
            default: return EMPTY;
        endcase
    endfunction

    always_ff @(posedge clk) begin
        if(rst) begin
            old_sp <= 0;
            old_stack_head <= {6'b000000, 6'b000000, 4'b0000};
            for (int i = 0; i < 64; i++) begin
                board[i] <= INIT_BOARD[i];
            end
            current_color <= WHITE;

        end else begin
            // coord = (x, y) -> index = x + y * 8
            // The representation does the conversion for us

            if (sp > old_sp) begin
                // push
                board[`dst(stack_head)] <= board[`src(stack_head)];
                board[`src(stack_head)] <= {WHITE, EMPTY};
                current_color <= ~current_color;
                
            end else if (sp < old_sp) begin
                // pop
                board[`src(old_stack_head)] <= board[`dst(old_stack_head)];
                board[`dst(old_stack_head)] <= {current_color, piece_that_was_taken(`meta(old_stack_head))};
                current_color <= ~current_color;

            end
            if (force_move) begin
                // force moved
                board[`dst(forced_board_move)] <= board[`src(forced_board_move)];
                board[`src(forced_board_move)] <= {WHITE, EMPTY};
                current_color <= ~current_color;
            end

            old_sp <= sp;
            old_stack_head <= stack_head;
        end
    end

    assign color_to_move = current_color;
endmodule

`default_nettype wire