module axi_mnist #(
    parameter ADDR_WIDTH = 12,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,
    input  wire                  resetn,

    // =====================================================
    // AXI-LITE SLAVE
    // =====================================================
    input  wire [ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire                  s_axi_awvalid,
    output reg                   s_axi_awready,

    input  wire [DATA_WIDTH-1:0] s_axi_wdata,
    input  wire [3:0]            s_axi_wstrb,
    input  wire                  s_axi_wvalid,
    output reg                   s_axi_wready,

    output wire [1:0]            s_axi_bresp,
    output reg                   s_axi_bvalid,
    input  wire                  s_axi_bready,

    input  wire [ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire                  s_axi_arvalid,
    output reg                   s_axi_arready,

    output reg  [DATA_WIDTH-1:0] s_axi_rdata,
    output wire [1:0]            s_axi_rresp,
    output reg                   s_axi_rvalid,
    input  wire                  s_axi_rready,

    output wire                  mnist_done,
    output wire [3:0]            mnist_digit
);

    // =====================================================
    // AXI RESP
    // =====================================================
    assign s_axi_bresp = 2'b00;
    assign s_axi_rresp = 2'b00;

    // =====================================================
    // AXI HANDSHAKE
    // =====================================================
    reg [ADDR_WIDTH-1:0] awaddr_lat;
    reg                  awaddr_valid;

    reg [ADDR_WIDTH-1:0] araddr_lat;

    wire aw_hs = s_axi_awvalid && s_axi_awready;
    wire w_hs  = s_axi_wvalid  && s_axi_wready;
    wire ar_hs = s_axi_arvalid && s_axi_arready;

    // =====================================================
    // CONTROLE INTERNO
    // =====================================================
    reg start;

    // configuração (mantido para futuro)
    reg        cfg_valid;
    reg [3:0]  cfg_neuron;
    reg [9:0]  cfg_addr;
    reg [7:0]  cfg_weight;
    reg        cfg_is_bias;

    // stream de pixels
    reg [7:0] pixel_data;
    reg       pixel_valid;
    reg       pixel_last;

    wire      pixel_ready;

    // =====================================================
    // TOP CLASSIFIER
    // =====================================================
    top_classifier DUT (
        .clk(clk),
        .rst(~resetn),
        .start(start),

        .cfg_valid(cfg_valid),
        .cfg_neuron(cfg_neuron),
        .cfg_addr(cfg_addr),
        .cfg_weight(cfg_weight),
        .cfg_is_bias(cfg_is_bias),

        .s_axis_tdata(pixel_data),
        .s_axis_tvalid(pixel_valid),
        .s_axis_tlast(pixel_last),
        .s_axis_tready(pixel_ready),

        .done(mnist_done),
        .digit(mnist_digit)
    );

    always @(posedge clk or negedge resetn)
    begin
        if (!resetn)
        begin
            // nada
        end
        else
        begin
            if (mnist_done)
            begin
                $display("\n====================================");
                $display("[SOC_TOP] MNIST DONE!");
                $display("[SOC_TOP] DIGITO PREDITO = %0d", mnist_digit);
                $display("[SOC_TOP] TIME = %0t", $time);
                $display("====================================\n");
            end
        end
    end

    // =====================================================
    // AXI FSM
    // =====================================================
    always @(posedge clk or negedge resetn)
    begin
        if (!resetn)
        begin
            s_axi_awready <= 0;
            s_axi_wready  <= 0;
            s_axi_bvalid  <= 0;
            s_axi_arready <= 0;
            s_axi_rvalid  <= 0;
            s_axi_rdata   <= 0;

            awaddr_lat    <= 0;
            awaddr_valid  <= 0;
            araddr_lat    <= 0;

            start         <= 0;

            cfg_valid     <= 0;
            cfg_neuron    <= 0;
            cfg_addr      <= 0;
            cfg_weight    <= 0;
            cfg_is_bias   <= 0;

            pixel_data    <= 0;
            pixel_valid   <= 0;
            pixel_last    <= 0;
        end
        else
        begin
            // =========================================
            // pulsos de 1 ciclo
            // =========================================
            start       <= 0;
            cfg_valid   <= 0;
            pixel_valid <= 0;

            // =========================================
            // WRITE ADDRESS CHANNEL
            // =========================================
            s_axi_awready <= (!awaddr_valid) && (!s_axi_bvalid);

            if (aw_hs)
            begin
                awaddr_lat   <= s_axi_awaddr;
                awaddr_valid <= 1'b1;
            end

            // =========================================
            // WRITE DATA CHANNEL
            // =========================================
            s_axi_wready <= (awaddr_valid) && (!s_axi_bvalid);

            if (w_hs)
            begin
                case (awaddr_lat[7:0])

                    // =================================
                    // CONTROL
                    // bit0 = cfg_valid pulse
                    // bit1 = start pulse
                    // =================================
                    8'h00:
                    begin
                        if (s_axi_wdata[0])
                        begin
                            cfg_valid <= 1'b1;
                        end

                        if (s_axi_wdata[1])
                        begin
                            start <= 1'b1;

                            $display(
                                "\n[AXI_MNIST] START RECEBIDO time=%0t",
                                $time
                            );
                        end
                    end

                    // =================================
                    // CFG_NEURON
                    // =================================
                    8'h10:
                    begin
                        cfg_neuron <= s_axi_wdata[3:0];
                    end

                    // =================================
                    // CFG_ADDR
                    // =================================
                    8'h14:
                    begin
                        cfg_addr <= s_axi_wdata[9:0];
                    end

                    // =================================
                    // CFG_WEIGHT
                    // =================================
                    8'h18:
                    begin
                        cfg_weight <= s_axi_wdata[7:0];
                    end

                    // =================================
                    // CFG_IS_BIAS
                    // =================================
                    8'h1C:
                    begin
                        cfg_is_bias <= s_axi_wdata[0];
                    end

                    // =================================
                    // PIXEL DATA
                    // =================================
                    8'h20:
                    begin
                        pixel_data  <= s_axi_wdata[7:0];
                        pixel_valid <= 1'b1;

                        /*$display(
                            "[AXI_MNIST] PIXEL RECEBIDO -> %0d time=%0t",
                            s_axi_wdata[7:0],
                            $time
                        );*/
                    end

                    // =================================
                    // PIXEL LAST
                    // =================================
                    8'h24:
                    begin
                        pixel_last <= s_axi_wdata[0];

                        if (s_axi_wdata[0])
                        begin
                            $display(
                                "[AXI_MNIST] ULTIMO PIXEL RECEBIDO time=%0t",
                                $time
                            );
                        end
                    end

                endcase

                s_axi_bvalid <= 1'b1;
                awaddr_valid <= 1'b0;
            end

            // WRITE RESPONSE
            if (s_axi_bvalid && s_axi_bready)
                s_axi_bvalid <= 1'b0;

            // =========================================
            // READ ADDRESS CHANNEL
            // =========================================
            s_axi_arready <= (!s_axi_rvalid);

            if (ar_hs)
            begin
                araddr_lat <= s_axi_araddr;

                case (s_axi_araddr[7:0])

                    // =================================
                    // STATUS
                    // =================================
                    8'h04:
                    begin
                        s_axi_rdata <= {31'b0, mnist_done};
                    end

                    // =================================
                    // RESULT
                    // =================================
                    8'h08:
                    begin
                        s_axi_rdata <= {28'b0, mnist_digit};

                        $display(
                            "[AXI_MNIST] RESULT LIDO -> digit=%0d time=%0t",
                            mnist_digit,
                            $time
                        );
                    end

                    default:
                    begin
                        s_axi_rdata <= 32'hDEADBEEF;
                    end

                endcase

                s_axi_rvalid <= 1'b1;
            end

            // READ RESPONSE
            if (s_axi_rvalid && s_axi_rready)
                s_axi_rvalid <= 1'b0;

            // =========================================
            // DONE DEBUG
            // =========================================
            /*if (done)
            begin
                $display(
                    "\n[AXI_MNIST] DONE -> DIGIT = %0d time=%0t\n",
                    digit,
                    $time
                );
            end*/
        end
    end

endmodule