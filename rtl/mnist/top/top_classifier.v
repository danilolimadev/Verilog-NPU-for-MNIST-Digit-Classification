module top_classifier (
    input clk,
    input rst,
    input start,
    // ============================================================
    // CONFIGURAÇÃO (AXI-LIKE) → PESOS + BIAS
    // ============================================================
    input        cfg_valid,
    input [3:0]  cfg_neuron,
    input [9:0]  cfg_addr,
    input [7:0]  cfg_weight,
    input        cfg_is_bias,
    // ============================================================
    // AXI-STREAM INPUT → IMAGEM (784 pixels)
    // ============================================================
    input  [7:0] s_axis_tdata,
    input        s_axis_tvalid,
    input        s_axis_tlast,
    output       s_axis_tready,
    // ============================================================
    // SAÍDA FINAL
    // ============================================================
    output reg done,
    output reg [3:0] digit
);

  // ============================================================
  // CONTROLE DO BUFFER DE ENTRADA (IMAGEM)
  // ============================================================
  reg [9:0] wr_ptr;        // ponteiro de escrita (0-783)
  reg buffer_full;         // indica que a imagem foi carregada

  // só aceita dados se não estiver cheio e não estiver configurando
  assign s_axis_tready = !buffer_full && !cfg_valid;

  // ============================================================
  // ESCRITA DO BUFFER (AXI → RAM)
  // ============================================================
  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      wr_ptr <= 0;
      buffer_full <= 0;
    end
    else
    begin
      if (s_axis_tvalid && s_axis_tready)
      begin
        wr_ptr <= wr_ptr + 1;

        // fim da imagem
        if (s_axis_tlast || wr_ptr == 10'd783)
        begin
          buffer_full <= 1;
          wr_ptr <= 0;
        end
      end
    end
  end

  // ============================================================
  // BUFFER DE ENTRADA (RAM)
  // ============================================================
  wire [9:0] addr;         // endereço vindo do classifier_layer
  wire [7:0] input_data;   // pixel atual

  input_memory BUFFER (
    .clk(clk),

    // WRITE (AXI)
    .we(s_axis_tvalid && s_axis_tready),
    .waddr(wr_ptr),
    .wdata(s_axis_tdata),

    // READ (PROCESSAMENTO)
    .raddr(addr),
    .rdata(input_data)
  );

  // ============================================================
  // START AUTOMÁTICO (quando buffer cheio)
  // ============================================================
  reg start_d;
  wire start_edge;

  always @(posedge clk)
    start_d <= buffer_full;

  // dispara apenas quando termina de carregar e não está configurando
  assign start_edge = buffer_full & ~start_d & ~cfg_valid;

  // ============================================================
  // DETECÇÃO DE FINALIZAÇÃO DO LAYER
  // ============================================================
  wire layer_done;

  reg layer_done_d;
  wire layer_done_edge;

  always @(posedge clk)
    layer_done_d <= layer_done;

  assign layer_done_edge = layer_done & ~layer_done_d;

  // ============================================================
  // SAÍDA DOS NEURÔNIOS
  // ============================================================
  wire signed [15:0] n0,n1,n2,n3,n4;
  wire signed [15:0] n5,n6,n7,n8,n9;

  // ============================================================
  // CLASSIFIER LAYER
  // ============================================================
  classifier_layer L1 (
    .clk(clk),
    .rst(rst),
    .start(start_edge),

    // dados
    .input_data(input_data),

    // configuração
    .cfg_valid(cfg_valid),
    .cfg_neuron(cfg_neuron),
    .cfg_addr(cfg_addr),
    .cfg_weight(cfg_weight),
    .cfg_is_bias(cfg_is_bias),

    // controle
    .addr(addr),
    .done(layer_done),

    // outputs
    .n0(n0), .n1(n1),
    .n2(n2), .n3(n3),
    .n4(n4), .n5(n5),
    .n6(n6), .n7(n7),
    .n8(n8), .n9(n9)
  );

  // ============================================================
  // FSM DE DECISÃO (ARGMAX)
  // ============================================================
  localparam IDLE       = 2'd0,
             COMPARE   = 2'd1,
             DONE_STATE = 2'd2;

  reg [1:0] state;
  reg [3:0] idx;
  reg signed [15:0] max_val;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      state   <= IDLE;
      done    <= 0;
      digit   <= 0;
      max_val <= 0;
      idx     <= 0;
    end
    else
    begin
      case (state)
        // ======================================================
        // ESPERA RESULTADO DO LAYER
        // ======================================================
        IDLE:
        begin
          done <= 0;

          if (layer_done_edge)
          begin
            max_val <= n0;
            digit   <= 0;
            idx     <= 1;
            state   <= COMPARE;
          end
        end

        // ======================================================
        // ARGMAX (comparação dos 10 neurônios)
        // ======================================================
        COMPARE:
        begin
          case (idx)
            1: if (n1 > max_val) begin max_val <= n1; digit <= 1; end
            2: if (n2 > max_val) begin max_val <= n2; digit <= 2; end
            3: if (n3 > max_val) begin max_val <= n3; digit <= 3; end
            4: if (n4 > max_val) begin max_val <= n4; digit <= 4; end
            5: if (n5 > max_val) begin max_val <= n5; digit <= 5; end
            6: if (n6 > max_val) begin max_val <= n6; digit <= 6; end
            7: if (n7 > max_val) begin max_val <= n7; digit <= 7; end
            8: if (n8 > max_val) begin max_val <= n8; digit <= 8; end
            9: if (n9 > max_val) begin max_val <= n9; digit <= 9; end
          endcase

          if (idx == 9)
            state <= DONE_STATE;
          else
            idx <= idx + 1;
        end

        // ======================================================
        // FINALIZAÇÃO
        // ======================================================
        DONE_STATE:
        begin
          done <= 1;

          // libera para próxima imagem
          buffer_full <= 0;

          state <= IDLE;
        end

      endcase
    end
  end

  // ============================================================
  // DEBUG (PROGRESSO)
  // ============================================================
  reg [9:0] last_addr;

  always @(posedge clk)
    last_addr <= addr;

  always @(posedge clk)
  begin
    if (addr != last_addr)
    begin
      if (addr % 78 == 0)
      begin
        $display("Processando: %0d%%", (addr * 100) / 784);
      end
    end
  end

endmodule