`timescale 1ns/1ps

module tb_top_classifier;

    reg clk = 0;
    reg rst = 1;
    reg start = 0;

    // =========================
    // OUTPUTS DOS 10 DUTs
    // =========================
    wire done [0:9];
    wire [3:0] digit [0:9];

    integer cycles;

    // =========================
    // CLOCK
    // =========================
    always #5 clk = ~clk;

    // =========================
    // INSTÂNCIAS (10 INPUTS)
    // =========================
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_0.mem")) DUT0 (.clk(clk), .rst(rst), .start(start), .done(done[0]), .digit(digit[0]));
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_1.mem")) DUT1 (.clk(clk), .rst(rst), .start(start), .done(done[1]), .digit(digit[1]));
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_2.mem")) DUT2 (.clk(clk), .rst(rst), .start(start), .done(done[2]), .digit(digit[2]));
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_3.mem")) DUT3 (.clk(clk), .rst(rst), .start(start), .done(done[3]), .digit(digit[3]));
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_4.mem")) DUT4 (.clk(clk), .rst(rst), .start(start), .done(done[4]), .digit(digit[4]));
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_5.mem")) DUT5 (.clk(clk), .rst(rst), .start(start), .done(done[5]), .digit(digit[5]));
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_6.mem")) DUT6 (.clk(clk), .rst(rst), .start(start), .done(done[6]), .digit(digit[6]));
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_7.mem")) DUT7 (.clk(clk), .rst(rst), .start(start), .done(done[7]), .digit(digit[7]));
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_8.mem")) DUT8 (.clk(clk), .rst(rst), .start(start), .done(done[8]), .digit(digit[8]));
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_9.mem")) DUT9 (.clk(clk), .rst(rst), .start(start), .done(done[9]), .digit(digit[9]));

    // =========================
    // START PULSE
    // =========================
    task start_pulse;
    begin
        @(posedge clk);
        start = 1;
        @(posedge clk);
        start = 0;
    end
    endtask

    // =========================
    // TESTE
    // =========================
    integer i;

    initial begin
        $display("\n======================================");
        $display(" TESTE 10 DIGITOS EM PARALELO");
        $display("======================================");

        cycles = 0;

        // RESET
        repeat(5) @(posedge clk);
        rst = 0;

        // START GLOBAL
        start_pulse();

        // ESPERA TODOS TERMINAREM
        while (!(done[0] && done[1] && done[2] && done[3] && done[4] &&
                 done[5] && done[6] && done[7] && done[8] && done[9])
               && cycles < 2000000) begin

            @(posedge clk);
            cycles = cycles + 1;

            if (cycles % 200000 == 0)
                $display("... ciclos = %d", cycles);
        end

        if (cycles >= 2000000) begin
            $display("TIMEOUT ❌");
            $stop;
        end

        @(posedge clk);

        // =========================
        // RESULTADOS
        // =========================
        $display("\n==== RESULTADOS ====");

        for (i = 0; i < 10; i = i + 1) begin
            $display("Input %0d → Predito = %0d", i, digit[i]);
        end

        $display("Cycles = %d", cycles);
        $display("====================\n");

        #50 $stop;
    end

endmodule