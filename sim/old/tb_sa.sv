`default_nettype none
`timescale 1ns/1ps

module tb_sa;

    localparam DATA_WIDTH = 8;
    localparam ROW_NUM = 8;  //m
    localparam COL_NUM = 8;  //n
    localparam INTER_NUM = 8; //l
    localparam PARIAL_SUM_WIDTH = 19;

    logic clk;
    logic nrst;

    logic sa_iv; // activate SA array
    logic sa_mac_iv;
    logic sa_bias_iv;

    logic [DATA_WIDTH-1:0] row_A_i [COL_NUM-1:0]; // layer input
    logic [DATA_WIDTH-1:0] col_W_i [ROW_NUM-1:0]; // weight matrix B
    logic [DATA_WIDTH-1:0] bias_col_i [COL_NUM-1:0];

    logic sa_ov; //when output is ready
    logic [DATA_WIDTH-1:0] psum_o [COL_NUM-1:0];

    Systolic_array u_Systolic_array(
        .clk         ( clk         ),
        .nrst        ( nrst        ),
        .sa_iv       ( sa_iv       ),
        .sa_mac_iv   ( sa_mac_iv   ),
        .sa_bias_iv  ( sa_bias_iv  ),
        .row_A_i     ( row_A_i     ),
        .col_W_i     ( col_W_i     ),
        .bias_col_i  ( bias_col_i  ),
        
        .sa_ov       ( sa_ov       ),
        .psum_o      ( psum_o      )
    );

    initial begin
        clk = 1'd1;
        forever 
            #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/sa_output_stationary.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_sa); //store everything at the current level and below
        $display("Testing assorted values");
        
        // initialize
        nrst = 1'b0;
        sa_iv = 1'b0;
        sa_mac_iv = 1'b0;
        sa_bias_iv = 1'b0;

        for(int i=0; i<8; i=i+1) begin
            row_A_i[i] = 8'd0;
            col_W_i[i] = 8'd0;
            bias_col_i[i] = 8'd0;
        end

        // enable Sa
        #1; // change after 1ns of the rising clock edge 
        #100 nrst = 1'b1;
        #10  sa_iv = 1'b1;

        // enable mac
        #10 sa_mac_iv = 1'b1;
        for(int i=0; i<15; i=i+1) begin
            for(int j=0; j<8; j=j+1) begin
                row_A_i[j] = ((i>=j) && (i<j+8)) ? (j+1) : 0;
                col_W_i[j] = ((i>=j) && (i<j+8)) ? 8'b0010_0000 : 0;
            end
            #10;
        end
        sa_mac_iv = 1'b0;

        // enable bias
        #10 sa_bias_iv = 1'b1;
        for(int i=0; i<8; i=i+1) begin
            for(int j=0; j<8; j=j+1) begin
                bias_col_i[j] = 4-j;
            end
            #10;
        end
        sa_bias_iv = 1'b0;

        // finish
        #20 sa_iv = 1'b0;
        #10000;

        $display("Finishing Sim"); //print nice message
        $finish;
    end
endmodule
`default_nettype wire