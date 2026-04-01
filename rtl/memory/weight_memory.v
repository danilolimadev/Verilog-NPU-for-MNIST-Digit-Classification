module weight_memory #(
    parameter FILE = "E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights.mem"
)(
    input clk,
    input [9:0] addr,
    output reg [7:0] data
);

    reg [7:0] mem [0:1023];

    initial begin
        $readmemh(FILE, mem);
    end

    always @(posedge clk)
        data <= mem[addr];

endmodule