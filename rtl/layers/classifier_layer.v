module classifier_layer (
    input clk,
    input rst,
    input start,
    input [7:0] input_data,

    output reg [9:0] addr,
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

  wire pixel_done0, pixel_done1, pixel_done2, pixel_done3, pixel_done4;
  wire pixel_done5, pixel_done6, pixel_done7, pixel_done8, pixel_done9;

  // =========================
  // SCORES
  // =========================
  wire signed [15:0] s0, s1, s2, s3, s4;
  wire signed [15:0] s5, s6, s7, s8, s9;

  wire [7:0] weight0, weight1, weight2, weight3, weight4;
  wire [7:0] weight5, weight6, weight7, weight8, weight9;

  wire [7:0] bias0, bias1, bias2, bias3, bias4;
  wire [7:0] bias5, bias6, bias7, bias8, bias9;

  // =========================
  // MEMÓRIAS
  // =========================
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n0.mem")) W0 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight0)
                );
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n1.mem")) W1 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight1)
                );
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n2.mem")) W2 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight2)
                );
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n3.mem")) W3 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight3)
                );
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n4.mem")) W4 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight4)
                );
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n5.mem")) W5 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight5)
                );
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n6.mem")) W6 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight6)
                );
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n7.mem")) W7 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight7)
                );
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n8.mem")) W8 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight8)
                );
  weight_memory #(.FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n9.mem")) W9 (
                  .clk(clk),
                  .addr(addr),
                  .data(weight9)
                );

  bias_memory BM0 (.clk(clk), .addr(0), .data(bias0));
  bias_memory BM1 (.clk(clk), .addr(1), .data(bias1));
  bias_memory BM2 (.clk(clk), .addr(2), .data(bias2));
  bias_memory BM3 (.clk(clk), .addr(3), .data(bias3));
  bias_memory BM4 (.clk(clk), .addr(4), .data(bias4));
  bias_memory BM5 (.clk(clk), .addr(5), .data(bias5));
  bias_memory BM6 (.clk(clk), .addr(6), .data(bias6));
  bias_memory BM7 (.clk(clk), .addr(7), .data(bias7));
  bias_memory BM8 (.clk(clk), .addr(8), .data(bias8));
  bias_memory BM9 (.clk(clk), .addr(9), .data(bias9));

  // =========================
  // NEURONS (COM pixel_done)
  // =========================
  neuron_unit N0 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight0), .bias(bias0), .done(done0), .pixel_done(pixel_done0), .score(s0), .state_debug());
  neuron_unit N1 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight1), .bias(bias1), .done(done1), .pixel_done(pixel_done1), .score(s1), .state_debug());
  neuron_unit N2 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight2), .bias(bias2), .done(done2), .pixel_done(pixel_done2), .score(s2), .state_debug());
  neuron_unit N3 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight3), .bias(bias3), .done(done3), .pixel_done(pixel_done3), .score(s3), .state_debug());
  neuron_unit N4 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight4), .bias(bias4), .done(done4), .pixel_done(pixel_done4), .score(s4), .state_debug());
  neuron_unit N5 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight5), .bias(bias5), .done(done5), .pixel_done(pixel_done5), .score(s5), .state_debug());
  neuron_unit N6 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight6), .bias(bias6), .done(done6), .pixel_done(pixel_done6), .score(s6), .state_debug());
  neuron_unit N7 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight7), .bias(bias7), .done(done7), .pixel_done(pixel_done7), .score(s7), .state_debug());
  neuron_unit N8 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight8), .bias(bias8), .done(done8), .pixel_done(pixel_done8), .score(s8), .state_debug());
  neuron_unit N9 (.clk(clk), .rst(rst), .start(start_all), .input_data(input_data), .weight(weight9), .bias(bias9), .done(done9), .pixel_done(pixel_done9), .score(s9), .state_debug());

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
      addr <= 0;
    end
    else
    begin
      case (state)

        IDLE:
        begin
          done <= 0;
          start_all <= 0;
          addr <= 0;

          if (start)
          begin
            start_all <= 1;
            state <= RUN;
          end
        end

        RUN:
        begin
          start_all <= 0;

          // 🔥 AVANÇA PIXEL CORRETAMENTE
          if (pixel_done0 && pixel_done1 && pixel_done2 && pixel_done3 && pixel_done4 &&
              pixel_done5 && pixel_done6 && pixel_done7 && pixel_done8 && pixel_done9)
          begin
            if (addr == 10'd783)
              state <= DONE_STATE;
            else
              addr <= addr + 1;
          end
        end

        DONE_STATE:
        begin
          if(done0 && done1 && done2 && done3 && done4 && done5 && done6 && done7 && done8 && done9) begin
            done <= 1;
            n0 <= s0; n1 <= s1; n2 <= s2; n3 <= s3; n4 <= s4;
            n5 <= s5; n6 <= s6; n7 <= s7; n8 <= s8; n9 <= s9;
            state <= IDLE;
          end          
        end

      endcase
    end
  end

endmodule
