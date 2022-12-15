`default_nettype none

`define CONV 1'b0
`define MUL  1'b1

module unified_buffer#(
    parameter WIDTH = 8,
    parameter HEIGHT = 8,
    parameter DATA_WIDTH = 8,

    parameter OUTPUT_HEIGHT = 1,
    parameter OUTPUT_WIDTH = 1 // since 1 output, the output is just a multibit variable
)(
    input wire clk,
    input wire nrst,

    input wire grid_iv,
    input wire [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] grid_id,

    input wire load_layer_info,
    input wire [3:0] ifmap_i_height,
    input wire [3:0] ifmap_i_width, // vector length
    input wire [3:0] w_height,
    input wire [3:0] w_width,
    input wire is_first_layer,
    input wire is_lastLayer, // whether is the last hidden layer
    input wire op_sel,
    input wire flatten,

    // mul
    input wire layer_mul_iv,
    input wire [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] layer_mul_id,

    // conv
    input wire layer_conv_iv,
    input wire [DATA_WIDTH-1:0] layer_conv_id,

    // to register file
    output logic receive_layer,

    // systolic data output
    input wire send_sd,
    output logic sd_sign_en,
    output logic sd_ov,
    output logic [WIDTH-1:0][DATA_WIDTH-1:0] sd_od,

    output logic dnn_ov,
    output logic [DATA_WIDTH-1:0] dnn_od
);

    localparam IDLE                 = 0;
    localparam LOAD_LAYER_INFO      = 1;
    localparam LOAD_IFMAP_O         = 2;
    localparam CONV                 = 3;
    localparam MUL                  = 4;
    localparam RECEIVE_OUTPUT_LAYER = 5;
    localparam SEND_DNN_OUT         = 6;

    // logic [4:0] latency; 
    // logic [3:0] send_times;
    // logic [7:0] sa_cnt;
 
    // assign latency = ifmap_i_w_r + weight_w - 1;
    // assign send_times = ifmap_i_h_r - weight_h_r + 1;

    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] ifmap_i_r;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] ifmap_o_r;
    logic [3:0] ifmap_i_h_r, ifmap_i_w_r, weight_h_r, weight_w_r;
    logic [3:0] ifmap_o_h, ifmap_o_w;
    logic is_finalLayer_r;
    logic op_r;

    logic [2:0] state;
    logic finish_conv_sd_receive, finish_mul_sd_receive;
    logic [3:0] conv_row_cnt, conv_col_cnt;
    
    // FSM
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) state <= IDLE;
        else begin
            case(state)
                IDLE: state <= (grid_iv) ? LOAD_LAYER_INFO : state;
                LOAD_LAYER_INFO: state <= (load_layer_info) ? ((is_first_layer) ? ((op_sel==`CONV) ? CONV : MUL) : LOAD_IFMAP_O) : state; // if not receive
                LOAD_IFMAP_O: state <= (op_r==`CONV) ? CONV : MUL;
                CONV: state <= (finish_conv_sd_receive) ? RECEIVE_OUTPUT_LAYER : state;
                MUL:  state <= (finish_mul_sd_receive) ? RECEIVE_OUTPUT_LAYER : state;
                RECEIVE_OUTPUT_LAYER: state <= (is_finalLayer_r) ? SEND_DNN_OUT : LOAD_LAYER_INFO;
                SEND_DNN_OUT: state <= IDLE;
                default: state <= IDLE;
            endcase
        end
    end

    assign receive_layer = ((state==CONV) && finish_conv_sd_receive) || ((state==MUL) && finish_mul_sd_receive);

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) sd_sign_en <= 0;
        else if(state==LOAD_LAYER_INFO) sd_sign_en <= (is_first_layer) ? 1'b0 : 1'b1;
        else sd_sign_en <= sd_sign_en;
    end

// load input grid, first layer, skip ifmap_o loading
    

// load layer info
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) {ifmap_i_h_r, ifmap_i_w_r, weight_h_r, weight_w_r} <= 0;
        else if(load_layer_info) {ifmap_i_h_r, ifmap_i_w_r, weight_h_r, weight_w_r} <= {ifmap_i_height, ifmap_i_width, w_height, w_width};
        else {ifmap_i_h_r, ifmap_i_w_r, weight_h_r, weight_w_r} <= {ifmap_i_h_r, ifmap_i_w_r, weight_h_r, weight_w_r};
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) op_r <= 0;
        else if(load_layer_info) op_r <= op_sel;
        else op_r <= op_sel;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) is_finalLayer_r <= 0;
        else if(load_layer_info) is_finalLayer_r <= is_lastLayer;
        else is_finalLayer_r <= is_finalLayer_r;
    end

// compute new ifmap_o height and width after loading ifmap_o
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            ifmap_o_h <= 0;
            ifmap_o_w <= 0;
        end
        else if(state==IDLE) begin
            ifmap_o_h <= 0;
            ifmap_o_w <= 0;
        end
        else if((state==LOAD_LAYER_INFO) && is_first_layer) begin
            if(op_r==`CONV) begin
                ifmap_o_h <= ifmap_i_height - w_height + 1;
                ifmap_o_w <= ifmap_i_width - w_width + 1;
            end
            else begin
                ifmap_o_h <= ifmap_i_width;
                ifmap_o_w <= w_width;
            end
        end
        else if(state==LOAD_IFMAP_O) begin
            if(op_r==`CONV) begin
                ifmap_o_h <= ifmap_i_h_r - weight_h_r + 1;
                ifmap_o_w <= ifmap_i_w_r - weight_w_r + 1;
            end
            else begin
                ifmap_o_h <= ifmap_i_w_r;
                ifmap_o_w <= weight_w_r;
            end
        end
        else begin
            ifmap_o_h <= ifmap_o_h;
            ifmap_o_w <= ifmap_o_w;
        end
    end
    
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) ifmap_i_r <= 0;
        else if((state==IDLE) && grid_iv) ifmap_i_r <= grid_id;
        else if(state==LOAD_IFMAP_O) begin
            if(op_r==`CONV) ifmap_i_r <= ifmap_o_r;
            else begin // MUL, transpose
                if(flatten) begin
                    for(int i=0; i<HEIGHT; i=i+1) begin
                        for(int j=0; j<WIDTH; j=j+1) begin
                            if(i<ifmap_o_h && j<ifmap_o_w && (i*ifmap_o_w+j<HEIGHT)) ifmap_i_r[(i*ifmap_o_w+j)][0] <= ifmap_o_r[i][j];
                            else ifmap_i_r[j][i] <= 0;
                        end
                    end
                end
                else begin
                    for(int i=0; i<HEIGHT; i=i+1) begin
                        for(int j=0; j<WIDTH; j=j+1) begin
                            if(i<ifmap_o_h && j<ifmap_o_w) ifmap_i_r[j][i] <= ifmap_o_r[i][j];
                            else ifmap_i_r[j][i] <= 0;
                        end
                    end
                end
            end
        end
        else ifmap_i_r <= ifmap_i_r;
    end



