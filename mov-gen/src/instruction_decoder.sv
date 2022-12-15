`default_nettype none

`define DECODE_LAYER               4'd0 
`define COMPUTE_GRID	           4'd1
`define DECODE_LAYER_INFO          4'd2
`define COMPUTE_IFMAP	           4'd3
`define SEND_LAYER_INFO	           4'd4
`define LOAD_WEIGHT	               4'd5
`define LOAD_BIAS	               4'd6
`define SEND_SYSTOLIC_DATA	       4'd7
`define SET_IFMAP_O	               4'd8
`define SEND_OPTIMAL_MOVE	       4'd9

// combinational logic 
module instruction_decoder(
    input wire [31:0] instr,

    output logic [7:0] src1_addr,
    output logic [7:0] src2_addr,
    output logic [11:0] immediate, 
    output logic [7:0] rd_addr, // {rd_group, rd_addr[5:0]}

    output logic [2:0] alu_funct,
    output logic [2:0] br_funct,

    output logic pc_sel, // whether increase or branch operation
    output logic jump_sel,
    output logic src2_sel, 
    output logic wrd_sel, // value load from alu or data_mem
    output logic wrd_en, // write back enable

    output logic decode_layer,
    output logic compute_grid,
    output logic decode_layer_info,
    output logic compute_ifmap,
    output logic send_layer_info,
    output logic load_weights,
    output logic load_bias,
    output logic send_systolic_data,
    output logic set_ifmap_o,
    output logic send_optimal_move
);

    localparam ARITHMETIC = 0;
    localparam BRANCH = 1;
    localparam JUMP = 2;
    localparam LOAD = 3;
    localparam SPECIAL = 4;

    // FURTHER CHECK
    logic [2:0] instr_type;
    always_comb begin
        case(instr[27:25])
            3'b000: instr_type = ARITHMETIC;
            3'b010: instr_type = BRANCH;
            3'b001: instr_type = JUMP;
            3'b100: instr_type = LOAD;
            3'b111: instr_type = SPECIAL;
            default: instr_type = ARITHMETIC;
        endcase
    end

    assign {src2_sel, wrd_sel} = instr[28:27];

    always_comb begin
        if(instr_type==SPECIAL) {pc_sel, jump_sel} = 2'b0;
        else {pc_sel, jump_sel} = instr[26:25];
    end

    always_comb begin
        case(instr_type)
            ARITHMETIC: begin
                alu_funct = instr[31:29]; //selected
                br_funct  = 3'b111;     

                src1_addr = {2'b00, 1'b0, instr[22:18]};
                src2_addr = (instr[28]==0) ?  {2'b00, 1'b0, instr[17:13]} : 8'h00;
                immediate = (instr[28]==1) ? instr[17:6] : 0;
                rd_addr   = {instr[24:23], instr[5:0]};
                wrd_en    = 1;
            end
            BRANCH: begin
                alu_funct = 3'b111; 
                br_funct  = instr[31:29]; //selected     

                src1_addr = {2'b00, 1'b0, instr[22:18]};
                src2_addr = {2'b00, 1'b0, instr[17:13]};
                immediate = instr[11:0];
                rd_addr   = 8'h00;
                wrd_en    = 0;
            end
            JUMP: begin
                alu_funct = 3'b111; 
                br_funct  = 3'b111;     

                src1_addr = 8'h00;
                src2_addr = 8'h00;
                immediate = instr[11:0];
                rd_addr   = 8'h00;
                wrd_en    = 0;
            end
            LOAD: begin
                alu_funct = instr[31:29]; //selected
                br_funct  = 3'b111;     

                src1_addr = {2'b00, 1'b0, instr[22:18]};
                src2_addr = (src2_sel==0) ? {2'b00, 1'b0, instr[17:13]} : 0;
                immediate = (instr[28]==1) ? instr[17:6] : 0;
                rd_addr   = {instr[24:23], instr[5:0]};
                wrd_en    = 1;
            end
            default: begin
                alu_funct = 3'b111; 
                br_funct  = 3'b111;     

                src1_addr = 8'h00;
                src2_addr = 8'h00;
                immediate = 0;
                rd_addr   = 8'h00;
                wrd_en    = 0;
            end
        endcase
    end

    always_comb begin
        if(instr_type==SPECIAL) begin
            decode_layer = (instr[9:6]==`DECODE_LAYER) ? 1 : 0;
            compute_grid  = (instr[9:6]==`COMPUTE_GRID) ? 1 : 0;
            decode_layer_info  = (instr[9:6]==`DECODE_LAYER_INFO) ? 1 : 0;
            compute_ifmap = (instr[9:6]==`COMPUTE_IFMAP) ? 1 : 0;
            send_layer_info  = (instr[9:6]==`SEND_LAYER_INFO) ? 1 : 0;
            load_weights  = (instr[9:6]==`LOAD_WEIGHT) ? 1 : 0;
            load_bias  = (instr[9:6]==`LOAD_BIAS) ? 1 : 0;
            send_systolic_data  = (instr[9:6]==`SEND_SYSTOLIC_DATA) ? 1 : 0;
            set_ifmap_o  = (instr[9:6]==`SET_IFMAP_O) ? 1 : 0;
            send_optimal_move = (instr[9:6]==`SEND_OPTIMAL_MOVE) ? 1 : 0;
        end
        else begin
            decode_layer = 0;
            compute_grid  = 0;
            decode_layer_info  = 0;
            compute_ifmap = 0;
            send_layer_info  = 0;
            load_weights  = 0;
            load_bias  = 0;
            send_systolic_data  = 0;
            set_ifmap_o  = 0;
            send_optimal_move = 0;
        end
    end

endmodule

`default_nettype wire