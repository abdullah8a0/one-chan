`default_nettype none
`timescale 1ns/1ps

module tb_ws_layer;

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

    logic biased_ov;
    logic [DATA_WIDTH-1:0] biased_od;

    logic reLU_ov;
    logic [DATA_WIDTH-1:0] reLU_od;

    assign {psum_o2, psum_o1, psum_o0} = psum_o;

    SA_WS_conv#(
        .SA_ROW        ( SA_ROW ),
        .SA_COL        ( SA_COL),
        .DATA_WIDTH    ( DATA_WIDTH ),
        .PSUM_WIDTH    ( PSUM_WIDTH ),
        .VECTOR_LENGTH ( VECTOR_LENGTH )
    )u_SA_WS_conv(
        .clk     ( clk     ),
        .nrst    ( nrst    ),
        .sa_iv   ( sa_iv   ),
        .row_A_i ( row_A_i ),
        .sa_ov   ( sa_ov   ),
        .psum_o  ( psum_o  )
    );

    bias_adder#(
        .BIAS            ( 8'd10 ),
        .PSUM_WIDTH      ( PSUM_WIDTH ),
        .DATA_WIDTH      ( DATA_WIDTH ),
        .SA_COL          ( SA_COL )
    )u_bias_adder(
        .clk             ( clk             ),
        .nrst            ( nrst            ),
        .bias_adder_iv   ( sa_ov   ),
        .psum_i          ( psum_o          ),
        .biased_ov ( biased_ov ),
        .biased_od  ( biased_od  )
    );

    reLU#(
        .DATA_WIDTH    ( DATA_WIDTH )
    )u_reLU(
        .clk           ( clk           ),
        .nrst          ( nrst          ),
        .reLU_iv       ( biased_ov       ),
        .neuron_i      ( biased_od      ),
        .reLU_ov    ( reLU_ov ),
        .reLU_od    ( reLU_od  )
    );


    always begin
        #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/layer_weight_stationary.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_ws_layer); //store everything at the current level and below
        $display("Testing assorted values");
        
        //initalize
        clk = 1;
        nrst = 1'b0;
        sa_iv = 1'b0;
        for(int i=0; i<SA_ROW; i=i+1) begin
            row_A_i[i] = 0;
        end
        #1; nrst = 1'b1;
        #20;

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