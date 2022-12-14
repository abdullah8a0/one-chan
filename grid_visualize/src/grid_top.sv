`timescale 1ns / 1ps
`default_nettype none

module grid_top(
    input wire clk_100mhz, //clock @ 100 mhz
    input wire btnc, //btnc (used for reset)

    // input wire [7:0][7:0][7:0] grid_i,

    output logic [3:0] vga_r, vga_g, vga_b,
    output logic vga_hs, vga_vs
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

    localparam GRID = 60;

    logic [7:0][7:0][7:0] grid_i;
    always_comb begin
        for(int i=0; i<8; i=i+1) begin
            for(int j=0; j<8; j=j+1) begin
                grid_i[i][j] = INIT_BOARD[j+8*i];
            end
        end
    end
    logic [63:0][7:0] INIT_BOARD;
        assign INIT_BOARD[0] = {WHITE, ROOK};
        assign INIT_BOARD[1] = {WHITE, KNIGHT};
        assign INIT_BOARD[2] = {WHITE, BISHOP};
        assign INIT_BOARD[3] = {WHITE, QUEEN};
        assign INIT_BOARD[4] = {WHITE, KING};
        assign INIT_BOARD[5] = {WHITE, BISHOP};
        assign INIT_BOARD[6] = {WHITE, KNIGHT};
        assign INIT_BOARD[7] = {WHITE, ROOK};
        assign INIT_BOARD[8] = {WHITE, PAWN};
        assign INIT_BOARD[9] = {WHITE, PAWN};
        assign INIT_BOARD[10] = {WHITE, PAWN};
        assign INIT_BOARD[11] = {WHITE, PAWN};
        assign INIT_BOARD[12] = {WHITE, PAWN};
        assign INIT_BOARD[13] = {WHITE, PAWN};
        assign INIT_BOARD[14] = {WHITE, PAWN};
        assign INIT_BOARD[15] = {WHITE, PAWN};
        assign INIT_BOARD[16] = EMPTY;
        assign INIT_BOARD[17] = EMPTY;
        assign INIT_BOARD[18] = EMPTY;
        assign INIT_BOARD[19] = EMPTY;
        assign INIT_BOARD[20] = EMPTY;
        assign INIT_BOARD[21] = EMPTY;
        assign INIT_BOARD[22] = EMPTY;
        assign INIT_BOARD[23] = EMPTY;
        assign INIT_BOARD[24] = EMPTY;
        assign INIT_BOARD[25] = EMPTY;
        assign INIT_BOARD[26] = EMPTY;
        assign INIT_BOARD[27] = EMPTY;
        assign INIT_BOARD[28] = EMPTY;
        assign INIT_BOARD[29] = EMPTY;
        assign INIT_BOARD[30] = EMPTY;
        assign INIT_BOARD[31] = EMPTY;
        assign INIT_BOARD[32] = EMPTY;
        assign INIT_BOARD[33] = EMPTY;
        assign INIT_BOARD[34] = EMPTY;
        assign INIT_BOARD[35] = EMPTY;
        assign INIT_BOARD[36] = EMPTY;
        assign INIT_BOARD[37] = EMPTY;
        assign INIT_BOARD[38] = EMPTY;
        assign INIT_BOARD[39] = EMPTY;
        assign INIT_BOARD[40] = EMPTY;
        assign INIT_BOARD[41] = EMPTY;
        assign INIT_BOARD[42] = EMPTY;
        assign INIT_BOARD[43] = EMPTY;
        assign INIT_BOARD[44] = EMPTY;
        assign INIT_BOARD[45] = EMPTY;
        assign INIT_BOARD[46] = EMPTY;
        assign INIT_BOARD[47] = EMPTY;
        assign INIT_BOARD[48] = {BLACK, PAWN};
        assign INIT_BOARD[49] = {BLACK, PAWN};
        assign INIT_BOARD[50] = {BLACK, PAWN};
        assign INIT_BOARD[51] = {BLACK, PAWN};
        assign INIT_BOARD[52] = {BLACK, PAWN};
        assign INIT_BOARD[53] = {BLACK, PAWN};
        assign INIT_BOARD[54] = {BLACK, PAWN};
        assign INIT_BOARD[55] = {BLACK, PAWN};
        assign INIT_BOARD[56] = {BLACK, ROOK};
        assign INIT_BOARD[57] = {BLACK, KNIGHT};
        assign INIT_BOARD[58] = {BLACK, BISHOP};
        assign INIT_BOARD[59] = {BLACK, QUEEN};
        assign INIT_BOARD[60] = {BLACK, KING};
        assign INIT_BOARD[61] = {BLACK, BISHOP};
        assign INIT_BOARD[62] = {BLACK, KNIGHT};
        assign INIT_BOARD[63] = {BLACK, ROOK};

    logic clk_65mhz; //65 MHz clock line
    clk_wiz_lab3 clk_gen(
        .clk_in1(clk_100mhz),
        .clk_out1(clk_65mhz)); //after frame buffer everything on clk_65mhz


    //vga module generation signals:
    logic [10:0] hcount_out;    // pixel on current line
    logic [9:0] vcount_out;     // line number
    logic hsync_out, vsync_out, blank_out; //control signals for vga
    vga u_vga(
        .pixel_clk_in      ( clk_65mhz      ),
        .hcount_out        ( hcount_out ),
        .vcount_out        ( vcount_out ),
        .vsync_out         ( vsync_out   ),
        .hsync_out         ( hsync_out   ),
        .blank_out         ( blank_out   )
    );

    logic [2:0] col_cnt, row_cnt;
    always_ff @(posedge clk_65mhz or negedge nrst) begin
        if(~nrst) row_cnt <= 0;
        else if(hcount_out<480 && (hcount_out+1)%60==10) row_cnt <= row_cnt + 1;
        else row_cnt <= row_cnt;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) col_cnt <= 0;
        else if(hcount_out==640-1 && (vcount_out+1)%60==10) col_cnt <= col_cnt + 1;
        else col_cnt <= col_cnt;
    end

    logic [11:0] pixel_out_grid, pixel_out_bus;
    logic [11:0] pixel_out_piece; 
    grid_pixel u_grid_pixel(
        .hcount_in    ( hcount_out    ),
        .vcount_in    ( vcount_out    ),
        .pixel_out    ( pixel_out_grid  )
    );


    image_sprite#(
        .WIDTH     ( 40 ),
        .HEIGHT    ( 40 )
    )u_image_sprite(
        .pixel_clk_in ( clk_65mhz ),
        .piece_sel_i  ( grid_i[col_cnt][row_cnt]  ),
        .x_in         ( row_cnt*GRID+10-1    ),
        .hcount_in    ( hcount_out   ),
        .y_in         ( col_cnt*GRID+10-1   ),
        .vcount_in    ( vcount_out    ),
        .pixel_out    ( pixel_out_piece  )
    );


    always_comb begin
        for(int i=0; i<8; i=i+1) begin
            for(int j=0; j<8; j=j+1) begin
                if((10+GRID*i< hcount_out) && (hcount_out < GRID*(i+1)-10) && (10+GRID*j< vcount_out) && (vcount_out < GRID*(j+1)-10)) begin
                    pixel_out_bus = pixel_out_piece[i][j];
                end 
                else pixel_out_bus = pixel_out_grid;
            end
        end
    end

    always_ff @(posedge clk_65mhz)begin
        vga_r <= pixel_out_bus[11:8]; //TODO: needs to use pipelined signal (PS6)
        vga_g <= pixel_out_bus[7:4];  //TODO: needs to use pipelined signal (PS6)
        vga_b <= pixel_out_bus[3:0];  //TODO: needs to use pipelined signal (PS6)
    end

    assign vga_hs = ~hsync_out;  //TODO: needs to use pipelined signal (PS7)
    assign vga_vs = ~vsync_out;  //TODO: needs to use pipelined signal (PS7)

endmodule




`default_nettype wire
