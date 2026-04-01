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

    // scores
    wire [15:0] score0, score1, score2, score3, score4;

    // =========================
    // EDGE DETECT (start global)
    // =========================
    reg start_d;
    wire start_edge;

    always @(posedge clk) begin
        start_d <= start;
    end

    assign start_edge = start & ~start_d;

    // =========================
    // EDGE DETECT (layer_done)
    // =========================
    reg layer_done_d;
    wire layer_done_edge;

    always @(posedge clk) begin
        layer_done_d <= layer_done;
    end

    assign layer_done_edge = layer_done & ~layer_done_d;

    // =========================
    // LAYER 1
    // =========================
    layer1 L1 (
        .clk(clk),
        .rst(rst),
        .start(start_edge),   // 🔥 corrigido
        .done(layer_done),
        .pair_results(pair_results),

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
        .start(layer_done_edge),  // 🔥 corrigido

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