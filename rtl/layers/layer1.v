module layer1 (
    input clk,
    input rst,
    input start,

    output reg done,
    output reg [4:0] pair_results,

    // 🔥 NOVO: scores dos vencedores
    output [15:0] score0,
    output [15:0] score1,
    output [15:0] score2,
    output [15:0] score3,
    output [15:0] score4
);

    // =========================
    // sinais dos 5 pares
    // =========================
    reg start_all;

    wire done0, done1, done2, done3, done4;
    wire [7:0] res0, res1, res2, res3, res4;

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
        .done(done0), .result(res0), .state_debug()
    );

    neuron_pair_unit #(
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n2.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n3.mem"),
        .BIAS_ID0(2),
        .BIAS_ID1(3)
    ) pair1 (
        .clk(clk), .rst(rst), .start(start_all),
        .done(done1), .result(res1), .state_debug()
    );

    neuron_pair_unit #(
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n4.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n5.mem"),
        .BIAS_ID0(4),
        .BIAS_ID1(5)
    ) pair2 (
        .clk(clk), .rst(rst), .start(start_all),
        .done(done2), .result(res2), .state_debug()
    );

    neuron_pair_unit #(
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n6.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n7.mem"),
        .BIAS_ID0(6),
        .BIAS_ID1(7)
    ) pair3 (
        .clk(clk), .rst(rst), .start(start_all),
        .done(done3), .result(res3), .state_debug()
    );

    neuron_pair_unit #(
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n8.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n9.mem"),
        .BIAS_ID0(8),
        .BIAS_ID1(9)
    ) pair4 (
        .clk(clk), .rst(rst), .start(start_all),
        .done(done4), .result(res4), .state_debug()
    );

    // =========================
    // 🔥 SCORES (IMPORTANTE)
    // =========================
    assign score0 = {8'd0, res0};
    assign score1 = {8'd0, res1};
    assign score2 = {8'd0, res2};
    assign score3 = {8'd0, res3};
    assign score4 = {8'd0, res4};

    // =========================
    // FSM simples
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
                        pair_results[0] <= res0[0];
                        pair_results[1] <= res1[0];
                        pair_results[2] <= res2[0];
                        pair_results[3] <= res3[0];
                        pair_results[4] <= res4[0];

                        $display("\n===== DEBUG LAYER1 =====");
                        $display("res0 = %d", res0);
                        $display("res1 = %d", res1);
                        $display("res2 = %d", res2);
                        $display("res3 = %d", res3);
                        $display("res4 = %d", res4);
                        $display("========================\n");

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