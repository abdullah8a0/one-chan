`default_nettype none

//pipe line 3 adder
module multiport_adder3 #(
    parameter WIDTH = 19
)(
    input wire clk,
    input wire nrst,

    input wire port_iv,
    input wire signed [3-1:0][WIDTH-1:0] port_id,

    output logic sum_ov,
    output logic signed [WIDTH-1:0] sum_od
);

    logic signed [1:0][WIDTH-1:0] sum_r;
    logic signed [1:0] port_iv_pipe;
    logic signed [WIDTH-1:0] port_id_pipe;

    // verify
    logic signed [WIDTH-1:0] sum_r0, sum_r1;
    assign {sum_r1, sum_r0} = sum_r;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) port_id_pipe <= 0;
        else port_id_pipe <= port_id[2];
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) port_iv_pipe <= 0;
        else begin
            port_iv_pipe[0] <= port_iv;
            port_iv_pipe[1] <= port_iv_pipe[0];
        end
    end  

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) sum_r <= 0;
        else begin
            sum_r[0] <= (port_iv) ? (port_id[0]+port_id[1]) : 0;
            sum_r[1] <= (port_iv_pipe[0]) ? (sum_r[0]+port_id_pipe) : 0;
        end 
    end 

    assign sum_ov = port_iv_pipe[1];
    assign sum_od = sum_r[1];

endmodule

`default_nettype wire