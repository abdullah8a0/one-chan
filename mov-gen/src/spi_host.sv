`default_nettype none

// load data_length, and en high one period
// then load value in the interface
// send data 
module spi_host #(
    parameter DATA_WIDTH = 8,// output 1 byte(8-bit) at one spi_clk cycle
    parameter BIT_DUR = 2,
    parameter BYTE_STORE = 250 // maximum store data in interface before send data
)( 
    input wire clk, 
    input wire nrst,
    //input wire en,
    //input wire [7:0] data_length,

    input wire load_iv,
    input wire [DATA_WIDTH-1:0] load_id,
    
    output logic clk_out,
    output logic sel_out,
    output logic [DATA_WIDTH-1:0] data_out
);  

    localparam IDLE = 0;
    localparam START = 1;
    localparam LOAD = 2;
    localparam SEND = 3;

    localparam CNT_WIDTH = $clog2(BYTE_STORE);

    logic [1:0] state;
    logic [DATA_WIDTH*BYTE_STORE-1:0] data_buf;

    logic [CNT_WIDTH-1:0] load_cnt;
    logic finish_load;

    logic [CNT_WIDTH-1:0] send_cnt;
    logic [BIT_DUR-1:0] clk_cnt;
    logic finish_send;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) state <= IDLE;
        //else if((state==IDLE) && en) state <= START;
        //else if(state==START) state <= LOAD;
        else if((state==IDLE) && load_iv) state <= LOAD;
        else if((state==LOAD) && finish_load) state <= SEND;
        else if((state==SEND) && finish_send) state <= IDLE;
        else state <= state;
    end

    // // store length
    // always_ff @(posedge clk or negedge nrst) begin
    //     if(~nrst) load_cnt <= 0;
    //     else if(state==START) load_cnt <= data_length;
    //     else if(state==IDLE)  load_cnt <= 0;
    //     else load_cnt <= load_cnt;
    // end

    // data load
    assign finish_load = (state==LOAD) && ~load_iv;
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) load_cnt <= 0;
        else if((state==LOAD) && load_iv) load_cnt <= load_cnt + 1;
        else if(state==IDLE) load_cnt <= 0;
        else load_cnt <= load_cnt;
    end

    // send 
    always_ff @(posedge clk or negedge nrst) begin
        if (~nrst) sel_out <= 1;
        else if((state==LOAD) && finish_load) sel_out <= 0;
        else if(state==SEND) sel_out <= (finish_send) ? 1 : 0;
        else sel_out <= 1;
    end

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) begin
            clk_cnt <= 0;
            clk_out <= 1;
        end
        else if((state==LOAD) && finish_load) begin
            clk_cnt <= 0;
            clk_out <= 0;
        end
        else if(state==SEND) begin
            clk_cnt <= clk_cnt + 1;
            clk_out <= (~finish_send && ((clk_cnt=={(BIT_DUR-1){1'b1}}) || (clk_cnt=={BIT_DUR{1'b1}}))) ? ~clk_out : clk_out;
        end
        else begin
            clk_cnt <= 0;
            clk_out <= 1;
        end
    end

    assign finish_send = (send_cnt==load_cnt) && (clk_cnt=={BIT_DUR{1'b1}});
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) send_cnt <= 0;
        else if((state==SEND) && (send_cnt<load_cnt)) send_cnt <= (clk_cnt=={BIT_DUR{1'b1}}) ? (send_cnt+1) : send_cnt;
        else if((state==SEND) && (send_cnt==load_cnt)) send_cnt <= (clk_cnt=={BIT_DUR{1'b1}}) ? 0 : send_cnt;
        else send_cnt <= 0;
    end

    // load data during LOAD, pip data at SEND
    assign data_out = data_buf[DATA_WIDTH-1:0];
    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) data_buf <= 0;
        else if(state==LOAD) data_buf <= (load_iv) ? {data_buf, load_id} : data_buf;
        else if(state==SEND) data_buf <= (clk_cnt=={BIT_DUR{1'b1}}) ? data_buf >> DATA_WIDTH : data_buf;
        else data_buf <= 0;
    end

endmodule


// module spi_gen #(parameter MESSAGE_WIDTH = 8,
//                     parameter BIT_DUR = 2)
//                   ( input wire clk_in, input wire rst_in,
//                     input wire [MESSAGE_WIDTH-1:0]msg_in,
//                     input wire trigger_in,
//                     output logic data_out,
//                     output logic clk_out,
//                     output logic sel_out);
    
//     logic [MESSAGE_WIDTH-1:0] msg_reg;
//     logic [BIT_DUR-1:0] clk_cnt;
//     logic [MESSAGE_WIDTH-1:0] msg_cnt;
//     logic finish;

//     assign data_out = msg_reg[MESSAGE_WIDTH-1];

//     always_ff @(posedge clk_in) begin
//         if(rst_in) begin
//             clk_out  <= 1'b1;
//             sel_out  <= 1'b1;
//             msg_reg  <= {MESSAGE_WIDTH{1'b1}};
//             msg_cnt  <= {MESSAGE_WIDTH{1'b1}};
//             clk_cnt  <= {BIT_DUR{1'b0}};
//             finish   <= 1'b0;
//         end
//         else if(trigger_in) begin
//             clk_cnt <= 1'b0;
//             msg_reg <= msg_in; // one clk
//             msg_cnt <= {1'b0, msg_cnt[MESSAGE_WIDTH-2:0]};
//             finish  <= 1'b0;

//             sel_out <= 1'b0;
//             clk_out <= 1'b0;
//         end
//         else if(~finish && ~sel_out) begin
//             sel_out  <= 1'b0;
//             finish   <= ((|msg_cnt==1'b0) && (clk_cnt=={BIT_DUR{1'b1}}-1'b1)) ? 1'b1 : 1'b0;
//             if(BIT_DUR > 1) clk_out  <= ((clk_cnt== {(BIT_DUR-1){1'b1}}) || (clk_cnt=={BIT_DUR{1'b1}}))? ~clk_out : clk_out;
//             else            clk_out  <= ((clk_cnt== 1'b0) || (clk_cnt=={BIT_DUR{1'b1}}))? ~clk_out : clk_out;
//             msg_reg  <= (clk_cnt == {BIT_DUR{1'b1}}) ? {msg_reg[MESSAGE_WIDTH-2:0], 1'b0} : msg_reg;
//             msg_cnt  <= (clk_cnt == {BIT_DUR{1'b1}}) ? {1'b0, msg_cnt[MESSAGE_WIDTH-1:1]} : msg_cnt;
//             clk_cnt  <= clk_cnt + 1'b1;
//         end
//         else if(finish) begin
//             clk_out  <= 1'b1;
//             sel_out  <= 1'b1;
//             finish   <= 1'b0;

//             msg_reg  <= {MESSAGE_WIDTH{1'b1}};
//             msg_cnt  <= {MESSAGE_WIDTH{1'b1}};
//             clk_cnt  <= {BIT_DUR{1'b0}};
//         end
//         else begin
//             clk_out  <= 1'b1;
//             sel_out  <= 1'b1;

//             finish   <= 1'b0;
//             msg_reg  <= {MESSAGE_WIDTH{1'b1}};
//             msg_cnt  <= {MESSAGE_WIDTH{1'b1}};
//             clk_cnt  <= {BIT_DUR{1'b0}};
//         end
//     end
// endmodule


// `default_nettype wire

