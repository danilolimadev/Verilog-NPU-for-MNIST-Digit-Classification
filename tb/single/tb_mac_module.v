`timescale 1ns/1ps

module tb_top_classifier;

    reg CLKEXT = 0;
    reg EN_MAC = 0;
    reg RST_MAC = 0;

    reg [7:0] A = 0;
    reg signed [7:0] B = 0;
    reg [7:0] BIAS_IN = 0;

    wire signed [15:0] Y;

    mac_module DUT (
        .CLKEXT(CLKEXT),
        .EN_MAC(EN_MAC),
        .RST_MAC(RST_MAC),
        .BIAS_IN(BIAS_IN),
        .A(A),
        .B(B),
        .Y(Y)
    );

    always #5 CLKEXT = ~CLKEXT;

    // 🔥 tarefa: pulso de 1 ciclo
    task mac_step;
    begin
        EN_MAC = 1;
        @(posedge CLKEXT);
        EN_MAC = 0;
        @(posedge CLKEXT); // espera atualizar Y
    end
    endtask

    initial begin
        $display("\n===== TESTE MAC =====");

        // RESET
        BIAS_IN = 8'd10;
        RST_MAC = 1;
        @(posedge CLKEXT);

        if (Y == 10)
            $display("TESTE 1 PASS (bias)");
        else
            $display("TESTE 1 FAIL: %d", Y);

        RST_MAC = 0;

        // =========================
        // TESTE 2
        // =========================
        A = 8'd2;
        B = 8'd3;

        mac_step();

        if (Y == 16)
            $display("TESTE 2 PASS");
        else
            $display("TESTE 2 FAIL: %d", Y);

        // =========================
        // TESTE 3
        // =========================
        mac_step();

        if (Y == 22)
            $display("TESTE 3 PASS");
        else
            $display("TESTE 3 FAIL: %d", Y);

        // =========================
        // TESTE 4
        // =========================
        B = -8'd5;

        mac_step();

        if (Y == 12)
            $display("TESTE 4 PASS");
        else
            $display("TESTE 4 FAIL: %d", Y);

        // =========================
        // TESTE 5 (sat +)
        // =========================
        A = 8'd127;
        B = 8'd127;

        repeat(20) mac_step();

        if (Y == 16'h7FFF)
            $display("TESTE 5 PASS");
        else
            $display("TESTE 5 FAIL: %d", Y);

        // =========================
        // TESTE 6 (sat -)
        // =========================
        RST_MAC = 1;
        @(posedge CLKEXT);
        RST_MAC = 0;

        A = 8'd127;
        B = -8'd127;

        repeat(20) mac_step();

        if (Y == 16'h8000)
            $display("TESTE 6 PASS");
        else
            $display("TESTE 6 FAIL: %d", Y);

        $display("===== FIM TESTE MAC =====\n");

        #20 $stop;
    end

endmodule