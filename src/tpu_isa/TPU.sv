`default_nettype none

module TPU #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire nrst,

    //spi
    input wire clk_in, 
    input wire sel_in,
    input wire [DATA_WIDTH-1:0] data_in,

    // send optimal move by SPI
    output wire clk_out,
    output wire sel_out,
    output wire [DATA_WIDTH-1:0] data_out
);

    // FSM
    localparam IDLE = 0;
    localparam FETCH = 1;
    localparam EXECUTE = 2;


    // register file
    reg [15:0] zero; // always zero
    reg [7:0] layer_num; // counting the layer
    reg [7:0] weight_height, weight_width;
    reg [7:0] ifmap_height,  ifmap_width;
    reg [7:0] conv_sp;
    reg [7:0] conv_total_num;
    reg [7:0] move_sp;
    reg [7:0] move_total_num;
    reg [15:0] move; // the move that is evaluated

    reg [15:0] optimal_move;
    reg [7:0] optimal_move_output;

    // memory management
    

    assign zero = 0;

endmodule

`default_nettype wire