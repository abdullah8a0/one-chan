`default_nettype none

module layer_info_decoder(
    input wire [31:0] layer_info, // {3, 3, 8, 3, 3, 8, 3, (1)}

    output wire [3:0] weight_height,
    output wire [3:0] weight_width,
    output wire [7:0] weight_start_addr,
    output wire [3:0] bias_height,
    output wire [3:0] bias_width,
    output wire [7:0] bias_start_addr,
    output wire [2:0] op  // {reLU_sel, op_sel, flatten_sel}
);

    
    assign weight_height = {1'b0, layer_info[31:29]} + 1;
    assign weight_width = {1'b0, layer_info[28:26]} + 1;
    assign weight_start_addr = layer_info[25:18];

    assign bias_height = {1'b0, layer_info[17:15]} + 1;
    assign bias_width = {1'b0, layer_info[14:12]} + 1;
    assign bias_start_addr = layer_info[11:4];

    assign op = layer_info[3:1];


endmodule

`default_nettype wire