// CONV or MUL receive
    // assign finish_mul_sd_receive = layer_mul_iv;
    // assign finish_conv_sd_receive = (conv_col_cnt==ifmap_o_h);

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) finish_mul_sd_receive <= 0;
        else if(layer_mul_iv && (state==MUL)) finish_mul_sd_receive <= 1;
        else finish_mul_sd_receive <= 0;
    end
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) finish_conv_sd_receive <= 0;
        else if((conv_col_cnt==ifmap_o_h) && (state==CONV)) finish_conv_sd_receive <= 1;
        else finish_conv_sd_receive <= 0;
    end
    
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) conv_row_cnt <= 0;
        else if(layer_conv_iv) conv_row_cnt <= conv_row_cnt + 1;
        else conv_row_cnt <= 0;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) conv_col_cnt <= 0;
        else if(~layer_conv_iv && (conv_row_cnt==ifmap_o_w)) conv_col_cnt <= conv_col_cnt + 1;
        else if(state==CONV) conv_col_cnt <= conv_col_cnt;
        else conv_col_cnt <= 0;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) ifmap_o_r <= 0;
        else if(state==IDLE) ifmap_o_r <= 0;
        else if((state==MUL) && layer_mul_iv) ifmap_o_r <= layer_mul_id;
        else if((state==CONV) && layer_conv_iv) begin
            for(int i=0; i<HEIGHT; i=i+1) begin
                for(int j=0; j<WIDTH; j=j+1) begin
                    if((i==conv_col_cnt) && (j==conv_row_cnt)) ifmap_o_r[i][j] <= layer_conv_id;
                    else ifmap_o_r[i][j] <= ifmap_o_r[i][j];
                end
            end
        end
        else ifmap_o_r <= ifmap_o_r;
    end

    systolic_data_buffer u_systolic_data_buffer(
        .clk              ( clk              ),
        .nrst             ( nrst             ),
        .layer_info_valid ( (state==CONV) || (state==MUL) ),
        .ifmap_height_i     ( ifmap_i_h_r     ),
        .ifmap_width_i      ( ifmap_i_w_r      ),
        .weight_height_i    ( weight_h_r    ),
        .op_i               ( op_r               ),
        .ifmap_i          ( ifmap_i_r        ),
        .send_sd_en       ( send_sd    ),
        .sd_ov            ( sd_ov        ),
        .sd_od            ( sd_od         )
    );


// send output
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            dnn_ov <= 0;
            dnn_od <= 0;
        end
        else if(state==SEND_DNN_OUT) begin
            dnn_ov <= 1;
            dnn_od <= ifmap_o_r[0][0];
        end
        else begin
            dnn_ov <= 0;
            dnn_od <= dnn_od;
        end
    end

endmodule

`default_nettype wire