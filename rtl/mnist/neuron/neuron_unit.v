module neuron_unit (
    input clk,
    input rst,
    input start,
    input [7:0] input_data,
    input [7:0] weight,
    input [7:0] bias,

    output reg done,
    output reg pixel_done,
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
  // NPU CORE
  // =========================
  reg [7:0] DA, DB;

  wire DONE;
  wire signed [15:0] MAC_OUT;

  neuron_core NCR (
    .CLKEXT(clk),
    .RST_GLO(rst),
    .START(start_pulse),
    .DA(DA),
    .DB(DB),
    .DONE(DONE),
    .STATE_DEBUG(state_debug),
    .MAC_OUT(MAC_OUT)
  );

  // =========================
  // INPUT PIPE
  // =========================
  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      DA <= 0;
      DB <= 0;
    end
    else
    begin
      DA <= input_data;
      DB <= weight;
    end
  end

  // =========================
  // ACUMULADOR
  // =========================
  reg signed [31:0] acc;

  // contador local
  reg [9:0] count;

  // =========================
  // FSM
  // =========================
  reg [2:0] state;

  parameter IDLE = 0,
            LOAD = 1,
            WAIT_NPU = 2,
            NEXT = 3,
            DONE_STATE = 4;

  always @(posedge clk or posedge rst)
  begin
    if (rst)
    begin
      state <= IDLE;
      done <= 0;
      pixel_done <= 0;
      start_pulse <= 0;
      acc <= 0;
      score <= 0;
      count <= 0;
    end
    else
    begin
      // default
      pixel_done <= 0;

      case (state)

        IDLE:
        begin
          done <= 0;
          if (start_edge)
          begin
            acc <= 0;
            count <= 0;
            state <= LOAD;
          end
        end

        LOAD:
        begin
          start_pulse <= 1;
          state <= WAIT_NPU;
        end

        WAIT_NPU:
        begin
          start_pulse <= 0;
          if (DONE)
          begin
            acc <= acc + MAC_OUT;
            pixel_done <= 1;
            state <= NEXT;
          end
        end

        NEXT:
        begin
          if (count == 10'd783)
            state <= DONE_STATE;
          else
          begin
            count <= count + 1;
            state <= LOAD;
          end
        end

        DONE_STATE:
        begin
          done <= 1;
          score <= acc + $signed({{8{bias[7]}}, bias});
          state <= IDLE;
        end

      endcase
    end
  end

endmodule