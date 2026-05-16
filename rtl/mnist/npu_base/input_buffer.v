module input_buffer (
    input  CLKEXT,
    input  CLR_BUF_IN,
    input  EN_BUF_IN,
    input  [7:0] DA, DB,
    output reg [7:0] QA, QB
  );

  always @(posedge CLKEXT or posedge CLR_BUF_IN)
  begin
    if (CLR_BUF_IN)
    begin
      QA <= 8'd0;
      QB <= 8'd0;
    end
    else if (EN_BUF_IN)
    begin
      QA <= DA;
      QB <= DB;
    end
  end

endmodule
