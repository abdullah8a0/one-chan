`default_nettype none

`define CONV 1'b0
`define MUL  1'b1

module tb_unified_buffer;

    parameter WIDTH = 8;
    parameter HEIGHT = 8;
    parameter DATA_WIDTH = 8;
    parameter PSUM_WIDTH = DATA_WIDTH*2 + $clog2(HEIGHT);
    parameter WIDTH_W = $clog2(WIDTH);
    parameter HEIGHT_W = $clog2(HEIGHT);

    localparam EMPTY     = 8'b01_111111;
    localparam KING      = 6'b000001;
    localparam QUEEN     = 6'b000010;
    localparam ROOK      = 6'b000100;
    localparam KNIGHT    = 6'b001000;
    localparam BISHOP    = 6'b010000;
    localparam PAWN      = 6'b100000;
    localparam WHITE     = 2'b01;
    localparam BLACK     = 2'b10;

    logic [63:0][7:0] INIT_BOARD;
        assign INIT_BOARD[0] = {WHITE, ROOK};
        assign INIT_BOARD[1] = {WHITE, KNIGHT};
        assign INIT_BOARD[2] = {WHITE, BISHOP};
        assign INIT_BOARD[3] = {WHITE, QUEEN};
        assign INIT_BOARD[4] = {WHITE, KING};
        assign INIT_BOARD[5] = {WHITE, BISHOP};
        assign INIT_BOARD[6] = {WHITE, KNIGHT};
        assign INIT_BOARD[7] = {WHITE, ROOK};
        assign INIT_BOARD[8] = {WHITE, PAWN};
        assign INIT_BOARD[9] = {WHITE, PAWN};
        assign INIT_BOARD[10] = {WHITE, PAWN};
        assign INIT_BOARD[11] = {WHITE, PAWN};
        assign INIT_BOARD[12] = {WHITE, PAWN};
        assign INIT_BOARD[13] = {WHITE, PAWN};
        assign INIT_BOARD[14] = {WHITE, PAWN};
        assign INIT_BOARD[15] = {WHITE, PAWN};
        assign INIT_BOARD[16] = EMPTY;
        assign INIT_BOARD[17] = EMPTY;
        assign INIT_BOARD[18] = EMPTY;
        assign INIT_BOARD[19] = EMPTY;
        assign INIT_BOARD[20] = EMPTY;
        assign INIT_BOARD[21] = EMPTY;
        assign INIT_BOARD[22] = EMPTY;
        assign INIT_BOARD[23] = EMPTY;
        assign INIT_BOARD[24] = EMPTY;
        assign INIT_BOARD[25] = EMPTY;
        assign INIT_BOARD[26] = EMPTY;
        assign INIT_BOARD[27] = EMPTY;
        assign INIT_BOARD[28] = EMPTY;
        assign INIT_BOARD[29] = EMPTY;
        assign INIT_BOARD[30] = EMPTY;
        assign INIT_BOARD[31] = EMPTY;
        assign INIT_BOARD[32] = EMPTY;
        assign INIT_BOARD[33] = EMPTY;
        assign INIT_BOARD[34] = EMPTY;
        assign INIT_BOARD[35] = EMPTY;
        assign INIT_BOARD[36] = EMPTY;
        assign INIT_BOARD[37] = EMPTY;
        assign INIT_BOARD[38] = EMPTY;
        assign INIT_BOARD[39] = EMPTY;
        assign INIT_BOARD[40] = EMPTY;
        assign INIT_BOARD[41] = EMPTY;
        assign INIT_BOARD[42] = EMPTY;
        assign INIT_BOARD[43] = EMPTY;
        assign INIT_BOARD[44] = EMPTY;
        assign INIT_BOARD[45] = EMPTY;
        assign INIT_BOARD[46] = EMPTY;
        assign INIT_BOARD[47] = EMPTY;
        assign INIT_BOARD[48] = {BLACK, PAWN};
        assign INIT_BOARD[49] = {BLACK, PAWN};
        assign INIT_BOARD[50] = {BLACK, PAWN};
        assign INIT_BOARD[51] = {BLACK, PAWN};
        assign INIT_BOARD[52] = {BLACK, PAWN};
        assign INIT_BOARD[53] = {BLACK, PAWN};
        assign INIT_BOARD[54] = {BLACK, PAWN};
        assign INIT_BOARD[55] = {BLACK, PAWN};
        assign INIT_BOARD[56] = {BLACK, ROOK};
        assign INIT_BOARD[57] = {BLACK, KNIGHT};
        assign INIT_BOARD[58] = {BLACK, BISHOP};
        assign INIT_BOARD[59] = {BLACK, QUEEN};
        assign INIT_BOARD[60] = {BLACK, KING};
        assign INIT_BOARD[61] = {BLACK, BISHOP};
        assign INIT_BOARD[62] = {BLACK, KNIGHT};
        assign INIT_BOARD[63] = {BLACK, ROOK};

    logic clk;
    logic nrst;

    // declare status
    logic grid_iv;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] grid_id;

    logic load_layer_info;
    logic [3:0] ifmap_i_height;
    logic [3:0] ifmap_i_width; // vector length
    logic [3:0] w_height;
    logic [3:0] w_width;
    logic [3:0] mul_b_w;
    logic [3:0] mul_b_h;
    logic is_first_layer;
    logic is_lastLayer; 
    logic op_sel;
    logic flatten;
    logic reLU_sel;

    logic send_sd;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_id;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] bias_id;
    
    logic [2:0] tests;
    always_comb begin
        case(tests) 
            3'd0: begin
                ifmap_i_height = 8;  ifmap_i_width = 8;
                w_height = 3;  w_width = 3;
                mul_b_h = 1;  mul_b_w = 1;
                is_first_layer = 1;  is_lastLayer = 0;
                op_sel = `CONV;  flatten = 0;   reLU_sel = 0;
            end
            3'd1: begin
                ifmap_i_height = 6;  ifmap_i_width = 6;
                w_height = 3;  w_width = 3;
                mul_b_h = 1;  mul_b_w = 1;
                is_first_layer = 0;  is_lastLayer = 0;
                op_sel = `CONV;  flatten = 0;   reLU_sel = 0;
            end
            3'd2: begin
                ifmap_i_height = 4;  ifmap_i_width = 4;
                w_height = 1;  w_width = 3;
                mul_b_h = 1;  mul_b_w = 1;
                is_first_layer = 0;  is_lastLayer = 0;
                op_sel = `CONV;  flatten = 0;   reLU_sel = 0;
            end
            3'd3: begin
                ifmap_i_height = 8;  ifmap_i_width = 1;
                w_height = 8;  w_width = 8;
                mul_b_h = 1;  mul_b_w = 8;
                is_first_layer = 0;  is_lastLayer = 0;
                op_sel = `MUL;  flatten = 1;   reLU_sel = 1;
            end
            3'd4: begin
                ifmap_i_height = 8;  ifmap_i_width = 1;
                w_height = 8;  w_width = 1;
                mul_b_h = 1;  mul_b_w = 1;
                is_first_layer = 0;  is_lastLayer = 1;
                op_sel = `MUL;  flatten = 0;   reLU_sel = 0;
            end
            default: begin
                ifmap_i_height = 0;  ifmap_i_width = 0;
                w_height = 0;  w_width = 0;
                mul_b_h = 0;  mul_b_w = 0;
                is_first_layer = 0;  is_lastLayer = 0;
                op_sel = `CONV;  flatten = 0;   reLU_sel = 0;
            end
        endcase
    end

    always_comb begin
        case(tests)
            3'd0: begin
                weight_id = {64'd0, 64'd0, 64'd0, 64'd0, 64'd0,
                             {8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  8'sd5,   8'sd14, 8'sd10 },
                             {8'd0, 8'd0, 8'd0, 8'd0, 8'd0, -8'sd34, -8'sd12, -8'sd18},
                             {8'd0, 8'd0, 8'd0, 8'd0, 8'd0,  -8'sd22, -8'sd8,-8'sd11}};
                bias_id = {64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, {56'd0, 8'd5}};
            end
            3'd1: begin
                weight_id = { 64'd0, 64'd0, 64'd0, 64'd0, 64'd0,
                            { 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, 8'sd30, -8'sd14, -8'sd8},
                             { 8'd0, 8'd0, 8'd0, 8'd0, 8'd0, -8'sd25, -8'sd19, 8'sd4},
                             {     8'd0, 8'd0, 8'd0, 8'd0, 8'd0, -8'sd28, -8'sd20,8'sd3} };
                bias_id = { 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, {56'd0, 8'd27}};
            end
            3'd2:begin
                weight_id = {64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 
                            {  8'd0, 8'd0, 8'd0, 8'd0, 8'd0,8'sd69,  8'sd2,-8'sd40}};
                bias_id = { 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, { 56'd0, -8'sd19}};
            end
            3'd3:begin
                weight_id = {{-8'sd31, -8'sd27,   8'sd3,  -8'sd4,  -8'sd6, -8'sd25,  -8'sd5, -8'sd35},
                            {-8'sd36,  -8'sd3, -8'sd10, -8'sd35,  8'sd34,  8'sd33, -8'sd40, -8'sd8},
                            {8'sd7,   8'sd6,  8'sd36, -8'sd13,  8'sd35,  -8'sd1, -8'sd36, -8'sd43},
                            {-8'sd39, -8'sd31,  8'sd37, -8'sd35, -8'sd21,  8'sd31,   8'sd8, -8'sd13},
                            { -8'sd34, -8'sd22,   8'sd9, -8'sd20,  8'sd23, -8'sd31,  8'sd41, -8'sd8},
                            {-8'sd14,   8'sd7, -8'sd24,  -8'sd1,   8'sd3, -8'sd16, -8'sd41, -8'sd30},
                            {-8'sd22,  8'sd15, -8'sd34,   8'sd8, -8'sd23, -8'sd39, -8'sd17, -8'sd42},
                            {8'sd33, 8'sd34,  8'sd29,   8'sd3,  8'sd34,   8'sd0, -8'sd25, -8'sd22 }};
                bias_id = { 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 
                            {8'sd10, 8'sd29,  -8'sd6,  8'sd18,  8'sd37,  8'sd44, -8'sd30, -8'sd32}};
            end
            3'd4:begin
                weight_id = {{56'd0, -8'sd18},
                             {56'd0, 8'sd0},
                             {56'd0, -8'sd9},
                             {56'd0, 8'sd21},
                             {56'd0, -8'sd5},
                             {56'd0, -8'sd17},
                             {56'd0, 8'sd16},
                             {56'd0, -8'sd30}};
                bias_id = { 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, 64'd0, {56'd0, -8'sd15}};
            end
            default: begin
                weight_id = 0;
                bias_id = 0;
            end
        endcase
    end

    always_comb begin
        for(int i=0; i<HEIGHT; i=i+1) begin
            for(int j=0; j<WIDTH; j=j+1) begin
                grid_id[i][j] = INIT_BOARD[i*WIDTH+j];
            end
        end
    end


    // interconnect
    logic sd_sign_en;
    logic sd_ov;
    logic [WIDTH-1:0][DATA_WIDTH-1:0] sd_od;

    logic dnn_ov;
    logic [DATA_WIDTH-1:0] dnn_od;

    logic weight_iv;
    logic bias_iv;
    
    logic data_ov_sa;
    logic [WIDTH-1:0][PSUM_WIDTH-1:0] data_od_sa;

    logic conv_ov_acc, conv_ov_re;
    logic [PSUM_WIDTH-1:0] conv_od_acc;
    logic [DATA_WIDTH-1:0] conv_od_re;
    logic mul_ov_acc, mul_ov_re;
    logic [HEIGHT-1:0][WIDTH-1:0][PSUM_WIDTH-1:0] mul_od_acc;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] mul_od_re;

    initial begin
        clk = 1'd1;
        forever 
            #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/unified_buf.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_unified_buffer); //store everything at the current level and below
        $display("Testing assorted values");

        // initialize
        clk = 1; nrst = 0; grid_iv = 0; 
        load_layer_info = 0; send_sd = 0; tests = 0;
        weight_iv = 0; bias_iv = 0;

        #1;
        #10 nrst = 1;

        #10 grid_iv = 1;
        #10 grid_iv = 0; // LOAD_LAYER_INFO state

        // #10 load_layer_info = 1;
        // #10 load_layer_info = 0; weight_iv = 1; bias_iv = 1;
        // #10 weight_iv = 0;  bias_iv = 0;
        // #10;
        // #10 send_sd = 1;
        // #10 send_sd = 0;
        // #1000;
        
        for(int i=0; i<5; i=i+1) begin
            #10 tests=i;
            #10 load_layer_info = 1;
            #10 load_layer_info = 0; weight_iv = 1; bias_iv = 1;
            #10 weight_iv = 0;  bias_iv = 0;
            #10;
            #10 send_sd = 1;
            #10 send_sd = 0;
            #1000;
        end

        #101;

        $display("Finishing Sim"); //print nice message
        $finish;
    end

    unified_buffer u_unified_buffer(
        .clk             ( clk             ),
        .nrst            ( nrst            ),
        .grid_iv         ( grid_iv         ),
        .grid_id         ( grid_id         ),
        .load_layer_info ( load_layer_info ),
        .ifmap_i_height  ( ifmap_i_height  ),
        .ifmap_i_width   ( ifmap_i_width   ),
        .w_height        ( w_height        ),
        .w_width         ( w_width         ),
        .is_first_layer  ( is_first_layer  ),
        .is_lastLayer    ( is_lastLayer    ),
        .op_sel          ( op_sel          ),
        .flatten         ( flatten         ),
        
        .layer_mul_iv    ( mul_ov_re    ),
        .layer_mul_id    ( mul_od_re    ),
        .layer_conv_iv   ( conv_ov_re   ),
        .layer_conv_id   ( conv_od_re   ),
        
        .send_sd         ( send_sd         ),
        .sd_sign_en      ( sd_sign_en      ),
        .sd_ov           ( sd_ov           ),
        .sd_od           ( sd_od           ),
        
        .dnn_ov          ( dnn_ov          ),
        .dnn_od          ( dnn_od          )
    );

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
        .ifmap_i_w       ( ifmap_i_width       ),
        .weight_iv       ( weight_iv       ),
        .weight_id       ( weight_id       ),
        .data_sign_en    ( sd_sign_en   ),
        .data_iv         ( sd_ov         ),
        .data_id         ( sd_od         ),
        .data_ov         ( data_ov_sa   ),
        .data_od         ( data_od_sa  )
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

        .b_iv            ( bias_iv ),
        .b_id            ( bias_id ),

        .data_iv         ( data_ov_sa         ),
        .data_id         ( data_od_sa         ),

        .conv_ov         ( conv_ov_acc   ),
        .conv_od         ( conv_od_acc ),
        .mul_ov          ( mul_ov_acc    ),
        .mul_od          ( mul_od_acc   )
    );

    reLU#(
        .HEIGHT             ( 8 ),
        .WIDTH              ( 8 ),
        .DATA_WIDTH         ( 8 )
    )u_reLU(
        .clk                ( clk                ),
        .nrst               ( nrst               ),
        .load_layer_info    ( load_layer_info    ),
        .reLU_sel           ( reLU_sel           ),
        .op_sel             ( op_sel             ),
        .mul_b_w            ( mul_b_w            ),
        .mul_b_h            ( mul_b_h            ),

        .conv_b_iv          ( conv_ov_acc          ),
        .conv_b_id          ( conv_od_acc          ),
        .mul_b_iv           ( mul_ov_acc           ),
        .mul_b_id           ( mul_od_acc           ),

        .conv_ov            ( conv_ov_re      ),
        .conv_od            ( conv_od_re     ),
        .mul_ov             ( mul_ov_re       ),
        .mul_od             ( mul_od_re      )
    );

endmodule

`default_nettype wire