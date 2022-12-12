`default_nettype none

module Tiny_TPU_top#(
    parameter DATA_WIDTH = 8,// output 1 byte(8-bit) at one spi_clk cycle
    parameter BIT_DUR = 2,
    parameter INPUT_BYTE_STORE = 250, // maximum store data in interface before send data
    parameter OUTPUT_BYTE_STORE = 1
)( 
    input wire clk, 
    input wire nrst,
    
    // spi input
    input wire clk_in,
    input wire sel_in,
    input wire [DATA_WIDTH-1:0] data_in,

    // spi output
    output clk_out,
    output sel_out,
    output [DATA_WIDTH-1:0] data_out
);


    logic spi_iv;
    logic [DATA_WIDTH-1:0] spi_id; 
    logic spi_ov;
    logic [DATA_WIDTH-1:0] spi_od;

    spi_host#(
        .DATA_WIDTH    ( DATA_WIDTH ),
        .BIT_DUR       ( BIT_DUR ),
        .BYTE_STORE    ( OUTPUT_BYTE_STORE )
    )u_spi_host(
        .clk           ( clk           ),
        .nrst          ( nrst          ),
        .load_iv       ( spi_ov       ),
        .load_id       ( spi_od       ),
        .clk_out       ( clk_out ),
        .sel_out       ( sel_out ),
        .data_out      (  data_out  )
    );

    spi_slave#(
        .DATA_WIDTH   ( 8 ),
        .BIT_DUR      ( 2 ),
        .BYTE_STORE   ( INPUT_BYTE_STORE )
    )u_spi_slave(
        .clk          ( clk          ),
        .nrst         ( nrst         ),
        .clk_in       ( clk_in       ),
        .sel_in       ( sel_in       ),
        .data_in      ( data_in      ),

        .spi_ov       ( spi_iv  ),
        .spi_od       ( spi_id    )
    );


    TPU#(
        .WIDTH         ( 8 ),
        .HEIGHT        ( 8 ),
        .DATA_WIDTH    ( 8 ),
        .PC_ADDR_WIDTH ( 12 ),
        .MOVE_WIDTH    ( 16 ),
        .MAX_MOVES     ( 220 ),
        .GRID_HEADER   ( 8'b11_01_01_01 ),
        .MOVE_HEADER   ( 8'b11_10_10_10 ),
        .INSTR_FILE    ( "" ),
        .MAIN_MEM_FILE ( "" )
    )u_TPU(
        .clk           ( clk           ),
        .nrst          ( nrst          ),

        .spi_iv        ( spi_iv        ),
        .spi_id        ( spi_id        ),
        
        .spi_ov        ( spi_ov  ),
        .spi_od        ( spi_od  )
    );



    endmodule

    `default_nettype wire