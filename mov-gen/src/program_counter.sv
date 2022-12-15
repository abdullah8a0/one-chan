`default_nettype none

// PC for single-cycle processor
module program_counter#(
    parameter INSTR_WIDTH = 32,
    parameter ADDR_WIDTH = 12,
    parameter INIT_FILE = "instruction.mem"
)(
    input wire clk,
    input wire nrst,

    input wire next_pc,
    input wire load_pc,
    input wire [ADDR_WIDTH-1:0] load_pc_addr,

    output logic [INSTR_WIDTH-1:0] instr
);

    logic [ADDR_WIDTH-1:0] read_addr;
    logic [INSTR_WIDTH-1:0] rom_out;

    always_ff @(posedge clk or negedge nrst) begin
        if(~nrst) read_addr <= 12'd0;
        else if(load_pc) read_addr <= load_pc_addr;  
        else if(next_pc) read_addr <= read_addr + 12'd1;
        else read_addr <= read_addr;
    end

    distributive_rom#(
        .WORD_WIDTH ( 32 ),
        .ADDR_WIDTH ( 12 ),
        .INIT_FILE  ( INIT_FILE )
    )u_distributive_rom(
        .addr       ( read_addr ),
        .rom_out    ( rom_out     )
    );

    assign instr = rom_out;

endmodule

`default_nettype wire