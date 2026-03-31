module neuron_pair_unit (
    input clk,
    input rst,
    input start,

    output reg done,
    output reg [7:0] result,
    output [3:0] state_debug
);

    // =========================
    // sinais internos
    // =========================
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

    // =========================
    // memória
    // =========================
    reg [9:0] addr;

    wire [7:0] input_data;
    wire [7:0] weight_n0;
    wire [7:0] weight_n1;

    input_memory IM (
        .clk(clk),
        .addr(addr),
        .data(input_data)
    );

    weight_memory #(.FILE("data/weights_n0.mem")) W0 (
        .clk(clk),
        .addr(addr),
        .data(weight_n0)
    );

    weight_memory #(.FILE("data/weights_n1.mem")) W1 (
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
        .BIAS_IN(0),
        .D_OUT(D_OUT),
        .FIFO_FULL(FIFO_FULL),
        .FIFO_EMPTY(FIFO_EMPTY),
        .BUSY(BUSY),
        .DONE(DONE),
        .STATE_DEBUG(state_debug)
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
    // FSM (controle 784 ciclos)
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
            result <= 0;
        end else begin
            case (state)

                IDLE: begin
                    done <= 0;
                    start_pulse <= 0;

                    if (start) begin
                        addr <= 0;
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    start_pulse <= 1;   // pulso de start
                    state <= WAIT_NPU;
                end

                WAIT_NPU: begin
                    start_pulse <= 0;

                    if (DONE) begin
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
                    result <= D_OUT;
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule