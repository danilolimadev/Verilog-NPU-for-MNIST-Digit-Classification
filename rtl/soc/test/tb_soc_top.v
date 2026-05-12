`timescale 1ns/1ps
// =============================================================
// Testbench do SoC
// Bootloader + UART + AXI_MNIST + carga de weights/bias
// =============================================================

module soc_tb;

  // =========================================================
  // CLOCK E RESET
  // =========================================================

  reg clk;
  reg resetn;
  reg boot_mode;

  // Clock 50 MHz
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  // Reset + boot
  initial begin
    resetn    = 0;
    boot_mode = 0;

    #200;
    resetn = 1;

    #100;
    boot_mode = 1;
  end

  // =========================================================
  // UART
  // =========================================================

  wire uart_tx;
  reg  uart_rx;

  // =========================================================
  // SPI
  // =========================================================

  wire spi_mosi;
  wire spi_miso;
  wire spi_sck;
  wire spi_cs;

  assign spi_miso = 1'b0;

  // =========================================================
  // I2C
  // =========================================================

  wire i2c_sda;
  wire i2c_scl;

  wire mnist_done;
  wire [3:0] mnist_digit;

  pullup(i2c_sda);
  pullup(i2c_scl);

  reg tb_drive_sda_low = 0;
  assign i2c_sda = (tb_drive_sda_low) ? 1'b0 : 1'bz;

  // =========================================================
  // OUTROS SINAIS
  // =========================================================

  wire [31:0] gpio_out;
  wire        trap;
  wire        timer_irq;

  wire        uart_rx_boot;
  wire [31:0] firmware_size;

  // =========================================================
  // MEMÓRIAS DE PESOS / BIAS
  // =========================================================

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

  integer i;
  integer j;

  // =========================================================
  // BOOTLOADER UART
  // =========================================================

  bootloader_uart #(
    .FIRMWARE_FILE("firmware.hex")
  ) tb_boot (
    .clk(clk),
    .resetn(resetn),
    .boot_enable(boot_mode),
    .uart_tx(uart_rx_boot),
    .done(),
    .firmware_size(firmware_size)
  );

  // =========================================================
  // SOC TOP
  // =========================================================

  soc_top uut (
    .clk(clk),
    .resetn(resetn),
    .boot_mode(boot_mode),
    .uart_rx_boot(uart_rx_boot),
    .firmware_size(firmware_size),

    .trap(trap),
    .gpio_out(gpio_out),
    .timer_irq(timer_irq),

    .uart_tx(uart_tx),
    .uart_rx(uart_rx),

    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .spi_sck(spi_sck),
    .spi_cs(spi_cs),

    .i2c_sda(i2c_sda),
    .i2c_scl(i2c_scl),

    .mnist_done(mnist_done),
    .mnist_digit(mnist_digit)

  );

  // =========================================================
  // TASK AUXILIAR
  // =========================================================

  task send_and_log;
    input [8*1:1] char_name;
    input [7:0]   value;
    input integer delay_after;
    begin
      $display("[TB] Enviando byte '%s'", char_name);
      uart_send_byte(value);
      #(delay_after);
    end
  endtask

  // =========================================================
  // UART SEND BYTE (8N1)
  // =========================================================

  task uart_send_byte;
    input [7:0] data;
    integer k;
    begin
      // start bit
      uart_rx = 1'b0;
      #400;

      // data bits (LSB first)
      for (k = 0; k < 8; k = k + 1)
      begin
        uart_rx = data[k];
        #400;
      end

      // stop bit
      uart_rx = 1'b1;
      #400;
    end
  endtask

  // =========================================================
  // LOAD WEIGHTS + BIAS
  // =========================================================

  task load_mnist_cfg;
  begin
    $display("\n====================================");
    $display("[TB] Carregando pesos e bias da NPU...");
    $display("====================================");

    // =====================================
    // LOAD FILES
    // =====================================

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

    // =====================================
    // LOAD BIAS
    // =====================================

    for (i = 0; i < 10; i = i + 1)
    begin
      @(posedge clk);

      uut.mnist_inst.cfg_is_bias <= 1'b1;
      uut.mnist_inst.cfg_neuron  <= i;
      uut.mnist_inst.cfg_addr    <= 0;
      uut.mnist_inst.cfg_weight  <= bias_mem[i];
      uut.mnist_inst.cfg_valid   <= 1'b1;

      @(posedge clk);
      uut.mnist_inst.cfg_valid   <= 1'b0;
    end

    // =====================================
    // LOAD WEIGHTS
    // =====================================

    for (i = 0; i < 10; i = i + 1)
    begin
      for (j = 0; j < 784; j = j + 1)
      begin
        @(posedge clk);

        uut.mnist_inst.cfg_is_bias <= 1'b0;
        uut.mnist_inst.cfg_neuron  <= i;
        uut.mnist_inst.cfg_addr    <= j;

        case (i)
          0: uut.mnist_inst.cfg_weight <= w0[j];
          1: uut.mnist_inst.cfg_weight <= w1[j];
          2: uut.mnist_inst.cfg_weight <= w2[j];
          3: uut.mnist_inst.cfg_weight <= w3[j];
          4: uut.mnist_inst.cfg_weight <= w4[j];
          5: uut.mnist_inst.cfg_weight <= w5[j];
          6: uut.mnist_inst.cfg_weight <= w6[j];
          7: uut.mnist_inst.cfg_weight <= w7[j];
          8: uut.mnist_inst.cfg_weight <= w8[j];
          9: uut.mnist_inst.cfg_weight <= w9[j];
        endcase

        uut.mnist_inst.cfg_valid <= 1'b1;

        @(posedge clk);
        uut.mnist_inst.cfg_valid <= 1'b0;
      end
    end

    $display("[TB] Pesos e bias carregados com sucesso!\n");
  end
  endtask

  // =========================================================
  // TESTE PRINCIPAL
  // =========================================================

  initial begin
    uart_rx = 1'b1;

    wait(boot_mode);

    $display("\n====================================");
    $display("[TB] Bootloader ativado...");
    $display("====================================");

    // espera ROM terminar
    wait(uut.boot_mgr.rom_done);

    // carrega pesos e bias antes da CPU iniciar
    load_mnist_cfg();

    // libera CPU
    boot_mode = 0;

    $display("[TB] Firmware carregado com sucesso!");
    $display("[TB] CPU iniciando execução...\n");

    // tempo para CPU subir
    #3000000;

    // =====================================
    // TESTES ANTIGOS
    // =====================================

    send_and_log("A", 8'h41, 100000);
    send_and_log("B", 8'h42, 1300000);
    send_and_log("C", 8'h43, 200000);
    send_and_log("D", 8'h44, 200000);
    send_and_log("E", 8'h45, 200000);

    // =====================================
    // TESTE AXI_MNIST
    // =====================================

    $display("\n====================================");
    $display("[TB] TESTE AXI_MNIST");
    $display("====================================");

    // comando UART 'M'
    send_and_log("M", 8'h4D, 5000000);

    // espera processamento
    #3000000;

    $display("\n====================================");
    $display("[TB] Teste finalizado.");
    $display("====================================");

    $stop;
  end

endmodule