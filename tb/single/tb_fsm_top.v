`timescale 1ns/1ps

module tb_top_classifier;

    reg CLKEXT = 0;
    reg RST_GLO = 1;
    reg START = 0;

    reg [7:0] DA, DB, DC, DD;
    reg [7:0] BIAS_IN;

    wire [15:0] OUT0, OUT1;
    wire [7:0] D_OUT;
    wire BUSY, DONE;

    npu_fsm_top DUT (
        .CLKEXT(CLKEXT),
        .RST_GLO(RST_GLO),
        .START(START),
        .SSFR(0),
        .CON_SIG(0),
        .DA(DA), .DB(DB), .DC(DC), .DD(DD),
        .BIAS_IN(BIAS_IN),
        .OUT0(OUT0),
        .OUT1(OUT1),
        .D_OUT(D_OUT),
        .FIFO_FULL(),
        .FIFO_EMPTY(),
        .BUSY(BUSY),
        .DONE(DONE),
        .STATE_DEBUG()
    );

    always #5 CLKEXT = ~CLKEXT;

    initial begin
        $display("\n===== TESTE FINAL =====");

        @(posedge CLKEXT);
        RST_GLO = 0;

        DA = 8'd5;
        DB = 8'd2;
        DC = 8'd7;
        DD = 8'd1;
        BIAS_IN = 8'd1;

        @(posedge CLKEXT);
        START = 1;
        @(posedge CLKEXT);
        START = 0;

        wait(DONE);

        $display("OUT0 = %d", OUT0);
        $display("OUT1 = %d", OUT1);
        $display("D_OUT = %d", D_OUT);

        if (^D_OUT === 1'bx)
            $display("FAIL");
        else
            $display("PASS");

        $display("===== FIM =====\n");

        #20 $stop;
    end

endmodule