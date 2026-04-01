`timescale 1ns/1ps

module tb_top_classifier;

    reg CLKEXT = 0;
    reg RST_GLO = 1;
    reg START = 0;

    reg [15:0] SSFR = 0;
    reg [15:0] CON_SIG = 0;

    reg [7:0] DA, DB, DC, DD;
    reg [7:0] BIAS_IN;

    wire [7:0] D_OUT;
    wire FIFO_FULL, FIFO_EMPTY;
    wire BUSY, DONE;
    wire [3:0] STATE_DEBUG;

    npu_top DUT (
        .CLKEXT(CLKEXT),
        .RST_GLO(RST_GLO),
        .START(START),
        .SSFR(SSFR),
        .CON_SIG(CON_SIG),
        .DA(DA),
        .DB(DB),
        .DC(DC),
        .DD(DD),
        .BIAS_IN(BIAS_IN),
        .D_OUT(D_OUT),
        .FIFO_FULL(FIFO_FULL),
        .FIFO_EMPTY(FIFO_EMPTY),
        .BUSY(BUSY),
        .DONE(DONE),
        .STATE_DEBUG(STATE_DEBUG)
    );

    always #5 CLKEXT = ~CLKEXT;

    initial begin
        $display("\n===== TESTE NPU_TOP =====");

        // RESET
        @(posedge CLKEXT);
        RST_GLO = 0;

        // INPUT
        DA = 8'd5;
        DB = 8'd2;
        DC = 8'd7;
        DD = 8'd1;
        BIAS_IN = 8'd1;

        // START
        @(posedge CLKEXT);
        START = 1;
        @(posedge CLKEXT);
        START = 0;

        // WAIT DONE
        wait(DONE);

        $display("D_OUT = %d", D_OUT);
        $display("STATE = %d", STATE_DEBUG);
        $display("BUSY = %b", BUSY);
        $display("DONE = %b", DONE);

        if (^D_OUT === 1'bx)
            $display("FAIL: saída indefinida");
        else
            $display("PASS");

        $display("===== FIM TESTE =====\n");

        #20 $stop;
    end

endmodule