`timescale 1ns / 1ps
`default_nettype none


/*
Generates moves for the chess engine
*/
module moves(
    input wire clk,
    input wire rst,

    // board interface
    input wire [7:0] board [63:0],
    input wire [1:0] top_col,

    // mov-gen interface 
    input wire step,
    input wire spray,

    // stack interface
    input wire [15:0] stack_top,
    input wire [5:0] delta,
    input wire [3:0] sp,

    output logic move_out_valid,
    output logic [11:0] move_out,
    output logic no_move, // exhausted all moves
    output logic [5:0] delta_out
    );

    logic [5:0] from_reg;
    logic [2:0] dx;
    logic [2:0] dy;

    // states
    localparam SEARCH = 2'b00;
    localparam MOVE1 = 2'b01; // ring 1
    localparam MOVE2 = 2'b10; // ring 2
    localparam IDLE = 2'b11;

    logic [1:0] state;

    // (-2,-2) -> (2,2)
    function logic target_xy (logic [5:0] piece, logic [2:0] x, logic [2:0] y); // x,y signed 3 bit
        
        localparam KING      = 6'b000001;
        localparam QUEEN     = 6'b000010;
        localparam ROOK      = 6'b000100;
        localparam KNIGHT    = 6'b001000;
        localparam BISHOP    = 6'b010000;
        localparam PAWN      = 6'b100000;


        case ({x, y}) // x,y := {0, 1, 2, -1, -2}

            // x = 0, y = 0, 1, 2, -1, -2
            6'b000000: return 0;

            6'b000001: return piece == KING || piece == QUEEN || piece == ROOK;
            6'b000010: return piece == QUEEN || piece == ROOK;

            6'b000111: return piece == KING || piece == QUEEN || piece == ROOK;
            6'b000110: return piece == QUEEN || piece == ROOK;

            // x = 1, y = 0, 1, 2, -1, -2
            6'b001000: return piece == KING || piece == QUEEN || piece == ROOK;

            6'b001001: return piece == KING || piece == QUEEN || piece == BISHOP;
            6'b001010: return piece == KNIGHT;

            6'b001111: return piece == KING || piece == QUEEN || piece == BISHOP;
            6'b001110: return piece == KNIGHT;

            // x = 2, y = 0, 1, 2, -1, -2
            6'b010000: return piece == QUEEN || piece == ROOK;

            6'b010001: return piece == KNIGHT;
            6'b010010: return piece == QUEEN || piece == BISHOP;

            6'b010111: return piece == KNIGHT;
            6'b010110: return piece == QUEEN || piece == BISHOP;

            // x = -1, y = 0, 1, 2, -1, -2
            6'b111000: return piece == KING || piece == QUEEN || piece == ROOK;

            6'b111001: return piece == KING || piece == QUEEN || piece == BISHOP;
            6'b111010: return piece == KNIGHT;

            6'b111111: return piece == KING || piece == QUEEN || piece == BISHOP;
            6'b111100: return piece == KNIGHT;

            // x = -2, y = 0, 1, 2, -1, -2
            6'b100000: return piece == QUEEN || piece == ROOK;

            6'b110001: return piece == KNIGHT;
            6'b110010: return piece == QUEEN || piece == BISHOP;

            6'b110111: return piece == KNIGHT;
            6'b110110: return piece == QUEEN || piece == BISHOP;
            default: return 0;
        endcase

    endfunction



    function logic in_bounds (logic [5:0] from, logic [2:0] dx, logic [2:0] dy);
        // dx, dy := {0, 1, 2, -1, -2}, checks if to is in bounds in the x and y direction in 8x8 board
        // does not use signed arithmetic, do it manually usign bit tricks
        logic x_neg_out_bound;
        logic y_neg_out_bound;
        logic x_pos_out_bound;
        logic y_pos_out_bound;
            
        // (dx = -1 and x = 0) or (dx = -2 and x=0,1)
        // so dx is neg and x is 0 or dx is -2 and x is 1
        x_neg_out_bound = (dx[2] & (from[2:0] == 3'b000)) | (dx == 3'b110 && from[2:0] == 3'b001);
        y_neg_out_bound = (dy[2] & (from[5:3] == 3'b000)) | (dy == 3'b110 && from[5:3] == 3'b001);

        // (dx = 1 and x = 7) or (dx = 2 and x=6,7)
        x_pos_out_bound = (dx == 3'b001 && from[2:0] == 3'b111) | (dx == 3'b010 && from[2:1] == 3'b11);
        y_pos_out_bound = (dy == 3'b001 && from[5:3] == 3'b111) | (dy == 3'b010 && from[5:4] == 3'b11);
            
        return ~(x_neg_out_bound || y_neg_out_bound || x_pos_out_bound || y_pos_out_bound);

    endfunction



    // move generator
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            from_reg <= 0;
            move_out_valid <= 0;
            no_move <= 0;
            move_out <= 0;
            delta_out <= 0;

        end else begin
            case (state)
                IDLE: begin
                    if (step) begin
                        state <= SEARCH;
                        from_reg <= stack_top[15:10]; // from continues from stack top
                        dy <= delta[5:3];
                        dx <= delta[2:0];
                    end
                    no_move <= 0;
                    move_out_valid <= 0;
                end
                SEARCH: begin
                    if (from_reg == 63) begin
                        state <= IDLE;
                        delta_out <= delta;
                        no_move <= 1;
                    end else begin
                        // if color to move found then move to move state
                        if (board[from_reg][7:6] != top_col) begin
                            // if any of dx, dx is -2 or 2 then move to move2
                            if (dx == 3'b110 || dx == 3'b010 || dy == 3'b110 || dy == 3'b010) begin
                                state <= MOVE2;
                            end else begin
                                state <= MOVE1;
                            end
                        end else begin
                            // else increment from
                            from_reg <= from_reg + 1;
                            dx <= 3'b111;
                            dy <= 3'b111;
                        end
                        
                    end
                end
                MOVE1: begin
                    if (dx == 3'b001 && dy == 3'b001) begin
                        dx <= 3'b110;
                        dy <= 3'b110;
                        state <= MOVE2;
                    end else begin // increment to
                        if (dx == 3'b001) begin
                            dx <= 3'b111;
                            dy <= dy + 1;
                        end else begin
                            dx <= dx + 1;
                        end
                        if (in_bounds(from_reg,dx,dy)) begin
                            if (target_xy(board[from_reg][5:0], dx, dy)) begin
                                move_out_valid <= 1;
                                move_out <= {from_reg, from_reg[5:3] + dy, from_reg[2:0] + dx};
                                state <= IDLE; // only need one move
                                // set delta_out
                                delta_out <= {dy+1'b1,(dx == 3'b001) ? 3'b111 :  dx+1'b1};
                            end
                        end
                    end
                end
                MOVE2: begin
                    if (dx == 3'b010 && dy == 3'b010) begin
                        from_reg <= from_reg + 1;
                        state <= SEARCH;
                    end else begin // increment to
                        if (dx == 3'b010) begin
                            dx <= 3'b110;
                            dy <= dy + 1;
                        end else begin
                            // dy = -2,2. Do dx = -2,-1,0,1,2
                            // otherwise do dx = -2,0,2
                            if (dy == 3'b110 || dy == 3'b010) begin
                                dx <= dx + 1;
                            end else begin
                                dx <= dx + 2;
                            end
                        end
                        if (in_bounds(from_reg,dx,dy)) begin
                            // TODO: check here for blockage
                            if (target_xy(board[from_reg][5:0], dx, dy)) begin
                                move_out_valid <= 1;
                                move_out <= {from_reg, from_reg[5:3] + dy, from_reg[2:0] + dx};
                                state <= IDLE; // only need one move
                                // set delta_out

                                delta_out <= (dx == 3'b010) ? {dy+1'b1,3'b110} : ( (dy == 3'b010 || dy == 3'b110) ? {dy,dx+1'b1} : {dy,dx+2'b10});

                            end
                        end
                    end
                end
        endcase 
        end
    end
endmodule




`default_nettype wire