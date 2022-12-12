`default_nettype none

module memory_mux #(
    parameter MEM_NUM = 6,
    parameter OUTPUT_MEM_DEPTH = 6,
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = $clog2(OUTPUT_MEM_DEPTH)
)(
    input wire clk,
    input wire nrst,

    input wire data_iv,
    input wire [DATA_WIDTH-1:0] data_id,

    output logic [MEM_NUM-1:0] mem_ov, // connect to write enable signal to dual-port RAM
    output logic [ADDR_WIDTH-1:0] addr_o,
    output logic [DATA_WIDTH-1:0] mem_od
);

    logic d_data_iv;
    logic data_iv_negedge;
    always_ff @(posedge clk) begin
        d_data_iv <= data_iv;
    end
    assign data_iv = ({d_data_iv, data_iv}==2'b10) ? 1'b1 : 1'b0;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) addr_o <= 0;
        else if(load) addr_o <= addr_o + 1;
    end

    // output assignment
    assign mem_od = data_id;
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) mem_ov <= {(MEM_NUM-1){1'b0}, 1'b1};
        else if(data_iv_negedge && (input_cnt<MEM_NUM-1)) mem_ov <= (mem_ov << 1);
        else if(data_iv_negedge && (input_cnt==MEM_NUM-1)) mem_ov <= {(MEM_NUM-1){1'b0}, 1'b1};
        else mem_ov <= mem_ov;
    end

endmodule

`default_nettype wire