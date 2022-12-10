`timescale 1ns / 1ps
`default_nettype none


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
    input wire [3:0] sp,

    output logic move_out_valid,
    output logic [12:0] move_out,
    output logic no_move // exhausted all moves
    );

    logic [5:0] from_reg;
    logic [5:0] to_reg;
    logic [2:0] dx;
    logic [2:0] dy;

    // states
    localparam SEARCH = 2'b00;
    localparam MOVE = 2'b01;
    localparam IDLE = 2'b10;

    logic [1:0] state;


    // move generator
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            from_reg <= 0;
            to_reg <= 0;
            move_out_valid <= 0;
            no_move <= 0;
        end
    end

    always_ff @(posedge clk) begin 
        case (state)
            IDLE: begin
                if (step) begin
                    state <= SEARCH;
                    from_reg <= stack_top[15:10]; // from continues from stack top
                    to_reg <= 0;
                
                end
                no_move <= 0;
                move_out_valid <= 0;
            end
            SEARCH: begin
                if (from_reg == 63) begin
                    state <= IDLE;
                    no_move <= 1;
                end else begin
                    // if color to move found then move to move state
                    if (board[from_reg][7:6] == top_col) begin
                        to_reg <= 0;
                        dx <= 3'b110;
                        dy <= 3'b110;
                        state <= MOVE;
                    end else begin
                        // else increment from
                        from_reg <= from_reg + 1;
                        to_reg <= 0;
                    end
                    
                end
            end
            MOVE: begin
                if (dx == 3'b010 && dy == 3'b010) begin
                    to_reg <= 0;
                    from_reg <= from_reg + 1;
                    state <= SEARCH;
                end else begin // increment to
                    if (dx == 3'b010) begin
                        dx <= 3'b110;
                        dy <= dy + 1;
                    end else begin
                        dx <= dx + 1;
                    end
                    if (in_bounds(from_reg,dx,dy)) begin
                        to_reg <= {from_reg[5:3] + dy, from_reg[2:0] + dx};
                        if (target_xy(board[from_reg][5:0], dx, dy)) begin
                            move_out_valid <= 1;
                            move_out <= {from_reg, to_reg};
                            state <= IDLE; // only need one move
                        end
                    end else begin
                        to_reg <= 0;
                    end
                end
                    


                // if (to_reg == 63) begin
                //     to_reg <= 0;
                //     from_reg <= from_reg + 1;
                //     state <= SEARCH;
                // end else begin
                //     if (dx == 3'b010) begin
                //         dx <= 3'b110;
                //         dy <= dy + 1;
                //     end else begin
                //         dx <= dx + 1;
                //     end
                //     to_reg <= {from_reg[5:3] + dx, from_reg[2:0] + dy};
                // end
                // if (target_xy(board[from_reg][5:0], dx, dy)) begin
                //     move_out_valid <= 1;
                //     move_out <= {from_reg, to_reg};
                //     state <= IDLE; // only need one move
                // end
            end
       endcase 
    end
endmodule



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
    localparam X = 3'b010;
    localparam Y = 3'b010;

    logic [2:0] x;
    logic [2:0] y;
    logic x_neg_out_bound;
    logic y_neg_out_bound;
    logic x_pos_out_bound;
    logic y_pos_out_bound;

    assign x = from[2:0] + dx;
    assign y = from[5:3] + dy;


    assign x_neg_out_bound = x[2] && ~dx[2];
    assign y_neg_out_bound = y[2] && ~dy[2];


    assign x_pos_out_bound = ~x[2] && dx[2];
    assign y_pos_out_bound = ~y[2] && dy[2];

    return ~x_neg_out_bound & ~x_pos_out_bound & ~y_neg_out_bound & ~y_pos_out_bound;



endfunction

`default_nettype wire