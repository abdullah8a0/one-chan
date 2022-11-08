`default_nettype none

// A:m*l, B:l*n, AB:m*n
module Systolic_array #(
    parameter DATA_WIDTH = 8,
    parameter ROW_NUM = 8,  //m
    parameter COL_NUM = 8,  //n
    parameter INTER_NUM = 8, //l
    parameter PARIAL_SUM_WIDTH = 19
)(
    input wire clk,
    input wire nrst,

    input wire sa_iv, // activate SA array
    input wire sa_mac_iv,
    input wire sa_bias_iv,

    input wire [DATA_WIDTH-1:0] row_A_i [COL_NUM-1:0], // layer input
    input wire [DATA_WIDTH-1:0] col_W_i [ROW_NUM-1:0], // weight matrix B
    input wire [DATA_WIDTH-1:0] bias_col_i [COL_NUM-1:0],

    output logic sa_ov, //when output is ready
    output logic [DATA_WIDTH-1:0] psum_o [COL_NUM-1:0]
);

    // FSM
    localparam IDLE = 3'd0;
    localparam STAR = 3'd1;
    localparam MAC  = 3'd2;
    localparam BIAS = 3'd3;
    localparam RELU = 3'd4;
    localparam OUT  = 3'd5;

    // inteconect between PE and input, output is of no need
    logic [DATA_WIDTH-1:0] ifmap_row_w  [ROW_NUM-1:0][COL_NUM:0];
    logic [DATA_WIDTH-1:0] weight_col_w [ROW_NUM:0][COL_NUM-1:0];
    logic [DATA_WIDTH-1:0] bias_r       [ROW_NUM-1:0][COL_NUM-1:0];
    logic [PARIAL_SUM_WIDTH-1:0] psum_w [ROW_NUM-1:0][COL_NUM-1:0];

    logic [2:0] state;

    //bias 
    logic bias_load;
    logic [2:0] bias_cnt;

    //OUT state, counting 8 cycles, reset FSM
    logic output_finish;
    logic [2:0] output_cnt; 


    // state machine
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) state <= IDLE;
        else if((state==IDLE) && sa_iv    ) state <= STAR;
        else if((state==STAR) && sa_mac_iv) state <= MAC;
        else if((state==MAC)  && sa_BIAS_iv) state <= BIAS;
        else if((state==BIAS) && bias_load) state <= RELU;
        else if(state==RELU) state <= OUT;
        else if((state==OUT)  && output_finish) state <= IDLE;
        else state <= state;
    end



    // input ifmap/weight matrix assignment
    genvar m, n;
    generate
        for(m=0; m<ROW_NUM; m=m+1) begin : ifmap_input_row
            assign ifmap_row_w[m][0] = row_A_i[m];
        end

        for(n=0; n<COL_NUM; n=n+1) begin : weight_input_col
            assign weight_col_w[0][n] = col_W_i[n];
        end
    endgenerate


    // bias storage
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) bias_load <= 1'b0;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) bias_cnt <= 3'd0;
        else if(sa_bias_iv) bias_cnt <= bias_cnt + 3'd1;
        else bias_cnt <= 3'd0;
    end

    genvar b_r, b_c;
    generate
        for(b_r=0; b_r<ROW_NUM; b_r=b_r+1) begin
            for(b_c=0; b_c<COL_NUM; b_c=b_c+1) begin
                always_ff @(posedge clk or negedge nrst) begin
                    if(~nrst) bias_r[b_r][b_c] <= 0;
                    else if(sa_bias_iv && (bias_cnt==b_c)) bias_r[b_r][b_c] <= bias_col_i[b_r];
                    else if(state == BIAS) bias_r[b_r][b_c] <= bias_r[b_r][b_c];
                    else bias_r[b_r][b_c] <= 0;
                end
            end
        end
    endgenerate


    // output buffer
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) output_cnt <= 3'd0;
        else if(state==OUT) output_cnt <= output_cnt + 3'd1;
        else output_cnt <= 3'd0;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) output_finish <= 1'b0;
        else if((state==OUT) && (output_cnt==3'd7)) output_finish <= 1'b1;
        else output_finish<= 1'b0;
    end

    assign sa_ov = (state==OUT) ? 1'b1 : 1'b0;
    
    genvar oi;
    generate
        for(oi=0;oi<8; oi++) begin
            always_comb begin : OUT_COL
                case(output_cnt)
                    3'd0: psum_o[oi] = psum_w[oi][0] >>> 7; //quantization, since weight has a fixed point between 7 and 6
                    3'd1: psum_o[oi] = psum_w[oi][1] >>> 7;
                    3'd2: psum_o[oi] = psum_w[oi][2] >>> 7;
                    3'd3: psum_o[oi] = psum_w[oi][3] >>> 7;
                    3'd4: psum_o[oi] = psum_w[oi][4] >>> 7;
                    3'd5: psum_o[oi] = psum_w[oi][5] >>> 7;
                    3'd6: psum_o[oi] = psum_w[oi][6] >>> 7;
                    3'd7: psum_o[oi] = psum_w[oi][7] >>> 7;
                endcase
            end
        end
    endgenerate


    
    // PE instantiation, 8-by-8
    genvar i, j;
    generate
        for(i=0; i<ROW_NUM; i=i+1) begin: GEN_COL
            for(j=0; j<COL_NUM; j=j+1) begin: GEN_ROW
                PE#(
                    .IFMAP_WIDTH        ( DATA_WIDTH ),
                    .WEIGHT_WIDTH       ( DATA_WIDTH ),
                    .BIAS_WIDTH         ( DATA_WIDTH ),
                    .ACCUMULATION_WIDTH ( $clog2(DATA_WIDTH) )
                )u_PE(
                    .clk        ( clk        ),
                    .nrst       ( nrst       ),
                    .en         ( sa_iv      ),
                    .ifmap_i    ( ifmap_row_w[i][j]  ),
                    .weight_i   ( weight_col_w[i][j] ),
                    .bias_i     ( bias_r[i][j]     ),
                    .mac_en     ( sa_mac_iv     ),
                    .bias_en    ( bias_load   ),
                    .reLU_en    ( sa_reLU_en    ),
                    .ifmap_o    ( ifmap_row_w[i][j+1]    ),
                    .weight_o   ( weight_col_w[i+1][j]   ),
                    .psum_o     ( psum_w[i][j]    )
                );

            end
        end
    endgenerate 

endmodule 

`default_nettype wire