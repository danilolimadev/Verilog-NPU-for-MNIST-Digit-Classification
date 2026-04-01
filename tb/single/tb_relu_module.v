`timescale 1ns/1ps

module tb_top_classifier;

    reg CLKEXT = 0;
    reg RST_GLO = 1;
    reg EN_ReLU = 0;
    reg BYPASS_ReLU = 0;
    reg [15:0] Data_Reg = 0;

    wire [15:0] ReLU_OUT;

    // DUT
    relu_module DUT (
        .Data_Reg(Data_Reg),
        .EN_ReLU(EN_ReLU),
        .BYPASS_ReLU(BYPASS_ReLU),
        .RST_GLO(RST_GLO),
        .CLKEXT(CLKEXT),
        .ReLU_OUT(ReLU_OUT)
    );

    // CLOCK
    always #5 CLKEXT = ~CLKEXT;

    // =========================
    // TESTE CORRETO
    // =========================
    initial begin
        $display("\n===== TESTE RELU =====");

        // RESET
        @(posedge CLKEXT);
        @(posedge CLKEXT);
        RST_GLO = 0;

        // =========================
        // TESTE 1: positivo
        // =========================
        Data_Reg = 16'd25;
        EN_ReLU = 1;
        BYPASS_ReLU = 0;

        @(posedge CLKEXT); // ciclo de processamento
        @(posedge CLKEXT); // ciclo de saída válida

        if (ReLU_OUT == 25)
            $display("TESTE 1 PASS");
        else
            $display("TESTE 1 FAIL: %d", ReLU_OUT);

        // =========================
        // TESTE 2: negativo
        // =========================
        Data_Reg = -16'd10;

        @(posedge CLKEXT);
        @(posedge CLKEXT);

        if (ReLU_OUT == 0)
            $display("TESTE 2 PASS");
        else
            $display("TESTE 2 FAIL: %d", ReLU_OUT);

        // =========================
        // TESTE 3: bypass
        // =========================
        EN_ReLU = 0;
        BYPASS_ReLU = 1;
        Data_Reg = -16'd20;

        @(posedge CLKEXT);
        @(posedge CLKEXT);

        if (ReLU_OUT == -16'd20)
            $display("TESTE 3 PASS");
        else
            $display("TESTE 3 FAIL: %d", ReLU_OUT);

        // =========================
        // TESTE 4: hold
        // =========================
        BYPASS_ReLU = 0;
        EN_ReLU = 0;
        Data_Reg = 16'd99;

        @(posedge CLKEXT);
        @(posedge CLKEXT);

        if (ReLU_OUT == -16'd20)
            $display("TESTE 4 PASS");
        else
            $display("TESTE 4 FAIL: %d", ReLU_OUT);

        // =========================
        // TESTE 5: reset
        // =========================
        RST_GLO = 1;

        @(posedge CLKEXT);

        if (ReLU_OUT == 0)
            $display("TESTE 5 PASS");
        else
            $display("TESTE 5 FAIL: %d", ReLU_OUT);

        $display("===== FIM TESTE RELU =====\n");
        #20 $stop;
    end

endmodule