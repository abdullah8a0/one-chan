`default_nettype none

module matrix_buffer #(
    parameter DATA_WIDTH = 8,
    parameter PARALLEL_NUM = 8, // larger than 1
    parameter INTER_NUM = 8,  // depth of the memory
    parameter ADDR_WIDTH = $clog2(INTER_NUM)
)(
    input wire clk,
    input wire nrst,
    input wire en_buf,

    input wire [DATA_WIDTH-1:0] mem_row_i [PARALLEL_NUM-1:0],
    output wire [ADDR_WIDTH-1:0] addr_row_ [PARALLEL_NUM-1:0],

    output logic data_valid,
    output logic [DATA_WIDTH-1:0] mem_row_o [PARALLEL_NUM-1:0],
);

    localparam LATENCY = INTER_NUM*2 - 1;
    localparam LATE_WIDTH = $clog2(LATENCY);
    
    localparam MEM_LATENCY = 2;

    localparam IDLE = 2'd0;
    localparam STAR = 2'd1;
    localparam SEND = 2'd2;
    
    logic state;
    logic begin_buf;
    logic finish_buf;
    logic [LATE_WIDTH-1:0] buf_cnt;
    
    logic [ADDR_WIDTH-1:0] addr [PARALLEL_NUM-1:0];

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) addr[0] <= 0;
        else if((state==IDLE) && (addr[0]<INTER_NUM)) addr <= addr + 1;
        else if((state==SEND) && (addr[0]<INTER_NUM-1) && (addr[0]!=0)) addr <= addr + 1;
        else if((state==SEND) && (addr[0]==INTER_NUM-1)) addr[0] <= 0;
        else addr[0] <= addr[0];
    end

    // state control
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) state <= IDLE;
        else if((state==IDLE) && en_buf) state <= STAR;
        else if((state==STAR) && begin_buf) state <= SEND;
        else if((state==SEND) && finish_buf) state <= IDLE;
        else state <= state;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) 
    end

endmodule 

`default_nettype wire