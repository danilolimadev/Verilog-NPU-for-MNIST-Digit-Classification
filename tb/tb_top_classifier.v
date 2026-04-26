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
    // CFG (NOVO)
    // =========================
    reg        cfg_valid;
    reg [3:0]  cfg_neuron;
    reg [9:0]  cfg_addr;
    reg [7:0]  cfg_weight;
    reg        cfg_is_bias;
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

    reg [7:0] w0 [0:783];
    reg [7:0] w1 [0:783];
    reg [7:0] w2 [0:783];
    reg [7:0] w3 [0:783];
    reg [7:0] w4 [0:783];
    reg [7:0] w5 [0:783];
    reg [7:0] w6 [0:783];
    reg [7:0] w7 [0:783];
    reg [7:0] w8 [0:783];
    reg [7:0] w9 [0:783];

    reg [7:0] bias_mem [0:9];

    // =========================
    // CLOCK
    // =========================
    always #5 clk = ~clk;

    // =========================
    // DUTs
    // =========================
    top_classifier DUT0 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[0]), .digit(digit[0]),
        .s_axis_tdata(tdata[0]), .s_axis_tvalid(tvalid[0]),
        .s_axis_tlast(tlast[0]), .s_axis_tready(tready[0])
    );

    top_classifier DUT1 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[1]), .digit(digit[1]),
        .s_axis_tdata(tdata[1]), .s_axis_tvalid(tvalid[1]),
        .s_axis_tlast(tlast[1]), .s_axis_tready(tready[1])
    );

    top_classifier DUT2 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[2]), .digit(digit[2]),
        .s_axis_tdata(tdata[2]), .s_axis_tvalid(tvalid[2]),
        .s_axis_tlast(tlast[2]), .s_axis_tready(tready[2])
    );

    top_classifier DUT3 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[3]), .digit(digit[3]),
        .s_axis_tdata(tdata[3]), .s_axis_tvalid(tvalid[3]),
        .s_axis_tlast(tlast[3]), .s_axis_tready(tready[3])
    );

    top_classifier DUT4 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[4]), .digit(digit[4]),
        .s_axis_tdata(tdata[4]), .s_axis_tvalid(tvalid[4]),
        .s_axis_tlast(tlast[4]), .s_axis_tready(tready[4])
    );

    top_classifier DUT5 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[5]), .digit(digit[5]),
        .s_axis_tdata(tdata[5]), .s_axis_tvalid(tvalid[5]),
        .s_axis_tlast(tlast[5]), .s_axis_tready(tready[5])
    );

    top_classifier DUT6 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[6]), .digit(digit[6]),
        .s_axis_tdata(tdata[6]), .s_axis_tvalid(tvalid[6]),
        .s_axis_tlast(tlast[6]), .s_axis_tready(tready[6])
    );

    top_classifier DUT7 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[7]), .digit(digit[7]),
        .s_axis_tdata(tdata[7]), .s_axis_tvalid(tvalid[7]),
        .s_axis_tlast(tlast[7]), .s_axis_tready(tready[7])
    );

    top_classifier DUT8 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[8]), .digit(digit[8]),
        .s_axis_tdata(tdata[8]), .s_axis_tvalid(tvalid[8]),
        .s_axis_tlast(tlast[8]), .s_axis_tready(tready[8])
    );

    top_classifier DUT9 (
        .clk(clk), .rst(rst), .start(start),
        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),
        .done(done[9]), .digit(digit[9]),
        .s_axis_tdata(tdata[9]), .s_axis_tvalid(tvalid[9]),
        .s_axis_tlast(tlast[9]), .s_axis_tready(tready[9])
    );

    integer i, j;
    task load_weights;
    begin
        $display("Carregando pesos reais...");
        cfg_valid   <= 1;
        cfg_is_bias <= 0;

        for (i = 0; i < 10; i = i + 1)
        begin
            for (j = 0; j < 784; j = j + 1)
            begin
                @(posedge clk);
                cfg_neuron <= i;
                cfg_addr   <= j;

                case (i)
                    0: cfg_weight <= w0[j];
                    1: cfg_weight <= w1[j];
                    2: cfg_weight <= w2[j];
                    3: cfg_weight <= w3[j];
                    4: cfg_weight <= w4[j];
                    5: cfg_weight <= w5[j];
                    6: cfg_weight <= w6[j];
                    7: cfg_weight <= w7[j];
                    8: cfg_weight <= w8[j];
                    9: cfg_weight <= w9[j];
                endcase
            end
        end

        @(posedge clk);
        cfg_valid <= 0;

        $display("Pesos carregados (arquivo)!");
    end
    endtask

    task load_bias;
    begin
        $display("Carregando bias...");
        cfg_valid   <= 1;
        cfg_is_bias <= 1; 
        cfg_addr    <= 0;
        for (i = 0; i < 10; i = i + 1)
        begin
            @(posedge clk);
            cfg_neuron  <= i;
            cfg_weight  <= bias_mem[i];
        end

        @(posedge clk);
        cfg_valid   <= 0;
        cfg_is_bias <= 0;

        $display("Bias carregados!");
    end
    endtask

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

        cfg_valid  = 0;
        cfg_neuron = 0;
        cfg_addr   = 0;
        cfg_weight = 0;
        cfg_is_bias = 0;

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

        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n0.mem", w0);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n1.mem", w1);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n2.mem", w2);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n3.mem", w3);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n4.mem", w4);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n5.mem", w5);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n6.mem", w6);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n7.mem", w7);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n8.mem", w8);
        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/weights_n9.mem", w9);

        $readmemh("E:/Disco Local E/Projeto/CI Digital/verilog-npu-mnist/data/bias.mem", bias_mem);

        // RESET
        repeat(5) @(posedge clk);
        rst = 0;

        // CONFIGURA PESOS
        load_bias();
        load_weights();

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