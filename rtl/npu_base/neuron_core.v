module neuron_core (
    input  CLKEXT,
    input  RST_GLO,
    input  START,

    input  [15:0] SSFR,
    input  [15:0] CON_SIG,

    input  [7:0] DA, DB, DC, DD,

    output [15:0] OUT0,
    output [15:0] OUT1,
    output [7:0] D_OUT,

    output FIFO_FULL,
    output FIFO_EMPTY,

    output reg BUSY,
    output reg DONE,
    output reg [3:0] STATE_DEBUG,
    output [15:0] MAC0_OUT,
    output [15:0] MAC1_OUT
);

  parameter IDLE         = 4'd0;
  parameter LOAD_INPUT   = 4'd1;
  parameter WAIT_DATA    = 4'd2;
  parameter WAIT_DATA2   = 4'd3;
  parameter COMPUTE      = 4'd4;
  parameter RELU_STAGE   = 4'd5;
  parameter RELU_WAIT    = 4'd6;
  parameter COMPARE      = 4'd7;
  parameter DONE_STATE   = 4'd8;

  parameter MAC_CYCLES = 10'd784;

  reg [3:0] state, next_state;
  reg [9:0] cycle_cnt;

  reg start_sync, start_prev;

  wire [7:0] QA, QB, QC, QD;

  reg EN_MAC, RST_MAC;
  wire [15:0] MAC0_Y, MAC1_Y;

  wire [15:0] ReLU0_OUT, ReLU1_OUT;

  reg [15:0] mac0_out_reg, mac1_out_reg;

  reg [7:0] digit_reg;

  // ==============================
  // INPUT BUFFER
  // ==============================
  input_buffer ib (
    .CLKEXT(CLKEXT),
    .CLR_BUF_IN(RST_GLO),
    .EN_BUF_IN(state == WAIT_DATA),
    .DA(DA), .DB(DB), .DC(DC), .DD(DD),
    .QA(QA), .QB(QB), .QC(QC), .QD(QD)
  );

  // ==============================
  // MAC
  // ==============================
  mac_module mac0 (
    .A(QA),
    .B(QB),
    .Y(MAC0_Y)
  );

  mac_module mac1 (
    .A(QC),
    .B(QD),
    .Y(MAC1_Y)
  );

  // ==============================
  // RELU
  // ==============================
  relu_module relu1 (
    .Data_Reg(mac0_out_reg),
    .EN_ReLU(1'b1),
    .BYPASS_ReLU(1'b0),
    .RST_GLO(RST_GLO),
    .CLKEXT(CLKEXT),
    .ReLU_OUT(ReLU0_OUT)
  );

  relu_module relu2 (
    .Data_Reg(mac1_out_reg),
    .EN_ReLU(1'b1),
    .BYPASS_ReLU(1'b0),
    .RST_GLO(RST_GLO),
    .CLKEXT(CLKEXT),
    .ReLU_OUT(ReLU1_OUT)
  );

  assign OUT0 = ReLU0_OUT;
  assign OUT1 = ReLU1_OUT;
  assign D_OUT = MAC0_Y[7:0]; // ou MAC1 dependendo do caso

  assign MAC0_OUT = MAC0_Y;
  assign MAC1_OUT = MAC1_Y;

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
      mac0_out_reg <= 0;
      mac1_out_reg <= 0;
      digit_reg <= 0;
    end else begin
      state <= next_state;
      STATE_DEBUG <= state;

      if (state == COMPUTE)
        cycle_cnt <= cycle_cnt + 1;
      else
        cycle_cnt <= 0;

      BUSY <= (state != IDLE && state != DONE_STATE);
      DONE <= (state == DONE_STATE);

      // captura MAC
      if (state == RELU_STAGE) begin
        mac0_out_reg <= MAC0_Y;
        mac1_out_reg <= MAC1_Y;
      end

      // 🔥 COMPARATOR DIRETO (SEM MODULE)
      if (state == COMPARE) begin
        if (ReLU0_OUT > ReLU1_OUT)
            digit_reg <= 0;
        else
            digit_reg <= 1;
      end
    end
  end

  // ==============================
  // FSM COMB
  // ==============================
  always @(*) begin

    next_state = state;

    EN_MAC = 0;
    RST_MAC = 0;

    case (state)

      IDLE:
        if (start_sync)
          next_state = LOAD_INPUT;

      LOAD_INPUT: begin
        RST_MAC = 1;
        next_state = WAIT_DATA;
      end

      WAIT_DATA:
        next_state = WAIT_DATA2;

      WAIT_DATA2:
        next_state = COMPUTE;

      COMPUTE: begin
        EN_MAC = 1;
        if (cycle_cnt == MAC_CYCLES-1)
          next_state = RELU_STAGE;
      end

      RELU_STAGE:
        next_state = RELU_WAIT;

      RELU_WAIT:
        next_state = COMPARE;

      COMPARE:
        next_state = DONE_STATE;

      DONE_STATE:
        next_state = IDLE;

    endcase
  end

endmodule