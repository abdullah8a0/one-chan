`default_nettype none

module seven_seg #(parameter COUNT_TO = 'd100_000) (
        input wire         clk,
        input wire         rst,
        input board_pos_t  row [7:0],

        output logic[6:0]   cat_out,
        output logic        dot_out,
        output logic[7:0]   an_out
    );
    logic [7:0]	segment_state;
    logic [31:0]	segment_counter;
    logic [7:0]	routed_vals;
    logic [6:0]	led_out;

    localparam EMPTY     = 6'b111111;
    localparam KING      = 6'b000001;
    localparam QUEEN     = 6'b000010;
    localparam ROOK      = 6'b000100;
    localparam KNIGHT    = 6'b001000;
    localparam BISHOP    = 6'b010000;
    localparam PAWN      = 6'b100000;

    localparam WHITE     = 2'b01;
    localparam BLACK     = 2'b10;

    always_comb begin 
        case (segment_state)
            8'b0000_0001: 
            routed_vals = `piece(row[0]);
            8'b0000_0010: 
            routed_vals = `piece(row[1]);
            8'b0000_0100: 
            routed_vals = `piece(row[2]);
            8'b0000_1000: 
            routed_vals = `piece(row[3]);
            8'b0001_0000: 
            routed_vals = `piece(row[4]);
            8'b0010_0000: 
            routed_vals = `piece(row[5]);
            8'b0100_0000: 
            routed_vals = `piece(row[6]);
            8'b1000_0000: 
            routed_vals = `piece(row[7]);
            default: routed_vals = EMPTY;
        endcase       
    end

  cto7s mcto7s (.x_in(routed_vals), .s_out(led_out));
  assign cat_out = ~led_out; //<--note this inversion is needed
  assign dot_out = `color(routed_vals) == WHITE ? 1'b1 : 1'b0;
  assign an_out = ~segment_state; //note this inversion is needed

  always_ff @(posedge clk)begin
    if (rst)begin
      segment_state <= 8'b0000_0001;
      segment_counter <= 32'b0;
    end else begin
      if (segment_counter == COUNT_TO) begin
        segment_counter <= 32'd0;
        segment_state <= {segment_state[6:0],segment_state[7]};
    	end else begin
    	  segment_counter <= segment_counter +1;
    	end
    end
  end
endmodule // seven_segment_controller


module cto7s(
        input logic [5:0] x_in,
        output logic [6:0] s_out
        );
        // array of bits that are "one hot" with chess pieces


        localparam EMPTY     = 6'b111111;
        localparam KING      = 6'b000001;
        localparam QUEEN     = 6'b000010;
        localparam ROOK      = 6'b000100;
        localparam KNIGHT    = 6'b001000;
        localparam BISHOP    = 6'b010000;
        localparam PAWN      = 6'b100000;

        logic [6:0] pie;
        always_comb begin
          case (x_in)
              KING:   pie = 7'b0000001; // 0
              QUEEN:  pie = 7'b0000010; // 1
              ROOK:   pie = 7'b0000100; // 2
              KNIGHT: pie = 7'b0001000; // 3
              BISHOP: pie = 7'b0010000; // 4
              PAWN:   pie = 7'b0100000; // 5
              default: pie = 7'b1000000; // 6
          endcase
        end 



        logic sa,sb,sc,sd,se,sf,sg;

          
         

        assign sa = ~(pie[0] || pie[3] || pie[6]);
        assign sb = ~(pie[3] || pie[6]);
        assign sc = ~(pie[5] || pie[6]);
        assign sd = ~(pie[5] || pie[3] || pie[2] || pie [1]);
        assign se = ~(pie[1] || pie[6]);
        assign sf = ~(pie[3] || pie[6]);
        assign sg = ~(pie[2] || pie[6]);
        
        assign s_out = {sg, sf, se, sd, sc, sb, sa};

endmodule





`default_nettype wire