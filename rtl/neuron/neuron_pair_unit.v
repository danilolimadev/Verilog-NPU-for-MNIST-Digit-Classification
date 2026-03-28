module neuron_pair_unit (
    input clk,
    input rst,
    input start,

    output reg done,
    output reg [7:0] result,
    output [3:0] state_debug
);

    // sinais internos
    reg start_pulse;

    // entradas da NPU
    reg [7:0] DA, DB, DC, DD;

    wire [7:0] D_OUT;
    wire DONE;
    wire BUSY;

    // debug
    wire [15:0] SSFR = 0;
    wire [15:0] CON_SIG = 0;
    wire FIFO_FULL, FIFO_EMPTY;

    reg [9:0] addr;

    wire [7:0] input_data;
    wire [7:0] weight_data;

    input_memory IM (
        .clk(clk),
        .addr(addr),
        .data(input_data)
    );

    weight_memory WM (
        .clk(clk),
        .addr(addr),
        .data(weight_data)
    );

    // =========================
    // INSTÂNCIA DA NPU
    // =========================
    npu_top NPU (
        .CLKEXT(clk),
        .RST_GLO(rst),
        .START(start_pulse),
        .SSFR(SSFR),
        .CON_SIG(CON_SIG),
        .DA(DA),
        .DB(DB),
        .DC(DC),
        .DD(DD),
        .BIAS_IN(0),
        .D_OUT(D_OUT),
        .FIFO_FULL(FIFO_FULL),
        .FIFO_EMPTY(FIFO_EMPTY),
        .BUSY(BUSY),
        .DONE(DONE),
        .STATE_DEBUG(state_debug)
    );

    // =========================
    // CONTROLE DE START (1 ciclo)
    // =========================
    always @(posedge clk or posedge rst) begin
        if (rst)
            start_pulse <= 0;
        else
            start_pulse <= start;
    end

    // =========================
    // DADOS DE TESTE CORRETOS
    // =========================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            DA <= 0; DB <= 0; DC <= 0; DD <= 0;
        end else begin
            //DA <= input_data;
            //DB <= weight_data;

            //DC <= input_data + 1;   // próximo índice (simples por enquanto)
            //DD <= weight_data;
            DA <= input_data;
            DB <= weight_data;

            DC <= input_data;   // mesmo input
            DD <= weight_data;  // outro peso (depois mudamos)
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst)
            addr <= 0;
        else if (start)
            addr <= 0;
        else
            addr <= addr + 1;
    end

    // =========================
    // CAPTURA DO RESULTADO
    // =========================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            done <= 0;
            result <= 0;
        end else begin
            done <= DONE;

            // 🔥 captura só quando DONE = 1
            if (DONE)
                result <= D_OUT;
        end
    end

endmodule