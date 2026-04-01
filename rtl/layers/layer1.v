module layer1 #(
    parameter INPUT_FILE = "data/input_0.mem"
)(
    input clk,
    input rst,
    input start,

    output reg done,

    // 🔥 AGORA: 10 SAÍDAS DIRETAS
    output reg [15:0] n0,
    output reg [15:0] n1,
    output reg [15:0] n2,
    output reg [15:0] n3,
    output reg [15:0] n4,
    output reg [15:0] n5,
    output reg [15:0] n6,
    output reg [15:0] n7,
    output reg [15:0] n8,
    output reg [15:0] n9
);

    reg start_all;

    wire done0, done1, done2, done3, done4;

    wire [15:0] s0a, s0b;
    wire [15:0] s1a, s1b;
    wire [15:0] s2a, s2b;
    wire [15:0] s3a, s3b;
    wire [15:0] s4a, s4b;

    // =========================
    // INSTÂNCIAS (mantidas)
    // =========================
    neuron_pair_unit #(.INPUT_FILE(INPUT_FILE),
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n0.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n1.mem"),
        .BIAS_ID0(0), .BIAS_ID1(1)
    ) pair0 (.clk(clk), .rst(rst), .start(start_all), .done(done0), .score0(s0a), .score1(s0b), .state_debug());

    neuron_pair_unit #(.INPUT_FILE(INPUT_FILE),
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n2.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n3.mem"),
        .BIAS_ID0(2), .BIAS_ID1(3)
    ) pair1 (.clk(clk), .rst(rst), .start(start_all), .done(done1), .score0(s1a), .score1(s1b), .state_debug());

    neuron_pair_unit #(.INPUT_FILE(INPUT_FILE),
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n4.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n5.mem"),
        .BIAS_ID0(4), .BIAS_ID1(5)
    ) pair2 (.clk(clk), .rst(rst), .start(start_all), .done(done2), .score0(s2a), .score1(s2b), .state_debug());

    neuron_pair_unit #(.INPUT_FILE(INPUT_FILE),
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n6.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n7.mem"),
        .BIAS_ID0(6), .BIAS_ID1(7)
    ) pair3 (.clk(clk), .rst(rst), .start(start_all), .done(done3), .score0(s3a), .score1(s3b), .state_debug());

    neuron_pair_unit #(.INPUT_FILE(INPUT_FILE),
        .WFILE0("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n8.mem"),
        .WFILE1("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n9.mem"),
        .BIAS_ID0(8), .BIAS_ID1(9)
    ) pair4 (.clk(clk), .rst(rst), .start(start_all), .done(done4), .score0(s4a), .score1(s4b), .state_debug());

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

            n0 <= 0; n1 <= 0; n2 <= 0; n3 <= 0; n4 <= 0;
            n5 <= 0; n6 <= 0; n7 <= 0; n8 <= 0; n9 <= 0;
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
                        $display("\n==============================");
                        $display("START NOVA INFERENCIA");
                        $display("==============================");

                        start_all <= 1;
                        state <= RUN;
                    end
                end

                RUN:
                begin
                    start_all <= 0;

                    if (done0 && done1 && done2 && done3 && done4)
                    begin
                        // DEBUG
                        $display("\n--- SCORES BRUTOS ---");
                        $display("N0=%d N1=%d", s0a, s0b);
                        $display("N2=%d N3=%d", s1a, s1b);
                        $display("N4=%d N5=%d", s2a, s2b);
                        $display("N6=%d N7=%d", s3a, s3b);
                        $display("N8=%d N9=%d", s4a, s4b);

                        // 🔥 SALVA DIRETO (SEM ARGMAX)
                        n0 <= s0a;
                        n1 <= s0b;
                        n2 <= s1a;
                        n3 <= s1b;
                        n4 <= s2a;
                        n5 <= s2b;
                        n6 <= s3a;
                        n7 <= s3b;
                        n8 <= s4a;
                        n9 <= s4b;

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