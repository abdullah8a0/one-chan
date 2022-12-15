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



// takes a stack element and prints it
`define print_stack_element(element) \
    $write("Stack pos: "); \
    case (element[2:0]) \
        3'b000: $write("A"); \
        3'b001: $write("B"); \
        3'b010: $write("C"); \
        3'b011: $write("D"); \
        3'b100: $write("E"); \
        3'b101: $write("F"); \
        3'b110: $write("G"); \
        3'b111: $write("H"); \
    endcase \
    $write("%d", {1'b0,element[5:3]}+1'b1); \
    $display("");\

// takes a board element and prints it
`define print_board_element(element) \ 
        if (element[1:0] == WHITE) begin\
            $display("W");\
        end else begin\
            $display("B");\
        end\
        case(element[7:2])\
            PAWN: $display("PAWN");\
            KNIGHT: $display("KNIGHT");\
            BISHOP: $display("BISHOP");\
            ROOK: $display("ROOK");\
            QUEEN: $display("QUEEN");\
            KING: $display("KING");\
            EMPTY: $display("EMPTY");\
            default: $display("ERROR %b", element[7:2]);\
        endcase\

// Print whole board
`define print \
        $display("BOARD:");\
               \
            if (board[0][1:0] == 2'b01) begin \
                case (board[0][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[0][1:0] == 2'b10) begin \
                case (board[0][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (0 % 8 == 7) $display("");\
       \
            if (board[1][1:0] == 2'b01) begin \
                case (board[1][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[1][1:0] == 2'b10) begin \
                case (board[1][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (1 % 8 == 7) $display("");\
       \
            if (board[2][1:0] == 2'b01) begin \
                case (board[2][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[2][1:0] == 2'b10) begin \
                case (board[2][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (2 % 8 == 7) $display("");\
       \
            if (board[3][1:0] == 2'b01) begin \
                case (board[3][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[3][1:0] == 2'b10) begin \
                case (board[3][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (3 % 8 == 7) $display("");\
       \
            if (board[4][1:0] == 2'b01) begin \
                case (board[4][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[4][1:0] == 2'b10) begin \
                case (board[4][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (4 % 8 == 7) $display("");\
       \
            if (board[5][1:0] == 2'b01) begin \
                case (board[5][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[5][1:0] == 2'b10) begin \
                case (board[5][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (5 % 8 == 7) $display("");\
       \
            if (board[6][1:0] == 2'b01) begin \
                case (board[6][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[6][1:0] == 2'b10) begin \
                case (board[6][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (6 % 8 == 7) $display("");\
       \
            if (board[7][1:0] == 2'b01) begin \
                case (board[7][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[7][1:0] == 2'b10) begin \
                case (board[7][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (7 % 8 == 7) $display("");\
       \
            if (board[8][1:0] == 2'b01) begin \
                case (board[8][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[8][1:0] == 2'b10) begin \
                case (board[8][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (8 % 8 == 7) $display("");\
       \
            if (board[9][1:0] == 2'b01) begin \
                case (board[9][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[9][1:0] == 2'b10) begin \
                case (board[9][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (9 % 8 == 7) $display("");\
       \
            if (board[10][1:0] == 2'b01) begin \
                case (board[10][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[10][1:0] == 2'b10) begin \
                case (board[10][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (10 % 8 == 7) $display("");\
       \
            if (board[11][1:0] == 2'b01) begin \
                case (board[11][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[11][1:0] == 2'b10) begin \
                case (board[11][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (11 % 8 == 7) $display("");\
       \
            if (board[12][1:0] == 2'b01) begin \
                case (board[12][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[12][1:0] == 2'b10) begin \
                case (board[12][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (12 % 8 == 7) $display("");\
       \
            if (board[13][1:0] == 2'b01) begin \
                case (board[13][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[13][1:0] == 2'b10) begin \
                case (board[13][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (13 % 8 == 7) $display("");\
       \
            if (board[14][1:0] == 2'b01) begin \
                case (board[14][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[14][1:0] == 2'b10) begin \
                case (board[14][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (14 % 8 == 7) $display("");\
       \
            if (board[15][1:0] == 2'b01) begin \
                case (board[15][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[15][1:0] == 2'b10) begin \
                case (board[15][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (15 % 8 == 7) $display("");\
       \
            if (board[16][1:0] == 2'b01) begin \
                case (board[16][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[16][1:0] == 2'b10) begin \
                case (board[16][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (16 % 8 == 7) $display("");\
       \
            if (board[17][1:0] == 2'b01) begin \
                case (board[17][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[17][1:0] == 2'b10) begin \
                case (board[17][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (17 % 8 == 7) $display("");\
       \
            if (board[18][1:0] == 2'b01) begin \
                case (board[18][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[18][1:0] == 2'b10) begin \
                case (board[18][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (18 % 8 == 7) $display("");\
       \
            if (board[19][1:0] == 2'b01) begin \
                case (board[19][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[19][1:0] == 2'b10) begin \
                case (board[19][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (19 % 8 == 7) $display("");\
       \
            if (board[20][1:0] == 2'b01) begin \
                case (board[20][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[20][1:0] == 2'b10) begin \
                case (board[20][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (20 % 8 == 7) $display("");\
       \
            if (board[21][1:0] == 2'b01) begin \
                case (board[21][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[21][1:0] == 2'b10) begin \
                case (board[21][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (21 % 8 == 7) $display("");\
       \
            if (board[22][1:0] == 2'b01) begin \
                case (board[22][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[22][1:0] == 2'b10) begin \
                case (board[22][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (22 % 8 == 7) $display("");\
       \
            if (board[23][1:0] == 2'b01) begin \
                case (board[23][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[23][1:0] == 2'b10) begin \
                case (board[23][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (23 % 8 == 7) $display("");\
       \
            if (board[24][1:0] == 2'b01) begin \
                case (board[24][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[24][1:0] == 2'b10) begin \
                case (board[24][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (24 % 8 == 7) $display("");\
       \
            if (board[25][1:0] == 2'b01) begin \
                case (board[25][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[25][1:0] == 2'b10) begin \
                case (board[25][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (25 % 8 == 7) $display("");\
       \
            if (board[26][1:0] == 2'b01) begin \
                case (board[26][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[26][1:0] == 2'b10) begin \
                case (board[26][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (26 % 8 == 7) $display("");\
       \
            if (board[27][1:0] == 2'b01) begin \
                case (board[27][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[27][1:0] == 2'b10) begin \
                case (board[27][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (27 % 8 == 7) $display("");\
       \
            if (board[28][1:0] == 2'b01) begin \
                case (board[28][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[28][1:0] == 2'b10) begin \
                case (board[28][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (28 % 8 == 7) $display("");\
       \
            if (board[29][1:0] == 2'b01) begin \
                case (board[29][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[29][1:0] == 2'b10) begin \
                case (board[29][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (29 % 8 == 7) $display("");\
       \
            if (board[30][1:0] == 2'b01) begin \
                case (board[30][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[30][1:0] == 2'b10) begin \
                case (board[30][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (30 % 8 == 7) $display("");\
       \
            if (board[31][1:0] == 2'b01) begin \
                case (board[31][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[31][1:0] == 2'b10) begin \
                case (board[31][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (31 % 8 == 7) $display("");\
       \
            if (board[32][1:0] == 2'b01) begin \
                case (board[32][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[32][1:0] == 2'b10) begin \
                case (board[32][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (32 % 8 == 7) $display("");\
       \
            if (board[33][1:0] == 2'b01) begin \
                case (board[33][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[33][1:0] == 2'b10) begin \
                case (board[33][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (33 % 8 == 7) $display("");\
       \
            if (board[34][1:0] == 2'b01) begin \
                case (board[34][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[34][1:0] == 2'b10) begin \
                case (board[34][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (34 % 8 == 7) $display("");\
       \
            if (board[35][1:0] == 2'b01) begin \
                case (board[35][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[35][1:0] == 2'b10) begin \
                case (board[35][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (35 % 8 == 7) $display("");\
       \
            if (board[36][1:0] == 2'b01) begin \
                case (board[36][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[36][1:0] == 2'b10) begin \
                case (board[36][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (36 % 8 == 7) $display("");\
       \
            if (board[37][1:0] == 2'b01) begin \
                case (board[37][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[37][1:0] == 2'b10) begin \
                case (board[37][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (37 % 8 == 7) $display("");\
       \
            if (board[38][1:0] == 2'b01) begin \
                case (board[38][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[38][1:0] == 2'b10) begin \
                case (board[38][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (38 % 8 == 7) $display("");\
       \
            if (board[39][1:0] == 2'b01) begin \
                case (board[39][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[39][1:0] == 2'b10) begin \
                case (board[39][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (39 % 8 == 7) $display("");\
       \
            if (board[40][1:0] == 2'b01) begin \
                case (board[40][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[40][1:0] == 2'b10) begin \
                case (board[40][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (40 % 8 == 7) $display("");\
       \
            if (board[41][1:0] == 2'b01) begin \
                case (board[41][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[41][1:0] == 2'b10) begin \
                case (board[41][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (41 % 8 == 7) $display("");\
       \
            if (board[42][1:0] == 2'b01) begin \
                case (board[42][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[42][1:0] == 2'b10) begin \
                case (board[42][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (42 % 8 == 7) $display("");\
       \
            if (board[43][1:0] == 2'b01) begin \
                case (board[43][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[43][1:0] == 2'b10) begin \
                case (board[43][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (43 % 8 == 7) $display("");\
       \
            if (board[44][1:0] == 2'b01) begin \
                case (board[44][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[44][1:0] == 2'b10) begin \
                case (board[44][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (44 % 8 == 7) $display("");\
       \
            if (board[45][1:0] == 2'b01) begin \
                case (board[45][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[45][1:0] == 2'b10) begin \
                case (board[45][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (45 % 8 == 7) $display("");\
       \
            if (board[46][1:0] == 2'b01) begin \
                case (board[46][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[46][1:0] == 2'b10) begin \
                case (board[46][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (46 % 8 == 7) $display("");\
       \
            if (board[47][1:0] == 2'b01) begin \
                case (board[47][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[47][1:0] == 2'b10) begin \
                case (board[47][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (47 % 8 == 7) $display("");\
       \
            if (board[48][1:0] == 2'b01) begin \
                case (board[48][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[48][1:0] == 2'b10) begin \
                case (board[48][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (48 % 8 == 7) $display("");\
       \
            if (board[49][1:0] == 2'b01) begin \
                case (board[49][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[49][1:0] == 2'b10) begin \
                case (board[49][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (49 % 8 == 7) $display("");\
       \
            if (board[50][1:0] == 2'b01) begin \
                case (board[50][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[50][1:0] == 2'b10) begin \
                case (board[50][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (50 % 8 == 7) $display("");\
       \
            if (board[51][1:0] == 2'b01) begin \
                case (board[51][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[51][1:0] == 2'b10) begin \
                case (board[51][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (51 % 8 == 7) $display("");\
       \
            if (board[52][1:0] == 2'b01) begin \
                case (board[52][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[52][1:0] == 2'b10) begin \
                case (board[52][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (52 % 8 == 7) $display("");\
       \
            if (board[53][1:0] == 2'b01) begin \
                case (board[53][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[53][1:0] == 2'b10) begin \
                case (board[53][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (53 % 8 == 7) $display("");\
       \
            if (board[54][1:0] == 2'b01) begin \
                case (board[54][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[54][1:0] == 2'b10) begin \
                case (board[54][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (54 % 8 == 7) $display("");\
       \
            if (board[55][1:0] == 2'b01) begin \
                case (board[55][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[55][1:0] == 2'b10) begin \
                case (board[55][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (55 % 8 == 7) $display("");\
       \
            if (board[56][1:0] == 2'b01) begin \
                case (board[56][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[56][1:0] == 2'b10) begin \
                case (board[56][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (56 % 8 == 7) $display("");\
       \
            if (board[57][1:0] == 2'b01) begin \
                case (board[57][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[57][1:0] == 2'b10) begin \
                case (board[57][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (57 % 8 == 7) $display("");\
       \
            if (board[58][1:0] == 2'b01) begin \
                case (board[58][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[58][1:0] == 2'b10) begin \
                case (board[58][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (58 % 8 == 7) $display("");\
       \
            if (board[59][1:0] == 2'b01) begin \
                case (board[59][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[59][1:0] == 2'b10) begin \
                case (board[59][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (59 % 8 == 7) $display("");\
       \
            if (board[60][1:0] == 2'b01) begin \
                case (board[60][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[60][1:0] == 2'b10) begin \
                case (board[60][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (60 % 8 == 7) $display("");\
       \
            if (board[61][1:0] == 2'b01) begin \
                case (board[61][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[61][1:0] == 2'b10) begin \
                case (board[61][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (61 % 8 == 7) $display("");\
       \
            if (board[62][1:0] == 2'b01) begin \
                case (board[62][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[62][1:0] == 2'b10) begin \
                case (board[62][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (62 % 8 == 7) $display("");\
       \
            if (board[63][1:0] == 2'b01) begin \
                case (board[63][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("K ");\
                    QUEEN: $write("Q ");\
                    ROOK: $write("R ");\
                    KNIGHT: $write("N ");\
                    BISHOP: $write("B ");\
                    PAWN: $write("P ");\
                    default: $write("X ");\
                endcase\
            end \
            else if (board[63][1:0] == 2'b10) begin \
                case (board[63][7:2])\
                    EMPTY: $write(". ");\
                    KING: $write("k ");\
                    QUEEN: $write("q ");\
                    ROOK: $write("r ");\
                    KNIGHT: $write("n ");\
                    BISHOP: $write("b ");\
                    PAWN: $write("p ");\
                    default: $write("x ");\
                endcase\
            end\
            if (63 % 8 == 7) $display("");\





`default_nettype wire