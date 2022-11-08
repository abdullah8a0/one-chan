`timescale 1ns / 1ps
`default_nettype none



module board_tb;
    logic clk_in;
    logic rst_in;

    logic [2:0] sp;
    stack_mov_t stack_head;

    board_pos_t data_out [63:0] ;

    parameter EMPTY     = 6'b111111;
    parameter KING      = 6'b000001;
    parameter QUEEN     = 6'b000010;
    parameter ROOK      = 6'b000100;
    parameter KNIGHT    = 6'b001000;
    parameter BISHOP    = 6'b010000;
    parameter PAWN      = 6'b100000;

    parameter WHITE     = 2'b01;
    parameter BLACK     = 2'b10;

    board_rep uut(
        .clk(clk_in),
        .rst(rst_in),
        .sp(sp),
        .stack_head(stack_head),
        .board_data(data_out)
    );

    always begin
        #5;
        clk_in = ~clk_in;
    end


 
    initial begin
        $dumpfile("board.vcd");
        $dumpvars(0, board_tb);
        clk_in = 1'b0;
        rst_in = 1'b1;
        #10;
        rst_in = 1'b0;
        sp = 3'b000;
        stack_head = {6'b000000, 6'b000000, 4'b0000};


        #50;
        // display initial board
        $display("BOARD:");
        for (integer i = 0; i < 64; i = i + 1) begin
            logic [7:0] piece = data_out[i];
            case (piece[5:0])
                EMPTY: $write(". ");
                KING: $write("K ");
                QUEEN: $write("Q ");
                ROOK: $write("R ");
                KNIGHT: $write("N ");
                BISHOP: $write("B ");
                PAWN: $write("P ");
                default: $write("X ");
            endcase
            if (i % 8 == 7) $display("");
        end

        sp = 3'b001;
        stack_head = {6'b000000, 6'b010010, 4'b0000};
        #50;

        // display board after move
        $display("BOARD:");
        for (integer i = 0; i < 64; i = i + 1) begin
            logic [7:0] piece = data_out[i];
            case (piece[5:0])
                EMPTY: $write(". ");
                KING: $write("K ");
                QUEEN: $write("Q ");
                ROOK: $write("R ");
                KNIGHT: $write("N ");
                BISHOP: $write("B ");
                PAWN: $write("P ");
                default: $write("X ");
            endcase
            if (i % 8 == 7) $display("");
        end
        


        #100
        $finish;
    end

    endmodule
`default_nettype wire