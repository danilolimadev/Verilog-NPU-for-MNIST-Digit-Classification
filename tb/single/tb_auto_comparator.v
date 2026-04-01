`timescale 1ns/1ps

module tb_top_classifier;

    reg CLKEXT = 0;
    reg EN_COMP = 0;
    reg RST_COMP = 0;
    reg trig = 0;

    reg signed [15:0] in1, in2;

    wire [7:0] index;
    wire signed [15:0] largest;

    auto_comparator DUT (
        .CLKEXT(CLKEXT),
        .EN_COMP(EN_COMP),
        .RST_COMP(RST_COMP),
        .trig(trig),
        .in1(in1),
        .in2(in2),
        .index(index),
        .largest(largest)
    );

    always #5 CLKEXT = ~CLKEXT;

    // pulso de trigger
    task trigger;
    begin
        @(negedge CLKEXT);
        trig = 1;
        @(negedge CLKEXT);
        trig = 0;
    end
    endtask

    initial begin
        $display("\n===== TESTE AUTO COMPARATOR =====");

        // RESET
        RST_COMP = 1;
        @(posedge CLKEXT);
        RST_COMP = 0;

        EN_COMP = 1;

        // =========================
        // TESTE 1
        // =========================
        in1 = 10;
        in2 = 20;

        trigger();

        @(posedge CLKEXT);

        if (largest == 20 && index == 1)
            $display("TESTE 1 PASS");
        else
            $display("TESTE 1 FAIL: %d idx=%d", largest, index);

        // =========================
        // TESTE 2
        // =========================
        in1 = 50;
        in2 = 30;

        trigger();

        @(posedge CLKEXT);

        if (largest == 50 && index == 0)
            $display("TESTE 2 PASS");
        else
            $display("TESTE 2 FAIL");

        // =========================
        // TESTE 3 (negativos)
        // =========================
        in1 = -10;
        in2 = -3;

        trigger();

        @(posedge CLKEXT);

        if (largest == -3 && index == 1)
            $display("TESTE 3 PASS");
        else
            $display("TESTE 3 FAIL: %d", largest);

        $display("===== FIM TESTE =====\n");

        #20 $stop;
    end

endmodule