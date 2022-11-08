`timescale 1ns / 1ps
`default_nettype none

`define PRINT_STACK $display("STACK:"); \
        $display("sp = %b", sp_out);\
        case (data_out.meta)\
            NONE: $display(". ");\
            KING: $display("K ");\
            QUEEN: $display("Q ");\
            ROOK: $display("R ");\
            KNIGHT: $display("N ");\
            BISHOP: $display("B ");\
            PAWN: $display("P ");\
            default: $display("X ");\
        endcase\

module  stack_tb;
    logic clk_in;
    logic rst_in;

    // DEFINE INPUTS HERE
    stack_mov_t data_in;
    stack_mov_t data_out;
    logic push_in = 0;
    logic pop_in = 0;
    logic [2:0] sp_out;


    stack uut(
        .clk(clk_in),
        .rst(rst_in),

        .push(push_in),
        .pop(pop_in),
        .data_in(data_in), 
        .data_out(data_out),
        .sp(sp_out)
    );

    always begin
        #5;
        clk_in = ~clk_in;
    end

    parameter NONE = 4'b1111;
    parameter PAWN = 4'b0000;
    parameter KNIGHT = 4'b0001;
    parameter BISHOP = 4'b0010;
    parameter ROOK = 4'b0011;
    parameter QUEEN = 4'b0100;
    parameter KING = 4'b0101;
 
    initial begin
        $dumpfile("stack.vcd"); 
        $dumpvars(0, stack_tb);
        clk_in = 1'b1;
        #7;
        rst_in = 1'b1;
        #10;
        rst_in = 1'b0;
        
        #10;
        push_in = 1'b1;
        data_in = {6'b000_000,6'b111_000,NONE};
        
        #10;
        `PRINT_STACK
        push_in = 1'b1;
        data_in = {6'b001_001,6'b111_000,PAWN};
        #10;
        `PRINT_STACK
        push_in = 1'b0;
        #100
        pop_in = 1'b1;
        #10;
        `PRINT_STACK
        pop_in = 1'b0;
        #1000
        $finish;
    end

    endmodule
`default_nettype wire