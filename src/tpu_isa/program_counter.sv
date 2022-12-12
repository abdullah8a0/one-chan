`default_nettype none

module program_counter#(
    parameter CNT_WIDTH = 8
)(
    input wire clk,
    input wire nrst,

    input wire load,
    input wire inc,
    
    input wire [CNT_WIDTH-1:0] load_data,
    output logic [CNT_WIDTH-1:0] out
);

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) out <= 0;
        else if(load) out <= load_data;
        else if(inc)  out <= out + 1;
        else out <= out;
    end

endmodule

`default_nettype wire