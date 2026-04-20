module top_classifier #(
    parameter INPUT_FILE = "data/input_0.mem"
)(
    input clk,
    input rst,
    input start,

    // AXI
    input  [7:0] s_axis_tdata,
    input        s_axis_tvalid,
    input        s_axis_tlast,
    output       s_axis_tready,

    output reg done,
    output reg [3:0] digit
);

  wire layer_done;

  // =========================
  // BUFFER AXI (🔥 NOVO)
  // =========================
  reg [7:0] buffer [0:783];
  reg [9:0] wr_ptr;
  reg buffer_full;

  assign s_axis_tready = !buffer_full;

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
        buffer[wr_ptr] <= s_axis_tdata;
        wr_ptr <= wr_ptr + 1;

        if (s_axis_tlast || wr_ptr == 10'd783)
        begin
          buffer_full <= 1;
          wr_ptr <= 0;
        end
      end
    end
  end

  // =========================
  // READ SIDE
  // =========================
  wire [9:0] addr;
  wire [7:0] input_data;

  assign input_data = buffer[addr];

  // =========================
  // START AUTOMÁTICO
  // =========================
  reg start_d;
  wire start_edge;

  always @(posedge clk)
    start_d <= buffer_full;

  assign start_edge = buffer_full & ~start_d;

  // =========================
  // EDGE DONE
  // =========================
  reg layer_done_d;
  wire layer_done_edge;

  always @(posedge clk)
    layer_done_d <= layer_done;

  assign layer_done_edge = layer_done & ~layer_done_d;

  // =========================
  // LAYER
  // =========================
  wire signed [15:0] n0,n1,n2,n3,n4;
  wire signed [15:0] n5,n6,n7,n8,n9;

  classifier_layer L1 (
    .clk(clk),
    .rst(rst),
    .start(start_edge),
    .input_data(input_data),
    .addr(addr),
    .done(layer_done),
    .n0(n0), .n1(n1),
    .n2(n2), .n3(n3),
    .n4(n4), .n5(n5),
    .n6(n6), .n7(n7),
    .n8(n8), .n9(n9)
  );

  // =========================
  // FSM (INALTERADA)
  // =========================
  reg [1:0] state;

  parameter IDLE = 0,
            COMPARE = 1,
            DONE_STATE = 2;

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

        DONE_STATE:
        begin
          done <= 1;
          buffer_full <= 0; // 🔥 libera próximo frame
          state <= IDLE;
        end

      endcase
    end
  end

  //DEBUG
  reg [9:0] last_addr;
  always @(posedge clk)
  begin
    last_addr <= addr;
  end

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