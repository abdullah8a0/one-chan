`default_nettype none

module tb_spi_host;

    parameter DATA_WIDTH = 8;// output 1 byte(8-bit) at one spi_clk cycle
    parameter BIT_DUR = 2;
    parameter BYTE_STORE = 250; // maximum store data in interface before send data

    logic clk;
    logic nrst;
    logic en;
    //logic [7:0] data_length;

    logic load_iv;
    logic [DATA_WIDTH-1:0] load_id;
    
    logic clk_out;
    logic sel_out;
    logic [DATA_WIDTH-1:0] data_out;

    spi_host#(
        .DATA_WIDTH    ( 8 ),
        .BIT_DUR       ( 2 ),
        .BYTE_STORE    ( 20 )
    )u_spi_host(
        .clk         ( clk           ),
        .nrst        ( nrst          ),
        //.en          ( en            ),
        //.data_length ( data_length   ),
        .load_iv     ( load_iv       ),
        .load_id     ( load_id       ),
        .clk_out     ( clk_out ),
        .sel_out     ( sel_out ),
        .data_out    ( data_out  )
    );

    always begin
        #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/spi_host.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_spi_host); //store everything at the current level and below
        $display("Testing assorted values");
        
        // initialize
        clk = 1;  nrst = 0;
        en = 0;   load_iv = 0;
        load_id = 0;
        #1;
        #10 nrst = 1;
        #10 en = 1;
        #10 en = 0;

        #10;
        #10 load_iv = 1;
        for(int i=1; i<15; i=i+1) begin
            #10 load_id = i;
        end
        #10 load_iv = 0;

        #5000;
        
        $display("Finishing Sim"); //print nice message
        $finish;
    end

endmodule 

`default_nettype wire