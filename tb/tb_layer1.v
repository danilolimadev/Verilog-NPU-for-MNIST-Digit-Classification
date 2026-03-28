`timescale 1ns/1ps

module tb_layer1;

    // sinais
    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    wire done;
    wire [4:0] pair_results;

    // =========================
    // DUT
    // =========================
    layer1 DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .pair_results(pair_results)
    );

    // =========================
    // CLOCK (100MHz)
    // =========================
    always #5 clk = ~clk;

    // =========================
    // MONITOR
    // =========================
    initial begin
        $display("======================================");
        $display(" TESTE LAYER1 ");
        $display("======================================");

        $monitor("T=%0t | DONE=%b | RESULTS=%b",
                 $time, done, pair_results);
    end

    // =========================
    // ESTÍMULO
    // =========================
    initial begin
        // reset
        #10 rst = 0;

        // start (1 ciclo)
        #10 start = 1;
        #10 start = 0;

        // espera terminar
        wait(done);

        #10;

        $display("\n==== RESULTADO FINAL ====");
        $display("Pair results = %b", pair_results);

        // =========================
        // VALIDAÇÃO
        // =========================
        // Como neuron_pair_unit usa:
        // (1*1) vs (2*1) → sempre ganha neurônio 1

        if (pair_results == 5'b11111)
            $display("PASS ✅ todos pares corretos");
        else
            $display("FAIL ❌ resultado inesperado");

        $display("=========================\n");

        #20 $finish;
    end

endmodule