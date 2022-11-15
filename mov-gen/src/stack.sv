`timescale 1ns / 1ps
`default_nettype none

`define src(stack_mov) (stack_mov[15:
`define dst(stack_mov) (stack_mov[11:6])
`define meta(stack_mov) (stack_mov[15:12])

/*
Each 16-bit move on stack looks like:

mov.src = 6 bit;
mov.dst = 6 bit;
mov.meta = 4 bit; // holds the taken piece
*/
// typedef struct packed {
//     logic [5:0] src;
//     logic [5:0] dst;
//     logic [3:0] meta;
// } stack_mov_t;

typedef logic [15:0] stack_mov_t;

/*
3 element Stack, containing 16 bits in each level. 
Each level contains a stack_mov_t struct.
*/
module stack #(parameter DEPTH = 3) (
    input wire clk,
    input wire rst,
    input wire push,
    input wire pop,
    input stack_mov_t data_in, 
    output stack_mov_t data_out,
    output logic [DEPTH-1:0] sp // points to next free space
    );
    // OH: how to write good state machines in verilog? 
    // OH: how to do combinational logic in always_ff?
    // meta data values
    localparam NONE = 4'b1111; 
    localparam PAWN = 4'b0000;
    localparam KNIGHT = 4'b0001;
    localparam BISHOP = 4'b0010;
    localparam ROOK = 4'b0011;
    localparam QUEEN = 4'b0100; // DO AUXILIARY stuff in comb, state in always_ff
    localparam KING = 4'b0101;
    


    logic [DEPTH-1:0] sp_minus_one;
    stack_mov_t stack [DEPTH-1:0];

    always_ff @(posedge clk) begin
        if(rst) begin
            sp <= 0;
            sp_minus_one <= -1;
            // stack[0] <= {6'b0, 6'b0, NONE};
        end else begin
            if(push) begin
                sp <= sp + 1;
                sp_minus_one <= sp;
                stack[sp] <= data_in;
            end else if(pop) begin
                sp <= sp_minus_one;
                sp_minus_one <= sp_minus_one - 1;
            end
        end
    end


    // data_out is the top of the stack
    assign data_out = (sp==0)?{6'b0, 6'b0, NONE}:stack[sp_minus_one];

endmodule


`default_nettype wire