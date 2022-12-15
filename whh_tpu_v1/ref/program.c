#include<stdio.h>

#define LAYER_INFO_BASE_ADDR

#define CONV 1
#define MUL  0

int move_total_num;
int move_current_num;
int move_current;
int move_max_value;

int layer_num_info;
int layer_total_num;
int layer_current_num;
int input_height;
int input_width;

int layer_info;
int weight_height, weight_width;
int bias_height, bias_width;
int ifmap_height, ifmap_width;
int weight_start_addr;
int bias_start_addr;
int op; // {reLU_sel, op_sel, flatten}

int weight_length;
int bias_length;

int dnn_out;

int weight[64];
int bias[64]; 


void loop(){
    while(move_total_num==0) {} // when the SPI received a valid packet, break out the loop

    move_current_num = 0;
    move_max_value = -128; // -8'h1_000_0000
    
    layer_num_info = load(LAYER_INFO_BASE_ADDR);  // load function
    layer_total_num, input_height, input_width = decode_layer(layer_num_info);

    // traverse all the moves
    while(move_current_num < move_total_num) {
        move_current = compute_grid(move_current_num); // compute new grid and send it to unified buffer

        ifmap_height = input_height;
        ifmap_width = input_width;

        // deep neural network computation
        layer_current_num = 1; 
        while(layer_current_num <= layer_total_num){
            layer_info = load(LAYER_INFO_BASE_ADDR+layer_current_num); // load function
            weight_height, weight_width, weight_start_addr, bias_height, bias_width, bias_start_addr, op 
                = decode_layer_compute_info(layer_info); 

            // something about flatten function should be discussed here
            // 1. flatten the matrix if op[0]==1
            // 2. if conv, then ifmap h/w remains the same; if mul, then transpose it
            ifmap_height, ifmap_width = compute_ifmap(op, ifmap_height, ifmap_width);

            send_layer_info(weight_height, weight_width, bias_height, bias_width, ifmap_width);

            weight_length = weight_height * weight_width;
            bias_length = bias_height * bias_width;

            load_weight(weight_start_addr, weight_length);
            load_bias(bias_start_addr, bias_length);

            send_systolic_data();
            
            ifmap_height, ifmap_width = set_ifmap_o(ifmap_height, ifmap_width, 
                                                    weight_height, weight_width);      
            layer_current_num++;
        }

        if(dnn_out > move_max_value){
            move_max_value = dnn_out;
        }

        move_current_num++;
    }

    move_total_num = 0;

    send_optimal_move();
}


int set_ifmap_o(int weight_height, int weight_width, int ifmap_height, int ifmap_width){
    if(op[1]==CONV){
        ifmap_height = ifmap_height - weight_height + 1;
        ifmap_width = ifmap_width - weight_width + 1;
    }
    else{ 
        ifmap_height = ifmap_width;
        ifmap_width = weight_width;
    }

    return ifmap_height, ifmap_width;
}
