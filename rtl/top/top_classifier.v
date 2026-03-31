module top_classifier (
    input clk,
    input rst,
    input start,

    output done,
    output [3:0] digit
);

    // =========================
    // sinais
    // =========================
    wire [4:0] pair_results;
    wire layer_done;
    wire final_done;

    // 🔥 NOVOS: scores dos pares
    wire [15:0] score0, score1, score2, score3, score4;

    // =========================
    // LAYER 1
    // =========================
    layer1 L1 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(layer_done),
        .pair_results(pair_results),

        // 🔥 conectar scores
        .score0(score0),
        .score1(score1),
        .score2(score2),
        .score3(score3),
        .score4(score4)
    );

    // =========================
    // ARGMAX FINAL
    // =========================
    final_argmax FA (
        .clk(clk),
        .rst(rst),
        .start(layer_done),

        // 🔥 agora usa scores reais
        .score0(score0),
        .score1(score1),
        .score2(score2),
        .score3(score3),
        .score4(score4),

        .pair_results(pair_results),
        .done(final_done),
        .digit(digit)
    );

    assign done = final_done;

endmodule