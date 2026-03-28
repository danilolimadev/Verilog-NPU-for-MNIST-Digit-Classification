`timescale 1ns/1ps

module tb_top_classifier;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    wire done;
    wire [3:0] digit;

    top_classifier DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .digit(digit)
    );

    always #5 clk = ~clk;

    initial begin
        $display("======================================");
        $display(" TESTE CLASSIFICADOR COMPLETO ");
        $display("======================================");

        $monitor("T=%0t | DONE=%b | DIGIT=%d",
                 $time, done, digit);
    end

    initial begin
        #10 rst = 0;

        #10 start = 1;
        #10 start = 0;

        wait(done);

        #10;

        $display("\n==== RESULTADO FINAL ====");
        $display("Digit = %d", digit);

        #20 $finish;
    end

endmodule