module top_classifier (
    input clk,
    input rst,
    input start,

    output done,
    output [3:0] digit
);

    wire [4:0] pair_results;

    layer1 L1 (
        .clk(clk),
        .rst(rst),
        .start(start),
        .done(done),
        .pair_results(pair_results)
    );

    final_classifier FC (
        .pair_results(pair_results),
        .digit(digit)
    );

endmodule