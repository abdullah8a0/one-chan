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
    input wire input_iv,
    input wire [DATA_WIDTH-1:0] row_input_id [COL_NUM-1:0],

    //output grid
    output logic output_ov,
    output logic [DATA_WIDTH-1:0] output_od
);

endmodule

`default_nettype wire