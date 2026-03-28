module weight_memory (
    input clk,
    input [9:0] addr,
    output reg [7:0] data
);

    reg [7:0] mem [0:1023];

    /*initial begin
        // pesos exemplo
        mem[0] = 1;
        mem[1] = 1;
        mem[2] = 1;
        mem[3] = 1;
    end*/

    initial begin
        $readmemh("data/weights.mem", mem); //TODO: Provavelmente vai ter que colocar o definitivo aqui
    end

    always @(posedge clk) begin
        data <= mem[addr];
    end

endmodule