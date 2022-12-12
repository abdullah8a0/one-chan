from layer_mac import *
import numpy as np



layer_num = 5
input_height = 8
input_width = 8

weight_height = [3,3,1,8,8]
weight_width = [3,3,3,8,1]
weight_length = [weight_height[i]*weight_width[i] for i in range(len(weight_height))]
print(weight_length)
weight_start_addr = []

bias_height = [1,1,1,1,1]
bias_width = [1,1,1,8,1]
bias_length = [bias_height[i]*bias_width[i] for i in range(len(bias_height))]
bias_start_addr = []

reLU_sel = [0,0,0,1,0]
op_sel = [0,0,0,1,1]
flatten = [0,0,0,1,0]

start_addr_w = 0x00
start_addr_b = 0x00
# print(hex(start_addr_w))
# print(hex(start_addr_b))
for i in range(0, layer_num):
    weight_start_addr.append(start_addr_w) # [weight_start_addr, start_addr_w]
    bias_start_addr.append(start_addr_b)
    
    start_addr_w = start_addr_w + (weight_height[i]*weight_width[i])
    start_addr_b = start_addr_b + (bias_height[i]*bias_width[i])

print(weight_start_addr)
print(bias_start_addr)


depth = 0x300
mem = []
mem.append(layer_num_info(input_height=input_height, input_width=input_width, layer_total_num=layer_num))
for i in range(0, layer_num):
    mem.append(layer_info_2_mach(weight_height[i], weight_width[i], weight_start_addr[i], 
                                    bias_height[i], bias_width[i], bias_start_addr[i],
                                    reLU_sel[i], op_sel[i], flatten[i]))
    # print(hex(mem[i+1])) 
    # print(i+1)   

print ([hex(x) for x in mem])


# data
conv0_w= np.array( [[-0.08656828, -0.06462713, -0.17349112],
                     [-0.14688432, -0.0996029,  -0.27237958],
                     [ 0.0851955,   0.11699538,  0.04402129]], dtype=np.float32)
conv0_b = np.float32(0.04654125)

conv1_w = np.array([[ 0.02396365, -0.16358249, -0.2261846 ],
                    [ 0.03402003, -0.14865908, -0.20128998],
                    [-0.07002946, -0.11470139,  0.23676495]], dtype=np.float32)
conv1_b = np.float32(0.21370661)

conv2_w = np.array([[-0.31584883,  0.02201033,  0.54485226]], dtype=np.float32)
conv2_b = np.float32(-0.15500683)

mul0_w = np.array([[-0.17771813, -0.20027217, -0.00589057, 0.272158, 0.02603377, 0.22764663, 0.2659146,   0.25834766],
                   [-0.3335022,  -0.13859965, -0.3082366, -0.18501298,  0.06262575, -0.2657864, 0.11901119, -0.17597231],
                   [-0.238825,   -0.32270837, -0.12815167,  0.02824488, -0.01367223, -0.18836577, 0.06131296, -0.11429496],
                   [-0.06269284,  0.32289466, -0.24477401,  0.185614,   -0.16175269,  0.07682266, -0.1745692,  -0.2691302 ],
                   [-0.1076688,   0.06271603,  0.24929667, -0.16479072, -0.2800885,   0.29443046, -0.24311161, -0.30693713],
                   [-0.33715224, -0.28506473, -0.00977807,  0.2796256,  -0.10205611,  0.28564268, 0.05421244,  0.06161296],
                   [-0.06642339, -0.31364697,  0.26560265,  0.27076086, -0.27802068, -0.08559679, -0.02912077, -0.28424686],
                   [-0.2735344,  -0.04439513, -0.20170043, -0.04870431, -0.03483155,  0.02883708, -0.21359602, -0.24233198]], dtype=np.float32)
mul0_b = np.array([-0.2568526,  -0.2418403,   0.34562412,  0.2949618,   0.14507973, -0.05017148,  0.22873019,  0.08445529], dtype=np.float32)

mul1_w = np.array([[-0.23708765], 
                   [0.12837015], 
                   [-0.13549764], 
                   [-0.04578189],  
                   [0.17099512], 
                   [-0.07681836], 
                   [-0.00231458], 
                   [-0.1436751 ]], dtype=np.float32)
mul1_b = np.float32(-0.11749408)

conv0_w_i = np.int8(conv0_w*128)
conv1_w_i = np.int8(conv1_w*128)
conv2_w_i = np.int8(conv2_w*128)
mul0_w_i  = np.int8(mul0_w*128)
mul1_w_i  = np.int8(mul1_w*128)

conv0_b_i = np.int8(conv0_b*128)
conv1_b_i = np.int8(conv1_b*128)
conv2_b_i = np.int8(conv2_b*128)
mul0_b_i  = np.int8(mul0_b*128)
mul1_b_i  = np.int8(mul1_b*128)

np.set_printoptions(formatter={'int':hex})
print('layer 1: \n', conv0_w_i, conv0_b_i)
print('layer 2: \n', conv1_w_i, conv1_b_i)
print('layer 3: \n', conv2_w_i, conv2_b_i)
print('layer 4: \n', mul0_w_i, mul0_b_i)
print('layer 5: \n', mul1_w_i, mul0_b_i)

np.set_printoptions(formatter={'int':hex})


def complement_2_int8(a):
    b = (a<0)
    return a+b*128

print(conv0_w_i)
print(complement_2_int8(conv0_w_i))

np.set_printoptions(formatter={'int':hex})
print('layer 1: \n', complement_2_int8(conv0_w_i), complement_2_int8(conv0_b_i))
print('layer 2: \n', complement_2_int8(conv1_w_i), complement_2_int8(conv1_b_i))
print('layer 3: \n', complement_2_int8(conv2_w_i), complement_2_int8(conv2_b_i))
print('layer 4: \n', complement_2_int8(mul0_w_i), complement_2_int8(mul0_b_i))
print('layer 5: \n', complement_2_int8(mul1_w_i), complement_2_int8(mul0_b_i))

c0w = complement_2_int8(conv0_w_i).flatten()
c0b = complement_2_int8(conv0_b_i).flatten()
c1w = complement_2_int8(conv0_w_i).flatten()
c1b = complement_2_int8(conv0_b_i).flatten()
c2w = complement_2_int8(conv0_w_i).flatten()
c2b = complement_2_int8(conv0_b_i).flatten()
m0w = complement_2_int8(mul0_w_i).flatten()
m0b = complement_2_int8(mul0_b_i).flatten()
m1w = complement_2_int8(mul1_w_i).flatten()
m1b = complement_2_int8(mul1_b_i).flatten()

w = np.concatenate((c0w, c1w, c2w, m0w, m1w), axis=None)
b = np.concatenate((c0b, c1b, c2b, m0b, m1b), axis=None)
print(w)

main_mem = []
for i in range(0,0x300):
    if(i<5): main_mem.append(mem[i])
    elif(i>=0x100 and i<w.size+0x100): main_mem.append(w[i-0x100])
    elif(i>=0x200 and i<b.size+0x200): main_mem.append(w[i-0x200])
    else: main_mem.append(int('00000000', 16))
print([hex(main_mem_ele) for main_mem_ele in main_mem])