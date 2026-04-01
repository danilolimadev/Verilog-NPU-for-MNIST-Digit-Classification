module input_memory (
    input clk,
    input [9:0] addr,
    output reg [7:0] data
);

    reg [7:0] mem [0:1023];

    initial begin
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input.mem", mem); //TODO: PROVAVELMENTE VAI TER QUE COLOCAR O DEFINITIVO AQUI
    end

    always @(posedge clk) begin
        data <= mem[addr];
    end

endmodule