module top_classifier #(
    parameter INPUT_FILE = "data/input_0.mem"
  )(
    input clk,
    input rst,
    input start,
    output reg done,
    output reg [3:0] digit
  );
  wire layer_done;

  // SIGNED
  wire signed [15:0] n0, n1, n2, n3, n4;
  wire signed [15:0] n5, n6, n7, n8, n9;

  // =========================
  // EDGE DETECT
  // =========================
  reg start_d;
  wire start_edge;

  always @(posedge clk)
    start_d <= start;

  assign start_edge = start & ~start_d;

  reg layer_done_d;
  wire layer_done_edge;

  always @(posedge clk)
    layer_done_d <= layer_done;

  assign layer_done_edge = layer_done & ~layer_done_d;

  // =========================
  // LAYER
  // =========================
  classifier_layer #(
                     .INPUT_FILE(INPUT_FILE)
                   ) L1 (
                     .clk(clk),
                     .rst(rst),
                     .start(start_edge),
                     .done(layer_done),
                     .n0(n0), .n1(n1),
                     .n2(n2), .n3(n3),
                     .n4(n4), .n5(n5),
                     .n6(n6), .n7(n7),
                     .n8(n8), .n9(n9)
                   );

  // =========================
  // FSM
  // =========================
  reg [1:0] state;

  parameter IDLE = 0,
            COMPARE = 1,
            DONE_STATE = 2;

  reg [3:0] idx;
  reg signed [15:0] max_val;

  // =========================
  // FSM PRINCIPAL
  // =========================
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
            $display("\n--- SCORES ---");
            $display("n0=%d n1=%d n2=%d n3=%d n4=%d", n0,n1,n2,n3,n4);
            $display("n5=%d n6=%d n7=%d n8=%d n9=%d", n5,n6,n7,n8,n9);

            max_val <= n0;
            digit   <= 0;
            idx     <= 1; // começa do n1

            state <= COMPARE;
          end
        end

        COMPARE:
        begin
          case (idx)

            4'd1:
              if (n1 > max_val)
              begin
                max_val <= n1;
                digit <= 1;
              end
            4'd2:
              if (n2 > max_val)
              begin
                max_val <= n2;
                digit <= 2;
              end
            4'd3:
              if (n3 > max_val)
              begin
                max_val <= n3;
                digit <= 3;
              end
            4'd4:
              if (n4 > max_val)
              begin
                max_val <= n4;
                digit <= 4;
              end
            4'd5:
              if (n5 > max_val)
              begin
                max_val <= n5;
                digit <= 5;
              end
            4'd6:
              if (n6 > max_val)
              begin
                max_val <= n6;
                digit <= 6;
              end
            4'd7:
              if (n7 > max_val)
              begin
                max_val <= n7;
                digit <= 7;
              end
            4'd8:
              if (n8 > max_val)
              begin
                max_val <= n8;
                digit <= 8;
              end
            4'd9:
              if (n9 > max_val)
              begin
                max_val <= n9;
                digit <= 9;
              end

          endcase

          if (idx == 4'd9)
          begin
            state <= DONE_STATE;
          end
          else
          begin
            idx <= idx + 1;
          end
        end

        DONE_STATE:
        begin
          $display("\n--- ARGMAX GLOBAL ---");
          $display("MAX = %d | DIGIT = %d", max_val, digit);

          done <= 1;
          state <= IDLE;
        end
      endcase
    end
  end
endmodule
