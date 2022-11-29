`timescale 1ns / 1ps
`default_nettype none


/*
inputs:
    // mov-gen interface 
    input wire move_in_valid,
    input wire [15:0] move_in,
    input wire no_move, // exhausted all moves
    output logic step,
    output logic spray,

    // stack interface
    input wire [15:0] stack_head,
    input wire [DEPTH-1:0] sp,
    output logic [15:0] stack_move_out,
    output logic push,
    output logic pop,
    
    output logic [15:0] best_move_out,
*/

`define src(stack_mov) (stack_mov[15:10])
`define dst(stack_mov) (stack_mov[9:4])
`define meta(stack_mov) (stack_mov[3:0])



`define DO_STACK_ONCE if (push) begin\
            stack[sp] <= stack_move_out;\
            sp = sp + 1;\
        end else if (pop) begin\
            sp = sp - 1;\
            stack[sp] <= 16'b0;\
        end\
        #10\
        stack_head = (sp==0)?0:stack[sp-1];
        

`define DO_STACK `DO_STACK_ONCE\
        #10\
        `DO_STACK_ONCE\
        #10\
        `DO_STACK_ONCE\
        #10\

`define SEND_INVALID move_in_valid = 1'b0;\
        no_move = 1'b1;\
        move_in = 16'b0000000000000000;\
        #10;\
        move_in_valid = 1'b0;\
        no_move = 1'b0;\
        move_in = 16'b0000000000000000;\

`define SEND_MOVE(move) move_in_valid = 1'b1;\
        no_move = 1'b0;\
        move_in = move;\
        #10;\
        move_in_valid = 1'b0;\
        no_move = 1'b0;\
        move_in = 16'b0000000000000000;\

module minmax_tb;
    logic clk_in;
    logic rst_in;

    logic move_in_valid;
    logic [15:0] move_in;
    logic no_move;
    logic step;
    logic spray;

    logic [15:0] stack_head;
    logic [2:0] sp;
    logic [15:0] stack_move_out;
    logic push;
    logic pop;

    logic [15:0] stack[0:2];
    
    logic [15:0] best_move_out;


    traverse uut(
        .clk(clk_in),
        .rst(rst_in),

        .move_in_valid(move_in_valid),
        .move_in(move_in),
        .no_move(no_move),
        .step(step),
        .spray(spray),

        .stack_head(stack_head),
        .sp(sp),
        .stack_move_out(stack_move_out),
        .push(push),
        .pop(pop),

        .best_move_out(best_move_out)
    );

    always begin
        #5;
        clk_in = ~clk_in;
    end


    initial begin
        $dumpfile("minmax.vcd");
        $dumpvars(0, minmax_tb);
        clk_in = 1'b1;
        rst_in = 1'b1;

        stack[0] = 16'b0000000000000000;
        stack[1] = 16'b0000000000000000;
        stack[2] = 16'b0000000000000000;
        
        #10;
        rst_in = 1'b0;
        move_in_valid = 1'b0;
        sp = 3'b000;
        stack_head = 16'b0000000000000000;

        #10;

        `SEND_MOVE(16'b0000000000000001)
        `DO_STACK

        #100;

        `SEND_MOVE(16'b0000000000000011)
        `DO_STACK

        #100;

        `SEND_MOVE(16'b0000000000000101)
        `DO_STACK

        #100;

        `SEND_MOVE(16'b0000000000000110)
        `DO_STACK

        #100;

        // on move3 but no more moves to send
        `SEND_INVALID
        `DO_STACK

        #100;

        `SEND_MOVE(16'b0000000000000100)
        `DO_STACK
        
        #100;

        `SEND_MOVE(16'b0000000000000111)
        `DO_STACK
        
        #100;

        `SEND_INVALID
        `DO_STACK
        
        #100;

        `SEND_INVALID
        `DO_STACK
        
        #100;

        `SEND_MOVE(16'b0000000000000010)
        `DO_STACK
        
        #100;

        `SEND_INVALID
        `DO_STACK
        
        #100;

        `SEND_INVALID
        `DO_STACK
        
        #100;

        $finish;
    end

    endmodule
`default_nettype wire