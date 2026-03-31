module top_classifier (
    input clk,
    input rst,
    input start,

    output done,
    output [3:0] digit
);

    wire [4:0] pair_results;
    wire layer_done;
    wire final_done;

    layer1 L1 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(layer_done),
        .pair_results(pair_results)
    );

    final_argmax FA (
        .clk(clk),
        .rst(rst),
        .start(layer_done),
        .pair_results(pair_results),
        .done(final_done),
        .digit(digit)
    );

    assign done = final_done;

endmodule