`timescale 1ns/1ps

module tb_neuron;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    wire done;
    wire [7:0] result;
    wire [3:0] state_debug;

    neuron_pair_unit DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .result(result),
        .state_debug(state_debug)
    );

    // clock
    always #5 clk = ~clk;

    initial begin
        $display("======================================");
        $display(" TESTE NPU - NEURON PAIR (CORRIGIDO)");
        $display("======================================");

        $monitor("T=%0t | DONE=%b | RESULT=%d | STATE=%d",
                 $time, done, result, state_debug);
    end

    initial begin
        rst = 1;
        #10 rst = 0;

        #10 start = 1;
        #10 start = 0;

        wait(done);

        $display("Resultados pares = %b", pair_results);

        $finish;
    end

    /*initial begin
        // reset
        #10 rst = 0;

        // start (1 ciclo)
        #10 start = 1;
        #10 start = 0;

        // espera finalizar
        wait(done);

        #10;

        $display("\n==== RESULTADO FINAL ====");
        $display("Saída da NPU = %d", result);

        // esperado: neuron1 > neuron0 → index = 1
        if (result == 1)
            $display("PASS ✅ correto");
        else
            $display("FAIL ❌ inesperado");

        $display("=========================\n");

        #20 $finish;
    end*/

endmodule