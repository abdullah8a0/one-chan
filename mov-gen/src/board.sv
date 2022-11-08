`timescale 1ns / 1ps
`default_nettype none

/*
Each 8-bit board position looks like:

pos.piece = 6 bit; // holds the piece in one-hot encoding
pos.color = 2 bit; // holds the color in one-hot encoding
*/
typedef struct packed {
    logic [5:0] piece;
    logic [1:0] color;
} board_pos_t;

/*
Stateful chess board, with 64 8-bit cells.

Syncs with the stack, and updates the board based on the moves.
*/
module board_rep #(parameter DEPTH=3) (
    input wire clk,
    input wire rst,
    input wire [DEPTH-1:0] sp,
    input stack_mov_t stack_head,
    output board_pos_t board_data [63:0]
    );
    parameter EMPTY     = 6'b111111;
    parameter KING      = 6'b000001;
    parameter QUEEN     = 6'b000010;
    parameter ROOK      = 6'b000100;
    parameter KNIGHT    = 6'b001000;
    parameter BISHOP    = 6'b010000;
    parameter PAWN      = 6'b100000;

    parameter WHITE     = 2'b01;
    parameter BLACK     = 2'b10;
    
    // OH: find better way to have constants
        // board_pos_t INIT_BOARD[63:0] = { // initial chess board config at the start of a game
        //     {ROOK, WHITE},  {KNIGHT, WHITE},{BISHOP, WHITE},{QUEEN, WHITE}, {KING, WHITE},  {BISHOP, WHITE},{KNIGHT, WHITE},{ROOK, WHITE},
        //     {PAWN, WHITE},  {PAWN, WHITE},  {PAWN, WHITE},  {PAWN, WHITE},  {PAWN, WHITE},  {PAWN, WHITE},  {PAWN, WHITE},  {PAWN, WHITE},
        //     {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE},
        //     {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE},
        //     {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE},
        //     {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE}, {EMPTY, WHITE},
        //     {PAWN, BLACK},  {PAWN, BLACK},  {PAWN, BLACK},  {PAWN, BLACK},  {PAWN, BLACK},  {PAWN, BLACK},  {PAWN, BLACK},  {PAWN, BLACK},
        //     {ROOK, BLACK},  {KNIGHT, BLACK},{BISHOP, BLACK},{QUEEN, BLACK}, {KING, BLACK},  {BISHOP, BLACK},{KNIGHT, BLACK},{ROOK, BLACK}
        // };

    // do the above assignment sequentially

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



    board_pos_t board [63:0]; // OH: find better memory type

    logic [DEPTH-1:0] old_sp;
    stack_mov_t old_stack_head;

    logic [1:0] current_color; // stores the current color of the player to move

    // turn stack meta data into board meta data. color can be inferred from the taking
    // meta = 4 bits -> piece = 6 bits OH: find how this works
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
            board[0] <= {ROOK, WHITE};
            current_color <= WHITE;

        end else begin
            board[0] <= {ROOK, WHITE};
            $display("board[0] = %b", board[0]);
            // coord = (x, y) -> index = x + y * 8
            // The representation does the conversion for us

            if (sp > old_sp) begin
                // push
                board[stack_head.dst] <= board[stack_head.src];
                board[stack_head.src] <= {EMPTY, current_color};
                current_color <= ~current_color;

            end else if (sp < old_sp) begin
                // pop
                board[old_stack_head.src] <= board[old_stack_head.dst];
                board[old_stack_head.dst] <= {piece_that_was_taken(old_stack_head.meta), current_color};

            end

            old_sp <= sp;
            old_stack_head <= stack_head;
        end
    end
endmodule

`default_nettype wire