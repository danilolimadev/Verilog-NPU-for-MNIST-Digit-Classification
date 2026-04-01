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
    // CONTADOR DE CICLOS
    // =========================
    always @(posedge clk) begin
        if (!rst && !done)
            cycle_count <= cycle_count + 1;
    end

    // =========================
    // MONITOR
    // =========================
    initial begin
        $display("======================================");
        $display(" TESTE CLASSIFICADOR MNIST (REAL)");
        $display("======================================");

        /*$monitor("T=%0t | DONE=%b | DIGIT=%d | CYCLES=%d",
                 $time, done, digit, cycle_count);*/
    end

    // =========================
    // TESTE PRINCIPAL
    // =========================
    initial begin
        cycle_count = 0;

        // reset
        #20 rst = 0;

        // start
        #20 start = 1;
        #10 start = 0;

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

        #20;

        $display("\n==== RESULTADO FINAL ====");
        $display("Digit = %d", digit);
        $display("Total ciclos = %d", cycle_count);

        // validação básica
        if (digit <= 9)
            $display("PASS ✅ valor válido");
        else
            $display("FAIL ❌ valor inválido");

        $display("=========================\n");

        #50 $stop;
    end

endmodule