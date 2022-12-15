`define ADD   3'b000
`define MUL   3'b001 
`define SHL   3'b010  // arithmetic shift?
`define SHR   3'b011
`define BAND  3'b100  
`define BXOR  3'b101 
`define BOR   3'b110

`define EQ    3'b000 
`define NE    3'b001 
`define GE    3'b010 
`define LE    3'b011 
`define GT    3'b100
`define LT    3'b101
`define NEG   3'b110 


module ALU (
    input wire signed [31:0] a,
    input wire signed [31:0] b,

    input wire [2:0] alu_funct,
    input wire [2:0] br_funct,

    output logic br_out,
    output logic signed [31:0] alu_out
);

    wire [15:0] m, y;

    assign m = a + 16'h8000;
    assign y = b + 16'h8000;

    always_comb begin
        case( alu_funct )
            `ADD  : alu_out = b + a;
            `MUL  : alu_out = b * a;
            `SHL  : alu_out = b << a;
            `SHR  : alu_out = b >> a;
            `BAND : alu_out = b & a;
            `BXOR : alu_out = b ^ a;
            `BOR  : alu_out = b | a;
            default: alu_out = a;
        endcase
    end

    always_comb begin
        case(br_funct) 
            `EQ   : br_out = (b==a);
            `NE   : br_out = (b!=a);
            `GE   : br_out = (a>=b);
            `LE   : br_out = (a<=b);
            `GT   : br_out = (a>b);
            `LT   : br_out = (b<a);
            `NEG  : br_out = -a;
            default : br_out = 0;
        endcase
    end

endmodule