`default_nettype none

`include "register_map.sv"
// address {2-bit, 6-bit}
// arithmetic operation uses single-cycle computing
// for special instruction, which executes for several clock cycles, the PC will stop increasing until finished

`define CONV 1'b0
`define MUL  1'b1

// single sysle register map
// Always combinational logic!!!
module register_file#(
    parameter WIDTH = 8,
    parameter HEIGHT = 8,
    parameter DATA_WIDTH = 8,
    parameter MOVE_WIDTH = 16,
    parameter int X_WIDTH[`TOTAL_REG_NUM] = {32,8,8,16,16,8,32,4,4,4,4,32,4,4,8,4,4,8,5,5,3,9,9,8},

    parameter WEIGHT_BASE_ADDR = 10'h100,
    parameter BIAS_BASE_ADDR = 10'h200
)(
    input wire clk,
    input wire nrst,
    
    // load total number of moves, indicating the starting of the program, MMIO
    input wire move_iv,
    input wire [7:0] total_move_id,

    // for arithmetic operation
    input wire [7:0] src1_addr,
    input wire [7:0] src2_addr,
    input wire [7:0] rd_addr,
    output logic signed [31:0] src1_reg_value,
    output logic signed [31:0] src2_reg_value, // reg value or constant
    input wire wrb_en, // write back enable
    input wire signed [31:0] wrb_value,

    // send weight and bias
    output logic weight_ov,
    output logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_od,

    output logic bias_ov,
    output logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] bias_od,

    // output layer info
    output logic layer_info_ov,
    output logic [3:0] weight_height_od,
    output logic [3:0] weight_width_od,
    output logic [3:0] ifmap_height_od,
    output logic [3:0] ifmap_width_od,
    output logic [3:0] bias_height_od,
    output logic [3:0] bias_width_od,
    output logic [2:0] op_od,  // {reLU_sel, op_sel, flatten}
    output logic is_first_layer,
    output logic is_final_layer,

    output logic [7:0] move_current_num,
    input wire move_current_iv,
    input wire [MOVE_WIDTH-1:0] move_current_id,

    // special instruction
    input wire decode_layer,
    input wire compute_grid,
    input wire decode_layer_info,
    input wire compute_ifmap,
    input wire send_layer_info,
    input wire load_weights,  // multi-cycle
    input wire load_biases,   // multi-cycle
    input wire send_systolic_data, // multi-cycle
    input wire set_ifmap_o,
    input wire send_optimal_move,

    output logic send_sd, // to unified buffer

    // load DNN output
    input wire dnn_iv,
    input wire [DATA_WIDTH-1:0] dnn_id,

    // optimal output send
    output logic op_move_ov,
    output logic [MOVE_WIDTH-1:0] op_move_od,

    // pc control
    output logic next_pc,
    input wire received_SA_od
);

    localparam NORMAL = 0;
    localparam LOAD_W = 1;
    localparam LOAD_B = 2;
    localparam SA_COMPUTE = 3;
    
    logic [1:0] state;
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) state <= NORMAL;
        else begin
            case(state)
                NORMAL: begin
                    if(load_weights && ~weight_ov) state <= LOAD_W;
                    else if(load_biases && ~bias_ov) state <= LOAD_B;
                    else if(send_systolic_data) state <= SA_COMPUTE;
                    else state <= state;
                end
                LOAD_W: begin
                    if(finish_load_weight) state <= NORMAL;
                    else state <= state;
                end
                LOAD_B: begin
                    if(finish_load_bias) state <= NORMAL;
                    else state <= state;
                end
                SA_COMPUTE: begin
                    if(received_SA_od) state <= NORMAL;
                    else state <= state; 
                end
            endcase
        end
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) send_sd <= 0;
        else if((state==NORMAL) && send_systolic_data) send_sd <= 1;
        else send_sd <= 0;
    end 

    assign next_pc = ((state==NORMAL) && (~load_biases && ~load_weights && ~send_systolic_data)) ||
                    ((state==LOAD_W) && finish_load_weight) || 
                    ((state==LOAD_B) && finish_load_bias) ||
                    ((state==SA_COMPUTE) && received_SA_od);

// first group of registers
    logic [`TOTAL_REG_NUM-1:0][31:0] X_w; // mapping for all the registers in the first group
    // assign X_w[0] = 0;

    // since not all the register has length of 32
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) X_w <= 0;
        else if(wrb_en) begin
            for(int i=0; i<`TOTAL_REG_NUM; i=i+1) begin
                if(i==rd_addr[4:0] && rd_addr[7:6]==2'b00) begin
                    for(int j=0; j<32; j=j+1) begin
                        if(j<X_WIDTH[i]) X_w[i][j] <= wrb_value[j];
                        else X_w[i][j] <= wrb_value[X_WIDTH[i]-1];
                    end
                end
                else X_w[i] <= X_w[i];

                if(i==`MOVE_CURRENT && move_current_iv) X_w[i] <= move_current_id;
            end
        end
        else begin // special instruction           
            for(int i=1; i<`TOTAL_REG_NUM; i=i+1) begin
                if(i==`MOVE_TOTAL_NUM && move_iv) X_w[i] <= total_move_id;
                if(i==`DNN_OUT && dnn_iv) X_w[i] <= $signed(dnn_id);

                // decode layer
                if(i==`LAYER_TOTAL_NUM && decode_layer) X_w[i] <= layer_total_num_ld;
                if(i==`INPUT_HEIGHT && decode_layer) X_w[i] <= input_height_ld;
                if(i==`INPUT_WIDTH && decode_layer) X_w[i] <= input_width_ld;
                
                // decode layer info
                if(i==`WEIGHT_HEIGHT && decode_layer_info) X_w[i] <= weight_height_lid;
                if(i==`WEIGHT_WIDTH && decode_layer_info) X_w[i] <= weight_width_lid;
                if(i==`WEIGHT_START_ADDR && decode_layer_info) X_w[i] <= weight_start_addr_lid + WEIGHT_BASE_ADDR;
                if(i==`BIAS_HEIGHT && decode_layer_info) X_w[i] <= bias_height_lid;
                if(i==`BIAS_WIDTH && decode_layer_info) X_w[i] <= bias_width_lid;
                if(i==`BIAS_START_ADDR && decode_layer_info) X_w[i] <= bias_start_addr_lid + BIAS_BASE_ADDR;
                if(i==`OP && decode_layer_info) X_w[i] <= op_lid;

                // compute ifmap, set ifmap_o
                if(i==`IFMAP_HEIGHT)
                    if(compute_ifmap && X_w[`OP][1]==`MUL) X_w[i] <= (X_w[`OP][0]==1) ? (X_w[`IFMAP_WIDTH]*X_w[`IFMAP_HEIGHT]) : X_w[`IFMAP_WIDTH]; 
                    else if(set_ifmap_o) begin
                        if(X_w[`OP][1]==`MUL) X_w[i] <= X_w[`IFMAP_WIDTH];
                        else X_w[i] <= X_w[i] - X_w[`WEIGHT_HEIGHT] + 1;
                    end
                if(i==`IFMAP_WIDTH)
                    if(compute_ifmap && X_w[`OP][1]==`MUL) X_w[i] <= (X_w[`OP][0]==1) ? 1 : X_w[`IFMAP_HEIGHT];
                    else if(set_ifmap_o) begin
                        if(X_w[`OP][1]==`MUL) X_w[i] <= X_w[`WEIGHT_WIDTH];
                        else X_w[i] <= X_w[i] - X_w[`WEIGHT_WIDTH] + 1;
                    end
            end
        end
    end

// second group of registers
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_reg;

// third group of registers
    // for conv, bias is stored in [0][0]
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] bias_reg; 

// load weight and bias from Main memory
    logic finish_load_weight;
    logic finish_load_bias;

    logic [5:0] w_cnt, b_cnt;
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) w_cnt <= 0;
        else if(state==LOAD_W) w_cnt <= w_cnt + 1;
        else if(state==LOAD_W && finish_load_weight) w_cnt <= 0;
        else w_cnt <= 0;
    end
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) b_cnt <= 0;
        else if(state==LOAD_B) b_cnt <= b_cnt + 1;
        else if(state==LOAD_B && finish_load_bias) b_cnt <= 0;
        else b_cnt <= 0;
    end
    assign finish_load_weight = (w_cnt==X_w[`WEIGHT_LENGTH]-1);
    assign finish_load_bias = (b_cnt==X_w[`BIAS_LENGTH]-1);

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) weight_reg <= 0;
        else if(state==LOAD_W) begin
            for(int i=0; i<HEIGHT; i=i+1) begin
                for(int j=0; j<WIDTH; j=j+1) begin
                    if((i<X_w[`WEIGHT_HEIGHT]) && (j<X_w[`WEIGHT_WIDTH]) && (i*X_w[`WEIGHT_WIDTH]+j==w_cnt)) weight_reg[i][j] <= wrb_value[7:0];
                    else weight_reg[i][j] <= weight_reg[i][j]; 
                end
            end
        end
        else weight_reg <= weight_reg;
    end
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) bias_reg <= 0;
        else if(state==LOAD_B) begin
            for(int i=0; i<HEIGHT; i=i+1) begin
                for(int j=0; j<WIDTH; j=j+1) begin
                    if((i<X_w[`BIAS_HEIGHT]) && (j<X_w[`BIAS_WIDTH]) && (i*X_w[`BIAS_WIDTH]+j==b_cnt)) bias_reg[i][j] <= wrb_value[7:0];
                    else bias_reg[i][j] <= bias_reg[i][j]; 
                end
            end
        end
        else bias_reg <= bias_reg;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) weight_ov <= 0;
        else if(state==LOAD_W && finish_load_weight) weight_ov <= 1;
        else weight_ov <= 0;
    end
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) bias_ov <= 0;
        else if(state==LOAD_B && finish_load_bias) bias_ov <= 1;
        else bias_ov <= 0;
    end
    

    // decode layer 
    logic [3:0] input_width_ld;
    logic [3:0] input_height_ld;
    logic [3:0] layer_total_num_ld;
    layer_decoder u_layer_decoder(
        .layer_info      ( X_w[`LAYER_NUM_INFO] ),
        .input_height    ( input_height_ld    ),
        .input_width     ( input_width_ld     ),
        .layer_total_num ( layer_total_num_ld )
    );

    // decode layer info
    logic [3:0] weight_height_lid;
    logic [3:0] weight_width_lid;
    logic [7:0] weight_start_addr_lid;
    logic [3:0] bias_height_lid;
    logic [3:0] bias_width_lid;
    logic [7:0] bias_start_addr_lid;
    logic [2:0] op_lid;  // {reLU_sel, op_sel, flatten_sel}
    layer_info_decoder u_layer_info_decoder(
        .layer_info ( X_w[`LAYER_INFO] ),
        
        .weight_height        ( weight_height_lid        ),
        .weight_width         ( weight_width_lid         ),
        .weight_start_addr    ( weight_start_addr_lid    ),
        .bias_height          ( bias_height_lid          ),
        .bias_width           ( bias_width_lid           ),
        .bias_start_addr      ( bias_start_addr_lid      ),
        .op                   ( op_lid                   )
    );
 
    // outut assignment
    assign weight_height_od = X_w[`WEIGHT_HEIGHT];
    assign weight_width_od = X_w[`WEIGHT_WIDTH];
    assign ifmap_height_od = X_w[`IFMAP_HEIGHT];
    assign ifmap_width_od = X_w[`IFMAP_WIDTH];
    assign bias_height_od = X_w[`BIAS_HEIGHT];
    assign bias_width_od = X_w[`BIAS_WIDTH];
    assign op_od = X_w[`OP];

    always_comb begin
        case(state)
            NORMAL: begin
                src1_reg_value = X_w[src1_addr[5:0]];
                src2_reg_value = X_w[src2_addr[5:0]];
            end
            LOAD_W: begin
                src1_reg_value = X_w[`WEIGHT_START_ADDR] + w_cnt;
                src2_reg_value = 0;
            end
            LOAD_B: begin
                src1_reg_value = X_w[`BIAS_START_ADDR] + b_cnt;
                src2_reg_value = 0;
            end
            SA_COMPUTE: begin
                src1_reg_value = 0;
                src2_reg_value = 0;
            end
        endcase
    end

    assign is_first_layer = (X_w[`LAYER_CURRENT_NUM] == 1);
    assign is_final_layer = (X_w[`LAYER_TOTAL_NUM] == X_w[`LAYER_CURRENT_NUM]);

    assign weight_od = weight_reg;
    assign bias_od = bias_reg;
    assign layer_info_ov = send_layer_info;
    
    assign op_move_od = X_w[`MOVE_MAX];
    assign op_move_ov = send_optimal_move;

    assign move_current_num = X_w[`MOVE_CURRENT_NUM];
endmodule

`default_nettype wire