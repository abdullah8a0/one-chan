`default_nettype none

module TPU #(
    parameter WIDTH = 8,
    parameter HEIGHT = 8,

    parameter DATA_WIDTH = 8,
    parameter PC_ADDR_WIDTH = 12,
    
    parameter MOVE_WIDTH = 16,
    parameter MAX_MOVES = 220,

    parameter GRID_HEADER = 8'b11_01_01_01,
    parameter MOVE_HEADER = 8'b11_10_10_10,

    parameter INSTR_FILE = "",
    parameter MAIN_MEM_FILE = ""
)(
    input wire clk,
    input wire nrst,

    //spi
    input wire spi_iv,
    input wire [DATA_WIDTH-1:0] spi_id,

    // send optimal move by SPI
    output logic spi_ov,
    output logic spi_od
);

    logic next_pc;
    logic load_pc;
    logic [PC_ADDR_WIDTH-1:0] load_pc_addr; //related to immediate

    program_counter#(
        .INSTR_WIDTH  ( 32 ),
        .ADDR_WIDTH   ( 12 ),
        .INIT_FILE    ( INSTR_FILE )
    )u_program_counter(
        .clk          ( clk          ),
        .nrst         ( nrst         ),
        .next_pc      ( next_pc      ),
        .load_pc      ( load_pc      ),
        .load_pc_addr ( load_pc_addr ),
        .instr        ( instr )
    );

    logic [31:0] instr;

    logic [7:0] src1_addr;
    logic [7:0] src2_addr;
    logic [11:0] immediate;
    logic [7:0] rd_addr; // {rd_group, rd_addr[5:0]}

    logic [2:0] alu_funct;
    logic [2:0] br_funct;

    logic pc_sel; // whether increase or branch operation
    logic jump_sel;
    logic src2_sel; 
    logic wrd_sel; // value load from alu or data_mem
    logic wrd_en; // write back enable

    logic decode_layer;
    logic compute_grid;
    logic decode_layer_info;
    logic compute_ifmap;
    logic send_layer_info;
    logic load_weights;
    logic load_bias;
    logic send_systolic_data;
    logic set_ifmap_o;
    logic send_optimal_move;

    instruction_decoder u_instruction_decoder(
        .instr              ( instr              ),
        
        .src1_addr          ( src1_addr          ),
        .src2_addr          ( src2_addr          ),
        .immediate          ( immediate          ),
        .rd_addr            ( rd_addr            ),
        .alu_funct          ( alu_funct          ),
        .br_funct           ( br_funct           ),
        
        .pc_sel             ( pc_sel             ),
        .jump_sel           ( jump_sel           ),
        .src2_sel           ( src2_sel           ),
        .wrd_sel            ( wrd_sel            ),
        .wrd_en             ( wrd_en             ),
        
        .decode_layer       ( decode_layer       ),
        .compute_grid       ( compute_grid       ),
        .decode_layer_info  ( decode_layer_info  ),
        .compute_ifmap      ( compute_ifmap      ),
        .send_layer_info    ( send_layer_info    ),
        .load_weights       ( load_weights       ),
        .load_bias          ( load_bias          ),
        .send_systolic_data ( send_systolic_data ),
        .set_ifmap_o        ( set_ifmap_o        ),
        .send_optimal_move  ( send_optimal_move  )
    );

    
    // load total number of moves, indicating the starting of the program, MMIO
    logic move_w_v;
    logic [7:0] total_move_w_d;

    logic signed [31:0] src1_reg_value;
    logic signed [31:0] src2_reg_value; // reg value or constant
    logic signed [31:0] wrb_value;

    // send weight and bias, register map to systolic array
    logic weight_rm2sa_v;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_rm2sa_d; 
    logic bias_rm2sa_v;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] bias_rm2sa_d;

    // layer info
    logic layer_info_w_v;
    logic [3:0] weight_height_w_d;
    logic [3:0] weight_width_w_d;
    logic [3:0] ifmap_height_w_d;
    logic [3:0] ifmap_width_w_d;
    logic [3:0] bias_height_w_d;
    logic [3:0] bias_width_w_d;
    logic [2:0] op_w_d;  // {reLU_sel, op_sel, flatten}
    logic is_first_layer;
    logic is_final_layer;

    
    // optimal output send
    logic max_dnn_ov;
    logic [DATA_WIDTH-1:0]  max_dnn_od;

    // pc control
    logic received_SA_od;
    logic send_sd;

    register_file#(
        .WIDTH                   ( 8 ),
        .HEIGHT                  ( 8 ),
        .DATA_WIDTH              ( 8 ),
        .MOVE_WIDTH              ( 16 )
    )u_register_file(
        .clk                     ( clk                     ),
        .nrst                    ( nrst                    ),
        
        .move_iv                 ( moves_ov_gd                 ),
        .total_move_id           ( total_move_od_gd           ),
        
        .src1_addr               ( src1_addr               ),
        .src2_addr               ( src2_addr               ),
        .rd_addr                 ( rd_addr                 ),
        .src1_reg_value          ( src1_reg_value          ),
        .src2_reg_value          ( src2_reg_value           ),
        .wrb_en                  ( wrd_en                  ),
        .wrb_value               ( wrb_value               ),
        
        .weight_ov               ( weight_rm2sa_v         ),
        .weight_od               ( weight_rm2sa_d        ),
        .bias_ov                 ( bias_rm2sa_v           ),
        .bias_od                 ( bias_rm2sa_d          ),
        
        .layer_info_ov           ( layer_info_w_v     ),
        .weight_height_od        ( weight_height_w_d ),
        .weight_width_od         ( weight_width_w_d  ),
        .ifmap_height_od         ( ifmap_height_w_d  ),
        .ifmap_width_od          ( ifmap_width_w_d   ),
        .bias_height_od          ( bias_height_w_d   ),
        .bias_width_od           ( bias_width_w_d    ),
        .op_od                   ( op_w_d            ),
        .is_first_layer          ( is_first_layer    ),
        .is_final_layer          ( is_final_layer    ),

        .move_current_num        ( move_num_rf ),
        .move_current_iv         ( grid_ov_gd ),
        .move_current_id         ( current_move_gd ),
        
        .decode_layer            ( decode_layer            ),
        .compute_grid            ( compute_grid            ),
        .decode_layer_info       ( decode_layer_info       ),
        .compute_ifmap           ( compute_ifmap ),
        .send_layer_info         ( send_layer_info         ),
        .load_weights            ( load_weights            ),
        .load_biases             ( load_bias             ),
        .send_systolic_data      ( send_systolic_data      ),
        .set_ifmap_o             ( set_ifmap_o        ),
        .send_optimal_move       ( send_optimal_move  ),
        
        .send_sd                 ( send_sd ),

        .dnn_iv                  ( dnn_ov_u_buf      ),
        .dnn_id                  ( dnn_od_u_buf      ),
        .op_move_ov              (  max_dnn_ov        ),
        .op_move_od              ( max_dnn_od       ),
        
        .next_pc                 ( next_pc           ),
        .received_SA_od          ( received_SA_od          )
    );


    logic [31:0] src2_value;
    logic br_out;
    logic signed [31:0] alu_out;
    
    // src2 mux
    assign src2_value = (src2_sel) ? immediate : src2_reg_value;

    ALU u_ALU(
        .a            ( src1_reg_value ),
        .b            ( src2_value     ),
        .alu_funct    ( alu_funct      ),
        .br_funct     ( br_funct       ),
        .br_out       ( br_out         ),
        .alu_out      ( alu_out        )
    );

    logic [9:0] rom_addr;
    logic [31:0] rom_out;
    assign rom_addr = (wrd_sel) ? alu_out[9:0] : 0;

    distributive_rom#(
        .WORD_WIDTH ( 32 ),
        .ADDR_WIDTH ( 10 ),
        .INIT_FILE  ( MAIN_MEM_FILE )
    ) Processor_main_mem(
        .addr       ( rom_addr ),
        .rom_out    ( rom_out  )
    );

    assign wrb_value = (wrd_sel) ? rom_out : alu_out;

    assign load_pc_addr = immediate;
    assign load_pc = ((br_out & pc_sel) | jump_sel);

    logic moves_ov_gd;
    logic [7:0] total_move_od_gd;
    logic [7:0] move_num_rf;
    logic grid_ov_gd;
    logic [MOVE_WIDTH-1:0] current_move_gd;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] grid_od_gd;

    grid_decoder#(
        .WIDTH                ( 8 ),
        .HEIGHT               ( 8 ),
        .MOVE_WIDTH           ( MOVE_WIDTH ),
        .DATA_WIDTH           ( 8 ),
        .GRID_HEADER          ( GRID_HEADER ),
        .MOVE_HEADER          ( MOVE_HEADER )
    )u_grid_decoder(
        .clk                  ( clk                  ),
        .nrst                 ( nrst                 ),
        .spi_iv               ( spi_iv               ),
        .spi_id               ( spi_id               ),
       
        .moves_ov             ( moves_ov_gd             ),
        .total_move_od        ( total_move_od_gd        ),

        .compute_grid         ( compute_grid         ),
        .move_num             ( move_num_rf             ),
        
        .grid_ov              ( grid_ov_gd              ),
        .current_move         ( current_move_gd         ),
        .grid_od              ( grid_od_gd              )
    );


    logic layer_mul_v_sa;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] layer_mul_d_sa;
    logic layer_conv_v_sa;
    logic [DATA_WIDTH-1:0] layer_conv_d_sa;

    logic sd_sign_en;
    logic sd_ov_u_buf;
    logic [WIDTH-1:0][DATA_WIDTH-1:0] sd_od_u_buf;

    logic dnn_ov_u_buf;
    logic [DATA_WIDTH-1:0] dnn_od_u_buf;

    unified_buffer#(
        .WIDTH               ( 8 ),
        .HEIGHT              ( 8 ),
        .DATA_WIDTH          ( 8 ),
        .OUTPUT_HEIGHT       ( 1 ),
        .OUTPUT_WIDTH        ( 1 )
    )u_unified_buffer(
        .clk                 ( clk                 ),
        .nrst                ( nrst                ),

        .grid_iv             ( grid_ov_gd             ),
        .grid_id             ( grid_od_gd             ),

        .load_layer_info     ( layer_info_w_v     ),
        .ifmap_i_height      ( ifmap_height_w_d      ),
        .ifmap_i_width       ( ifmap_width_w_d       ),
        .w_height            ( weight_height_w_d        ),
        .w_width             ( weight_width_w_d        ),
        .is_first_layer      ( is_first_layer ),
        .is_lastLayer        ( is_final_layer ),
        .op_sel              ( op_w_d[1]        ),
        .flatten             ( op_w_d[0]         ),

        .layer_mul_iv        ( layer_mul_v_sa        ),
        .layer_mul_id        ( layer_mul_d_sa        ),
        .layer_conv_iv       ( layer_conv_v_sa       ),
        .layer_conv_id       ( layer_conv_d_sa       ),
        .receive_layer       ( received_SA_od      ),

        .send_sd             ( send_sd   ),
        .sd_sign_en          ( sd_sign_en    ),
        .sd_ov               ( sd_ov_u_buf         ),
        .sd_od               ( sd_od_u_buf        ),
        .dnn_ov              ( dnn_ov_u_buf        ),
        .dnn_od              ( dnn_od_u_buf      )
    );



    SA_top#(
        .WIDTH           ( 8 ),
        .HEIGHT          ( 8 ),
        .DATA_WIDTH      ( 8 )
    )u_SA_top(
        .clk             ( clk             ),
        .nrst            ( nrst            ),

        .load_layer_info ( layer_info_w_v ),
        .w_width         ( weight_width_w_d         ),
        .w_height        ( weight_height_w_d        ),
        .mul_b_w         ( bias_width_w_d         ),
        .mul_b_h         ( bias_height_w_d         ),
        .reLU_sel        ( op_w_d[2]        ),
        .op_sel          ( op_w_d[1]         ),
        .ifmap_i_w       ( ifmap_width_w_d       ),

        .weight_iv       ( weight_rm2sa_v       ),
        .weight_id       ( weight_rm2sa_d       ),
        .b_iv            ( bias_rm2sa_v         ),
        .b_id            ( bias_rm2sa_d        ),

        .data_sign_en    ( sd_sign_en    ),
        .data_iv         ( sd_ov_u_buf         ),
        .data_id         ( sd_od_u_buf         ),

        .conv_ov         ( layer_conv_v_sa         ),
        .conv_od         ( layer_conv_d_sa         ),
        .mul_ov          ( layer_mul_v_sa          ),
        .mul_od          ( layer_mul_d_sa          )
    );
    
    assign spi_ov = max_dnn_ov;
    assign spi_od = max_dnn_od;

endmodule

`default_nettype wire