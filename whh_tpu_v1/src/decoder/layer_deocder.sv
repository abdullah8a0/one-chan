`default_nettype none

module layer_decoder(
    input wire [31:0] layer_info,

    output logic [3:0] input_height,
    output logic [3:0] input_width,
    output logic [3:0] layer_total_num
);

    always_comb begin
        input_height = layer_info[31:28];
        input_width = layer_info[27:24];
        layer_total_num = layer_info[23:20];
    end

endmodule

`default_nettype wire