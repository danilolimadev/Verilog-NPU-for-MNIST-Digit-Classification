module relu_module (
    input wire [15:0] Data_Reg,
    input wire EN_ReLU,
    input wire BYPASS_ReLU,
    input wire RST_GLO,
    input wire CLKEXT,
    output reg [15:0] ReLU_OUT
  );

  always @(posedge CLKEXT or posedge RST_GLO)
  begin
    if (RST_GLO)
    begin
      ReLU_OUT <= 16'h0000;
    end
    else if (BYPASS_ReLU)
    begin
      ReLU_OUT <= Data_Reg;
    end
    else if (EN_ReLU)
    begin
      // ReLU real
      if (Data_Reg[15] == 1'b1)
        ReLU_OUT <= 16'h0000;
      else
        ReLU_OUT <= Data_Reg;
    end
    else
    begin
      // mantém valor (IMPORTANTE)
      ReLU_OUT <= ReLU_OUT;
    end
  end
endmodule
