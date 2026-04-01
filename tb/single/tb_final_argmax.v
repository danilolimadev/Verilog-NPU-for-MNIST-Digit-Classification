`timescale 1ns/1ps

module tb_top_classifier;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    reg [15:0] score0, score1, score2, score3, score4;
    reg [4:0] pair_results;

    wire done;
    wire [3:0] digit;

    final_argmax DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .score0(score0),
        .score1(score1),
        .score2(score2),
        .score3(score3),
        .score4(score4),
        .pair_results(pair_results),
        .done(done),
        .digit(digit)
    );

    always #5 clk = ~clk;

    // pulso start
    task start_pulse;
    begin
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
    end
    endtask

    initial begin
        $display("\n===== TESTE FINAL_ARGMAX =====");

        // RESET
        @(posedge clk);
        rst = 0;

        // =========================
        // TESTE 1
        // maior = score2 → dígito 5
        // =========================
        score0 = 10;
        score1 = 20;
        score2 = 50;
        score3 = 15;
        score4 = 5;

        pair_results = 5'b00100; // só par2 → neurônio alto → dígito 5

        start_pulse();
        wait(done);

        $display("TESTE 1 digit = %d", digit);

        if (digit == 5)
            $display("PASS");
        else
            $display("FAIL");

        // =========================
        // TESTE 2
        // maior = score1 → dígito 2
        // =========================
        score0 = 10;
        score1 = 40;
        score2 = 30;
        score3 = 15;
        score4 = 5;

        pair_results = 5'b00000; // todos low → pares (0,2,4,6,8)

        start_pulse();
        wait(done);

        $display("TESTE 2 digit = %d", digit);

        if (digit == 2)
            $display("PASS");
        else
            $display("FAIL");

        // =========================
        // TESTE 3
        // maior = score4 → dígito 9
        // =========================
        score0 = 10;
        score1 = 20;
        score2 = 30;
        score3 = 40;
        score4 = 80;

        pair_results = 5'b10000; // par4 alto → dígito 9

        start_pulse();
        wait(done);

        $display("TESTE 3 digit = %d", digit);

        if (digit == 9)
            $display("PASS");
        else
            $display("FAIL");

        $display("===== FIM TESTE =====\n");

        #20 $stop;
    end

endmodule