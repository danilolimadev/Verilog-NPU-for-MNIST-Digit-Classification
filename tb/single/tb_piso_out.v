`timescale 1ns/1ps

module tb_top_classifier;

    reg CLKEXT = 0;
    reg RST_GLO = 1;

    reg EN_PISO_OUT = 0;
    reg CLR_PISO_OUT = 0;
    reg SHIFT_OUT = 0;

    reg [15:0] mac0_out = 0;
    reg [15:0] mac1_out = 0;

    wire [7:0] D_OUT;

    piso_out DUT (
        .CLKEXT(CLKEXT),
        .RST_GLO(RST_GLO),
        .EN_PISO_OUT(EN_PISO_OUT),
        .CLR_PISO_OUT(CLR_PISO_OUT),
        .SHIFT_OUT(SHIFT_OUT),
        .mac0_out(mac0_out),
        .mac1_out(mac1_out),
        .D_OUT(D_OUT)
    );

    always #5 CLKEXT = ~CLKEXT;

    initial begin
        $display("\n===== TESTE PISO_OUT =====");

        // RESET
        repeat(2) @(posedge CLKEXT);
        RST_GLO = 0;

        // LOAD
        mac0_out = 16'hABCD;
        mac1_out = 16'h1234;

        EN_PISO_OUT = 1;
        SHIFT_OUT = 0;

        @(posedge CLKEXT); // LOAD ocorre aqui

        // =========================
        // SHIFT MODE
        // =========================
        SHIFT_OUT = 1;

        // SHIFT 1
        @(posedge CLKEXT);
        if (D_OUT == 8'hAB)
            $display("SHIFT 1 PASS");
        else
            $display("SHIFT 1 FAIL: %h", D_OUT);

        // SHIFT 2
        @(posedge CLKEXT);
        if (D_OUT == 8'hCD)
            $display("SHIFT 2 PASS");
        else
            $display("SHIFT 2 FAIL: %h", D_OUT);

        // SHIFT 3
        @(posedge CLKEXT);
        if (D_OUT == 8'h12)
            $display("SHIFT 3 PASS");
        else
            $display("SHIFT 3 FAIL: %h", D_OUT);

        // SHIFT 4
        @(posedge CLKEXT);
        if (D_OUT == 8'h34)
            $display("SHIFT 4 PASS");
        else
            $display("SHIFT 4 FAIL: %h", D_OUT);

        // CLEAR
        CLR_PISO_OUT = 1;
        @(posedge CLKEXT);

        if (D_OUT == 0)
            $display("CLEAR PASS");
        else
            $display("CLEAR FAIL: %h", D_OUT);

        $display("===== FIM TESTE PISO_OUT =====\n");

        #20 $stop;
    end

endmodule