`default_nettype none

`define CONV 1'b0
`define MUL  1'b1

module accumulator#(
    parameter HEIGHT = 8,
    parameter WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = DATA_WIDTH*2 + $clog2(HEIGHT)
)(
    input wire clk,
    input wire nrst,

    input wire load_layer_info,
    input wire [3:0] mul_b_w,
    input wire [3:0] mul_b_h,
    input wire op_sel,

    // for CONV, only b_id[0][0] is valid
    // for MUL, only b_id[i][j] lies in b_w/b_h rectangle is valid
    input wire b_iv,
    input wire [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] b_id,

    input wire data_iv,
    input wire [WIDTH-1:0][PSUM_WIDTH-1:0] data_id,

    // conv bias
    output logic conv_ov,
    output logic signed [PSUM_WIDTH-1:0] conv_od,
    
    output logic mul_ov,
    output logic [HEIGHT-1:0][WIDTH-1:0][PSUM_WIDTH-1:0] mul_od
);

    logic [HEIGHT-1:0][WIDTH-1:0][PSUM_WIDTH-1:0] data_r;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] b_mul_r;
    logic [DATA_WIDTH-1:0] b_conv_r;

    logic [3:0] b_w_r, b_h_r;
    logic op_r;

// load layer info
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) {b_w_r, b_h_r, op_r} <= 0;
        else if(load_layer_info && (op_sel==`MUL)) begin
            b_w_r <= mul_b_w + 1;
            b_h_r <= mul_b_h + 1;
            op_r <= `MUL;
        end
        else if(load_layer_info) {b_w_r, b_h_r, op_r} <= {4'd0, 4'd0, `CONV};
        else {b_w_r, b_h_r, op_r} <= {b_w_r, b_h_r, op_r};
    end

// CONV
// load conv bias
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) b_conv_r <= 0;
        else if((op_r==`CONV) && b_iv) b_conv_r <= b_id[0][0];
        else if(load_layer_info) b_conv_r <= 0;
        else b_conv_r <= b_conv_r;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            conv_od <= 0;
            conv_ov <= 0;
        end
        else if(data_iv && (op_r==`CONV)) begin
            conv_ov <= 1;
            conv_od <= $signed(data_id[0]) + $signed(data_id[1]) + $signed(data_id[2]) + $signed(b_conv_r);
        end
        else begin
            conv_od <= 0;
            conv_ov <= 0;
        end
    end
   

// MUL
// load mul bias
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) b_mul_r <= 0;
        else if((op_r==`MUL) && b_iv) b_mul_r <= b_id;
        else if(load_layer_info) b_mul_r <= 0;
        else b_mul_r <= b_mul_r;
    end

    logic [4:0] mul_cnt;
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) mul_cnt <= 0;
        else if(data_iv && (op_r==`MUL)) mul_cnt <= mul_cnt + 1;
        else mul_cnt <= 0;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) data_r <= 0;
        else if(data_iv && (op_r==`MUL)) begin
            for(int i=0; i<HEIGHT; i=i+1) begin
                for(int j=0; j<WIDTH; j=j+1) begin
                    // problematic
                    if((i<mul_b_h) && (j<mul_b_w) && mul_cnt==(i+j)) 
                        data_r[i][j] <= $signed(data_id[j]) + b_mul_r[i][j];
                    else data_r[i][j] <= data_r[i][j];
                end
            end
        end
        else if(load_layer_info) data_r <= 0;
        else data_r <= data_r;
    end

    logic d_data_iv;
    always_ff @(posedge clk) begin
        d_data_iv <= data_iv;
    end

    assign mul_od = data_r;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) mul_ov <= 0;
        else if({d_data_iv,data_iv} == 2'b10 && (op_r==`MUL)) mul_ov <= 1;
        else mul_ov <= 0;
    end

endmodule

`default_nettype wire