module auto_comparator (
    input  wire         CLKEXT,
    input  wire         EN_COMP,
    input  wire         RST_COMP,
    input  wire         trig,

    input  wire signed [15:0] in1,
    input  wire signed [15:0] in2,

    output reg  [7:0] index,
    output reg  signed [15:0] largest
  );

  always @(posedge CLKEXT or posedge RST_COMP)
  begin
    if (RST_COMP)
    begin
      largest <= -16'sd32768;
      index   <= 0;
    end
    else if (EN_COMP && trig)
    begin
      if (in1 > in2)
      begin
        largest <= in1;
        index   <= 0;
      end
      else
      begin
        largest <= in2;
        index   <= 1;
      end
    end
  end

endmodule
