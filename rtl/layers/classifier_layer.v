module classifier_layer (
    input clk,
    input rst,
    input start,
    input [7:0] input_data,

    // =========================
    // INTERFACE DE CONFIGURAÇÃO (AXI-LIKE)
    // =========================
    input        cfg_valid,
    input [3:0]  cfg_neuron,   // neurônio alvo (0-9)
    input [9:0]  cfg_addr,     // posição do peso (0-783)
    input [7:0]  cfg_weight,   // dado (peso ou bias)
    input        cfg_is_bias,  // 0 = weight | 1 = bias

    // =========================
    // CONTROLE / STATUS
    // =========================
    output reg [9:0] addr,
    output reg done,

    // =========================
    // SAÍDA (SCORES)
    // =========================
    output reg signed [15:0] n0, n1, n2, n3, n4,
    output reg signed [15:0] n5, n6, n7, n8, n9
);

  // =========================
  // CONTROLE INTERNO
  // =========================
  reg start_all;

  // =========================
  // SINAIS DOS NEURONS
  // =========================
  wire done0, done1, done2, done3, done4;
  wire done5, done6, done7, done8, done9;

  wire pixel_done0, pixel_done1, pixel_done2, pixel_done3, pixel_done4;
  wire pixel_done5, pixel_done6, pixel_done7, pixel_done8, pixel_done9;

  wire signed [15:0] s0, s1, s2, s3, s4;
  wire signed [15:0] s5, s6, s7, s8, s9;

  // =========================
  // PESOS (VINDOS DA RAM)
  // =========================
  wire [7:0] weight0, weight1, weight2, weight3, weight4;
  wire [7:0] weight5, weight6, weight7, weight8, weight9;

  // =========================
  // BIAS (REGISTRADORES)
  // =========================
  reg [7:0] bias0, bias1, bias2, bias3, bias4;
  reg [7:0] bias5, bias6, bias7, bias8, bias9;

  // ============================================================
  // RAM DE PESOS (UMA POR NEURÔNIO)
  // ============================================================
  weight_memory W0 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==0), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight0));
  weight_memory W1 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==1), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight1));
  weight_memory W2 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==2), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight2));
  weight_memory W3 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==3), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight3));
  weight_memory W4 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==4), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight4));
  weight_memory W5 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==5), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight5));
  weight_memory W6 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==6), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight6));
  weight_memory W7 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==7), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight7));
  weight_memory W8 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==8), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight8));
  weight_memory W9 (.clk(clk), .we(cfg_valid && !cfg_is_bias && cfg_neuron==9), .waddr(cfg_addr), .wdata(cfg_weight), .raddr(addr), .rdata(weight9));

  // ============================================================
  // NEURONS
  // ============================================================
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
  // FSM STATES
  // =========================
  reg [1:0] state;
  parameter IDLE = 0,
            RUN  = 1,
            DONE_STATE = 2;

  // ============================================================
  // CONFIGURAÇÃO DE BIAS
  // ============================================================
  always @(posedge clk)
  begin
    if (cfg_valid && state == IDLE && cfg_is_bias)
    begin
      case (cfg_neuron)
        0: bias0 <= cfg_weight;
        1: bias1 <= cfg_weight;
        2: bias2 <= cfg_weight;
        3: bias3 <= cfg_weight;
        4: bias4 <= cfg_weight;
        5: bias5 <= cfg_weight;
        6: bias6 <= cfg_weight;
        7: bias7 <= cfg_weight;
        8: bias8 <= cfg_weight;
        9: bias9 <= cfg_weight;
      endcase
    end
  end

  // ============================================================
  // FSM PRINCIPAL
  // ============================================================
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

        // =========================
        // ESPERA START
        // =========================
        IDLE:
        begin
          done <= 0;
          start_all <= 0;
          addr <= 0;

          if (start)
          begin
            start_all <= 1; // dispara neurônios
            state <= RUN;
          end
        end

        // =========================
        // PROCESSAMENTO
        // =========================
        RUN:
        begin
          start_all <= 0;

          // avança apenas quando TODOS terminaram o pixel
          if (pixel_done0 && pixel_done1 && pixel_done2 && pixel_done3 && pixel_done4 &&
              pixel_done5 && pixel_done6 && pixel_done7 && pixel_done8 && pixel_done9)
          begin
            if (addr == 10'd783)
              state <= DONE_STATE;
            else
              addr <= addr + 1;
          end
        end

        // =========================
        // FINALIZAÇÃO
        // =========================
        DONE_STATE:
        begin
          if (done0 && done1 && done2 && done3 && done4 &&
              done5 && done6 && done7 && done8 && done9)
          begin
            done <= 1;

            // captura resultados finais
            n0 <= s0; n1 <= s1; n2 <= s2; n3 <= s3; n4 <= s4;
            n5 <= s5; n6 <= s6; n7 <= s7; n8 <= s8; n9 <= s9;

            state <= IDLE;
          end
        end

      endcase
    end
  end

endmodule