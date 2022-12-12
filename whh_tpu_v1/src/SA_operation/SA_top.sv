`default_nettype none

`define CONV 1'b0
`define MUL  1'b1

module SA_top#(
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
    input wire [3:0] mul_b_w,
    input wire [3:0] mul_b_h,
    input wire reLU_sel,
    input wire op_sel,
    input wire [3:0] ifmap_i_w, // represent n in m*n and n*l matrix mul

    // load weights and biases
    input wire weight_iv,
    input wire [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_id,
    input wire b_iv,
    input wire [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] b_id,

    // systolic data input
    input wire data_sign_en, 
    input wire data_iv,
    input wire [WIDTH-1:0][DATA_WIDTH-1:0] data_id,

    // SA operation output
    output logic conv_ov,
    output logic [DATA_WIDTH-1:0] conv_od,
    output logic mul_ov,
    output logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] mul_od
);

    logic data_ov_sa;
    logic [WIDTH-1:0][PSUM_WIDTH-1:0] data_od_sa;

    logic conv_ov_acc;
    logic signed [PSUM_WIDTH-1:0] conv_od_acc;
    logic mul_ov_acc;
    logic [HEIGHT-1:0][WIDTH-1:0][PSUM_WIDTH-1:0] mul_od_acc;

    scalable_SA#(
        .WIDTH           ( 8 ),
        .HEIGHT          ( 8 ),
        .DATA_WIDTH      ( 8 )
    )u_scalable_SA(
        .clk             ( clk             ),
        .nrst            ( nrst            ),

        .load_layer_info ( load_layer_info ),
        .w_width         ( w_width         ),
        .w_height        ( w_height        ),
        .op_sel          ( op_sel          ),
        .ifmap_i_w       ( ifmap_i_w       ),

        .weight_iv       ( weight_iv       ),
        .weight_id       ( weight_id       ),
        .data_sign_en    ( data_sign_en    ),
        .data_iv         ( data_iv         ),
        .data_id         ( data_id         ),
        .data_ov         ( data_ov_sa      ),
        .data_od         ( data_od_sa      )
    );


    accumulator#(
        .HEIGHT          ( 8 ),
        .WIDTH           ( 8 ),
        .DATA_WIDTH      ( 8 )
    )u_accumulator(
        .clk             ( clk             ),
        .nrst            ( nrst            ),
        
        .load_layer_info ( load_layer_info ),
        .mul_b_w         ( mul_b_w         ),
        .mul_b_h         ( mul_b_h         ),
        .op_sel          ( op_sel          ),
        .b_iv            ( b_iv            ),
        .b_id            ( b_id            ),

        .data_iv         ( data_ov_sa         ),
        .data_id         ( data_od_sa         ),
        .conv_ov         ( conv_ov_acc         ),
        .conv_od         ( conv_od_acc         ),
        .mul_ov          ( mul_ov_acc          ),
        .mul_od          ( mul_od_acc          )
    );

    reLU#(
        .HEIGHT             ( 8 ),
        .WIDTH              ( 8 ),
        .DATA_WIDTH         ( 8 ),
        .WEIGHT_FIXED_POINT ( 7 )
    )u_reLU(
        .clk                ( clk                ),
        .nrst               ( nrst               ),

        .load_layer_info    ( load_layer_info    ),
        .reLU_sel           ( reLU_sel           ),
        .op_sel             ( op_sel             ),
        .mul_b_w            ( mul_b_w            ),
        .mul_b_h            ( mul_b_h            ),
        .conv_b_iv          ( conv_ov_acc        ),
        .conv_b_id          ( conv_od_acc          ),
        .mul_b_iv           ( mul_ov_acc           ),
        .mul_b_id           ( mul_od_acc           ),
        .conv_ov            ( conv_ov      ),
        .conv_od            ( conv_od     ),
        .mul_ov             ( mul_ov       ),
        .mul_od             ( mul_od      )
    );



endmodule

`default_nettype wire