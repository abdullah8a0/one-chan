`timescale 1ns / 1ps
`default_nettype none

`define BDT  4'd0
`define BLT  4'd1
`define KDT  4'd2
`define KLT  4'd3
`define NDT  4'd4
`define NLT  4'd5
`define PDT  4'd6
`define PLT  4'd7
`define QDT  4'd8
`define QLT  4'd9
`define RDT  4'd10
`define RLT  4'd11
`define EMPTY 4'd12

module image_sprite #(
    parameter WIDTH=40, HEIGHT=40
) (
    input wire pixel_clk_in,
    input wire rst_in,

    input wire [7:0] piece_sel_i,
    input wire [10:0] x_in, hcount_in,
    input wire [9:0]  y_in, vcount_in,
    output logic [11:0] pixel_out
);

    localparam BLACK = 2'b0;
    localparam WHITE = 2'b10;
    localparam GREY = 2'b01;

    localparam KING      = 6'b000001;
    localparam QUEEN     = 6'b000010;
    localparam ROOK      = 6'b000100;
    localparam KNIGHT    = 6'b001000;
    localparam BISHOP    = 6'b010000;
    localparam PAWN      = 6'b100000;
    localparam WHITE_C     = 2'b01;
    localparam BLACK_C     = 2'b10;

    logic [3:0] piece_sel;
    always_comb begin
        case(piece_sel_i)
            {BLACK_C,KING}  : piece_sel = `KDT;
            {BLACK_C,QUEEN} : piece_sel = `QDT;
            {BLACK_C,ROOK}  :piece_sel = `RDT;
            {BLACK_C,KNIGHT}:piece_sel = `NDT;
            {BLACK_C,BISHOP}:piece_sel = `BDT;
            {BLACK_C,PAWN}:piece_sel = `PDT; 
            {WHITE_C,KING} : piece_sel = `KLT;
            {WHITE_C,QUEEN} :piece_sel = `QLT;
            {WHITE_C,ROOK}  :piece_sel = `RLT;
            {WHITE_C,KNIGHT}:piece_sel = `NLT;
            {WHITE_C,BISHOP}:piece_sel = `BLT;
            {WHITE_C,PAWN}:piece_sel = `PLT;
            default: piece_sel = `EMPTY;
        endcase
    end
    

    logic [10:0] hcount_r [3:0];
    logic [9:0]  vcount_r [3:0];
    always_ff @(posedge pixel_clk_in) begin
        hcount_r[0] <= hcount_in;
        vcount_r[0] <= vcount_in;
        for (int i=1; i<4; i = i+1) begin
            hcount_r[i] <= hcount_r[i-1];
            vcount_r[i] <= vcount_r[i-1];
        end

    end

    // calculate rom address
    logic [$clog2(WIDTH*HEIGHT)-1:0] image_addr;
    assign image_addr = (hcount_r[3] - x_in) + ((vcount_r[3] - y_in) * WIDTH);

    logic in_sprite;
    assign in_sprite = ((hcount_r[3] >= x_in && hcount_r[3] < (x_in + WIDTH)) &&
                        (vcount_r[3] >= y_in && vcount_r[3] < (y_in + HEIGHT)));

    // Modify the line below to use your BRAMs!
    logic [12:0][1:0] color;
    logic [1:0] color_selected;
    logic [3:0] col1;

    assign color[`EMPTY] = 2'd0;
    assign color_selected = color[piece_sel];

    always_comb begin
        case(color_selected)
            BLACK: col1 = 4'd0;
            GREY:  col1 = 4'b1000;
            WHITE: col1 = 4'b1111;
            default: col1 = 4'd0;
        endcase
    end

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("bdt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) bdt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[0])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("blt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) blt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[1])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("kdt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) kdt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[2])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("klt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) klt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[3])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("ndt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) ndt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[4])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("nlt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) nlt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[5])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("pdt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) pdt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[6])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("plt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) plt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[7])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("qdt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) qdt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[8])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("qlt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) qlt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[9])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("rdt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) rdt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[10])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
        .RAM_WIDTH(2),                       // Specify RAM data width
        .RAM_DEPTH(WIDTH * HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
        .INIT_FILE("rlt.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
        //.INIT_FILE("image.mem")// Specify name/location of RAM initialization file if using one (leave blank if not)
    ) rlt (
        .addra(image_addr),     // Address bus, width determined from RAM_DEPTH
        .dina( 0 ),       // RAM input data, width determined from RAM_WIDTH
        .clka( pixel_clk_in ),       // Clock          
        .wea( 0 ),         // Write enable
        .ena( 1 ),         // RAM Enable, for additional power savings, disable port when not in use
        .rsta( rst_in ),       // Output reset (does not affect memory contents)
        .regcea( 1 ),   // Output register enable
        .douta(color[11])      // RAM output data, width determined from RAM_WIDTH
    );

    assign pixel_out = in_sprite ? {3{col1}} : 0;


endmodule

`default_nettype none
