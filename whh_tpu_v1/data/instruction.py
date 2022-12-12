from instr_assembly2mac import *
from data_mapping import *
import numpy as np

ZERO               = 0x00
MOVE_TOTAL_NUM	   = 0x01
MOVE_CURRENT_NUM   = 0x02
MOVE_CURRENT	   = 0x03
MOVE_MAX           = 0x04
MOVE_MAX_VALUE	   = 0x05
LAYER_NUM_INFO	   = 0x06
LAYER_TOTAL_NUM	   = 0x07
LAYER_CURRENT_NUM  = 0x08
INPUT_HEIGHT	   = 0x09
INPUT_WIDTH	       = 0x0A
LAYER_INFO	       = 0x0B
WEIGHT_HEIGHT	   = 0x0C
WEIGHT_WIDTH	   = 0x0D
WEIGHT_START_ADDR  = 0x0E
BIAS_HEIGHT	       = 0x0F
BIAS_WIDTH	       = 0x10
BIAS_START_ADDR	   = 0x11
IFMAP_HEIGHT       = 0x12
IFMAP_WIDTH	       = 0x13
OP	               = 0x14
WEIGHT_LENGTH      = 0x15
BIAS_LENGTH	       = 0x16
DNN_OUT	           = 0x17

ADD  = 0b000
MUL  = 0b001 
SHL  = 0b010  
SHR  = 0b011
BAND = 0b100  
BXOR = 0b101 
BOR  = 0b110

EQ   = 0b000 
NE   = 0b001 
GE   = 0b010 
LE   = 0b011 
GT   = 0b100
LT   = 0b101
NEG  = 0b110 


# instruction label 
CHECK_RECEIVE_MOVE = 0

CHECK_CURRENT_MOVE = 5 
FINISH_CURRENT_MOVE = 27

CHECK_DNN_COMPUTE = 10
FINISH_DNN_COMPUTE = 23

FINISH_COMPARE_DNN_OUT = 25

# info mapping
LAYER_INFO_ADDR = 0x000



np.set_printoptions(formatter={'int':hex})
instr = []

