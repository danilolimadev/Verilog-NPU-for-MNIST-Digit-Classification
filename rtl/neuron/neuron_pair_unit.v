module neuron_pair_unit #(
    parameter INPUT_FILE = "data/input_0.mem",
    parameter WFILE0 = "data/weights_n0.mem",
    parameter WFILE1 = "data/weights_n1.mem",
    parameter BIAS_ID0 = 0,
    parameter BIAS_ID1 = 1
)(
    input clk,
    input rst,
    input start,

    output reg done,

    // 🔥 NOVO: scores reais dos dois neurônios
    output reg [15:0] score0,
    output reg [15:0] score1,

    output [3:0] state_debug
);

    // =========================
    // START EDGE DETECT
    // =========================
    reg start_d;
    wire start_edge;

    always @(posedge clk) begin
        start_d <= start;
    end

    assign start_edge = start & ~start_d;

    reg start_pulse;

    // =========================
    // entradas da NPU
    // =========================
    reg [7:0] DA, DB, DC, DD;

    wire [7:0] D_OUT;
    wire DONE;
    wire BUSY;

    // debug
    wire [15:0] SSFR = 0;
    wire [15:0] CON_SIG = 0;
    wire FIFO_FULL, FIFO_EMPTY;

    wire [7:0] bias0;
    wire [7:0] bias1;

    // =========================
    // memória
    // =========================
    reg [9:0] addr;

    wire [7:0] input_data;
    wire [7:0] weight_n0;
    wire [7:0] weight_n1;

    wire [15:0] MAC0_OUT;
    wire [15:0] MAC1_OUT;

    input_memory #(.INPUT_FILE(INPUT_FILE)) IM (
        .clk(clk),
        .addr(addr),
        .data(input_data)
    );

    weight_memory #(.FILE(WFILE0)) W0 (
        .clk(clk),
        .addr(addr),
        .data(weight_n0)
    );

    weight_memory #(.FILE(WFILE1)) W1 (
        .clk(clk),
        .addr(addr),
        .data(weight_n1)
    );

    // =========================
    // NPU
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
        .BIAS_IN(bias0), // ⚠️ ainda único (limitação da sua NPU atual)
        .D_OUT(D_OUT),
        .FIFO_FULL(FIFO_FULL),
        .FIFO_EMPTY(FIFO_EMPTY),
        .BUSY(BUSY),
        .DONE(DONE),
        .STATE_DEBUG(state_debug),
        .MAC0_OUT(MAC0_OUT),
        .MAC1_OUT(MAC1_OUT)
    );

    bias_memory BM0 (
        .clk(clk),
        .addr(BIAS_ID0),
        .data(bias0)
    );

    bias_memory BM1 (
        .clk(clk),
        .addr(BIAS_ID1),
        .data(bias1)
    );

    // =========================
    // dados → NPU
    // =========================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            DA <= 0; DB <= 0; DC <= 0; DD <= 0;
        end else begin
            DA <= input_data;
            DB <= weight_n0;

            DC <= input_data;
            DD <= weight_n1;
        end
    end

    // =========================
    // acumuladores (🔥 CORREÇÃO PRINCIPAL)
    // =========================
    reg [15:0] acc0;
    reg [15:0] acc1;

    // =========================
    // FSM (784 ciclos)
    // =========================
    reg [2:0] state;

    parameter IDLE = 0,
              LOAD = 1,
              WAIT_NPU = 2,
              NEXT = 3,
              DONE_STATE = 4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            addr <= 0;
            done <= 0;
            start_pulse <= 0;

            acc0 <= 0;
            acc1 <= 0;

            score0 <= 0;
            score1 <= 0;

        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    start_pulse <= 0;

                    if (start_edge) begin
                        addr <= 0;

                        acc0 <= 0;
                        acc1 <= 0;

                        state <= LOAD;
                    end
                end

                LOAD: begin
                    start_pulse <= 1;
                    state <= WAIT_NPU;
                end

                WAIT_NPU: begin
                    start_pulse <= 0;

                    if (DONE) begin
                        // 🔥 ACUMULA RESULTADO
                        acc0 <= acc0 + MAC0_OUT;
                        acc1 <= acc1 + MAC1_OUT;

                        state <= NEXT;
                    end
                end
                NEXT: begin
                    if (addr == 10'd783) begin
                        state <= DONE_STATE;
                    end else begin
                        addr <= addr + 1;
                        state <= LOAD;
                    end
                end
                DONE_STATE: begin
                    done <= 1;

                    // 🔥 entrega scores finais
                    score0 <= acc0;
                    score1 <= acc1;

                    state <= IDLE;
                end

            endcase
        end
    end

endmodule