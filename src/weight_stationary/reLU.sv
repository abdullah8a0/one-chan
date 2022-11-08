`default_nettype none

module reLU #(
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire nrst, 

    input wire reLU_iv,
    input wire signed [DATA_WIDTH-1:0] neuron_i,

    output logic reLU_ov,
    output logic signed [DATA_WIDTH-1:0] reLU_od
);

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            reLU_ov <= 1'b0;
            reLU_od <= 0;
        end
        else if(reLU_iv) begin
            reLU_ov <= 1'b1;
            reLU_od <= (neuron_i>={(DATA_WIDTH){1'sd0}})? neuron_i : 0;
        end
        else begin
            reLU_ov <= 1'b0;
            reLU_od <= 0;
        end
    end   

endmodule

`default_nettype wire