
module tb_TPU;

    parameter WIDTH = 8;
    parameter HEIGHT = 8;
    parameter MOVE_WIDTH = 16;
    parameter DATA_WIDTH = 8;
    parameter MAX_MOVES = 220;
    parameter PC_ADDR_WIDTH = 12;

    parameter GRID_HEADER = 8'b11_01_01_01;
    parameter MOVE_HEADER = 8'b11_10_10_10;

    localparam EMPTY     = 8'b01_111111;
    localparam KING      = 6'b000001;
    localparam QUEEN     = 6'b000010;
    localparam ROOK      = 6'b000100;
    localparam KNIGHT    = 6'b001000;
    localparam BISHOP    = 6'b010000;
    localparam PAWN      = 6'b100000;
    localparam WHITE     = 2'b01;
    localparam BLACK     = 2'b10;

    logic [63:0][7:0] INIT_BOARD;
        assign INIT_BOARD[0] = {WHITE, ROOK};
        assign INIT_BOARD[1] = {WHITE, KNIGHT};
        assign INIT_BOARD[2] = {WHITE, BISHOP};
        assign INIT_BOARD[3] = {WHITE, QUEEN};
        assign INIT_BOARD[4] = {WHITE, KING};
        assign INIT_BOARD[5] = {WHITE, BISHOP};
        assign INIT_BOARD[6] = {WHITE, KNIGHT};
        assign INIT_BOARD[7] = {WHITE, ROOK};
        assign INIT_BOARD[8] = {WHITE, PAWN};
        assign INIT_BOARD[9] = {WHITE, PAWN};
        assign INIT_BOARD[10] = {WHITE, PAWN};
        assign INIT_BOARD[11] = {WHITE, PAWN};
        assign INIT_BOARD[12] = {WHITE, PAWN};
        assign INIT_BOARD[13] = {WHITE, PAWN};
        assign INIT_BOARD[14] = {WHITE, PAWN};
        assign INIT_BOARD[15] = {WHITE, PAWN};
        assign INIT_BOARD[16] = EMPTY;
        assign INIT_BOARD[17] = EMPTY;
        assign INIT_BOARD[18] = EMPTY;
        assign INIT_BOARD[19] = EMPTY;
        assign INIT_BOARD[20] = EMPTY;
        assign INIT_BOARD[21] = EMPTY;
        assign INIT_BOARD[22] = EMPTY;
        assign INIT_BOARD[23] = EMPTY;
        assign INIT_BOARD[24] = EMPTY;
        assign INIT_BOARD[25] = EMPTY;
        assign INIT_BOARD[26] = EMPTY;
        assign INIT_BOARD[27] = EMPTY;
        assign INIT_BOARD[28] = EMPTY;
        assign INIT_BOARD[29] = EMPTY;
        assign INIT_BOARD[30] = EMPTY;
        assign INIT_BOARD[31] = EMPTY;
        assign INIT_BOARD[32] = EMPTY;
        assign INIT_BOARD[33] = EMPTY;
        assign INIT_BOARD[34] = EMPTY;
        assign INIT_BOARD[35] = EMPTY;
        assign INIT_BOARD[36] = EMPTY;
        assign INIT_BOARD[37] = EMPTY;
        assign INIT_BOARD[38] = EMPTY;
        assign INIT_BOARD[39] = EMPTY;
        assign INIT_BOARD[40] = EMPTY;
        assign INIT_BOARD[41] = EMPTY;
        assign INIT_BOARD[42] = EMPTY;
        assign INIT_BOARD[43] = EMPTY;
        assign INIT_BOARD[44] = EMPTY;
        assign INIT_BOARD[45] = EMPTY;
        assign INIT_BOARD[46] = EMPTY;
        assign INIT_BOARD[47] = EMPTY;
        assign INIT_BOARD[48] = {BLACK, PAWN};
        assign INIT_BOARD[49] = {BLACK, PAWN};
        assign INIT_BOARD[50] = {BLACK, PAWN};
        assign INIT_BOARD[51] = {BLACK, PAWN};
        assign INIT_BOARD[52] = {BLACK, PAWN};
        assign INIT_BOARD[53] = {BLACK, PAWN};
        assign INIT_BOARD[54] = {BLACK, PAWN};
        assign INIT_BOARD[55] = {BLACK, PAWN};
        assign INIT_BOARD[56] = {BLACK, ROOK};
        assign INIT_BOARD[57] = {BLACK, KNIGHT};
        assign INIT_BOARD[58] = {BLACK, BISHOP};
        assign INIT_BOARD[59] = {BLACK, QUEEN};
        assign INIT_BOARD[60] = {BLACK, KING};
        assign INIT_BOARD[61] = {BLACK, BISHOP};
        assign INIT_BOARD[62] = {BLACK, KNIGHT};
        assign INIT_BOARD[63] = {BLACK, ROOK};
    
    logic clk;
    logic nrst;

    logic spi_iv;
    logic [DATA_WIDTH-1:0] spi_id;

    // input finish, then send moves to register files to activate the program
    logic [70-1:0][7:0] spi_ram_right;

    always_comb begin
        for(int i=0; i<70; i=i+1) begin
            if(i==0) spi_ram_right[i] = GRID_HEADER;
            else if(i<=64) spi_ram_right[i] = INIT_BOARD[i-1];
            else if(i==65) spi_ram_right[i] = MOVE_HEADER;
            else if(i==66) spi_ram_right[i] = 8'h01;
            else if(i==67) spi_ram_right[i] = 8'hB0;
            else if(i==68) spi_ram_right[i] = 8'hDA;
            else spi_ram_right[i] = 8'h40;
        end
    end

    
    TPU#(
        .WIDTH         ( 8 ),
        .HEIGHT        ( 8 ),
        .DATA_WIDTH    ( 8 ),
        .PC_ADDR_WIDTH ( 12 ),
        .MOVE_WIDTH    ( 16 ),
        .MAX_MOVES     ( 220 ),
        .GRID_HEADER   ( 8'b11_01_01_01 ),
        .MOVE_HEADER   ( 8'b11_10_10_10 ),
        .INSTR_FILE    ( "instruction.mem" ),
        .MAIN_MEM_FILE ( "main_mem.mem" )
    )u_TPU(
        .clk           ( clk           ),
        .nrst          ( nrst          ),
        .spi_iv        ( spi_iv        ),
        .spi_id        ( spi_id        )
    );

    
    initial begin
        clk = 1'd1;
        forever 
            #5 clk = ~clk;
    end

    initial begin
        $display("Starting Sim"); //print nice message
        $dumpfile("sim/vcd/id.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,tb_TPU); //store everything at the current level and below
        $display("Testing assorted values");
        
        //initalize
        clk=1; nrst=0;
        spi_id = 0; spi_iv = 0;

        #1;
        #10 nrst = 1;
        #10 spi_iv = 1; spi_id = spi_ram_right[0];
        for(int i=1; i<70; i=i+1) begin
            #10 spi_id = spi_ram_right[i];
        end
        #10 spi_iv = 0;
        #100;


        #10000;

        $display("Finishing Sim"); //print nice message
        $finish;
    end

endmodule

`default_nettype wire