module npu_fsm_top (
    input  CLKEXT,
    input  RST_GLO,
    input  START,

    input  [15:0] SSFR,
    input  [15:0] CON_SIG,

    input  [7:0] DA, DB, DC, DD,
    input  [7:0] BIAS_IN,

    output [7:0] D_OUT,
    output FIFO_FULL,
    output FIFO_EMPTY,

    output reg BUSY,
    output reg DONE,
    output reg [3:0] STATE_DEBUG
);

  // ==============================
  // STATES
  // ==============================
  parameter IDLE         = 4'd0;
  parameter LOAD_INPUT   = 4'd1;
  parameter COMPUTE      = 4'd2;
  parameter RELU_STAGE   = 4'd3;
  parameter WRITE_FIFO   = 4'd4;
  parameter OUTPUT_SHIFT = 4'd5;
  parameter DEBUG_MODE   = 4'd6;
  parameter FINISH       = 4'd7;

  parameter MAC_CYCLES   = 8'd4;

  // ==============================
  // REGISTERS
  // ==============================
  reg [3:0] state, next_state;
  reg [7:0] cycle_cnt;

  reg start_sync, start_prev;

  // ==============================
  // WIRES
  // ==============================
  wire [7:0] QA, QB, QC, QD;

  reg EN_MAC, RST_MAC;
  wire [15:0] MAC0_Y, MAC1_Y;

  reg En_ReLU, BYPASS_ReLU;
  wire [15:0] ReLU0_OUT, ReLU1_OUT;

  reg EN_PISO_OUT, CLR_PISO_OUT, SHIFT_OUT;
  wire [7:0] PISO_DOUT;

  reg EN_PISO_DEB, CLR_PISO_DEB, SHIFT_DEB;
  wire [7:0] PISO1_DOUT;

  reg fifo_wr_en, fifo_rd_en;
  reg [7:0] fifo_data_in;
  wire [7:0] fifo_data_out;

  reg [2:0] SEL_OUT;

  reg EN_COMP, RST_COMP;
  wire [7:0] index;
  wire [15:0] largest;

  reg [15:0] mac0_out_reg, mac1_out_reg;

  // ==============================
  // INPUT BUFFER
  // ==============================
  input_buffer ib (
    .CLKEXT(CLKEXT),
    .CLR_BUF_IN(RST_GLO),
    .EN_BUF_IN(state == LOAD_INPUT),
    .DA(DA), .DB(DB), .DC(DC), .DD(DD),
    .QA(QA), .QB(QB), .QC(QC), .QD(QD)
  );

  // ==============================
  // MAC (CORREÇÃO AQUI)
  // ==============================
  mac_module mac0 (
    .CLKEXT(CLKEXT),
    .EN_MAC(EN_MAC),
    .RST_MAC(RST_MAC),
    .BIAS_IN(BIAS_IN),   // ✅ CORRETO
    .A(QA),
    .B(QB),
    .Y(MAC0_Y)
  );

  mac_module mac1 (
    .CLKEXT(CLKEXT),
    .EN_MAC(EN_MAC),
    .RST_MAC(RST_MAC),
    .BIAS_IN(BIAS_IN),   // ✅ CORRETO
    .A(QC),
    .B(QD),
    .Y(MAC1_Y)
  );

  // ==============================
  // RELU
  // ==============================
  relu_module relu1 (
    .Data_Reg(mac0_out_reg),
    .EN_ReLU(En_ReLU),
    .BYPASS_ReLU(BYPASS_ReLU),
    .RST_GLO(RST_GLO),
    .CLKEXT(CLKEXT),
    .ReLU_OUT(ReLU0_OUT)
  );

  relu_module relu2 (
    .Data_Reg(mac1_out_reg),
    .EN_ReLU(En_ReLU),
    .BYPASS_ReLU(BYPASS_ReLU),
    .RST_GLO(RST_GLO),
    .CLKEXT(CLKEXT),
    .ReLU_OUT(ReLU1_OUT)
  );

  // ==============================
  // FIFO
  // ==============================
  fifo #(.DATA_WIDTH(8), .DEPTH(128)) out_fifo (
    .clk(CLKEXT),
    .rst(RST_GLO),
    .enable(1'b1),
    .wr_en(fifo_wr_en),
    .rd_en(fifo_rd_en),
    .data_in(fifo_data_in),
    .data_out(fifo_data_out),
    .empty(FIFO_EMPTY),
    .full(FIFO_FULL)
  );

  // ==============================
  // COMPARATOR
  // ==============================
  auto_comparator comp (
    .in1(ReLU0_OUT),
    .in2(ReLU1_OUT),
    .RST_COMP(RST_COMP),
    .EN_COMP(EN_COMP),
    .CLKEXT(CLKEXT),
    .trig(En_ReLU),
    .index(index),
    .largest(largest)
  );

  // ==============================
  // MUX FINAL
  // ==============================
  mux_out final_mux (
    .SEL_OUT(SEL_OUT),
    .fifo_data(fifo_data_out),
    .piso_out_data(PISO_DOUT),
    .index_data(index),
    .msb_largest_data(largest[15:8]),
    .lsb_largest_data(largest[7:0]),
    .piso_deb_data(PISO1_DOUT),
    .D_OUT(D_OUT)
  );

  // ==============================
  // START EDGE
  // ==============================
  always @(posedge CLKEXT or posedge RST_GLO) begin
    if (RST_GLO) begin
      start_sync <= 0;
      start_prev <= 0;
    end else begin
      start_prev <= START;
      start_sync <= START & ~start_prev;
    end
  end

  // ==============================
  // FSM SEQ
  // ==============================
  always @(posedge CLKEXT or posedge RST_GLO) begin
    if (RST_GLO) begin
      state <= IDLE;
      cycle_cnt <= 0;
      BUSY <= 0;
      DONE <= 0;
    end else begin
      state <= next_state;
      STATE_DEBUG <= state;

      // contador
      if (state == COMPUTE)
        cycle_cnt <= cycle_cnt + 1;
      else
        cycle_cnt <= 0;

      // status
      BUSY <= (state != IDLE && state != FINISH);
      DONE <= (state == FINISH);
    end
  end

  // ==============================
  // FSM COMB
  // ==============================
  always @(*) begin

    // defaults
    next_state = state;

    EN_MAC = 0;
    RST_MAC = 1;

    En_ReLU = 0;
    BYPASS_ReLU = 0;

    fifo_wr_en = 0;
    fifo_rd_en = 0;
    fifo_data_in = 0;

    SEL_OUT = 0;

    EN_COMP = 0;
    RST_COMP = 1;

    case (state)

      IDLE:
        if (start_sync)
          next_state = LOAD_INPUT;

      LOAD_INPUT:
        next_state = COMPUTE;

      COMPUTE: begin
        EN_MAC = 1;
        RST_MAC = 0;

        if (cycle_cnt == MAC_CYCLES-1)
          next_state = RELU_STAGE;
      end

      RELU_STAGE: begin
        En_ReLU = 1;
        EN_COMP = 1;
        RST_COMP = 0;
        next_state = WRITE_FIFO;
      end

      WRITE_FIFO: begin
        fifo_wr_en = 1;
        fifo_data_in = index;
        next_state = OUTPUT_SHIFT;
      end

      OUTPUT_SHIFT: begin
        fifo_rd_en = 1;
        SEL_OUT = 0;
        next_state = FINISH;
      end

      FINISH:
        next_state = IDLE;

    endcase
  end

  // ==============================
  // CAPTURE MAC OUTPUT
  // ==============================
  always @(posedge CLKEXT) begin
    if (state == COMPUTE && cycle_cnt == MAC_CYCLES-1) begin
      mac0_out_reg <= MAC0_Y;
      mac1_out_reg <= MAC1_Y;
    end
  end

endmodule