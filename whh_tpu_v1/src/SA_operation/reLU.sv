`default_nettype none

module reLU#(
    parameter HEIGHT = 8,
    parameter WIDTH = 8,
    parameter DATA_WIDTH = 8,

    parameter WEIGHT_FIXED_POINT = 7,
    parameter PSUM_WIDTH = DATA_WIDTH*2 + $clog2(HEIGHT)
)(
    input wire clk,
    input wire nrst,

    input wire load_layer_info,
    input wire reLU_sel,
    input wire op_sel,
    input wire [3:0] mul_b_w,
    input wire [3:0] mul_b_h,

    input wire conv_b_iv,
    input wire [PSUM_WIDTH-1:0] conv_b_id,
    input wire mul_b_iv,
    input wire [HEIGHT-1:0][WIDTH-1:0][PSUM_WIDTH-1:0] mul_b_id,

    output logic conv_ov,
    output logic [DATA_WIDTH-1:0] conv_od,
    output logic mul_ov,
    output logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] mul_od
);

    logic reLU_r, op_r;
    logic [3:0] b_w_r, b_h_r;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) {reLU_r, op_r, b_w_r, b_h_r} <= 0;
        else if(load_layer_info) {reLU_r, op_r, b_w_r, b_h_r} <= {reLU_sel, op_sel, mul_b_w, mul_b_h};
        else {reLU_r, op_r, b_w_r, b_h_r} <= {reLU_r, op_r, b_w_r, b_h_r};
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            conv_ov <= 0;
            conv_od <= 0;
        end
        else if((op_sel==`CONV) && (conv_b_iv) && reLU_r) begin
            conv_ov <= 1;
            conv_od <= ($signed(conv_b_id) > 1'sd0) ? conv_b_id[PSUM_WIDTH-1:WEIGHT_FIXED_POINT] : 0;
        end
        else if((op_sel==`CONV) && (conv_b_iv) && (~reLU_r)) begin
            conv_ov <= 1;
            conv_od <= conv_b_id[PSUM_WIDTH-1:WEIGHT_FIXED_POINT];
        end
        else begin
            conv_ov <= 0;
            conv_od <= 0;
        end
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            mul_ov <= 0;
            mul_od <= 0;
        end
        else if((op_sel==`MUL) && (mul_b_iv) && reLU_r) begin
            mul_ov <= 1;
            for(int i=0; i<HEIGHT; i=i+1) begin
                for(int j=0; j<WIDTH; j=j+1) begin
                    mul_od[i][j] <= ($signed(mul_b_id[i][j]) > 1'sd0) ? mul_b_id[i][j][PSUM_WIDTH-1:WEIGHT_FIXED_POINT] : 0;
                end
            end
        end
        else if((op_sel==`MUL) && (mul_b_iv) && (~reLU_r)) begin
            mul_ov <= 1;
            for(int i=0; i<HEIGHT; i=i+1) begin
                for(int j=0; j<WIDTH; j=j+1) begin
                    mul_od[i][j] <= mul_b_id[i][j][PSUM_WIDTH-1:WEIGHT_FIXED_POINT];
                end
            end
        end
        else begin
            mul_ov <= 0;
            mul_od <= 0;
        end
    end


endmodule

`default_nettype wire