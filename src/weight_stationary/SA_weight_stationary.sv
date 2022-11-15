`default_nettype none
`timescale 1ns/1ps

// weight stationary 
// for 3-by-3 convolution
module SA_WS_conv #(
    parameter SA_ROW = 3,
    parameter SA_COL = 3,
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 19,
    parameter VECTOR_LENGTH = 8
)(
    input wire clk,
    input wire nrst,

    input wire sa_iv, // activate SA array
    input wire [SA_ROW-1:0][DATA_WIDTH-1:0] row_A_i, // layer input

    // to test simulation, delete the weight_i
    // input wire [SA_ROW-1:0][SA_COL-1:0][DATA_WIDTH-1:0] weight_i,

    output logic sa_ov, //when output is ready
    output logic [SA_COL-1:0][PSUM_WIDTH-1:0] psum_o
);

    localparam LATENCY = VECTOR_LENGTH + SA_ROW + SA_COL - 1;
    localparam LATE_WIDTH = $clog2(LATENCY);
    
    logic [LATE_WIDTH-1:0] sa_cnt;
    
    logic [SA_ROW:0][SA_COL-1:0][PSUM_WIDTH-1:0] psum_w;
    logic [SA_ROW-1:0][SA_COL:0][DATA_WIDTH-1:0] ifmap_w;
    logic [SA_ROW-1:0][SA_COL-1:0][DATA_WIDTH-1:0] weight_w;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) sa_cnt <= 0;
        else if(sa_iv) sa_cnt <= sa_cnt + 1;
        else sa_cnt <= 0;
    end

    // output valid assignment
    assign sa_ov = ((sa_cnt>=(SA_ROW+SA_COL-1)) && (sa_cnt<=(VECTOR_LENGTH+SA_ROW-1))) ? 1'b1 : 1'b0;


    // edge assignment: ifmap_i and psum_i
    genvar row, col;
    generate
        for(row=0; row<SA_ROW; row=row+1) begin
            assign ifmap_w[row][0] = row_A_i[row];
        end

        for(col=0; col<SA_COL; col=col+1) begin
            assign psum_w[0][col] = 0;
            assign psum_o[col] = psum_w[SA_ROW][col];
        end
    endgenerate

    // SA array 
    genvar r, c;
    generate 
        for(r=0; r<SA_ROW; r=r+1) begin: R
            for(c=0; c<SA_COL; c=c+1) begin: C
                PE_weight_stationary#(
                    .IFMAP_WIDTH        ( 8 ),
                    .WEIGHT_WIDTH       ( 8 ),
                    .ACCUMULATION_WIDTH ( 4 )
                )u_PE_weight_stationary(
                    .clk       ( clk              ),
                    .nrst      ( nrst             ),
                    .ifmap_i   ( ifmap_w[r][c]    ),
                    .psum_i    ( psum_w[r][c]     ),
                    .weight_i  ( weight_w[r][c]   ),
                    .pe_en     ( sa_iv            ),
                    .ifmap_o   ( ifmap_w[r][c+1]  ),
                    .psum_o    ( psum_w[r+1][c]   ) 
                );

            end
        end
    endgenerate 

    // weight assignment
    weight_kernel_conv#(
        .KERNEL_WIDTH  ( 3 ),
        .KERNEL_HEIGHT ( 3 ),
        .WEIGHT_WIDTH  ( 8 )
    )u_weight_kernel_conv0(
        .weight_o  ( weight_w  )
    );


endmodule 

`default_nettype wire