`default_nettype none

module spi_slave #(
    parameter DATA_WIDTH = 8,// output 1 byte(8-bit) at one spi_clk cycle
    parameter BIT_DUR = 2,
    parameter BYTE_STORE = 250 // maximum store data in interface before send data
    )( 
    input wire clk, 
    input wire nrst,
    
    input wire clk_in,
    input wire sel_in,
    input wire [DATA_WIDTH-1:0] data_in,

    output logic spi_ov,
    output logic [DATA_WIDTH-1:0] spi_od 
    );

    localparam IDLE = 0;
    localparam RECE = 1;
    localparam PIPE = 2;

    localparam CNT_WIDTH = $clog2(BYTE_STORE);

    logic [1:0] state;
    logic finish_rece;
    logic finish_send;

    logic [CNT_WIDTH-1:0] length;
    logic [DATA_WIDTH*BYTE_STORE-1:0] data_buf;
    logic [CNT_WIDTH-1:0] send_cnt;

    logic d_clk_in;
    logic clk_in_posedge;
    always_ff @(posedge clk) begin
        d_clk_in <= clk_in;
    end
    assign clk_in_posedge = ({d_clk_in, clk_in}==2'b01) ? 1'b1 : 1'b0;

    assign finish_rece = clk_in && sel_in;
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) state <= IDLE;
        else if((state==IDLE) && ~sel_in) state <= RECE;
        else if((state==RECE) && finish_rece) state <= PIPE;
        else if((state==PIPE) && finish_send) state <= IDLE;
        else state <= state; 
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) length <= 0;
        else if((state==RECE) && clk_in_posedge) length <= length + 1;
        else if(state==IDLE) length <= 0;
        else length <= length;
    end

    assign finish_send = (state==PIPE) && (send_cnt==length-1);
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) send_cnt <= 0;
        else if((state==PIPE) && (send_cnt<length)) send_cnt <= send_cnt + 1;
        else if((state==PIPE) && (send_cnt==length)) send_cnt <= 0;
        else send_cnt <= 0;
    end

    assign spi_od = data_buf[DATA_WIDTH-1:0];
    assign spi_ov = (state==PIPE);
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) data_buf <= 0;
        else if(state==RECE) data_buf <= clk_in_posedge ? {data_buf, data_in} : data_buf;
        else if(state==PIPE) data_buf <= data_buf >> DATA_WIDTH;
        else data_buf <= 0;
    end

endmodule

`default_nettype wire