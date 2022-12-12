# from assembly program to machine language
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
CHECK_CURRENT_MOVE = 0
CHECK_CURRENT_LAYER = 0

ARITHMETIC = 0
BRANCH = 1
JUMP = 2
LOAD = 3
SPECIAL = 4

DECODE_LAYER = 0
COMPUTE_GRID = 1
DECODE_LAYER_INFO = 2
COMPUTE_IFMAP = 3
SEND_LAYER_INFO = 4
LOAD_WEIGHT = 5
LOAD_BIAS = 6
SEND_SYSTOLIC_DATA = 7
SET_IFMAP_O = 8
SEND_OPTIMAL_MOVE = 9

SRC2_SEL_REG = 0
SRC2_SEL_IMM = 1

def assembly2mach(instr_type, src1_addr, src2_sel, src2_addr, immediate, rd_group, rd_addr, label, funct, special_funct):
    instr = int('00000000', 16)
    if(instr_type==ARITHMETIC):
        print('ARITHMETIC, src2: ', src2_sel)
        if(src2_sel==SRC2_SEL_REG):
            instr = instr | (funct << 29)
            # rest of the 6 bit are all zero
            instr = instr | (src1_addr << 18)
            instr = instr | (src2_addr << 13)
            instr = instr | (rd_addr)
        else:
            instr = instr | (funct << 29)
            instr = instr | (1 << 28)
            instr = instr | (src1_addr << 18)
            instr = instr | (immediate << 6)
            instr = instr | (rd_addr)
    elif(instr_type==BRANCH):
        print('BRANCH')
        instr = instr | (funct << 29)
        instr = instr | (1 << 26)
        instr = instr | (src1_addr << 18)
        instr = instr | (src2_addr << 13)
        instr = instr | label
    elif(instr_type==JUMP):
        print('JUMP')
        instr = instr | (0b111000111 << 23)
        instr = instr | label
    elif(instr_type==LOAD):
        print('LOAD, src2: ', src2_sel)
        instr = instr | (0b000 << 29)
        instr = instr | (src2_sel << 27)
        instr = instr | (0b100 << 24)
        instr = instr | (rd_group << 23)
        instr = instr | (src1_addr << 18)
        instr = instr | (immediate << 6)
        instr = instr | (rd_addr)
    else:
        print('SPECIAL FUNCTION')
        instr = instr | (0b111111111 << 23)
        instr = instr | (special_funct << 6)

    return instr

# demo check
# instr0 = assembly2mach(instr_type=BRANCH, src1_addr=MOVE_TOTAL_NUM, 
#                             src2_sel=SRC2_SEL_REG, src2_addr=ZERO, immediate=0, 
#                             rd_group=0, rd_addr=0, 
#                             label=CHECK_RECEIVE_MOVE, funct=EQ, special_funct=0)
# print(instr0)