`default_nettype none

`define ZERO               5'h00
`define MOVE_TOTAL_NUM	   5'h01
`define MOVE_CURRENT_NUM   5'h02
`define MOVE_CURRENT	   5'h03
`define MOVE_MAX           5'h04
`define MOVE_MAX_VALUE	   5'h05
`define LAYER_NUM_INFO	   5'h06
`define LAYER_TOTAL_NUM	   5'h07
`define LAYER_CURRENT_NUM  5'h08
`define INPUT_HEIGHT	   5'h09
`define INPUT_WIDTH	       5'h0A
`define LAYER_INFO	       5'h0B
`define WEIGHT_HEIGHT	   5'h0C
`define WEIGHT_WIDTH	   5'h0D
`define WEIGHT_START_ADDR  5'h0E
`define BIAS_HEIGHT	       5'h0F
`define BIAS_WIDTH	       5'h10
`define BIAS_START_ADDR	   5'h11
`define IFMAP_HEIGHT       5'h12
`define IFMAP_WIDTH	       5'h13
`define OP	               5'h14
`define WEIGHT_LENGTH      5'h15
`define BIAS_LENGTH	       5'h16
`define DNN_OUT	           5'h17

module tb_instr_decoder;

    parameter WIDTH = 8;
    parameter HEIGHT = 8;
    parameter DATA_WIDTH = 8;
    parameter MOVE_WIDTH = 16;

    logic clk;
    logic nrst;

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
        .instr              ( instr                    ),
        
        .src1_addr          (  src1_addr         ),
        .src2_addr          (  src2_addr         ),
        .immediate          (  immediate         ),
        .rd_addr            (  rd_addr           ),
        
        .alu_funct          (  alu_funct         ),
        .br_funct           (  br_funct          ),
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
    logic move_iv;
    logic [7:0] total_move_id;
    assign total_move_id = 10;

    // for arithmetic operation
    logic signed [31:0] src1_reg_value;
    logic signed [31:0] src2_reg_value; // reg value or constant
    logic wrb_en; // write back enable
    assign wrb_en = wrd_en;
    logic signed [31:0] wrb_value;

    // send weight and bias
    logic weight_ov;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] weight_od;
    logic bias_ov;
    logic [HEIGHT-1:0][WIDTH-1:0][DATA_WIDTH-1:0] bias_od;

    // output layer info
    logic layer_info_ov;
    logic [3:0] weight_height_od;
    logic [3:0] weight_width_od;
    logic [3:0] ifmap_height_od;
    logic [3:0] ifmap_width_od;
    logic [3:0] bias_height_od;
    logic [3:0] bias_width_od;
    logic [2:0] op_od;  // {reLU_sel, op_sel, flatten}
    logic is_first_layer;
    logic is_final_layer;

    logic [7:0] move_current_num;
    logic move_current_iv;
    logic [MOVE_WIDTH-1:0] move_current_id;
    assign move_current_id = 16'h8484;

    // load DNN output
    logic dnn_iv;
    logic [DATA_WIDTH-1:0] dnn_id;
    assign dnn_id = 8'hA7;

    // optimal output send
    logic op_move_ov;
    logic [MOVE_WIDTH-1:0] op_move_od;

    logic next_pc;
    logic load_pc;
    logic [7:0] load_pc_addr;


    register_file#(
        .WIDTH                   ( 8 ),
        .HEIGHT                  ( 8 ),
        .DATA_WIDTH              ( 8 ),
        .MOVE_WIDTH              ( 16 )
    )u_register_file(
        .clk                     ( clk                     ),
        .nrst                    ( nrst                    ),

        .move_iv                 ( move_iv                 ),
        .total_move_id           ( total_move_id           ),
        
        .src1_addr               ( src1_addr               ),
        .src2_addr               ( src2_addr               ),
        .rd_addr                 ( rd_addr                 ),
        .src1_reg_value           (   src1_reg_value  ),
        .src2_reg_value         (   src2_reg_value  ),
        .wrb_en                  ( wrd_en                  ),
        .wrb_value               ( wrb_value               ),
        
        .weight_ov              ( weight_ov         ),
        .weight_od              (  weight_od        ),
        .bias_ov                ( bias_ov           ),
        .bias_od                (  bias_od          ),

        .layer_info_ov          ( layer_info_ov     ),
        .weight_height_od       (  weight_height_od ),
        .weight_width_od        (  weight_width_od  ),
        .ifmap_height_od        ( ifmap_height_od  ),
        .ifmap_width_od         (  ifmap_width_od   ),
        .bias_height_od         ( bias_height_od   ),
        .bias_width_od          (  bias_width_od    ),
        .op_od                  (  op_od            ),
        .is_first_layer         ( is_first_layer    ),
        .is_final_layer         ( is_final_layer    ),

        .move_current_num       ( move_current_num ),
        .move_current_iv         ( move_current_iv         ),
        .move_current_id         ( move_current_id         ),

        .decode_layer            ( decode_layer            ),
        .compute_grid            ( compute_grid            ),
        .decode_layer_info       ( decode_layer_info       ),
        .send_layer_info         ( send_layer_info         ),
        .load_weights            ( load_weights            ),
        .load_biases             ( load_bias             ),
        .send_systolic_data      ( send_systolic_data      ),
        .set_ifmap_o             ( set_ifmap_o             ),
        .send_optimal_move       ( send_optimal_move       ),

        .dnn_iv                  ( dnn_iv                  ),
        .dnn_id                  ( dnn_id                  ),

        .op_move_ov              ( op_move_ov        ),
        .op_move_od              (  op_move_od       ),
        .next_pc                 ( next_pc           ),
        .received_SA_od          ( 1'b0          )
    );

    logic [31:0] src2;
    logic br_out;
    logic signed [31:0] alu_out;
    assign src2 = (src2_sel) ? {20'd0, immediate} : src2_reg_value;

    ALU u_ALU(
        .a            ( src1_reg_value  ),
        .b            ( src2            ),

        .alu_funct    ( alu_funct    ),
        .br_funct     ( br_funct     ),

        .br_out       ( br_out     ),
        .alu_out      ( alu_out     )
    );

    logic [7:0] rom_addr;
    logic [31:0] rom_out;
    assign rom_addr = (wrd_sel) ? alu_out[7:0] : 0;

    distributive_rom#(
        .WORD_WIDTH ( 32 ),
        .ADDR_WIDTH ( 8 ),
        .INIT_FILE  ( "t1_layer.mem" )
    ) Processor_main_mem(
        .addr       ( rom_addr ),
        .rom_out    ( rom_out  )
    );

    assign wrb_value = (wrd_sel) ? rom_out : alu_out;

    assign load_pc_addr = immediate;
    assign load_pc = ((br_out & pc_sel) | jump_sel);

    initial begin
        clk = 1'd1;
        forever 
            #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/id.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_instr_decoder); //store everything at the current level and below
        $display("Testing assorted values");
        instr = 0; nrst = 0;
        move_current_iv = 0; dnn_iv = 0; move_iv = 1'b0;


        #1; nrst = 1;
        #10
        #10 instr = {3'b000, 6'b110_000, `ZERO, 12'h000, {1'b0, `LAYER_NUM_INFO}};
        $display("%h", instr);
        #10 instr = {9'b111_111_111, 13'd0, 4'b0000, 6'd0};
        $display("%h", instr);

        #10 instr = {3'd0, 6'd0, `INPUT_HEIGHT, `ZERO, 7'd0, {1'b0,`IFMAP_HEIGHT}};$display("%h", instr);
        #10 instr = {3'd0, 6'd0, `INPUT_WIDTH, `ZERO, 7'd0, {1'b0,`IFMAP_WIDTH}};$display("%h", instr);

        #10 instr = {3'b000, 6'b110_000, `ZERO, 12'h001, {1'b0, `LAYER_INFO}};$display("%h", instr);
        #10 instr = {9'b111_111_111, 13'd0, 4'b0010, 6'd0};$display("%h", instr);
        #10 instr = {9'b111_111_111, 13'd0, 4'b0011, 6'd0};$display("%h", instr);
        #10 instr = {9'b111_111_111, 13'd0, 4'b0100, 6'd0};$display("%h", instr);
        
        #10 instr = {3'd1, 6'd0, `WEIGHT_HEIGHT, `WEIGHT_WIDTH, 7'd0, {1'b0,`WEIGHT_LENGTH}};$display("%h", instr);
        #10 instr = {3'd1, 6'd0, `BIAS_HEIGHT, `BIAS_WIDTH, 7'd0, {1'b0,`BIAS_LENGTH}};$display("%h", instr);
        
        #10 instr = {9'b111_111_111, 13'd0, 4'b0101, 6'd0}; $display("%h", instr);// load weight
        #110 instr = {9'b111_111_111, 13'd0, 4'b0110, 6'd0};$display("%h", instr); // load bias
        #30 instr = 0;$display("%h", instr);
        #200;

        $display("Finishing Sim"); //print nice message
        $finish;
    end

endmodule

`default_nettype wire