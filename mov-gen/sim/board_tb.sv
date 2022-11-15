`timescale 1ns / 1ps
`default_nettype none



`define print \
        $display("BOARD:");\
        for (integer i = 0; i < 64; i = i + 1) begin\
            piece = data_out[i];\
            if (i == 10) piece = 9'b11111111;\
            case (piece[5:0])\
                EMPTY: $write(". ");\
                KING: $write("K ");\
                QUEEN: $write("Q ");\
                ROOK: $write("R ");\
                KNIGHT: $write("N ");\
                BISHOP: $write("B ");\
                PAWN: $write("P ");\
                default: $write("X ");\
            endcase\
            if (i % 8 == 7) $display("");\
        end \


module board_tb;
    logic clk_in;
    logic rst_in;

    logic [2:0] sp;
    stack_mov_t stack_head;

    logic [8:0] data_out [63:0] ;

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
        .board(data_out)
    );

    always begin
        #5;
        clk_in = ~clk_in;
    end
    logic [7:0] piece;


 
    initial begin
        $dumpfile("board.vcd");
        $dumpvars(0, board_tb);
        clk_in = 1'b0;
        rst_in = 1'b1;
        #10;
        rst_in = 1'b0;
        sp = 3'b000;
        stack_head = {6'b000000, 6'b000000, 4'b1111};


        #50;
        // display initial board
        // `print

        sp = 3'b001;
        stack_head = {6'b000000, 6'b010010, 4'b1111};
        #50;

        // `print

        sp = 3'b010;
        stack_head = {6'b111111, 6'b010010, 4'b0011};
        #50;

        // `print

        sp = 3'b011;
        stack_head = {6'b000111, 6'b010010, 4'b0011};
        #50;

        // `print
        // now we pop the stack

        sp = 3'b010;
        stack_head = {6'b111111, 6'b010010, 4'b0011};
        #50;

        // `print

        sp = 3'b001;
        stack_head = {6'b000000, 6'b010010, 4'b0011};
        #50;


        // `print
        sp = 3'b000;
        stack_head = {6'b000000, 6'b000000, 4'b1111};
        #50;

        #100
        $finish;
    end

    endmodule
`default_nettype wire