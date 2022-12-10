`timescale 1ns / 1ps
`default_nettype none


/*
Traverses the game tree in depth first order.
When the stack is full, goes into SPRAY mode.
Otherwise it explores the tree using the stack and
steping up and down the tree.
*/
module traverse #(parameter DEPTH = 3) (
    input wire clk,
    input wire rst,

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
    
    output logic [15:0] best_move_out
    );

    logic st_full, st_empty;
    assign st_full = (sp == DEPTH);
    assign st_empty = (sp == 0);

    logic mov_gen_done;
    assign mov_gen_done = move_in_valid || no_move;
    

    localparam STEP_UP = 2'b00; 
    localparam STEP_DOWN = 2'b01; 
    localparam SPRAY = 2'b10; 

    logic [1:0] state;
    /*
    Basic Idea:
    Ignore spraying for now.
    1. Step down the tree, if the stack is full or there are no moves left goto 2
    2. Step up the tree, if the stack is empty goto 3
    3. Output the current move

    Stepping down pushes onto the stack, stepping up pops from the stack
    */


    always_ff @(posedge clk ) begin : DRIVE_NEXT_STATE_FF
        if (rst) begin
            state <= STEP_DOWN;
        end else begin
            case (state)
                STEP_DOWN: begin
                    if (st_full) begin // immediately spray
                        state <= SPRAY;
                    end else if (mov_gen_done) begin // if no move step up and pop, otherwise push and step down
                        if (no_move) begin
                            state <= STEP_UP;
                        end else begin
                            state <= STEP_DOWN;
                        end
                    end else begin
                        state <= STEP_DOWN;
                    end
                end
                STEP_UP: begin
                    if (st_empty && no_move) begin // output the current move
                        state <= SPRAY;
                    end else if (mov_gen_done) begin // if no move step up and pop, otherwise push and step down
                        if (no_move) begin
                            state <= STEP_UP;
                        end else begin
                            state <= STEP_DOWN;
                        end
                    end else begin
                        state <= STEP_UP;
                    end
                end
                SPRAY: begin // steps up
                    state <= STEP_UP;
                end
            endcase
        end
    end


    always_comb begin : DRIVE_OUTPUTS_COMB
        case (state)
            STEP_DOWN: begin
                push = !st_full && move_in_valid;
                pop = st_full || no_move;
                stack_move_out = move_in;
                step = !st_full && move_in_valid;
                spray = 1'b0;  
            end
            STEP_UP: begin
                push = move_in_valid;
                pop = !st_empty && (no_move || st_full);
                stack_move_out = move_in;
                step = 1'b0;
                spray = st_empty && no_move;
            end
            SPRAY: begin
                push = 1'b0;
                pop = 1'b0;
                step = 1'b0;
                spray = 1'b1;
                // TODO: figure out spray
            end
        endcase
    end

endmodule


`default_nettype wire