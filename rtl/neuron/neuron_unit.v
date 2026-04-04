module neuron_unit #(
    parameter INPUT_FILE = "data/input_0.mem",
    parameter WFILE = "data/weights_n0.mem",
    parameter BIAS_ID = 0
)(
    input clk,
    input rst,
    input start,

    output reg done,
    output reg signed [15:0] score,

    output [3:0] state_debug
);

    // =========================
    // EDGE DETECT
    // =========================
    reg start_d;
    wire start_edge;

    always @(posedge clk)
        start_d <= start;

    assign start_edge = start & ~start_d;

    reg start_pulse;

    // =========================
    // NPU IO (APENAS 1 CAMINHO)
    // =========================
    reg [7:0] DA, DB;

    wire DONE;

    wire [7:0] bias;

    reg [9:0] addr;

    wire [7:0] input_data;
    wire [7:0] weight;

    wire signed [15:0] MAC_OUT;

    // =========================
    // MEMÓRIAS
    // =========================
    input_memory #(.INPUT_FILE(INPUT_FILE)) IM (
        .clk(clk),
        .addr(addr),
        .data(input_data)
    );

    weight_memory #(.FILE(WFILE)) W (
        .clk(clk),
        .addr(addr),
        .data(weight)
    );

    bias_memory BM (
        .clk(clk),
        .addr(BIAS_ID),
        .data(bias)
    );

    // =========================
    // NPU (USANDO SÓ 1 LADO)
    // =========================
    neuron_core NCR (
        .CLKEXT(clk),
        .RST_GLO(rst),
        .START(start_pulse),

        .DA(DA),
        .DB(DB),

        // 🔥 NÃO USA ESSE LADO
        .DC(8'd0),
        .DD(8'd0),

        .DONE(DONE),
        .STATE_DEBUG(state_debug),

        .MAC0_OUT(MAC_OUT),
        .MAC1_OUT() // ignorado
    );

    // =========================
    // INPUT PIPE
    // =========================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            DA <= 0;
            DB <= 0;
        end else begin
            DA <= input_data;
            DB <= weight; // ⚠️ se der problema: usar $signed(weight)
        end
    end

    // =========================
    // ACUMULADOR
    // =========================
    reg signed [31:0] acc;

    // =========================
    // FSM
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

            acc <= 0;
            score <= 0;

        end else begin
            case (state)

                IDLE: begin
                    done <= 0;

                    if (start_edge) begin
                        addr <= 0;
                        acc <= 0;
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
                        acc <= acc + MAC_OUT;
                        state <= NEXT;
                    end
                end

                NEXT: begin
                    if (addr == 10'd783)
                        state <= DONE_STATE;
                    else begin
                        addr <= addr + 1;
                        state <= LOAD;
                    end
                end

                DONE_STATE: begin
                    done <= 1;

                    // 🔥 bias no final
                    score <= acc + $signed({{8{bias[7]}}, bias});

                    state <= IDLE;
                end

            endcase
        end
    end

endmodule