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

    logic clk;

    

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
        instr = 0;
        #10 instr = {3'd1, 6'd0, `WEIGHT_HEIGHT, `WEIGHT_WIDTH, 7'd0, {1'b0,`WEIGHT_LENGTH}};
        #10 instr = {3'd0, 6'b100_000, `ZERO, 12'd1,{1'b0,`LAYER_CURRENT_NUM} };
        #10 instr = {3'b011, 6'b001_000, `LAYER_CURRENT_NUM, `LAYER_TOTAL_NUM, 1'b0, 12'd11};
        #10 instr = {3'b111, 6'b000_111, 11'b0, 12'd201};
        #10 instr = {3'd0, 6'b110_000, `ZERO, 12'h0AB, {1'b0, `LAYER_INFO}};

        #10 instr = {9'b111_111_111, 13'd0, 4'b0110, 6'd0};
        #10 instr = {9'b111_111_111, 13'd0, 4'b0111, 6'd0};
        #10 instr = {9'b111_111_111, 13'd0, 4'b1000, 6'd0};
        #10 instr = {9'b111_111_111, 13'd0, 4'b0010, 6'd0};

        #200;

        $display("Finishing Sim"); //print nice message
        $finish;
    end

endmodule

`default_nettype wire