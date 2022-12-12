`default_nettype none
`timescale 1ns/1ps

`define CONV 1'b0
`define MUL  1'b1

module tb_SA_v2;

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
    logic reLU_sel;
    logic [3:0] ifmap_i_w; // represent n in m*n and n*l matrix mul
    
    // weight load PE enable
    logic weight_iv;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_id;
    logic bias_iv;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] bias_id;
    logic [3:0] mul_b_w, mul_b_h;

    always_comb begin
        case(op_sel)
            `CONV: begin
                for(int i=0; i<HEIGHT; i=i+1) begin
                    for(int j=0; j<WIDTH; j=j+1) begin
                        if(i<3 && j<3) weight_id[i][j] = $signed(i-j);
                        else weight_id[i][j] =0;

                        if(i==0 && j==0) bias_id[i][j] = 10;
                        else bias_id[i][j] = $signed(i-j);
                    end
                end
                 mul_b_w = 1; 
                 mul_b_h = 1;
            end
            `MUL:  begin
                for(int i=0; i<HEIGHT; i=i+1) begin
                    for(int j=0; j<WIDTH; j=j+1) begin
                        if(i==0) bias_id[i][j] = $signed(j-3);
                        else bias_id[i][j] = 0;

                        weight_id[i][j] = $signed(i-j);
                    end
                end
                    mul_b_w = 8; 
                    mul_b_h = 2;
                end
        endcase   
    end

    // systolic data input
    logic data_iv;
    logic [WIDTH-1:0][DATA_WIDTH-1:0] data_id;
    logic data_ov_sa;
    logic [WIDTH-1:0][PSUM_WIDTH-1:0] data_od_sa;

    logic conv_ov_acc, conv_ov_re;
    logic [PSUM_WIDTH-1:0] conv_od_acc;
    logic [DATA_WIDTH-1:0] conv_od_re;
    logic mul_ov_acc, mul_ov_re;
    logic [HEIGHT-1:0][WIDTH-1:0][PSUM_WIDTH-1:0] mul_od_acc;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] mul_od_re;


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
        .data_iv         ( data_iv         ),
        .data_id         ( data_id         ),
        .data_ov         ( data_ov_sa   ),
        .data_od         ( data_od_sa  )
    );

    accumulator#(
        .HEIGHT          ( 8 ),
        .WIDTH           ( 8 ),
        .DATA_WIDTH      ( 8 )
    )u_accumulator(
        .clk             ( clk             ),
        .nrst            ( nrst            ),

        .load_layer_info ( load_layer_info ),
        .mul_b_w         ( mul_b_w         ),
        .mul_b_h         ( mul_b_h         ),
        .op_sel          ( op_sel          ),

        .b_iv            ( bias_iv ),
        .b_id            ( bias_id ),

        .data_iv         ( data_ov_sa         ),
        .data_id         ( data_od_sa         ),

        .conv_ov         ( conv_ov_acc   ),
        .conv_od         ( conv_od_acc ),
        .mul_ov          ( mul_ov_acc    ),
        .mul_od          ( mul_od_acc   )
    );

    reLU#(
        .HEIGHT             ( 8 ),
        .WIDTH              ( 8 ),
        .DATA_WIDTH         ( 8 )
    )u_reLU(
        .clk                ( clk                ),
        .nrst               ( nrst               ),
        .load_layer_info    ( load_layer_info    ),
        .reLU_sel           ( reLU_sel           ),
        .op_sel             ( op_sel             ),
        .mul_b_w            ( mul_b_w            ),
        .mul_b_h            ( mul_b_h            ),

        .conv_b_iv          ( conv_ov_acc          ),
        .conv_b_id          ( conv_od_acc          ),
        .mul_b_iv           ( mul_ov_acc           ),
        .mul_b_id           ( mul_od_acc           ),

        .conv_ov            ( conv_ov_re      ),
        .conv_od            ( conv_od_re     ),
        .mul_ov             ( mul_ov_re       ),
        .mul_od             ( mul_od_re      )
    );


    initial begin
        clk = 1'd1;
        forever 
            #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/sa_v2.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_SA_v2); //store everything at the current level and below
        $display("Testing assorted values");
        
        //initalize
        clk=1; nrst=0;
        load_layer_info=0; w_width=3; w_height=3; 
        op_sel=`CONV; ifmap_i_w <= 8; data_id =0; data_iv = 0;
        reLU_sel = 1;
        bias_iv = 0; weight_iv = 0;
        #1;
        #10 nrst =1;
        #20 load_layer_info = 1;
        #10 load_layer_info = 0;
        #10;
        #10 weight_iv = 1;
        #10 weight_iv = 0;
        #10;
        #10 bias_iv = 1;
        #10 bias_iv = 0;
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
        #10 bias_iv = 1;
        #10 bias_iv = 0;
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
        w_width=8; w_height=8; 
        op_sel=`MUL; ifmap_i_w <= 2; data_id =0; data_iv = 0;
        #20 load_layer_info = 1;
        #10 load_layer_info = 0;
        #10;
        #10 weight_iv = 1;
        #10 weight_iv = 0;
        #10;
        #10 bias_iv = 1;
        #10 bias_iv = 0;
        #10;
        #10 data_iv = 1;
            data_id = {{7{8'd0}}, 8'd1};
        #10 data_id = {{6{8'd0}}, 8'b1, 8'b10 };
        #10 data_id = {{5{8'd0}}, 8'b10, 8'b100, 8'd0 };
        #10 data_id = {{4{8'd0}}, 8'b100, 8'b1000, {2{8'd0}} };
        #10 data_id = {{3{8'd0}}, 8'b1000, 8'b1_0000, {3{8'd0}} };
        #10 data_id = {{2{8'd0}}, 8'b10000, 8'b10_0000, {4{8'd0}} };
        #10 data_id = {8'd0, 8'b10_0000, 8'b100_0000, {5{8'd0}} };
        #10 data_id = {8'b100_0000, 8'b1000_0000, {6{8'd0}} };
        #10 data_id = {8'b1000_0000, {7{8'd0}} };
        #10 data_iv = 0;

        #200;

        $display("Finishing Sim"); //print nice message
        $finish;
    end
endmodule
`default_nettype wire