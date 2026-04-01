module input_memory #(
    parameter INPUT_FILE = "data/input_0.mem"
)(
    input clk,
    input [9:0] addr,
    output reg [7:0] data
);

    reg [7:0] mem [0:1023];

    initial begin
        $display("Loading input file: %s", INPUT_FILE);
        $readmemh(INPUT_FILE, mem);
    end

    always @(posedge clk) begin
        data <= mem[addr];
    end

endmodule