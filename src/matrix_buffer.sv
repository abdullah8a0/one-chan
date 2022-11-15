`default_nettype none

module matrix_buffer #(
    parameter DATA_WIDTH = 8,
    parameter MEM_DEPTH = 8,
    parameter INPUT_PARALLEL_NUM = 8,
    parameter OUTPUT_PARALLEL_NUM = 3,
    parameter ADDR_WIDTH = $clog2(MEM_DEPTH)
)(
    input wire clk,
    input wire nrst,
    input wire en_buf,
    
    output wire [INPUT_PARALLEL_NUM-1:0][ADDR_WIDTH-1:0] addr_row_i,
    input  wire [INPUT_PARALLEL_NUM-1:0][DATA_WIDTH-1:0] mem_row_i,

    output logic data_valid,
    output logic  [OUTPUT_PARALLEL_NUM-1:0][DATA_WIDTH-1:0] mem_row_o
);

    localparam LATENCY = MEM_DEPTH + OUTPUT_PARALLEL_NUM - 1;
    localparam LATE_WIDTH = $clog2(LATENCY);
    
    localparam MEM_LATENCY = 2;

    localparam SEND_TIMES = INPUT_PARALLEL_NUM - OUTPUT_PARALLEL_NUM + 1;

    localparam IDLE = 2'd0;
    localparam READ = 2'd1;
    localparam SEND = 2'd2;
    
    logic [1:0] state;
    logic finish_read;
    logic finish_send;
    logic [$clog2(MEM_DEPTH):0] read_cnt;
    //logic [LATE_WIDTH-1:0] send_cnt;
    
    logic [INPUT_PARALLEL_NUM-1:0][ADDR_WIDTH-1:0] addr;
    logic [INPUT_PARALLEL_NUM-1:0][MEM_DEPTH-1:0][DATA_WIDTH-1:0] mem_buf;

    // state control
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) state <= IDLE;
        else if((state==IDLE) && en_buf) state <= READ;
        else if((state==READ) && finish_read) state <= SEND;
        else if((state==SEND) && finish_send) state <= IDLE;
        else state <= state;
    end

    // read setup
    assign addr_row_i = addr;
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            addr <= 0;
            read_cnt <= 0;
            finish_read <= 0;
        end
        else if((state==READ) && (read_cnt<MEM_DEPTH)) begin
            read_cnt <= read_cnt + 1;
            for(int i=0; i<INPUT_PARALLEL_NUM; i=i+1) begin
                addr[i] <= addr[i] + 1;
            end
            finish_read <= 0; 
        end
        else if((state==READ) && (read_cnt<(MEM_DEPTH+MEM_LATENCY))) begin
            read_cnt <= read_cnt + 1;
            addr <= 0;
            finish_read <= 1;
        end
        else begin
            addr <= 0;
            read_cnt <= 0;
            finish_read <= 0;
        end
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) mem_buf <= 0;
        else if(state==IDLE) mem_buf <= 0;
        else if((state==READ) && read_cnt>=MEM_LATENCY) begin
            for(int i=0; i<INPUT_PARALLEL_NUM; i++) begin
                mem_buf[i][read_cnt-MEM_LATENCY] <= mem_row_i[i];
            end
        end 
        else mem_buf <= mem_buf;
    end


    // send
    logic [$clog2(INPUT_PARALLEL_NUM-OUTPUT_PARALLEL_NUM+1)-1:0] col_cnt;
    logic [LATE_WIDTH-1:0] row_cnt;
    logic [OUTPUT_PARALLEL_NUM-1:0][$clog2(MEM_DEPTH)-1:0] output_addr;   
    
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) row_cnt <= 0;
        else if((state==SEND) && row_cnt<LATENCY) row_cnt <= row_cnt + 1;
        else if((state==SEND) && row_cnt==LATENCY) row_cnt <= 0;
        else row_cnt <= 0;
    end 

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) col_cnt <= 0;
        //else if((state==SEND) && (row_cnt==LATENCY) && (col_cnt<SEND_TIMES-1)) col_cnt <= col_cnt + 1;
        //else if((state==SEND) && (row_cnt==LATENCY) && (col_cnt==SEND_TIMES-1)) col_cnt <= 0;
        else if(state==SEND) begin
            if((row_cnt==LATENCY) && (col_cnt<SEND_TIMES-1)) col_cnt <= col_cnt + 1;
            else if((state==SEND) && (row_cnt==LATENCY) && (col_cnt==SEND_TIMES-1)) col_cnt <= 0;
            else col_cnt <= col_cnt;
        end
        else col_cnt <= 0;
    end

    // always_ff @(posedge clk or negedge nrst) begin
    //     if(~nrst) finish_send <= 0;
    //     else if((state==SEND) && (row_cnt==LATENCY) && (col_cnt==SEND_TIMES-1)) finish_send <= 1;
    //     else finish_send <= 0;
    // end
    assign finish_send = (state==SEND) && (row_cnt==LATENCY) && (col_cnt==SEND_TIMES-1);

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) output_addr <= 0;
        else if((state==SEND) && row_cnt<MEM_DEPTH-1) begin
            output_addr[0] <= output_addr[0] + 1;
            for(int i=1; i<OUTPUT_PARALLEL_NUM; i=i+1) begin
                output_addr[i] <= output_addr[i-1];
            end
        end
        else if((state==SEND) && row_cnt>=MEM_DEPTH-1) begin
            output_addr[0] <= 0;
            for(int i=1; i<OUTPUT_PARALLEL_NUM; i=i+1) begin
                output_addr[i] <= output_addr[i-1];
            end
        end
        else begin
            output_addr <= 0;
        end
    end 

    // output assignment
    assign data_valid = (state==SEND) && (row_cnt>=0) && (row_cnt<=LATENCY-1);


    // assign mem_row_o[0] = ((0<=row_cnt) && (row_cnt<=MEM_DEPTH-1)) ? mem_buf[col_cnt][output_addr[0]] : 0;
    // assign mem_row_o[1] = ((1<=row_cnt) && (row_cnt<=MEM_DEPTH+0)) ? mem_buf[col_cnt+1][output_addr[1]] : 0;
    // assign mem_row_o[2] = ((2<=row_cnt) && (row_cnt<=MEM_DEPTH+1)) ? mem_buf[col_cnt+2][output_addr[2]] : 0;

    // always_comb begin
    //     if((0<=row_cnt) && (row_cnt<=MEM_DEPTH-1)) mem_row_o[0] = mem_buf[col_cnt][output_addr[0]];
    //     else mem_row_o[0] = 0;
    // end
    genvar u;
    generate
        for(u=0; u<OUTPUT_PARALLEL_NUM; u=u+1) begin: MEM_OUT
            assign mem_row_o[u] = ((u<=row_cnt) && (row_cnt<=MEM_DEPTH-1+u)) ? mem_buf[col_cnt+u][output_addr[u]] : 0;
        end
    endgenerate
 
endmodule 

`default_nettype wire