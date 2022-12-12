`default_nettype none
`timescale 1ns/1ps

`define CONV 1'b0
`define MUL  1'b1

module tb_SA;

    parameter WIDTH = 8;
    parameter HEIGHT = 8;
    parameter DATA_WIDTH = 8;

    parameter PSUM_WIDTH = DATA_WIDTH*2 + $clog2(HEIGHT);
    parameter WIDTH_W = $clog2(WIDTH);
    parameter HEIGHT_W = $clog2(HEIGHT);

    logic clk;
    logic nrst;
    
    // load layer info
    logic load_layer_info;
    logic [3:0] w_width;
    logic [3:0] w_height;
    logic op_sel;
    logic [3:0] ifmap_i_w; // represent n in m*n and n*l matrix mul
    
    // weight load PE enable
    logic weight_iv;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_id;

    always_comb begin
        case(op_sel)
            `CONV:for(int i=0; i<HEIGHT; i=i+1) begin
                    for(int j=0; j<WIDTH; j=j+1) begin
                        if(i<3 && j<3) weight_id[i][j] = $signed(i-j);
                        else weight_id[i][j] =0;
                    end
                end
            `MUL:  for(int i=0; i<HEIGHT; i=i+1) begin
                    for(int j=0; j<WIDTH; j=j+1) begin
                        weight_id[i][j] = $signed(i-j);
                    end
                end
        endcase   
    end

    // systolic data input
    logic data_iv;
    logic [WIDTH-1:0][DATA_WIDTH-1:0] data_id;

    logic data_ov;
    logic [WIDTH-1:0][PSUM_WIDTH-1:0] data_od;


    scalable_SA#(
        .WIDTH           ( 8 ),
        .HEIGHT          ( 8 ),
        .DATA_WIDTH      ( 8 )
    )u_scalable_SA(
        .clk             ( clk             ),
        .nrst            ( nrst            ),
        .load_layer_info ( load_layer_info ),
        .w_width         ( w_width         ),
        .w_height        ( w_height        ),
        .op_sel          ( op_sel          ),
        .ifmap_i_w       ( ifmap_i_w       ),
        .weight_iv       ( weight_iv       ),
        .weight_id       ( weight_id       ),
        .data_sign_en    ( 1'b0 ), 
        .data_iv         ( data_iv         ),
        .data_id         ( data_id         ),
        .data_ov         ( data_ov   ),
        .data_od         (  data_od  )
    );


    initial begin
        clk = 1'd1;
        forever 
            #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/sa.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_SA); //store everything at the current level and below
        $display("Testing assorted values");
        
        //initalize
        clk=1; nrst=0;
        load_layer_info=0; w_width=3; w_height=3; 
        op_sel=`CONV; ifmap_i_w <= 8; data_id =0; data_iv = 0;

        #1;
        #10 nrst =1;
        #20 load_layer_info = 1;
        #10 load_layer_info = 0;
        #10;
        #10 weight_iv = 1;
        #10 weight_iv = 0;
        #10;
        #10 data_iv = 1;
            data_id = {{5{8'd0}}, 8'd0, 8'd0, 8'd12};
        #10 data_id = {{5{8'd0}}, 8'd0, 8'd2, 8'd05};
        #10 data_id = {{5{8'd0}}, 8'd1, 8'd7, 8'd4};
        #10 data_id = {{5{8'd0}}, 8'd4, 8'd9, 8'd12};
        #10 data_id = {{5{8'd0}}, 8'd6, 8'd6, 8'd43};
        #10 data_id = {{5{8'd0}}, 8'd2, 8'd0, 8'd22};
        #10 data_id = {{5{8'd0}}, 8'd8, 8'd0, 8'd11};
        #10 data_id = {{5{8'd0}}, 8'd9, 8'd51, 8'd9};
        #10 data_id = {{5{8'd0}}, 8'd2, 8'd23, 8'd0};
        #10 data_id = {{5{8'd0}}, 8'd8, 8'd0, 8'd0};
        #10 data_iv = 0;

        #200; 
        w_width=8; w_height=8; 
        op_sel=`MUL; ifmap_i_w <= 1; data_id =0; data_iv = 0;

        #20 load_layer_info = 1;
        #10 load_layer_info = 0;
        #10;
        #10 weight_iv = 1;
        #10 weight_iv = 0;
        #10;
       
        #10 data_iv = 1;
            data_id = {{7{8'd0}}, 8'd1};
        #10 data_id = {{6{8'd0}}, 8'b10, {8'd0} };
        #10 data_id = {{5{8'd0}}, 8'b100, {2{8'd0}} };
        #10 data_id = {{4{8'd0}}, 8'b1000, {3{8'd0}} };
        #10 data_id = {{3{8'd0}}, 8'b1_0000, {4{8'd0}} };
        #10 data_id = {{2{8'd0}}, 8'b10_0000, {5{8'd0}} };
        #10 data_id = {8'd0, 8'b100_0000, {6{8'd0}} };
        #10 data_id = {8'b1000_0000, {7{8'd0}} };
        #10 data_iv = 0;

        #200;

        $display("Finishing Sim"); //print nice message
        $finish;
    end
endmodule
`default_nettype wire