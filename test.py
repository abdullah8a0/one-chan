
for ind in range(0,64):
    string = f"""       \\
            if (board[{ind}][1:0] == 2'b01) begin \\
                case (board[{ind}][7:2])\\
                    EMPTY: $write(". ");\\
                    KING: $write("K ");\\
                    QUEEN: $write("Q ");\\
                    ROOK: $write("R ");\\
                    KNIGHT: $write("N ");\\
                    BISHOP: $write("B ");\\
                    PAWN: $write("P ");\\
                    default: $write("X ");\\
                endcase\\
            end \\
            else if (board[{ind}][1:0] == 2'b10) begin \\
                case (board[{ind}][7:2])\\
                    EMPTY: $write(". ");\\
                    KING: $write("k ");\\
                    QUEEN: $write("q ");\\
                    ROOK: $write("r ");\\
                    KNIGHT: $write("n ");\\
                    BISHOP: $write("b ");\\
                    PAWN: $write("p ");\\
                    default: $write("x ");\\
                endcase\\
            end\\
            if ({ind} % 8 == 7) $display("");\\"""
    print(string)