# while(move_total_num==0) {}
print('instruction number: ', len(instr), ' while(move_total_num==0) {}')
instr.append(assembly2mach(instr_type=BRANCH, src1_addr=MOVE_TOTAL_NUM, 
                            src2_sel=SRC2_SEL_REG, src2_addr=ZERO, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=CHECK_RECEIVE_MOVE, funct=EQ, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# move_current_num = 0;
print('instruction number: ', len(instr), ' move_current_num = 0;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=ZERO, 
                            src2_sel=SRC2_SEL_IMM, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=MOVE_CURRENT_NUM, 
                            label=0, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# move_max_value = -128;
print('instruction number: ', len(instr), ' move_max_value = -128;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=ZERO, 
                            src2_sel=SRC2_SEL_IMM, src2_addr=0, immediate=0x80, 
                            rd_group=0, rd_addr=MOVE_MAX_VALUE, 
                            label=0, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# layer_num_info = load(LAYER_INFO_BASE_ADDR);
print('instruction number: ', len(instr), ' layer_num_info = load(LAYER_INFO_BASE_ADDR);')
instr.append(assembly2mach(instr_type=LOAD, src1_addr=ZERO, 
                            src2_sel=SRC2_SEL_IMM, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=LAYER_NUM_INFO, 
                            label=0, funct=0, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# layer_total_num, input_height, input_width = decode_layer(layer_num_info)
print('instruction number: ', len(instr), ' layer_total_num, input_height, input_width = decode_layer(layer_num_info)')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=DECODE_LAYER))
print(hex(instr[len(instr)-1]))
print('\n')

# while(move_current_num < move_total_num)
# if the current move is not less than total moves, then break the loop
print('CHECK CURRENT MOVE at instr addr: ', len(instr))
print('instruction number: ', len(instr), ' while(move_current_num < move_total_num)')
instr.append(assembly2mach(instr_type=BRANCH, src1_addr=MOVE_CURRENT_NUM, 
                            src2_sel=SRC2_SEL_REG, src2_addr=MOVE_TOTAL_NUM, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=FINISH_CURRENT_MOVE, funct=GE, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# move_current = compute_grid(move_current_num); 
print('instruction number: ', len(instr), ' move_current = compute_grid(move_current_num); ')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=COMPUTE_GRID))
print(hex(instr[len(instr)-1]))
print('\n')


# ifmap_height = input_height;
print('instruction number: ', len(instr), ' ifmap_height = input_height;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=INPUT_HEIGHT, 
                            src2_sel=SRC2_SEL_REG, src2_addr=ZERO, immediate=0, 
                            rd_group=0, rd_addr=IFMAP_HEIGHT, 
                            label=0, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# ifmap_width = input_width;
print('instruction number: ', len(instr), ' ifmap_width = input_width;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=INPUT_WIDTH, 
                            src2_sel=SRC2_SEL_REG, src2_addr=ZERO, immediate=0, 
                            rd_group=0, rd_addr=IFMAP_WIDTH, 
                            label=0, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# layer_current_num = 1; 
print('instruction number: ', len(instr), ' layer_current_num = 1; ')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=ZERO, 
                            src2_sel=SRC2_SEL_IMM, src2_addr=0, immediate=1, 
                            rd_group=0, rd_addr=LAYER_CURRENT_NUM, 
                            label=0, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# while(layer_current_num <= layer_total_num){
# if layer_current_num is larger than layer_total_num
print('CHECK DNN COMPUTE at instr addr: ', len(instr))
print('instruction number: ', len(instr), ' while(layer_current_num <= layer_total_num){')
instr.append(assembly2mach(instr_type=BRANCH, src1_addr=LAYER_CURRENT_NUM, 
                            src2_sel=SRC2_SEL_REG, src2_addr=LAYER_TOTAL_NUM, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=FINISH_DNN_COMPUTE, funct=GT, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# layer_info = load(LAYER_INFO_BASE_ADDR+layer_current_num); 
print('instruction number: ', len(instr), ' layer_info = load(LAYER_INFO_BASE_ADDR+layer_current_num); ')
instr.append(assembly2mach(instr_type=LOAD, src1_addr=LAYER_CURRENT_NUM, 
                            src2_sel=SRC2_SEL_IMM, src2_addr=0, immediate=LAYER_INFO_ADDR, 
                            rd_group=0, rd_addr=LAYER_INFO, 
                            label=0, funct=0, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# weight_height, weight_width, weight_start_addr, bias_height, bias_width, bias_start_addr, op = decode_layer_compute_info(layer_info); 
print('instruction number: ', len(instr), ' weight_height, weight_width, weight_start_addr, bias_height, bias_width, bias_start_addr, op = decode_layer_compute_info(layer_info);')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=DECODE_LAYER_INFO))
print(hex(instr[len(instr)-1]))
print('\n')

# ifmap_height, ifmap_width = compute_ifmap(op, ifmap_height, ifmap_width);
print('instruction number: ', len(instr), ' ifmap_height, ifmap_width = compute_ifmap(op, ifmap_height, ifmap_width);')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=COMPUTE_IFMAP))
print(hex(instr[len(instr)-1]))
print('\n')

# send_layer_info(weight_height, weight_width, bias_height, bias_width, ifmap_width);
print('instruction number: ', len(instr), ' send_layer_info(weight_height, weight_width, bias_height, bias_width, ifmap_width);')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=SEND_LAYER_INFO))
print(hex(instr[len(instr)-1]))
print('\n')

# weight_length = weight_height * weight_width;
print('instruction number: ', len(instr), ' weight_length = weight_height * weight_width;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=WEIGHT_HEIGHT, 
                            src2_sel=SRC2_SEL_REG, src2_addr=WEIGHT_WIDTH, immediate=0, 
                            rd_group=0, rd_addr=WEIGHT_LENGTH, 
                            label=0, funct=MUL, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# bias_length = bias_height * bias_width;
print('multiply, verify with vivado simulation result!!!\n')
print('instruction number: ', len(instr), ' bias_length = bias_height * bias_width;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=BIAS_HEIGHT, 
                            src2_sel=SRC2_SEL_REG, src2_addr=BIAS_WIDTH, immediate=0, 
                            rd_group=0, rd_addr=BIAS_LENGTH, 
                            label=0, funct=MUL, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# load_weight(weight_start_addr, weight_length);
print('instruction number: ', len(instr), ' load_weight(weight_start_addr, weight_length);')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=LOAD_WEIGHT))
print(hex(instr[len(instr)-1]))
print('\n')

# load_bias(bias_start_addr, bias_length);
print('instruction number: ', len(instr), ' load_bias(bias_start_addr, bias_length);')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=LOAD_BIAS))
print(hex(instr[len(instr)-1]))
print('\n')

# send_systolic_data();
print('instruction number: ', len(instr), ' send_systolic_data();')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=SEND_SYSTOLIC_DATA))
print(hex(instr[len(instr)-1]))
print('\n')

