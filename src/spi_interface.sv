`default_nettype none

module spi_interface #(
    parameter DATA_WIDTH = 8,// output 1 byte(8-bit) at one spi_clk cycle
    parameter BIT_DUR = 2,
    parameter BYTE_STORE = 250 // store data in interface before send data
)( 
    input wire clk, 
    input wire nrst,
    input wire load_iv,
    input wire load_cnt,
    input wire [DATA_WIDTH-1:0] load_id,

    // receive as a slave
    input wire clk_spi_in,
    input wire sel_in,
    input wire [DATA_WIDTH-1:0] data_in,
    
    // send as a host
    input wire send_en,
    output logic clk_out,
    output logic sel_out,
    output logic [DATA_WIDTH-1:0] data_out
);


endmodule


module spi_gen #(parameter MESSAGE_WIDTH = 8,
                    parameter BIT_DUR = 2)
                  ( input wire clk_in, input wire rst_in,
                    input wire [MESSAGE_WIDTH-1:0]msg_in,
                    input wire trigger_in,
                    output logic data_out,
                    output logic clk_out,
                    output logic sel_out);
    
    logic [MESSAGE_WIDTH-1:0] msg_reg;
    logic [BIT_DUR-1:0] clk_cnt;
    logic [MESSAGE_WIDTH-1:0] msg_cnt;
    logic finish;

    assign data_out = msg_reg[MESSAGE_WIDTH-1];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            clk_out  <= 1'b1;
            sel_out  <= 1'b1;
            msg_reg  <= {MESSAGE_WIDTH{1'b1}};
            msg_cnt  <= {MESSAGE_WIDTH{1'b1}};
            clk_cnt  <= {BIT_DUR{1'b0}};
            finish   <= 1'b0;
        end
        else if(trigger_in) begin
            clk_cnt <= 1'b0;
            msg_reg <= msg_in; // one clk
            msg_cnt <= {1'b0, msg_cnt[MESSAGE_WIDTH-2:0]};
            finish  <= 1'b0;

            sel_out <= 1'b0;
            clk_out <= 1'b0;
        end
        else if(~finish && ~sel_out) begin
            sel_out  <= 1'b0;
            finish   <= ((|msg_cnt==1'b0) && (clk_cnt=={BIT_DUR{1'b1}}-1'b1)) ? 1'b1 : 1'b0;
            if(BIT_DUR > 1) clk_out  <= ((clk_cnt== {(BIT_DUR-1){1'b1}}) || (clk_cnt=={BIT_DUR{1'b1}}))? ~clk_out : clk_out;
            else            clk_out  <= ((clk_cnt== 1'b0) || (clk_cnt=={BIT_DUR{1'b1}}))? ~clk_out : clk_out;
            msg_reg  <= (clk_cnt == {BIT_DUR{1'b1}}) ? {msg_reg[MESSAGE_WIDTH-2:0], 1'b0} : msg_reg;
            msg_cnt  <= (clk_cnt == {BIT_DUR{1'b1}}) ? {1'b0, msg_cnt[MESSAGE_WIDTH-1:1]} : msg_cnt;
            clk_cnt  <= clk_cnt + 1'b1;
        end
        else if(finish) begin
            clk_out  <= 1'b1;
            sel_out  <= 1'b1;
            finish   <= 1'b0;

            msg_reg  <= {MESSAGE_WIDTH{1'b1}};
            msg_cnt  <= {MESSAGE_WIDTH{1'b1}};
            clk_cnt  <= {BIT_DUR{1'b0}};
        end
        else begin
            clk_out  <= 1'b1;
            sel_out  <= 1'b1;

            finish   <= 1'b0;
            msg_reg  <= {MESSAGE_WIDTH{1'b1}};
            msg_cnt  <= {MESSAGE_WIDTH{1'b1}};
            clk_cnt  <= {BIT_DUR{1'b0}};
        end
    end
endmodule


`default_nettype wire

