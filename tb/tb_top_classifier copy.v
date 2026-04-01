`timescale 1ns/1ps

module tb_top_classifier;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    wire done;
    wire [3:0] digit;

    integer cycle_count;

    top_classifier DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .digit(digit)
    );

    // =========================
    // CLOCK
    // =========================
    always #5 clk = ~clk;

    // =========================
    // CONTADOR DE CICLOS (CORRIGIDO)
    // =========================
    always @(posedge clk) begin
        if (rst)
            cycle_count <= 0;
        else if (!done)
            cycle_count <= cycle_count + 1;
    end

    // =========================
    // MONITOR
    // =========================
    initial begin
        $display("======================================");
        $display(" TESTE CLASSIFICADOR MNIST (REAL)");
        $display("======================================");
    end

    // =========================
    // TESTE PRINCIPAL
    // =========================
    initial begin

        // reset
        repeat(5) @(posedge clk);
        rst = 0;

        // 🔥 START SINCRONIZADO (CORREÇÃO IMPORTANTE)
        @(posedge clk);
        start = 1;

        @(posedge clk);
        start = 0;

        // =========================
        // ESPERA COM TIMEOUT
        // =========================
        while (!done && cycle_count < 1000000) begin
            @(posedge clk);
        end

        if (!done) begin
            $display("TIMEOUT ❌ - demorou demais");
            $finish;
        end

        @(posedge clk);

        $display("\n==== RESULTADO FINAL ====");
        $display("Digit = %d", digit);
        $display("Total ciclos = %d", cycle_count);

        if (digit <= 9)
            $display("PASS ✅ valor válido");
        else
            $display("FAIL ❌ valor inválido");

        $display("=========================\n");

        #20 $stop;
    end

endmodule