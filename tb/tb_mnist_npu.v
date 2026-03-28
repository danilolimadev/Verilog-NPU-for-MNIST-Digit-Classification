`timescale 1ns/1ps

module tb_mnist_npu;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    wire done;
    wire [7:0] result;

    mnist_npu_top DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .result(result)
    );

    always #5 clk = ~clk;

    initial begin
        $display("==== TESTE NPU ====");

        #10 rst = 0;

        #10 start = 1;
        #10 start = 0;

        wait(done);

        $display("Resultado = %d", result);

        $display("==== FIM ====");
        $finish;
    end

endmodule