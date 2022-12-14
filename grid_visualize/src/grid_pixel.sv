`default_nettype wire

module grid_pixel #(
    parameter WIDTH=480, HEIGHT=480
) (
    input wire [10:0] hcount_in,
    input wire [9:0]  vcount_in,
    output logic [11:0] pixel_out
);

    localparam GRID = 60;

    logic [HEIGHT-1:0][WIDTH-1:0] grid;
    always_comb begin
        for(int i=0; i<HEIGHT; i=i+1) begin
            for(int j=0; j<WIDTH; j=j+1) begin
                if((55<i%GRID | i%GRID<5) && ((55<j%GRID | j%GRID<5)) ) grid[i][j] = 0;
                else grid[i][j] = 1;
            end
        end
    end

    always_comb begin
        if(hcount_in >= WIDTH | vcount_in > HEIGHT) pixel_out = 0;
        else pixel_out = (grid[vcount_in][hcount_in]==1) ? 12'hFFF : 12'h888;
    end

endmodule

`default_nettype wire