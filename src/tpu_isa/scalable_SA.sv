`default_nettype none

`define CONV 1'b0
`define MUL  1'b1

// weight stationary
// SA-ST structure
// sum apart from column to column
// sum together from row to row

// signed number operation, so $signed() must be used!
module scalable_SA#(
    parameter WIDTH = 8,
    parameter HEIGHT = 8,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = DATA_WIDTH*2 + $clog2(HEIGHT)
)(
    input wire clk,
    input wire nrst,
    
    // weight load PE enable
    input wire load_weight,
    input wire weight_width,
    input wire weight_height,
    
    input wire weight_iv,
    input wire [WIDTH-1:0][DATA_WIDTH-1:0] weight_id,

    // select convolution or matrix multiplication, different data_ov
    input wire op_sel,

    // systolic data input
    input wire data_iv,
    input wire [WIDTH-1:0][DATA_WIDTH-1:0] data_id,

    output logic data_ov,
    output logic [WIDTH-1:0][PSUM_WIDTH-1:0] data_od
);

    

endmodule

`default_nettype wire