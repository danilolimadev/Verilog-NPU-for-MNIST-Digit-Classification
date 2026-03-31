module final_argmax (
    input clk,
    input rst,
    input start,

    input [4:0] pair_results,   // resultados da layer1

    output reg done,
    output reg [3:0] digit
);

    reg [2:0] state;

    parameter IDLE = 0,
              COMPUTE = 1,
              DONE_STATE = 2;

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
                    // lógica simples (árvore manual)
                    if (pair_results[4]) digit <= 9;
                    else if (pair_results[3]) digit <= 7;
                    else if (pair_results[2]) digit <= 5;
                    else if (pair_results[1]) digit <= 3;
                    else if (pair_results[0]) digit <= 1;
                    else digit <= 0;

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