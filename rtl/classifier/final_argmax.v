module final_argmax (
    input clk,
    input rst,
    input start,

    input [15:0] score0,
    input [15:0] score1,
    input [15:0] score2,
    input [15:0] score3,
    input [15:0] score4,

    input [4:0] pair_results,

    output reg done,
    output reg [3:0] digit
);

    // =========================
    // EDGE DETECT (start)
    // =========================
    reg start_d;
    wire start_edge;

    always @(posedge clk) begin
        start_d <= start;
    end

    assign start_edge = start & ~start_d;

    // =========================
    // FSM
    // =========================
    reg [1:0] state;

    parameter IDLE = 0,
              COMPUTE = 1,
              DONE_STATE = 2;

    // =========================
    // regs
    // =========================
    reg [15:0] max_val;
    reg [3:0]  max_digit;

    reg [15:0] tmp_max_val;
    reg [3:0]  tmp_max_digit;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            digit <= 0;
            max_val <= 0;
            max_digit <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;

                    if (start_edge)
                        state <= COMPUTE;
                end

                COMPUTE: begin

                    // 🔥 usar blocking aqui (cálculo combinacional interno)
                    tmp_max_val = score0;
                    tmp_max_digit = (pair_results[0]) ? 1 : 0;

                    if (score1 > tmp_max_val) begin
                        tmp_max_val = score1;
                        tmp_max_digit = (pair_results[1]) ? 3 : 2;
                    end

                    if (score2 > tmp_max_val) begin
                        tmp_max_val = score2;
                        tmp_max_digit = (pair_results[2]) ? 5 : 4;
                    end

                    if (score3 > tmp_max_val) begin
                        tmp_max_val = score3;
                        tmp_max_digit = (pair_results[3]) ? 7 : 6;
                    end

                    if (score4 > tmp_max_val) begin
                        tmp_max_val = score4;
                        tmp_max_digit = (pair_results[4]) ? 9 : 8;
                    end

                    // 🔥 registrar (non-blocking)
                    max_val   <= tmp_max_val;
                    max_digit <= tmp_max_digit;
                    digit     <= tmp_max_digit;

                    state <= DONE_STATE;
                end

                DONE_STATE: begin
                    done <= 1;
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule