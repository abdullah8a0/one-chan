`default_nettype none

module bias_adder #(
    parameter BIAS = 8'd0,
    parameter PSUM_WIDTH = 19,
    parameter DATA_WIDTH = 8,
    parameter SA_COL = 3
)(
    input wire clk,
    input wire nrst, 

    input wire bias_adder_iv,
    input wire signed [SA_COL-1:0][PSUM_WIDTH-1:0] psum_i,

    output logic biased_ov,
    output logic signed [DATA_WIDTH-1:0] biased_od
);

    logic psum_sv;
    logic [PSUM_WIDTH-1:0] psum_sd;
    logic [PSUM_WIDTH-1:0] psum_sd_shifted;


    multiport_adder3#(
        .WIDTH        ( PSUM_WIDTH )
    )u_multiport_adder(
        .clk     ( clk          ),
        .nrst    ( nrst     ),
        .port_iv ( bias_adder_iv      ),
        .port_id  ( psum_i         ),
        .sum_ov  ( psum_sv ),
        .sum_od   ( psum_sd  )
    );

    assign psum_sd_shifted = (psum_sd >>> 7);

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            biased_ov <= 1'b0;
            biased_od <= 0;
        end
        else if(psum_sv) begin
            biased_ov <= 1'b1;
            biased_od <= (psum_sd >>> 7) + BIAS;
        end
        else begin
            biased_ov <= 1'b0;
            biased_od <= 0;
        end
    end   

endmodule

`default_nettype wire