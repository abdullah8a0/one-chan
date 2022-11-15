`default_nettype none
`timescale 1ns/1ps

module tb_matrix_buffer;

    parameter DATA_WIDTH = 8;
    parameter MEM_DEPTH = 8;
    parameter INPUT_PARALLEL_NUM = 8;
    parameter OUTPUT_PARALLEL_NUM = 3;
    parameter ADDR_WIDTH = $clog2(MEM_DEPTH);

    logic clk, clka;
    logic nrst;
    logic en_buf;
    
    logic [INPUT_PARALLEL_NUM-1:0][ADDR_WIDTH-1:0] addr_row_i;
    logic [INPUT_PARALLEL_NUM-1:0][DATA_WIDTH-1:0] mem_row_i;

    logic data_valid;
    logic [OUTPUT_PARALLEL_NUM-1:0][DATA_WIDTH-1:0] mem_row_o;

    matrix_buffer#(
        .DATA_WIDTH          ( 8 ),
        .MEM_DEPTH           ( 8 ),
        .INPUT_PARALLEL_NUM  ( 8 ),
        .OUTPUT_PARALLEL_NUM ( 3 )
    )u_matrix_buffer(
        .clk          ( clk        ),
        .nrst         ( nrst       ),
        .en_buf       ( en_buf     ),
        .addr_row_i   ( addr_row_i ),
        .mem_row_i    ( mem_row_i  ),
        .data_valid   ( data_valid ),
        .mem_row_o    ( mem_row_o  )
    );

    assign clka = clk;

    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(8),                       // Specify RAM data width
      .RAM_DEPTH(8),                     // Specify RAM depth (number of entries)
      .INIT_FILE("data1.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) ram1 (
      .addra(addr_row_i[0]),     // Address bus, width determined from RAM_DEPTH
      .dina(),       // RAM input data, width determined from RAM_WIDTH
      .clka(clka),       // Clock
      .wea(1'b0),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(mem_row_i[0])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(8),                       // Specify RAM data width
      .RAM_DEPTH(8),                     // Specify RAM depth (number of entries)
      .INIT_FILE("data2.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) ram2 (
      .addra(addr_row_i[1]),     // Address bus, width determined from RAM_DEPTH
      .dina(),       // RAM input data, width determined from RAM_WIDTH
      .clka(clka),       // Clock
      .wea(1'b0),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(mem_row_i[1])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(8),                       // Specify RAM data width
      .RAM_DEPTH(8),                     // Specify RAM depth (number of entries)
      .INIT_FILE("data3.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) ram3 (
      .addra(addr_row_i[2]),     // Address bus, width determined from RAM_DEPTH
      .dina(),       // RAM input data, width determined from RAM_WIDTH
      .clka(clka),       // Clock
      .wea(1'b0),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(mem_row_i[2])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(8),                       // Specify RAM data width
      .RAM_DEPTH(8),                     // Specify RAM depth (number of entries)
      .INIT_FILE("data4.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) ram4 (
      .addra(addr_row_i[3]),     // Address bus, width determined from RAM_DEPTH
      .dina(),       // RAM input data, width determined from RAM_WIDTH
      .clka(clka),       // Clock
      .wea(1'b0),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(mem_row_i[3])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(8),                       // Specify RAM data width
      .RAM_DEPTH(8),                     // Specify RAM depth (number of entries)
      .INIT_FILE("data5.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) ram5 (
      .addra(addr_row_i[4]),     // Address bus, width determined from RAM_DEPTH
      .dina(),       // RAM input data, width determined from RAM_WIDTH
      .clka(clka),       // Clock
      .wea(1'b0),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(mem_row_i[4])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(8),                       // Specify RAM data width
      .RAM_DEPTH(8),                     // Specify RAM depth (number of entries)
      .INIT_FILE("data6.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) ram6 (
      .addra(addr_row_i[5]),     // Address bus, width determined from RAM_DEPTH
      .dina(),       // RAM input data, width determined from RAM_WIDTH
      .clka(clka),       // Clock
      .wea(1'b0),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(mem_row_i[5])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(8),                       // Specify RAM data width
      .RAM_DEPTH(8),                     // Specify RAM depth (number of entries)
      .INIT_FILE("data7.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) ram7 (
      .addra(addr_row_i[6]),     // Address bus, width determined from RAM_DEPTH
      .dina(),       // RAM input data, width determined from RAM_WIDTH
      .clka(clka),       // Clock
      .wea(1'b0),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(mem_row_i[6])      // RAM output data, width determined from RAM_WIDTH
    );

    xilinx_single_port_ram_read_first #(
      .RAM_WIDTH(8),                       // Specify RAM data width
      .RAM_DEPTH(8),                     // Specify RAM depth (number of entries)
      .INIT_FILE("data8.mem")          // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) ram8 (
      .addra(addr_row_i[7]),     // Address bus, width determined from RAM_DEPTH
      .dina(),       // RAM input data, width determined from RAM_WIDTH
      .clka(clka),       // Clock
      .wea(1'b0),         // Write enable
      .ena(1'b1),         // RAM Enable, for additional power savings, disable port when not in use
      .rsta(1'b0),       // Output reset (does not affect memory contents)
      .regcea(1'b1),   // Output register enable
      .douta(mem_row_i[7])      // RAM output data, width determined from RAM_WIDTH
    );


    always begin
        #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/matrix_buffer.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_matrix_buffer); //store everything at the current level and below
        $display("Testing assorted values");
        
        // initialize
        clk = 1;  nrst = 0; en_buf = 0;
        #1;
        #20 nrst = 1;
        #20 en_buf = 1;
        #10 en_buf = 0;
        
        #10000
        
        $display("Finishing Sim"); //print nice message
        $finish;
    end
endmodule

`default_nettype wire