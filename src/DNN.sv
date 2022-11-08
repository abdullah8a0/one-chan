`default_nettype none

module DNN #(
    parameter DATA_WIDTH = 8,
    parameter ROW_NUM = 8,  //m
    parameter COL_NUM = 8,  //n
    parameter INTER_NUM = 8, //l
)(
    input wire clk,
    input wire nrst,
    input wire en,

    //input grid
    input wire input_grid_iv,
    input wire [DATA_WIDTH-1:0] row_input_id [COL_NUM-1:0],

    //output grid
    output logic output_ov,
    output logic [DATA_WIDTH-1:0] output_od
);

    //fsm
    localparam IDLE = 3'd0;
    localparam INPUT_GRID = 3'd1;
    localparam CONV_1 = 3'd2; // 3*3 kernel
    localparam CONV_2 = 3'd3; // 3*3 kernel
    localparam CONV_3 = 3'd4; // 1*3 kernel
    localparam CLASSIFY_1 = 3'd5; // 8*8 weight matrix, 1*8 bias
    localparam CLASSIFY_2 = 3'd6; // 8*8 weight matrix, 1*8 bias
    localparam OUTPUT = 3'd7;

endmodule

`default_nettype wire