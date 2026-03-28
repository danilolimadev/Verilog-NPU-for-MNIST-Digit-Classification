module mnist_npu_top (
    input clk,
    input rst,
    input start,
    output done,
    output [7:0] result
);

    // Entradas fixas (teste)
    reg [7:0] DA, DB, DC, DD;
    reg [7:0] BIAS;

    wire [7:0] D_OUT;
    wire DONE;
    wire BUSY;

    // sinais debug (não usados)
    wire [15:0] SSFR = 0;
    wire [15:0] CON_SIG = 0;
    wire FIFO_FULL, FIFO_EMPTY;
    wire [3:0] STATE_DEBUG;

    // Instância da NPU
    npu_top NPU (
        .CLKEXT(clk),
        .RST_GLO(rst),
        .START(start),
        .SSFR(SSFR),
        .CON_SIG(CON_SIG),
        .DA(DA),
        .DB(DB),
        .DC(DC),
        .DD(DD),
        .BIAS_IN(BIAS),
        .D_OUT(D_OUT),
        .FIFO_FULL(FIFO_FULL),
        .FIFO_EMPTY(FIFO_EMPTY),
        .BUSY(BUSY),
        .DONE(DONE),
        .STATE_DEBUG(STATE_DEBUG)
    );

    assign result = D_OUT;
    assign done   = DONE;

    // valores de teste
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            DA   <= 0;
            DB   <= 0;
            DC   <= 0;
            DD   <= 0;
            BIAS <= 0;
        end else if (start) begin
            DA   <= 1;
            DB   <= 2;
            DC   <= 3;
            DD   <= 4;
            BIAS <= 0;
        end
    end

endmodule