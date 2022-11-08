`default_nettype none
`timescale 1ns/1ps

module PE_weight_stationary #(
    parameter IFMAP_WIDTH = 8,
    parameter WEIGHT_WIDTH = 8,
    parameter ACCUMULATION_WIDTH = 3, // since 8x8*8x8, log2(8)=3 to avoid overflow
    parameter PSUM_WIDTH = IFMAP_WIDTH + WEIGHT_WIDTH + ACCUMULATION_WIDTH
)(
    input wire clk,
    input wire nrst,

    input wire signed [IFMAP_WIDTH-1:0]  ifmap_i,
    input wire signed [PSUM_WIDTH-1:0]   psum_i,
    input wire signed [WEIGHT_WIDTH-1:0] weight_i,
    input wire pe_en,

    output logic signed [IFMAP_WIDTH-1:0]  ifmap_o,
    output logic signed [PSUM_WIDTH-1:0]   psum_o
);

    logic signed [IFMAP_WIDTH-1:0]  ifmap_r;
    logic signed [PSUM_WIDTH-1:0]   psum_r;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) psum_r <= 0;
        else if(pe_en) psum_r <= psum_i + ifmap_i * weight_i;
        else psum_r <= 0;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) ifmap_r <= 0;
        else if(pe_en) ifmap_r <= ifmap_i;
        else ifmap_r <= 0;
    end

    // output assignment
    assign ifmap_o = ifmap_r;
    assign psum_o = psum_r;

endmodule

`default_nettype wire