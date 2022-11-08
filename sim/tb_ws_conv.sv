`default_nettype none
`timescale 1ns/1ps

module tb_ws_conv;

    parameter SA_ROW = 3;
    parameter SA_COL = 3;
    parameter DATA_WIDTH = 8;
    parameter PSUM_WIDTH = 19;
    parameter VECTOR_LENGTH = 8;
    parameter LATENCY = VECTOR_LENGTH + SA_ROW + SA_COL - 1;

    logic clk;
    logic nrst;

    logic sa_iv; // activate SA array
    logic [SA_ROW-1:0][DATA_WIDTH-1:0] row_A_i; // layer input

    logic sa_ov; //when output is ready
    logic [SA_COL-1:0][PSUM_WIDTH-1:0] psum_o;
    logic [PSUM_WIDTH-1:0] psum_o0, psum_o1, psum_o2;

    assign {psum_o2, psum_o1, psum_o0} = psum_o;

    SA_WS_conv#(
        .SA_ROW        ( 3 ),
        .SA_COL        ( 3 ),
        .DATA_WIDTH    ( 8 ),
        .PSUM_WIDTH    ( 19 ),
        .VECTOR_LENGTH ( 8 )
    )u_SA_WS_conv(
        .clk     ( clk     ),
        .nrst    ( nrst    ),
        .sa_iv   ( sa_iv   ),
        .row_A_i ( row_A_i ),
        .sa_ov   ( sa_ov   ),
        .psum_o  ( psum_o  )
    );


    initial begin
        clk = 1'd1;
        forever 
            #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/sa_weight_stationary.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_ws_conv); //store everything at the current level and below
        $display("Testing assorted values");
        
        //initalize
        nrst = 1'b0;
        sa_iv = 1'b0;
        for(int i=0; i<SA_ROW; i=i+1) begin
            row_A_i[i] = 0;
        end
        #1; nrst = 1'b1;
        #20

        // ready to send data
        #10 sa_iv = 1'b1;
            row_A_i = {8'sd0, 8'sd0, 8'sd3}; // 2nd-byte, 1st-byte, 0th-byte
        #10 row_A_i = {8'sd0, 8'sd2, 8'sd3};
        #10 row_A_i = {8'sd1, 8'sd2, 8'sd3};
        #10 row_A_i = {8'sd1, 8'sd2, 8'sd3};
        #10 row_A_i = {8'sd1, 8'sd2, 8'sd3};
        #10 row_A_i = {8'sd1, 8'sd2, 8'sd3};
        #10 row_A_i = {8'sd1, 8'sd2, 8'sd3};
        #10 row_A_i = {8'sd1, 8'sd2, 8'sd3};
        #10 row_A_i = {8'sd1, 8'sd2, 8'sd0};
        #10 row_A_i = {8'sd1, 8'sd0, 8'sd0};
        #10 sa_iv = 1'b0;
            row_A_i = {8'sd0, 8'sd0, 8'sd0};
        
        #100;
        
        $display("Finishing Sim"); //print nice message
        $finish;
    end
endmodule
`default_nettype wire