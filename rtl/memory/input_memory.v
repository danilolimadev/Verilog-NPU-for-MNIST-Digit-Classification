module input_memory (
    input clk,
    input [9:0] addr,
    output reg [7:0] data
);

    reg [7:0] mem [0:1023];

    /*initial begin
        // exemplo simples (depois vem MNIST)
        mem[0] = 1;
        mem[1] = 2;
        mem[2] = 3;
        mem[3] = 4;
    end*/

    initial begin
        $readmemh("data/input.mem", mem); //TODO: PROVAVELMENTE VAI TER QUE COLOCAR O DEFINITIVO AQUI
    end

    always @(posedge clk) begin
        data <= mem[addr];
    end

endmodule