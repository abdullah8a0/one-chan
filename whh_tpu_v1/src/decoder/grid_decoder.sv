`default_nettype none

`define piece(board_pos) (board_pos[5:0])
`define color(board_pos) (board_pos[7:6])

`define src_x(stack_mov) (stack_mov[15:13])
`define src_y(stack_mov) (stack_mov[12:10])
`define dst_x(stack_mov) (stack_mov[9:7])
`define dst_y(stack_mov) (stack_mov[6:4])
`define meta(stack_mov) (stack_mov[3:0])

module grid_decoder#(
    parameter WIDTH = 8,
    parameter HEIGHT = 8,
    parameter MOVE_WIDTH = 16,
    parameter DATA_WIDTH = 8,
    parameter MAX_MOVES = 220,

    parameter GRID_HEADER = 8'b11_01_01_01,
    parameter MOVE_HEADER = 8'b11_10_10_10
)(
    input wire clk,
    input wire nrst,

    input wire spi_iv,
    input wire [DATA_WIDTH-1:0] spi_id,

    // input finish, then send moves to register files to activate the program
    output logic moves_ov,
    output logic [7:0] total_move_od, 

    input wire compute_grid,
    input wire [7:0] move_num,
    output logic [MOVE_WIDTH-1:0] current_move,

    output logic grid_ov,
    output logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] grid_od
);

    localparam EMPTY     = 8'b01_111111;
    localparam KING      = 6'b000001;
    localparam QUEEN     = 6'b000010;
    localparam ROOK      = 6'b000100;
    localparam KNIGHT    = 6'b001000;
    localparam BISHOP    = 6'b010000;
    localparam PAWN      = 6'b100000;
    localparam WHITE     = 2'b01;
    localparam BLACK     = 2'b10;

    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] init_grid_r;
    logic [MAX_MOVES-1:0][MOVE_WIDTH-1:0] moves_r;


    logic [6:0] grid_cnt;
    logic [8:0] move_cnt;
    logic grid_header_detected;
    logic move_header_detected;
    logic [7:0] total_move;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) grid_cnt <= 0;
        else if(grid_header_detected) grid_cnt <= grid_cnt + 1;
        else if((0<grid_cnt) && (grid_cnt<=64) && spi_iv) grid_cnt <= grid_cnt + 1;
        else if(move_header_detected) grid_cnt <= 0;
        else grid_cnt <= 0;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) move_cnt <= 0;
        else if(move_header_detected && (grid_cnt==65)) move_cnt <= move_cnt + 1;
        else if((move_cnt>0) && spi_iv) move_cnt <= move_cnt + 1;
        else move_cnt <= 0;
    end

    assign grid_header_detected = (spi_id==GRID_HEADER && spi_iv) ? 1'b1 : 1'b0;
    assign move_header_detected = (spi_id==MOVE_HEADER && spi_iv) ? 1'b1 : 1'b0;
    
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) init_grid_r <= 0;
        else if(grid_cnt>0) begin
            for(int i=0; i<HEIGHT; i=i+1) begin
                for(int j=0; j<WIDTH; j=j+1) begin
                    if(grid_cnt==i*WIDTH+(j+1)) init_grid_r[i][j] <= spi_id;
                    else init_grid_r[i][j] <= init_grid_r[i][j];
                end
            end
        end
        else if((grid_cnt==64) && move_header_detected) init_grid_r <= 0; //if number of grid component is not 64
        else init_grid_r <= init_grid_r;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            total_move <= 0;
            moves_r <= 0;
        end
        else if((move_cnt>0) && spi_iv) begin
            total_move <= (move_cnt[0]==1) ? total_move : (total_move+1);
            for(int i=0; i<MAX_MOVES; i=i+1) begin
                if(i==total_move) moves_r[i] <= (move_cnt[0]==1) ? {spi_id, moves_r[i][DATA_WIDTH-1:0]} : {moves_r[i][2*DATA_WIDTH-1:DATA_WIDTH], spi_id};
                else moves_r[i] <= moves_r[i];
            end
        end
        else begin
            total_move <= total_move;
            moves_r <= moves_r;
        end
    end

    assign total_move_od = total_move;
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) moves_ov <= 0;
        else if((move_cnt>0) && ~spi_iv) moves_ov <= 1;
        else moves_ov <= 0;
    end



    assign current_move = moves_r[move_num];

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) grid_ov <= 0;
        else if(compute_grid) grid_ov <= 1;
        else grid_ov <= 0;
    end

    always_comb begin
        for(int i=0; i<HEIGHT; i=i+1) begin
            for(int j=0; j<WIDTH; j=j+1) begin
                if((i==`src_x(current_move)) && (j==`src_y(current_move))) grid_od[i][j] = EMPTY;
                else if((i==`dst_x(current_move)) && (j==`dst_y(current_move))) grid_od[i][j] = init_grid_r[`src_x(current_move)][`src_y(current_move)];
                else grid_od[i][j] = init_grid_r[i][j];
            end
        end
    end

endmodule

`default_nettype wire