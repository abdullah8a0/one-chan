def layer_info_2_mach(weight_height, weight_width, weight_start_addr, bias_height, bias_width, bias_start_addr,
    reLU_sel, op, flatten):
    layer_info = int('00000000',16)
    layer_info = layer_info | ((weight_height-1) << 29)
    layer_info = layer_info | ((weight_width-1) << 26)
    layer_info = layer_info | (weight_start_addr << 18 )

    layer_info = layer_info | ((bias_height-1) << 15)
    layer_info = layer_info | ((bias_width-1) << 12)
    layer_info = layer_info | (bias_start_addr << 4 )

    layer_info = layer_info | (reLU_sel << 3)
    layer_info = layer_info | (op << 2)
    layer_info = layer_info | (flatten << 1)

    print('layer info transition: ', hex(layer_info))
    return layer_info

def layer_num_info(input_height, input_width, layer_total_num):
    layer_num_info = int('00000000',16)
    layer_num_info = layer_num_info | (input_height << 28)
    layer_num_info = layer_num_info | (input_width << 24)
    layer_num_info = layer_num_info | (layer_total_num << 20 )

    print('layer num info transition: ', hex(layer_num_info))
    return layer_num_info


# demo 
# weight_height = 3
# weight_width = 3
# weight_start_addr = 0x04

# bias_height = 1
# bias_width = 1
# bias_start_addr = 0x20

# reLU_sel = 0
# op = 0
# flatten = 0

# print(hex(layer_info_2_mach(weight_height, weight_width, weight_start_addr, bias_height, bias_width, bias_start_addr,
#     reLU_sel, op, flatten)))

# input_height = 8 
# input_width = 8
# layer_total_num = 5
# print(hex(layer_num_info(input_height, input_width, layer_total_num)))