module layer1 (
    input clk,
    input rst,
    input start,

    output reg done,
    output reg [4:0] pair_results,

    // 🔥 scores dos vencedores (já corretos)
    output reg [15:0] score0,
    output reg [15:0] score1,
    output reg [15:0] score2,
    output reg [15:0] score3,
    output reg [15:0] score4
);

    // =========================
    // controle
    // =========================
    reg start_all;

    // =========================
    // sinais dos pares
    // =========================
    wire done0, done1, done2, done3, done4;

    wire [15:0] s0a, s0b;
    wire [15:0] s1a, s1b;
    wire [15:0] s2a, s2b;
    wire [15:0] s3a, s3b;
    wire [15:0] s4a, s4b;

    // =========================
    // 5 pares (10 neurônios)
    // =========================

    neuron_pair_unit #(
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n0.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n1.mem"),
        .BIAS_ID0(0),
        .BIAS_ID1(1)
    ) pair0 (
        .clk(clk), .rst(rst), .start(start_all),
        .done(done0),
        .score0(s0a), .score1(s0b),
        .state_debug()
    );

    neuron_pair_unit #(
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n2.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n3.mem"),
        .BIAS_ID0(2),
        .BIAS_ID1(3)
    ) pair1 (
        .clk(clk), .rst(rst), .start(start_all),
        .done(done1),
        .score0(s1a), .score1(s1b),
        .state_debug()
    );

    neuron_pair_unit #(
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n4.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n5.mem"),
        .BIAS_ID0(4),
        .BIAS_ID1(5)
    ) pair2 (
        .clk(clk), .rst(rst), .start(start_all),
        .done(done2),
        .score0(s2a), .score1(s2b),
        .state_debug()
    );

    neuron_pair_unit #(
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n6.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n7.mem"),
        .BIAS_ID0(6),
        .BIAS_ID1(7)
    ) pair3 (
        .clk(clk), .rst(rst), .start(start_all),
        .done(done3),
        .score0(s3a), .score1(s3b),
        .state_debug()
    );

    neuron_pair_unit #(
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n8.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n9.mem"),
        .BIAS_ID0(8),
        .BIAS_ID1(9)
    ) pair4 (
        .clk(clk), .rst(rst), .start(start_all),
        .done(done4),
        .score0(s4a), .score1(s4b),
        .state_debug()
    );

    // =========================
    // FSM
    // =========================
    reg [1:0] state;

    parameter IDLE = 0,
              RUN  = 1,
              DONE_STATE = 2;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            state <= IDLE;
            done <= 0;
            start_all <= 0;
            pair_results <= 0;

            score0 <= 0;
            score1 <= 0;
            score2 <= 0;
            score3 <= 0;
            score4 <= 0;
        end
        else
        begin
            case (state)
                IDLE:
                begin
                    done <= 0;
                    start_all <= 0;

                    if (start)
                    begin
                        start_all <= 1;
                        state <= RUN;
                    end
                end

                RUN:
                begin
                    start_all <= 0;

                    if (done0 && done1 && done2 && done3 && done4)
                    begin
                        // 🔥 PAR 0 (0 vs 1)
                        if (s0b > s0a) begin
                            pair_results[0] <= 1;
                            score0 <= s0b;
                        end else begin
                            pair_results[0] <= 0;
                            score0 <= s0a;
                        end

                        // 🔥 PAR 1 (2 vs 3)
                        if (s1b > s1a) begin
                            pair_results[1] <= 1;
                            score1 <= s1b;
                        end else begin
                            pair_results[1] <= 0;
                            score1 <= s1a;
                        end

                        // 🔥 PAR 2 (4 vs 5)
                        if (s2b > s2a) begin
                            pair_results[2] <= 1;
                            score2 <= s2b;
                        end else begin
                            pair_results[2] <= 0;
                            score2 <= s2a;
                        end

                        // 🔥 PAR 3 (6 vs 7)
                        if (s3b > s3a) begin
                            pair_results[3] <= 1;
                            score3 <= s3b;
                        end else begin
                            pair_results[3] <= 0;
                            score3 <= s3a;
                        end

                        // 🔥 PAR 4 (8 vs 9)
                        if (s4b > s4a) begin
                            pair_results[4] <= 1;
                            score4 <= s4b;
                        end else begin
                            pair_results[4] <= 0;
                            score4 <= s4a;
                        end

                        state <= DONE_STATE;
                    end
                end

                DONE_STATE:
                begin
                    done <= 1;
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule