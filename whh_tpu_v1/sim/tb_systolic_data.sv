`default_nettype none

`define CONV 1'b0
`define MUL  1'b1

module tb_systolic_data;

    parameter DATA_WIDTH = 8;
    parameter HEIGHT = 8;
    parameter WIDTH = 8;

    parameter HEIGHT_W = $clog2(HEIGHT);


    logic clk;
    logic nrst;

    logic layer_info_valid;
    
    logic [HEIGHT_W:0] ifmap_height;
    logic [HEIGHT_W:0] ifmap_width; // vector length
    logic [HEIGHT_W:0] weight_height;
    logic op; // MUL or CONV
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] ifmap_i; // connect to 64 regs in unified buffer

    logic send_sd_en;// send_systolic_data
    
    logic sd_ov;
    logic [WIDTH-1:0][HEIGHT-1:0] sd_od;

    logic [1:0] test_case;
    always_comb begin
        case(test_case)
            2'd0: begin
                ifmap_height = 8;
                ifmap_width = 8;
                weight_height = 8;
                op = `MUL;
            end
            2'd1:begin
                ifmap_height = 6;
                ifmap_width = 6;
                weight_height = 3;
                op = `CONV;
            end
            2'd2:begin
                ifmap_height = 3;
                ifmap_width = 8;
                weight_height = 3;
                op = `MUL;
            end
            2'd3:begin
                ifmap_height = 4;
                ifmap_width = 4;
                weight_height = 1;
                op = `CONV; 
            end
        endcase
    end

    always_comb begin
        for(int i=0; i<HEIGHT; i=i+1) begin
            for(int j=0; j<WIDTH; j=j+1) begin
                if(i<ifmap_height && j<ifmap_width) ifmap_i[i][j] <= i+1+j;
                else ifmap_i[i][j] <= 0;
            end
        end
    end

    systolic_data_buffer u_systolic_data_buffer(
        .clk              ( clk              ),
        .nrst             ( nrst             ),
        .layer_info_valid ( layer_info_valid ),
        .ifmap_height_i   ( ifmap_height     ),
        .ifmap_width_i    ( ifmap_width      ),
        .weight_height_i  ( weight_height    ),
        .op_i             ( op               ),
        .ifmap_i          ( ifmap_i          ),
        .send_sd_en       ( send_sd_en       ),
        .sd_ov            ( sd_ov            ),
        .sd_od            ( sd_od            )
    );




    initial begin
        clk = 1'd1;
        forever 
            #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/sd.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_systolic_data); //store everything at the current level and below
        $display("Testing assorted values");

        // initialize
        clk = 1; nrst = 0; layer_info_valid = 0; send_sd_en = 0; test_case = 0;

        #1;
        #10 nrst = 1;
        #10 send_sd_en = 1; // since layer info not valid, should send nothing
        #10 send_sd_en = 0;
        #50 layer_info_valid = 1;
        #10 send_sd_en = 1;
        #10 send_sd_en = 0;
        #200;

        #10 test_case = 1;
        #10 send_sd_en = 1;
        #10 send_sd_en = 0;
        #400;

        #10 test_case = 2;
        #10 send_sd_en = 1;
        #10 send_sd_en = 0;
        #200;
        
        #10 test_case = 3;
        #10 send_sd_en = 1;
        #10 send_sd_en = 0;
        #400;

        #200;

        $display("Finishing Sim"); //print nice message
        $finish;
    end

endmodule

`default_nettype wire