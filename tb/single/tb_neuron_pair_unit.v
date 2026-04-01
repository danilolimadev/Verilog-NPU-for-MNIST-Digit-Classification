`timescale 1ns/1ps

module tb_top_classifier;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    wire done;
    wire [15:0] score0;
    wire [15:0] score1;
    wire [3:0] state_debug;

    neuron_pair_unit DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .score0(score0),
        .score1(score1),
        .state_debug(state_debug)
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
        $display("\n===== TESTE NEURON_PAIR_UNIT =====");

        cycles = 0;

        // RESET
        @(posedge clk);
        rst = 0;

        // START
        start_pulse();

        // 🔥 TEMPO REAL: 784 * latência da NPU (~10k)
        while (!done && cycles < 2000000) begin
            @(posedge clk);
            cycles = cycles + 1;

            // debug leve a cada 100k
            if (cycles % 100000 == 0)
                $display("... ciclos = %d | state = %d", cycles, state_debug);
        end

        if (!done) begin
            $display("FAIL: timeout (provavelmente NPU não está finalizando)");
            $stop;
        end

        $display("CYCLES = %d", cycles);
        $display("SCORE0 = %d", score0);
        $display("SCORE1 = %d", score1);

        if (^score0 === 1'bx || ^score1 === 1'bx)
            $display("FAIL: X detectado");
        else if (score0 != 0 || score1 != 0)
            $display("PASS");
        else
            $display("FAIL: score zero");

        $display("===== FIM TESTE =====\n");

        #20 $stop;
    end

endmodule