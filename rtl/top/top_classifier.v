module top_classifier #(
    parameter INPUT_FILE = "data/input_0.mem"
)(
    input clk,
    input rst,
    input start,

    output reg done,
    output reg [3:0] digit
);

    // =========================
    // sinais
    // =========================
    wire layer_done;

    // 🔥 10 neurônios
    wire [15:0] n0, n1, n2, n3, n4;
    wire [15:0] n5, n6, n7, n8, n9;

    // =========================
    // EDGE DETECT (start global)
    // =========================
    reg start_d;
    wire start_edge;

    always @(posedge clk)
        start_d <= start;

    assign start_edge = start & ~start_d;

    // =========================
    // EDGE DETECT (layer_done)
    // =========================
    reg layer_done_d;
    wire layer_done_edge;

    always @(posedge clk)
        layer_done_d <= layer_done;

    assign layer_done_edge = layer_done & ~layer_done_d;

    // =========================
    // LAYER 1
    // =========================
    layer1 #(
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
    // ARGMAX GLOBAL (10 classes)
    // =========================
    reg [15:0] max_val;

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            digit <= 0;
            done <= 0;
            max_val <= 0;
        end
        else
        begin
            done <= 0;

            if (layer_done_edge)
            begin
                // 🔥 argmax completo
                max_val = n0;
                digit  = 0;

                if (n1 > max_val) begin max_val = n1; digit = 1; end
                if (n2 > max_val) begin max_val = n2; digit = 2; end
                if (n3 > max_val) begin max_val = n3; digit = 3; end
                if (n4 > max_val) begin max_val = n4; digit = 4; end
                if (n5 > max_val) begin max_val = n5; digit = 5; end
                if (n6 > max_val) begin max_val = n6; digit = 6; end
                if (n7 > max_val) begin max_val = n7; digit = 7; end
                if (n8 > max_val) begin max_val = n8; digit = 8; end
                if (n9 > max_val) begin max_val = n9; digit = 9; end

                // DEBUG 🔥
                $display("\n--- ARGMAX GLOBAL ---");
                $display("n0=%d n1=%d n2=%d n3=%d n4=%d", n0,n1,n2,n3,n4);
                $display("n5=%d n6=%d n7=%d n8=%d n9=%d", n5,n6,n7,n8,n9);
                $display("=> DIGIT = %d", digit);

                done <= 1;
            end
        end
    end

endmodule