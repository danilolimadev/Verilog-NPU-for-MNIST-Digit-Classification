`timescale 1ns/1ps

module tb_top_classifier;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    wire done;
    wire [4:0] pair_results;

    wire [15:0] score0, score1, score2, score3, score4;

    layer1 DUT (  // :contentReference[oaicite:0]{index=0}
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .pair_results(pair_results),
        .score0(score0),
        .score1(score1),
        .score2(score2),
        .score3(score3),
        .score4(score4)
    );

    always #5 clk = ~clk;

    task start_pulse;
    begin
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
    end
    endtask

    integer cycles;

    initial begin
        $display("\n===== TESTE LAYER1 =====");

        cycles = 0;

        // RESET
        @(posedge clk);
        rst = 0;

        // START
        start_pulse();

        // ESPERA (tempo grande)
        while (!done && cycles < 5000000) begin
            @(posedge clk);
            cycles = cycles + 1;

            if (cycles % 500000 == 0)
                $display("... ciclos = %d", cycles);
        end

        if (!done) begin
            $display("FAIL: timeout");
            $stop;
        end

        $display("\n==== RESULTADOS ====");
        $display("CYCLES = %d", cycles);
        $display("pair_results = %b", pair_results);

        $display("score0 = %d", score0);
        $display("score1 = %d", score1);
        $display("score2 = %d", score2);
        $display("score3 = %d", score3);
        $display("score4 = %d", score4);

        if (^pair_results === 1'bx)
            $display("FAIL: pair_results X");
        else if (score0 == 0 && score1 == 0 && score2 == 0 && score3 == 0 && score4 == 0)
            $display("FAIL: scores zerados");
        else
            $display("PASS");

        $display("====================\n");

        #50 $stop;
    end

endmodule