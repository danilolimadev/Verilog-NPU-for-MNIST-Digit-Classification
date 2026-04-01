module piso_out (
    input  wire        CLKEXT,
    input  wire        RST_GLO,
    input  wire        EN_PISO_OUT,
    input  wire        CLR_PISO_OUT,
    input  wire        SHIFT_OUT,
    input  wire [15:0] mac0_out,
    input  wire [15:0] mac1_out,
    output reg  [7:0]  D_OUT
);

  reg [31:0] shift_reg;

  always @(posedge CLKEXT or posedge RST_GLO)
  begin
    if (RST_GLO)
    begin
      shift_reg <= 32'd0;
      D_OUT     <= 8'd0;
    end
    else if (CLR_PISO_OUT)
    begin
      shift_reg <= 32'd0;
      D_OUT     <= 8'd0;
    end
    else if (EN_PISO_OUT)
    begin
      if (!SHIFT_OUT)
      begin
        // 🔥 LOAD + PRIMEIRO BYTE
        shift_reg <= {mac0_out, mac1_out};
        D_OUT     <= mac0_out[15:8];  // AB já sai aqui
      end
      else
      begin
        shift_reg <= {shift_reg[23:0], 8'b0};
        D_OUT     <= shift_reg[23:16];
      end
    end
  end

endmodule