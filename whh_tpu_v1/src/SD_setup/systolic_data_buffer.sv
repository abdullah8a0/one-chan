`default_nettype none

`define CONV 1'b0
`define MUL  1'b1

module systolic_data_buffer#(
    parameter DATA_WIDTH = 8,
    parameter HEIGHT = 8,
    parameter WIDTH = 8,

    parameter HEIGHT_W = $clog2(HEIGHT),
    parameter WIDTH_W = $clog2(WIDTH)
)(
    input wire clk,
    input wire nrst,

    input wire layer_info_valid,
    input wire [HEIGHT_W:0] ifmap_height_i,
    input wire [HEIGHT_W:0] ifmap_width_i, // vector length
    input wire [HEIGHT_W:0] weight_height_i,
    input wire op_i, // MUL or CONV
    input wire [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] ifmap_i, // connect to 64 regs in unified buffer

    input wire send_sd_en, // send_systolic_data
    output logic sd_ov,
    output logic [WIDTH-1:0][HEIGHT-1:0] sd_od
);

    // state control
    localparam IDLE = 0;
    localparam SEND = 1;
    
    logic state;
    logic finish_send;
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) state <= IDLE;
        else if(send_sd_en && layer_info_valid) state <= SEND;
        else if(finish_send) state <= IDLE;
        else state <= state;
    end 

    logic [HEIGHT_W:0] ifmap_height;
    logic [HEIGHT_W:0] ifmap_width; // vector length
    logic [HEIGHT_W:0] weight_height;
    logic op; // MUL or CONV

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            ifmap_height <= 0;
            ifmap_width <= 0;
            weight_height <= 0;
            op <= 0;
        end
        else if(layer_info_valid && send_sd_en) begin
            ifmap_height <= ifmap_height_i;
            ifmap_width <= ifmap_width_i;
            weight_height <= weight_height_i;
            op <= op_i;
        end
        else if(state==SEND) begin
            ifmap_height <= ifmap_height;
            ifmap_width <= ifmap_width;
            weight_height <= weight_height;
            op <= op;
        end
        else begin
            ifmap_height <= 0;
            ifmap_width <= 0;
            weight_height <= 0;
            op <= 0;
        end
    end

    // 
    logic [WIDTH_W:0] latency;
    logic [HEIGHT_W:0] send_times;

    logic [HEIGHT-1:0][WIDTH_W:0] output_cnt;
    logic [WIDTH_W:0] row_cnt;
    logic [HEIGHT_W:0] col_cnt;

    assign latency = ifmap_width + weight_height - 1;
    assign send_times = (op==`MUL) ? 1 : (ifmap_height - weight_height + 1); 

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) row_cnt <= 0;
        else if((state==SEND) && row_cnt<latency) row_cnt <= row_cnt + 1;
        else if((state==SEND) && row_cnt==latency) row_cnt <= 0;
        else row_cnt <= 0;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) col_cnt <= 0;
        else if((state==SEND) && (op==`CONV)) begin
            if((row_cnt==latency) && (col_cnt<send_times-1)) col_cnt <= col_cnt + 1;
            else if((row_cnt==latency) && (col_cnt==send_times-1)) col_cnt <= 0;
            else col_cnt <= col_cnt;
        end
        else col_cnt <= 0;
    end

    assign finish_send = (state==SEND) && (row_cnt==latency) && (col_cnt==send_times-1);


    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) output_cnt <= 0;
        else if((state==SEND) && row_cnt<ifmap_width-1) begin
            output_cnt[0] <= output_cnt[0] + 1;
            for(int i=1; i<weight_height; i=i+1) begin
                output_cnt[i] <= output_cnt[i-1];
            end
        end
        else if((state==SEND) && row_cnt>=ifmap_width-1) begin
            output_cnt[0] <= 0;
            for(int i=1; i<weight_height; i=i+1) begin
                output_cnt[i] <= output_cnt[i-1];
            end
        end
        else begin
            output_cnt <= 0;
        end
    end

    assign sd_ov = (state==SEND) && (row_cnt>=0) && (row_cnt<=latency-1);

    genvar u;
    generate
        for(u=0; u<HEIGHT; u=u+1) begin: MEM_OUT
            //assign sd_od[u] = ((u<=row_cnt) && (row_cnt<=ifmap_width-1+u)) ? mem_buf[col_cnt+u][output_cnt[u]] : 0;
            always_comb begin
                if(u<weight_height) sd_od[u] = ((u<=row_cnt) && (row_cnt<=ifmap_width-1+u)) ? ifmap_i[col_cnt+u][output_cnt[u]] : 0;
                else sd_od[u] = 0;
            end
        end
    endgenerate

endmodule

`default_nettype wire