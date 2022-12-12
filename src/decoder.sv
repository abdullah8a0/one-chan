`default_nettype none

module decoder #(
    parameter MOVE_WIDTH = 16,
    parameter GRID_ELE_WIDTH = 8
)(
    input wire clk,
    input wire nrst,

    input wire grid_iv,
    input wire [GRID_ELE_WIDTH-1:0] grid_id,

    input wire move_iv, // activiate only once, ont a data flow
    input wire [MOVE_WIDTH-1:0] move_id,

    output logic grid_ov,
    output logic grid_od
);

    // fsm
    localparam IDLE = 0;
    localparam INPUT_GRID = 1;
    localparam MOVE = 2;
    localparam SEND = 3;

    // buffer: 64 register array
    logic [7:0][7:0][GRID_ELE_WIDTH-1:0] grid_buf;
    logic finish_input_grid;
    logic finish_move;
    logic finish_send;





    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) state <= IDLE;
        else if((state==IDLE) && grid_in)
    end





endmodule 

`default_nettype wire