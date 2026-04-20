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
    // AXI SIGNALS
    // =========================
    reg  [7:0] tdata  [0:9];
    reg        tvalid [0:9];
    reg        tlast  [0:9];
    wire       tready [0:9];

    // =========================
    // MEMÓRIAS (CORRIGIDO)
    // =========================
    reg [7:0] mem0 [0:783];
    reg [7:0] mem1 [0:783];
    reg [7:0] mem2 [0:783];
    reg [7:0] mem3 [0:783];
    reg [7:0] mem4 [0:783];
    reg [7:0] mem5 [0:783];
    reg [7:0] mem6 [0:783];
    reg [7:0] mem7 [0:783];
    reg [7:0] mem8 [0:783];
    reg [7:0] mem9 [0:783];

    // =========================
    // CLOCK
    // =========================
    always #5 clk = ~clk;

    // =========================
    // DUTs
    // =========================
    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_0.mem")) DUT0 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[0]), .digit(digit[0]),
        .s_axis_tdata(tdata[0]), .s_axis_tvalid(tvalid[0]),
        .s_axis_tlast(tlast[0]), .s_axis_tready(tready[0])
    );

    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_1.mem")) DUT1 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[1]), .digit(digit[1]),
        .s_axis_tdata(tdata[1]), .s_axis_tvalid(tvalid[1]),
        .s_axis_tlast(tlast[1]), .s_axis_tready(tready[1])
    );

    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_2.mem")) DUT2 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[2]), .digit(digit[2]),
        .s_axis_tdata(tdata[2]), .s_axis_tvalid(tvalid[2]),
        .s_axis_tlast(tlast[2]), .s_axis_tready(tready[2])
    );

    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_3.mem")) DUT3 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[3]), .digit(digit[3]),
        .s_axis_tdata(tdata[3]), .s_axis_tvalid(tvalid[3]),
        .s_axis_tlast(tlast[3]), .s_axis_tready(tready[3])
    );

    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_4.mem")) DUT4 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[4]), .digit(digit[4]),
        .s_axis_tdata(tdata[4]), .s_axis_tvalid(tvalid[4]),
        .s_axis_tlast(tlast[4]), .s_axis_tready(tready[4])
    );

    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_5.mem")) DUT5 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[5]), .digit(digit[5]),
        .s_axis_tdata(tdata[5]), .s_axis_tvalid(tvalid[5]),
        .s_axis_tlast(tlast[5]), .s_axis_tready(tready[5])
    );

    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_6.mem")) DUT6 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[6]), .digit(digit[6]),
        .s_axis_tdata(tdata[6]), .s_axis_tvalid(tvalid[6]),
        .s_axis_tlast(tlast[6]), .s_axis_tready(tready[6])
    );

    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_7.mem")) DUT7 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[7]), .digit(digit[7]),
        .s_axis_tdata(tdata[7]), .s_axis_tvalid(tvalid[7]),
        .s_axis_tlast(tlast[7]), .s_axis_tready(tready[7])
    );

    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_8.mem")) DUT8 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[8]), .digit(digit[8]),
        .s_axis_tdata(tdata[8]), .s_axis_tvalid(tvalid[8]),
        .s_axis_tlast(tlast[8]), .s_axis_tready(tready[8])
    );

    top_classifier #(.INPUT_FILE("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_9.mem")) DUT9 (
        .clk(clk), .rst(rst), .start(start),
        .done(done[9]), .digit(digit[9]),
        .s_axis_tdata(tdata[9]), .s_axis_tvalid(tvalid[9]),
        .s_axis_tlast(tlast[9]), .s_axis_tready(tready[9])
    );

    // =========================
    // START
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
    // ENVIO AXI
    // =========================
    integer i, j;

    task send_all_images;
    begin
        for (i = 0; i < 784; i = i + 1)
        begin
            for (j = 0; j < 10; j = j + 1)
            begin
                tvalid[j] <= 1;

                case (j)
                    0: tdata[j] <= mem0[i];
                    1: tdata[j] <= mem1[i];
                    2: tdata[j] <= mem2[i];
                    3: tdata[j] <= mem3[i];
                    4: tdata[j] <= mem4[i];
                    5: tdata[j] <= mem5[i];
                    6: tdata[j] <= mem6[i];
                    7: tdata[j] <= mem7[i];
                    8: tdata[j] <= mem8[i];
                    9: tdata[j] <= mem9[i];
                endcase

                tlast[j] <= (i == 783);
            end

            // 🔥 ESPERA TODOS ACEITAREM
            wait (tready[0] && tready[1] && tready[2] && tready[3] && tready[4] &&
                tready[5] && tready[6] && tready[7] && tready[8] && tready[9]);

            @(posedge clk);
        end

        // DESLIGA
        @(posedge clk);
        for (j = 0; j < 10; j = j + 1)
        begin
            tvalid[j] <= 0;
            tlast[j]  <= 0;
        end
    end
    endtask

    // =========================
    // TESTE
    // =========================
    initial begin
        $display("\n======================================");
        $display(" TESTE 10 DIGITOS EM PARALELO");
        $display("======================================");

        cycles = 0;

        // INIT AXI
        for (i = 0; i < 10; i = i + 1)
        begin
            tvalid[i] = 0;
            tlast[i]  = 0;
            tdata[i]  = 0;
        end

        // LOAD MEM
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_0.mem", mem0);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_1.mem", mem1);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_2.mem", mem2);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_3.mem", mem3);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_4.mem", mem4);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_5.mem", mem5);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_6.mem", mem6);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_7.mem", mem7);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_8.mem", mem8);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/input_9.mem", mem9);

        // RESET
        repeat(5) @(posedge clk);
        rst = 0;

        // START
        start_pulse();

        // ENVIA AXI
        send_all_images();

        // ESPERA
        while (!(done[0] && done[1] && done[2] && done[3] && done[4] &&
                 done[5] && done[6] && done[7] && done[8] && done[9])
               && cycles < 2000000) begin

            @(posedge clk);
            cycles = cycles + 1;
        end

        if (cycles >= 2000000) begin
            $display("TIMEOUT ❌");
            $stop;
        end

        @(posedge clk);

        $display("\n==== RESULTADOS ====");
        for (i = 0; i < 10; i = i + 1)
            $display("Input %0d → Predito = %0d", i, digit[i]);

        $display("Cycles = %d", cycles);
        $display("====================\n");

        #50 $stop;
    end

endmodule