module classifier_layer #(
    parameter INPUT_FILE = "data/input_0.mem"
  )(
    input clk,
    input rst,
    input start,

    output reg done,

    output reg signed [15:0] n0,
    output reg signed [15:0] n1,
    output reg signed [15:0] n2,
    output reg signed [15:0] n3,
    output reg signed [15:0] n4,
    output reg signed [15:0] n5,
    output reg signed [15:0] n6,
    output reg signed [15:0] n7,
    output reg signed [15:0] n8,
    output reg signed [15:0] n9
  );

  reg start_all;

  // =========================
  // DONEs individuais
  // =========================
  wire done0, done1, done2, done3, done4;
  wire done5, done6, done7, done8, done9;

  // =========================
  // SCORES
  // =========================
  wire signed [15:0] s0, s1, s2, s3, s4;
  wire signed [15:0] s5, s6, s7, s8, s9;

  // =========================
  // INSTÂNCIAS (1 neurônio cada)
  // =========================
  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n0.mem"),
                .BIAS_ID(0)
               ) N0 (.clk(clk), .rst(rst), .start(start_all), .done(done0), .score(s0), .state_debug());

  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n1.mem"),
                .BIAS_ID(1)
               ) N1 (.clk(clk), .rst(rst), .start(start_all), .done(done1), .score(s1), .state_debug());

  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n2.mem"),
                .BIAS_ID(2)
               ) N2 (.clk(clk), .rst(rst), .start(start_all), .done(done2), .score(s2), .state_debug());

  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n3.mem"),
                .BIAS_ID(3)
               ) N3 (.clk(clk), .rst(rst), .start(start_all), .done(done3), .score(s3), .state_debug());

  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n4.mem"),
                .BIAS_ID(4)
               ) N4 (.clk(clk), .rst(rst), .start(start_all), .done(done4), .score(s4), .state_debug());

  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n5.mem"),
                .BIAS_ID(5)
               ) N5 (.clk(clk), .rst(rst), .start(start_all), .done(done5), .score(s5), .state_debug());

  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n6.mem"),
                .BIAS_ID(6)
               ) N6 (.clk(clk), .rst(rst), .start(start_all), .done(done6), .score(s6), .state_debug());

  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n7.mem"),
                .BIAS_ID(7)
               ) N7 (.clk(clk), .rst(rst), .start(start_all), .done(done7), .score(s7), .state_debug());

  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n8.mem"),
                .BIAS_ID(8)
               ) N8 (.clk(clk), .rst(rst), .start(start_all), .done(done8), .score(s8), .state_debug());

  neuron_unit #(.INPUT_FILE(INPUT_FILE),
                .WFILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n9.mem"),
                .BIAS_ID(9)
               ) N9 (.clk(clk), .rst(rst), .start(start_all), .done(done9), .score(s9), .state_debug());

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

      n0 <= 0;
      n1 <= 0;
      n2 <= 0;
      n3 <= 0;
      n4 <= 0;
      n5 <= 0;
      n6 <= 0;
      n7 <= 0;
      n8 <= 0;
      n9 <= 0;
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
          if (done0 && done1 && done2 && done3 && done4 &&
              done5 && done6 && done7 && done8 && done9)
          begin
            $display("\n--- SCORES BRUTOS ---");
            $display("n0=%d n1=%d n2=%d n3=%d n4=%d", s0,s1,s2,s3,s4);
            $display("n5=%d n6=%d n7=%d n8=%d n9=%d", s5,s6,s7,s8,s9);
            n0 <= s0;
            n1 <= s1;
            n2 <= s2;
            n3 <= s3;
            n4 <= s4;
            n5 <= s5;
            n6 <= s6;
            n7 <= s7;
            n8 <= s8;
            n9 <= s9;
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
