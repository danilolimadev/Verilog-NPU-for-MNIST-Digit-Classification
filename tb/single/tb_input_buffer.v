`timescale 1ns/1ps

module tb_top_classifier;

    reg CLKEXT = 0;
    reg CLR_BUF_IN = 0;
    reg EN_BUF_IN = 0;

    reg [7:0] DA, DB, DC, DD;

    wire [7:0] QA, QB, QC, QD;

    input_buffer DUT (
        .CLKEXT(CLKEXT),
        .CLR_BUF_IN(CLR_BUF_IN),
        .EN_BUF_IN(EN_BUF_IN),
        .DA(DA), .DB(DB), .DC(DC), .DD(DD),
        .QA(QA), .QB(QB), .QC(QC), .QD(QD)
    );

    always #5 CLKEXT = ~CLKEXT;

    initial begin
        $display("\n===== TESTE INPUT BUFFER =====");

        // RESET
        CLR_BUF_IN = 1;
        @(posedge CLKEXT);
        CLR_BUF_IN = 0;

        @(posedge CLKEXT);

        if (QA==0) $display("TESTE 1 PASS");
        else $display("TESTE 1 FAIL");

        // LOAD
        DA=1; DB=2; DC=3; DD=4;
        EN_BUF_IN = 1;

        @(posedge CLKEXT); // captura
        EN_BUF_IN = 0;

        @(posedge CLKEXT); // atualiza saída

        if (QA==1 && QB==2 && QC==3 && QD==4)
            $display("TESTE 2 PASS");
        else
            $display("TESTE 2 FAIL: %d %d %d %d", QA,QB,QC,QD);

        // UPDATE
        DA=10; DB=20; DC=30; DD=40;
        EN_BUF_IN = 1;

        @(posedge CLKEXT);
        EN_BUF_IN = 0;

        @(posedge CLKEXT);

        if (QA==10 && QB==20 && QC==30 && QD==40)
            $display("TESTE 3 PASS");
        else
            $display("TESTE 3 FAIL: %d %d %d %d", QA,QB,QC,QD);

        $display("===== FIM TESTE =====\n");

        #20 $stop;
    end

endmodule