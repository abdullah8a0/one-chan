`default_nettype none

`define CONV 1'b0
`define MUL  1'b1

// weight stationary
// SA-ST structure
// sum apart from column to column
// sum together from row to row

// signed number operation, so $signed() must be used!
module scalable_SA#(
    parameter WIDTH = 8,
    parameter HEIGHT = 8,
    parameter DATA_WIDTH = 8,

    parameter PSUM_WIDTH = DATA_WIDTH*2 + $clog2(HEIGHT),
    parameter WIDTH_W = $clog2(WIDTH),
    parameter HEIGHT_W = $clog2(HEIGHT)
)(
    input wire clk,
    input wire nrst,
    
    // load layer info
    input wire load_layer_info,
    input wire [3:0] w_width,
    input wire [3:0] w_height,
    input wire op_sel,
    input wire [3:0] ifmap_i_w, // represent n in m*n and n*l matrix mul
    
    // weight load PE enable
    input wire weight_iv,
    input wire [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_id,

    // systolic data input
    input wire data_sign_en, 
    input wire data_iv,
    input wire [WIDTH-1:0][DATA_WIDTH-1:0] data_id,

    output logic data_ov,
    output logic [WIDTH-1:0][PSUM_WIDTH-1:0] data_od
);
    
    logic [HEIGHT:0][WIDTH-1:0][PSUM_WIDTH-1:0] psum_w;
    logic [HEIGHT-1:0][WIDTH:0][DATA_WIDTH-1:0] ifmap_w;

    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_r;
    logic [HEIGHT-1:0][WIDTH-1:0] en_r; // save energy

    logic [WIDTH_W:0]  width_r;
    logic [HEIGHT_W:0] height_r;
    logic op_r;
    logic [7:0] vec_len;

    logic [7:0] latency;
    logic [7:0] sa_cnt;

    assign latency = vec_len + width_r + height_r - 1;

    // layer info loading
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            width_r <= 0;
            height_r <= 0;
            op_r <= 0;
            vec_len <= 0;
        end
        else if(load_layer_info) begin
            width_r <= w_width;
            height_r <= w_height;
            op_r <= op_sel;
            vec_len <= ifmap_i_w;
        end
        else begin
            width_r <= width_r;
            height_r <= height_r;
            op_r <= op_r;
            vec_len <= vec_len;
        end
    end

    // load weight
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst)  weight_r <= 0;
        // PROBLEMATIC
        //else if(weight_iv) weight_r <= weight_id;
        else if(weight_iv) begin
            if(op_r==`MUL) weight_r <= weight_id;
            else begin
                for(int i=0; i<HEIGHT; i=i+1) begin
                    for(int j=0; j<WIDTH; j=j+1) begin
                        if(i<height_r && j<width_r) weight_r[i][j] <= weight_id[i][width_r-j-1];
                        else weight_r[i][j] <= weight_r[i][j];
                    end
                end
            end
        end
        else if(load_layer_info) weight_r <= 0;
        else weight_r <= weight_r;
    end
    
    // enable PE
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) en_r <= 0;
        else begin
            for(int i=0; i<HEIGHT; i=i+1) begin
                for(int j=0; j<WIDTH; j=j+1) begin
                    if((i<height_r) && (j<width_r)) en_r[i][j] <= 1;
                    else en_r[i][j] <= 0;
                end
            end
        end
    end

    // edge assignment: ifmap_i and psum_i
    genvar row, col;
    generate
        for(row=0; row<HEIGHT; row=row+1) begin
            assign ifmap_w[row][0] = (data_iv) ? data_id[row] :0;
        end

        for(col=0; col<WIDTH; col=col+1) begin
            assign psum_w[0][col] = 0;
            assign data_od[col] = psum_w[height_r][col];
        end
    endgenerate

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) sa_cnt <= 0;
        else if(data_iv && (sa_cnt==0)) sa_cnt <= sa_cnt + 1;
        else if((op_sel==`CONV) && data_iv && (0<sa_cnt) && (sa_cnt<latency)) sa_cnt <= sa_cnt +1;
        else if((op_sel==`MUL) && (0<sa_cnt) && (sa_cnt<latency)) sa_cnt <= sa_cnt +1;
        else sa_cnt <= 0;
    end

    // output valid assignment
    always_comb begin
        if(op_r==`CONV) begin
            data_ov = ((sa_cnt>=(width_r+height_r-1)) && (sa_cnt<=(vec_len+height_r-1))) ? 1'b1 : 1'b0;
        end
        else begin
            data_ov = ((sa_cnt>=(height_r)) && (sa_cnt<=(vec_len+ width_r +height_r-1 -1))) ? 1'b1 : 1'b0;
        end
    end

    // SA array 
    genvar r, c;
    generate 
        for(r=0; r<HEIGHT; r=r+1) begin: R
            for(c=0; c<WIDTH; c=c+1) begin: C
                PE_weight_stationary#(
                    .IFMAP_WIDTH        ( 8 ),
                    .WEIGHT_WIDTH       ( 8 )
                )u_PE_weight_stationary(
                    .clk       ( clk              ),
                    .nrst      ( nrst             ),
                    .ifmap_i_sign_en( data_sign_en), 
                    .ifmap_i   ( ifmap_w[r][c]    ),
                    .psum_i    ( psum_w[r][c]     ),
                    .weight_i  ( weight_r[r][c]   ),
                    .pe_en     ( en_r[r][c]),
                    .ifmap_o   ( ifmap_w[r][c+1]  ),
                    .psum_o    ( psum_w[r+1][c]   ) 
                );

            end
        end
    endgenerate 

endmodule

`default_nettype wire