# ifmap_height, ifmap_width = set_ifmap_o(ifmap_height, ifmap_width, weight_height, weight_width);
print('instruction number: ', len(instr), ' ifmap_height, ifmap_width = set_ifmap_o(ifmap_height, ifmap_width, weight_height, weight_width);')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=SET_IFMAP_O))
print(hex(instr[len(instr)-1]))
print('\n')

# layer_current_num++;
print('instruction number: ', len(instr), ' layer_current_num++;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=LAYER_CURRENT_NUM, 
                            src2_sel=SRC2_SEL_IMM, src2_addr=0, immediate=1, 
                            rd_group=0, rd_addr=LAYER_CURRENT_NUM, 
                            label=0, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# jump back to check layer
print('End of layer_current evaluation at instr addr: ', len(instr), ' jump back to judgement sentence')
print('instruction number: ', len(instr), ' jump back to check layer')
instr.append(assembly2mach(instr_type=JUMP, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=CHECK_DNN_COMPUTE, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# FINISH COMPUTE DNN OUTPUT !!!
print('FINISH DNN COMPUTE at instr addr: ', len(instr))
# if(dnn_out > move_max_value){
print('instruction number: ', len(instr), ' if(dnn_out > move_max_value){')
instr.append(assembly2mach(instr_type=BRANCH, src1_addr=DNN_OUT, 
                            src2_sel=SRC2_SEL_REG, src2_addr=MOVE_MAX_VALUE, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=FINISH_COMPARE_DNN_OUT, funct=LE, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# move_max_value = dnn_out;
print('instruction number: ', len(instr), ' move_max_value = dnn_out;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=DNN_OUT, 
                            src2_sel=SRC2_SEL_REG, src2_addr=ZERO, immediate=0, 
                            rd_group=0, rd_addr=MOVE_MAX_VALUE, 
                            label=0, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# FINISH DNN COMPARISON
print('FINISH DNN OUTPUT COMPARISON at instr addr: ', len(instr))

# move_current_num++;
print('instruction number: ', len(instr), ' move_current_num++;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=MOVE_CURRENT_NUM, 
                            src2_sel=SRC2_SEL_IMM, src2_addr=0, immediate=1, 
                            rd_group=0, rd_addr=MOVE_CURRENT_NUM, 
                            label=0, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# jump back to move judgement
print('instruction number: ', len(instr), ' jump back to move judgement')
instr.append(assembly2mach(instr_type=JUMP, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=CHECK_CURRENT_MOVE, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# FINISH MOVE EVALUATION
print('FINISH MOVE EVALUATION at instr addr: ', len(instr))

# move_total_num = 0;
print('instruction number: ', len(instr), ' move_total_num = 0;')
instr.append(assembly2mach(instr_type=ARITHMETIC, src1_addr=ZERO, 
                            src2_sel=SRC2_SEL_IMM, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=MOVE_TOTAL_NUM, 
                            label=0, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')

# send_optimal_move();
print('instruction number: ', len(instr), ' send_optimal_move();')
instr.append(assembly2mach(instr_type=SPECIAL, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=0, funct=0, special_funct=SEND_OPTIMAL_MOVE))
print(hex(instr[len(instr)-1]))
print('\n')


# jump back to CHECK RECEIVE MOVE
print('instruction number: ', len(instr), ' jump back to CHECK RECEIVE MOVE')
instr.append(assembly2mach(instr_type=JUMP, src1_addr=0, 
                            src2_sel=0, src2_addr=0, immediate=0, 
                            rd_group=0, rd_addr=0, 
                            label=CHECK_RECEIVE_MOVE, funct=ADD, special_funct=0))
print(hex(instr[len(instr)-1]))
print('\n')