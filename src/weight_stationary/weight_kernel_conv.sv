`default_nettype none
`timescale 1ns/1ps

// A:m*l, B:l*n, AB:m*n
module weight_kernel_conv #(
    parameter KERNEL_WIDTH = 3,
    parameter KERNEL_HEIGHT = 3,
    parameter WEIGHT_WIDTH = 8
)(
    output logic signed [KERNEL_HEIGHT-1:0][KERNEL_WIDTH-1:0][WEIGHT_WIDTH-1:0] weight_o
);

    /*
    00 01 02
    10 11 12
    20 21 22
    */
    assign weight_o = {8'sb00100000, 8'sb00100000, 8'sb00100000,
                       8'sb00100000, 8'sb00100000, 8'sb00100000,
                       8'sb00100000, 8'sb00100000, 8'sb00100000 }; // 22, 21, 20, 12, 11, 10, 02, 01, 00

endmodule 

`default_nettype wire