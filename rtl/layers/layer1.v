module layer1 (
    input clk,
    input rst,
    input start,

    output reg done,

    // resultado: 5 pares → cada um retorna 0 ou 1
    output reg [4:0] pair_results
);

    // =========================
    // controle
    // =========================
    reg [2:0] state;
    reg [2:0] pair_index;

    parameter IDLE  = 0,
              START_NEURON = 1,
              WAIT_NEURON  = 2,
              STORE_RESULT = 3,
              DONE_STATE   = 4;

    // =========================
    // neuron unit
    // =========================
    reg neuron_start;
    wire neuron_done;
    wire [7:0] neuron_result;

    neuron_pair_unit neuron (
        .clk(clk),
        .rst(rst),
        .start(neuron_start),
        .done(neuron_done),
        .result(neuron_result),
        .state_debug() // ignorar
    );

    // =========================
    // FSM
    // =========================
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            pair_index <= 0;
            done <= 0;
            neuron_start <= 0;
            pair_results <= 0;
        end else begin
            case (state)

                IDLE: begin
                    done <= 0;
                    if (start) begin
                        pair_index <= 0;
                        state <= START_NEURON;
                    end
                end

                START_NEURON: begin
                    neuron_start <= 1;
                    state <= WAIT_NEURON;
                end

                WAIT_NEURON: begin
                    neuron_start <= 0;
                    if (neuron_done)
                        state <= STORE_RESULT;
                end

                STORE_RESULT: begin
                    pair_results[pair_index] <= neuron_result[0]; // só 0 ou 1

                    if (pair_index == 4)
                        state <= DONE_STATE;
                    else begin
                        pair_index <= pair_index + 1;
                        state <= START_NEURON;
                    end
                end

                DONE_STATE: begin
                    done <= 1;
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule