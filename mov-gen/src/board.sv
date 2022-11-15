`timescale 1ns / 1ps
`default_nettype none

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
Stateful chess board, with 64 8-bit cells.

Syncs with the stack, and updates the board based on the moves.
*/
module board_rep #(parameter DEPTH=3) (
    input wire clk,
    input wire rst,
    input wire [DEPTH-1:0] sp,
    input stack_mov_t stack_head,
    output board_pos_t board [63:0]
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



    logic [DEPTH-1:0] old_sp;
    stack_mov_t old_stack_head;

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
                board[`src(stack_head)] <= {EMPTY, current_color};
                current_color <= ~current_color;

                // $display("push: %b %b %b %b", stack_head.src, stack_head.dst, stack_head.meta, current_color);

                // $display("PUSH, stack.src: ");
                // in = `src(stack_head);
                // `print_stack_element(in);
                // $display("PUSH, stack.dst: ");
                // `print_stack_element(`dst(stack_head));
                // $display("PUSH, board[dst]: ");
                // `print_board_element(board[`dst(stack_head)]);
                // $display("PUSH, board[src]: ");
                // `print_board_element(board[`src(stack_head)]);
                // $display("PUSH, meta: %b", `meta(stack_head));
                `print;

                
            end else if (sp < old_sp) begin
                // pop
                board[`src(old_stack_head)] <= board[`dst(old_stack_head)];
                board[`dst(old_stack_head)] <= {piece_that_was_taken(`meta(old_stack_head)), current_color};
                current_color <= ~current_color;
                // $display("POP, stack.src: ");
                // `print_stack_element(`src(old_stack_head));
                // $display("POP, stack.dst: ");
                // `print_stack_element(`dst(old_stack_head));
                // $display("POP, board[dst]: ");
                // `print_board_element(board[`dst(old_stack_head)]);
                // $display("POP, board[src]: ");
                // `print_board_element(board[`src(old_stack_head)]);
                // $display("POP, piece_that_was_taken: %b", piece_that_was_taken(`meta(old_stack_head)));
                `print;

            end 

            old_sp <= sp;
            old_stack_head <= stack_head;
        end
    end
endmodule

`default_nettype wire