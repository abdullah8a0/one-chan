`default_nettype none
`timescale 1ns/1ps

module PE #(
    parameter IFMAP_WIDTH = 8,
    parameter WEIGHT_WIDTH = 8,
    parameter BIAS_WIDTH = 8,
    parameter ACCUMULATION_WIDTH = 3, // since 8x8*8x8, log2(8)=3 to avoid overflow
    parameter PSUM_WIDTH = IFMAP_WIDTH + WEIGHT_WIDTH + ACCUMULATION_WIDTH
)(
    input wire clk,
    input wire nrst,
    input wire en,

    input wire signed [IFMAP_WIDTH-1:0]  ifmap_i,
    input wire signed [WEIGHT_WIDTH-1:0] weight_i,
    input wire signed [BIAS_WIDTH-1:0]   bias_i,

    input wire mac_en,
    input wire bias_en,
    input wire reLU_en,

    output logic signed [IFMAP_WIDTH-1:0]  ifmap_o,
    output logic signed [WEIGHT_WIDTH-1:0] weight_o,
    output logic signed [PSUM_WIDTH-1:0]   psum_o
);

    logic signed [IFMAP_WIDTH-1:0]  ifmap_r;
    logic signed [WEIGHT_WIDTH-1:0] weight_r;
    logic signed [PSUM_WIDTH-1:0]   psum_r;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) psum_r <= 0;
        else if(~en) psum_r <= 0;
        else if(mac_en) psum_r <= psum_r + ifmap_i*weight_i;
        else if(bias_en) psum_r <= psum_r + (bias_i <<< 7);
        else if(reLU_en) psum_r <= (psum_r >= {(PSUM_WIDTH){1'sd0}}) ? psum_r : 0;
        else psum_r <= psum_r;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) ifmap_r <= 0;
        else if(~en) ifmap_r <= 0;
        else if(mac_en) ifmap_r <= ifmap_i;
        else ifmap_r <= 0;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) weight_r <= 0;
        else if(~en) weight_r <= 0;
        else if(mac_en) weight_r <= weight_i;
        else weight_r <= 0;
    end

    // output assignment
    assign ifmap_o = ifmap_r;
    assign weight_o = weight_r;
    assign psum_o = psum_r;

endmodule

`default_nettype wire