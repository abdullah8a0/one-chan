`timescale 1ns / 1ps
`default_nettype none



module top_level_tb;
    logic clk_in;
    logic rst_in;

    logic [15:0] sw;
    logic btnd;
    logic btnu;
    logic btnr;
    logic btnl;


    top_level uut(
    .clk_in(clk_in),
    .sw(sw),
    .btnc(rst_in),
    .btnd(btnd),
    .btnu(btnu),
    .btnr(btnr),
    .btnl(btnl)
    );

    always begin
        #5;
        clk_in = ~clk_in;
    end


 
    initial begin
        $dumpfile("top_level.vcd"); // TODO: Change this to a file name of your choice
        $dumpvars(0, top_level_tb); // TODO: set to filename_tb
        clk_in = 1'b0;
        #10;
        rst_in = 1'b1;
        #10;
        rst_in = 1'b0;
        #10;
        rst_in = 1'b1;
        #10;
        rst_in = 1'b0;
        #10;
        rst_in = 1'b1;
        #10;
        rst_in = 1'b0;
        #1000;

        btnr = 1'b1;
        #100;
        btnr = 1'b0;
        #10000;

        #10000
        $finish;
    end

    endmodule
`default_nettype wire