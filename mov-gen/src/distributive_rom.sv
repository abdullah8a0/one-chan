`default_nettype none

module distributive_rom#(
    parameter WORD_WIDTH = 32,
    parameter ADDR_WIDTH = 10,
    parameter ROM_DEPTH = 2 ** ADDR_WIDTH,
    parameter INIT_FILE = ""
)(
    input wire [ADDR_WIDTH-1:0] addr,
    output wire [WORD_WIDTH-1:0] rom_out
);

    logic [WORD_WIDTH-1:0] ROM [ROM_DEPTH-1:0];

    generate
        if (INIT_FILE != "") begin: use_init_file
            initial
                $readmemh(INIT_FILE, ROM, 0, ROM_DEPTH-1);
        end else begin: init_bram_to_zero
            integer rom_index;
            initial
                for (rom_index = 0; rom_index < ROM_DEPTH; rom_index = rom_index + 1)
                    ROM[rom_index] = {ROM_DEPTH{1'b0}};
        end
    endgenerate

    assign rom_out = ROM[addr];

endmodule

`default_nettype wire