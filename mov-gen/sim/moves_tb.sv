`timescale 1ns / 1ps
`default_nettype none



module moves_tb;
    logic clk_in;
    logic rst_in;

    logic [7:0] board [63:0];
    logic [1:0] top_col;

    logic step;
    logic spray;

    logic [15:0] stack_top;
    logic [3:0] sp;

    logic move_out_valid;
    logic [12:0] move_out;
    logic no_move; // exhausted all moves


    moves uut(
        .clk(clk_in),
        .rst(rst_in),

        // board interface
        .board(board),
        .top_col(top_col),

        // mov-gen interface 
        .step(step),
        .spray(spray),

        // stack interface
        .stack_top(stack_top),
        .sp(sp),

        .move_out_valid(move_out_valid),
        .move_out(move_out),
        .no_move(no_move)
    );

    always begin
        #5;
        clk_in = ~clk_in;
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
        
        assign board[0] = {WHITE, ROOK};
        assign board[1] = {WHITE, KNIGHT};
        assign board[2] = {WHITE, BISHOP};
        assign board[3] = {WHITE, QUEEN};
        assign board[4] = {WHITE, KING};
        assign board[5] = {WHITE, BISHOP};
        assign board[6] = {WHITE, KNIGHT};
        assign board[7] = {WHITE, ROOK};
        assign board[8] = {WHITE, PAWN};
        assign board[9] = {WHITE, PAWN};
        assign board[10] = {WHITE, PAWN};
        assign board[11] = {WHITE, PAWN};
        assign board[12] = {WHITE, PAWN};
        assign board[13] = {WHITE, PAWN};
        assign board[14] = {WHITE, PAWN};
        assign board[15] = {WHITE, PAWN};
        assign board[16] = {WHITE, EMPTY};
        assign board[17] = {WHITE, EMPTY};
        assign board[18] = {WHITE, EMPTY};
        assign board[19] = {WHITE, EMPTY};
        assign board[20] = {WHITE, EMPTY};
        assign board[21] = {WHITE, EMPTY};
        assign board[22] = {WHITE, EMPTY};
        assign board[23] = {WHITE, EMPTY};
        assign board[24] = {WHITE, EMPTY};
        assign board[25] = {WHITE, EMPTY};
        assign board[26] = {WHITE, EMPTY};
        assign board[27] = {WHITE, EMPTY};
        assign board[28] = {WHITE, EMPTY};
        assign board[29] = {WHITE, EMPTY};
        assign board[30] = {WHITE, EMPTY};
        assign board[31] = {WHITE, EMPTY};
        assign board[32] = {WHITE, EMPTY};
        assign board[33] = {WHITE, EMPTY};
        assign board[34] = {WHITE, EMPTY};
        assign board[35] = {WHITE, EMPTY};
        assign board[36] = {WHITE, EMPTY};
        assign board[37] = {WHITE, EMPTY};
        assign board[38] = {WHITE, EMPTY};
        assign board[39] = {WHITE, EMPTY};
        assign board[40] = {WHITE, EMPTY};
        assign board[41] = {WHITE, EMPTY};
        assign board[42] = {WHITE, EMPTY};
        assign board[43] = {WHITE, EMPTY};
        assign board[44] = {WHITE, EMPTY};
        assign board[45] = {WHITE, EMPTY};
        assign board[46] = {WHITE, EMPTY};
        assign board[47] = {WHITE, EMPTY};
        assign board[48] = {BLACK, PAWN};
        assign board[49] = {BLACK, PAWN};
        assign board[50] = {BLACK, PAWN};
        assign board[51] = {BLACK, PAWN};
        assign board[52] = {BLACK, PAWN};
        assign board[53] = {BLACK, PAWN};
        assign board[54] = {BLACK, PAWN};
        assign board[55] = {BLACK, PAWN};
        assign board[56] = {BLACK, ROOK};
        assign board[57] = {BLACK, KNIGHT};
        assign board[58] = {BLACK, BISHOP};
        assign board[59] = {BLACK, QUEEN};
        assign board[60] = {BLACK, KING};
        assign board[61] = {BLACK, BISHOP};
        assign board[62] = {BLACK, KNIGHT};
        assign board[63] = {BLACK, ROOK};

 
    initial begin
        $dumpfile("moves.vcd");
        $dumpvars(0, moves_tb); 
        clk_in = 1'b0;
        rst_in = 1'b1;
        #10;
        rst_in = 1'b0;
        sp = 4'b0000;
        stack_top = 16'b0000000000000000;
        top_col = 2'b10;

        #10;
        step = 1'b1;

        #10;
        step = 1'b0;

        #10000
        $finish;
    end

    endmodule
`default_nettype wire