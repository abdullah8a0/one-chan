`timescale 1ns / 1ps
`default_nettype none



module seven_seg_tb;
    logic clk_in;
    logic rst_in;

    board_pos_t  row_in [7:0];

    logic [6:0]  cat;
    logic        dot;
    logic [7:0]  an;


    seven_seg #(.COUNT_TO('d1)) uut (
        .clk(clk_in),
        .rst(rst_in),
        .row(row_in),

        .cat_out(cat),
        .dot_out(dot),
        .an_out(an)
    );

    always begin
        #5;
        clk_in = ~clk_in;
    end

    localparam EMPTY     = 6'b111111;
    localparam KING      = 6'b000001;
    localparam QUEEN     = 6'b000010;
    localparam ROOK      = 6'b000100;
    localparam KNIGHT    = 6'b001000;
    localparam BISHOP    = 6'b010000;
    localparam PAWN      = 6'b100000;

    localparam WHITE     = 2'b01;
    localparam BLACK     = 2'b10;
 
    initial begin
        $dumpfile("seven_seg.vcd");
        $dumpvars(0, seven_seg_tb);
        clk_in = 1'b0;
        rst_in = 1'b1;
        #10;
        rst_in = 1'b0;

        for (int i = 0; i < 7; i++) begin
            row_in[i] = {WHITE, EMPTY};
        end

        row_in[7] = {WHITE, KING};

        #1000
        $finish;
    end

    endmodule
`default_nettype wire