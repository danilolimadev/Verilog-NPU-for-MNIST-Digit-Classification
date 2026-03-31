module bias_memory #(
    parameter FILE = "data/bias.mem"
)(
    input clk,
    input [3:0] addr,     // 10 neurônios → 4 bits
    output reg [7:0] data
);

    reg [7:0] mem [0:15];

    initial begin
        $readmemh(FILE, mem);
    end

    always @(posedge clk)
        data <= mem[addr];

endmodule