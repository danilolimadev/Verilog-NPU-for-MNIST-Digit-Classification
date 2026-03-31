module final_argmax (
    input clk,
    input rst,
    input start,

    // scores dos 5 pares (valores reais)
    input [15:0] score0,
    input [15:0] score1,
    input [15:0] score2,
    input [15:0] score3,
    input [15:0] score4,

    // bits indicando qual neurônio venceu no par
    input [4:0] pair_results,

    output reg done,
    output reg [3:0] digit
);

    reg [2:0] state;

    parameter IDLE = 0,
              COMPUTE = 1,
              DONE_STATE = 2;

    // variáveis internas
    reg [15:0] max_val;
    reg [3:0]  max_digit;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            digit <= 0;
        end else begin
            case (state)

                IDLE: begin
                    done <= 0;
                    if (start)
                        state <= COMPUTE;
                end

                COMPUTE: begin
                    // inicializa com primeiro par
                    max_val <= score0;
                    max_digit <= (pair_results[0]) ? 1 : 0;

                    // compara par 1 (2 vs 3)
                    if (score1 > max_val) begin
                        max_val <= score1;
                        max_digit <= (pair_results[1]) ? 3 : 2;
                    end

                    // compara par 2 (4 vs 5)
                    if (score2 > max_val) begin
                        max_val <= score2;
                        max_digit <= (pair_results[2]) ? 5 : 4;
                    end

                    // compara par 3 (6 vs 7)
                    if (score3 > max_val) begin
                        max_val <= score3;
                        max_digit <= (pair_results[3]) ? 7 : 6;
                    end

                    // compara par 4 (8 vs 9)
                    if (score4 > max_val) begin
                        max_val <= score4;
                        max_digit <= (pair_results[4]) ? 9 : 8;
                    end

                    digit <= max_digit;
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