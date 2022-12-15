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

"""
seq.conv-0.weight
[[[[ 0.05349247 -0.06295744  0.03098457]
   [-0.06049823  0.07439065  0.00831672]
   [-0.12889424  0.04654265  0.0663917 ]]]]


seq.conv-0.bias
[0.2606776]


seq.conv-1.weight
[[[[ 0.07819555 -0.20161156  0.07621235]
   [ 0.06875536  0.04006334  0.11295854]
   [ 0.2022701  -0.16211267 -0.1706963 ]]]]


seq.conv-1.bias
[-0.21954596]


seq.conv-2.weight
[[[[-3.7186698e-04  1.5096349e-04 -4.8995364e-05]]]]


seq.conv-2.bias
[-0.00019465]


seq.linear-4.weight
[[-0.13330132 -0.0021576   0.24439776  0.06976814  0.24061798 -0.23204443
   0.02064936 -0.37922326]
 [ 0.00305395  0.0197652  -0.03576813  0.21498983 -0.09096297 -0.30084512
   0.21032113 -0.2456917 ]
 [ 0.10069674  0.01272986 -0.01760478 -0.16258304  0.12440438 -0.1441982
  -0.35196328 -0.12016781]
 [ 0.1299938   0.12509762  0.46286428 -0.2882883   0.3121414   0.07534419
   0.12688495  0.3268983 ]
 [ 0.2285816   0.23609464 -0.09171303 -0.2566475  -0.00424508 -0.25714758
  -0.10289156 -0.1980997 ]
 [-0.03233824  0.2393134   0.08289444 -0.23164569  0.23050684  0.20868051
  -0.3377997  -0.31157497]
 [-0.41889134  0.30953166  0.01581291  0.2510488  -0.04200417  0.1812493
  -0.01199285  0.24153677]
 [-0.07168188  0.0174959   0.18468161 -0.14025794  0.1780701  -0.15364324
  -0.05787516  0.09703751]]


seq.linear-4.bias
[ 1.9668224e-01 -3.6361101e-01 -1.1425331e-04  4.5338441e-03
  2.4125065e-01 -3.4034953e-01  7.4849486e-02 -1.7797554e-01]


seq.linear-5.weight
[[ 1.80792466e-01 -2.24591956e-01 -1.56317139e-04 -9.01792606e-04
   1.17505945e-01 -1.36835203e-01  4.17691991e-02 -1.65599927e-01]]


seq.linear-5.bias
[-0.22433935]


"""
# data
conv0_w= np.array( [[ 0.05349247, -0.06295744,  0.03098457],
   [-0.06049823,  0.07439065,  0.00831672],
   [-0.12889424,  0.04654265,  0.0663917 ]], dtype=np.float32)

conv0_b = np.float32(0.2606776)

conv1_w = np.array([[[ 0.07819555, -0.20161156,  0.07621235],
   [ 0.06875536,  0.04006334,  0.11295854],
   [ 0.2022701 , -0.16211267, -0.1706963 ]]], dtype=np.float32)

conv1_b = np.float32(-0.21954596)

conv2_w = np.array([[[[-3.7186698e-04,  1.5096349e-04, -4.8995364e-05]]]], dtype=np.float32)

conv2_b = np.float32(-0.00019465)

mul0_w = np.array([[-0.13330132, -0.0021576 ,  0.24439776,  0.06976814,  0.24061798, -0.23204443,
   0.02064936, -0.37922326],
 [ 0.00305395,  0.0197652 , -0.03576813,  0.21498983, -0.09096297, -0.30084512,
   0.21032113, -0.2456917 ],
 [ 0.10069674,  0.01272986, -0.01760478, -0.16258304,  0.12440438, -0.1441982,
  -0.35196328, -0.12016781],
 [ 0.1299938 ,  0.12509762,  0.46286428, -0.2882883 ,  0.3121414 ,  0.07534419,
   0.12688495,  0.3268983 ],
 [ 0.2285816 ,  0.23609464, -0.09171303, -0.2566475 , -0.00424508, -0.25714758,
  -0.10289156, -0.1980997 ],
 [-0.03233824,  0.2393134 ,  0.08289444, -0.23164569,  0.23050684,  0.20868051,
  -0.3377997 , -0.31157497],
 [-0.41889134,  0.30953166,  0.01581291,  0.2510488 , -0.04200417,  0.1812493,
  -0.01199285,  0.24153677],
 [-0.07168188,  0.0174959 ,  0.18468161, -0.14025794,  0.1780701 , -0.15364324,
  -0.05787516,  0.09703751]], dtype=np.float32)

mul0_b = np.array([ 0.19668224, -0.36361101, -0.00011425,  0.00453384,  0.24125065, -0.34034953,
    0.07484949, -0.17797554], dtype=np.float32)

mul1_w = np.array([[ 0.18079247, -0.22459196, -0.00015632, -0.00090179,  0.11750595, -0.1368352 ,
    0.0417692 , -0.16559993]], dtype=np.float32)

mul1_b = np.float32(-0.22433935)



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