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
        $display("\n===== TESTE TOP_CLASSIFIER =====");

        cycles = 0;

        // RESET
        @(posedge clk);
        rst = 0;

        // START
        start_pulse();

        // ESPERA (tempo alto)
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

        $display("\n==== RESULTADO FINAL ====");
        $display("Digit = %d", digit);
        $display("Cycles = %d", cycles);

        if (^digit === 1'bx)
            $display("FAIL: digit X");
        else if (digit <= 9)
            $display("PASS");
        else
            $display("FAIL: digit inválido");

        $display("========================\n");

        #50 $stop;
    end

endmodule