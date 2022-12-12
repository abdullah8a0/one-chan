`default_nettype none

module TPU(
    input wire clk,
    input wire nrst, 

    // spi slave interface
    input wire clk_in,
    input wire sel_in,
    input wire [DATA_WIDTH-1:0] data_in,

    // 
);

    // FSM
    localparam IDLE = 3'd0;
    localparam INPUT_GRID_MOVE = 3'd1;
    localparam COMPUTE_GRID = 3'd2;
    localparam COMPUTE_DNN  = 3'd3;
    localparam STORE_OUTPUT = 3'd4;
    localparam SEND_OUTPUT  = 3'd5;

    // global register
    logic [7:0] move_cnt; // load one move, increase; else decrease by 1

    // initial grid 64*1

endmodule

`default_nettype wire