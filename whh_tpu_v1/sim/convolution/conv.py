import numpy as np
import cv2 as cv

def convolution2d(image, kernel, bias):
    m, n = kernel.shape
    if (m*n > 0):
        y, x = image.shape
        y = y - m + 1
        x = x - n + 1
        new_image = np.zeros((y,x))
        for i in range(y):
            for j in range(x):
                new_image[i][j] = np.sum(image[i:i+m, j:j+m]*kernel) + bias
        return new_image

mat1 = np.array([[127, 72, 80, 66, 65, 80, 72, 68],
                 [96, 96, 96, 96, 96, 96, 96, 96],
                 [127,127,127,127,127,127,127,127],
                 [127,127,127,68,127,127,127,127],
                 [127,127,127,127,127,127,127,127],
                 [127,127,127,127,127,127,127,127],
                 [160,160,160,160,160,160,160,160],
                 [132,136,144,130,129,144,136,132]], dtype=np.int32)
print('mat1: ', mat1)

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

conv0_w_i = np.int32(conv0_w*128)
conv1_w_i = np.int32(conv1_w*128)
conv2_w_i = np.int32(conv2_w*128)
mul0_w_i  = np.int32(mul0_w*128)
mul1_w_i  = np.int32(mul1_w*128)

conv0_b_i = np.int32(conv0_b*128)
conv1_b_i = np.int32(conv1_b*128)
conv2_b_i = np.int32(conv2_b*128)
mul0_b_i  = np.int32(mul0_b*128)
mul1_b_i  = np.int32(mul1_b*128)

print(conv0_w_i, conv0_b_i)
print(conv1_w_i, conv1_b_i)
print(conv2_w_i, conv2_b_i)
print(mul0_w_i, mul0_b_i)
print(mul1_w_i, mul1_b_i)


mat2 = convolution2d(mat1, conv0_w, conv0_b)
mat2 = np.int32(mat2)
print('mat2:', mat2)

mat3 = convolution2d(mat2, conv1_w, conv1_b)
mat3 = np.int32(mat3)
print('mat3:', mat3)

mat4 = convolution2d(mat3, conv2_w, conv2_b)
mat4 = np.int32(mat4)
print('mat4:', mat4)

mat5 = mat4.flatten()
print('mat5:', mat5)

mat6 = np.matmul(mat5, mul0_w)
mat6 = mat6 + mul0_b
mat6 = np.int32(mat6)
print('mat6:', mat6)

mat7 = np.matmul(mat6, mul1_w)
mat7 = mat7 + mul1_b
print('mat7:', mat7)

# [[-42 -41 -40 -42 -41 -41]
#  [-65 -65 -65 -65 -65 -65]
#  [-75 -75 -75 -75 -75 -75]
#  [-75 -75 -75 -75 -75 -75]
#  [-67 -67 -67 -67 -67 -67]
#  [-90 -90 -91 -91 -90 -90]]

mat2 = convolution2d(mat1, conv0_w_i, conv0_b_i)
# print('mat2_i_inter:', mat2)
mat2 = np.int32(mat2/128)
print('mat2_i:', mat2)

mat3 = convolution2d(mat2, conv1_w_i, conv1_b_i)
# print('mat3_i_inter:', mat3)
mat3 = np.int32(mat3/128)
print('mat3_i:', mat3)

mat4 = convolution2d(mat3, conv2_w_i, conv2_b_i)
# print('mat4_i_inter:', mat4)
mat4 = np.int32(mat4/128)
print('mat4_i:', mat4)

mat5 = mat4.flatten()
print('mat5_i:', mat5)

mat6 = np.matmul(mat5, mul0_w_i)
mat6 = mat6 + mul0_b
# print('mat6_i_inter:', mat6)
mat6 = np.int32(mat6/128)
print('mat6_i:', mat6)
for i in range(0,8):
    if(mat6[i] < 0): mat6[i]=0
print('mat6_i_reLU:', mat6)  

mat7 = np.matmul(mat6, mul1_w_i)
# print('mat7_i_inter:', mat7/128)
mat7 = mat7 + mul1_b
print('mat7_i:', mat7/128)