module mac_module (
    input  [7:0] A,
    input  signed [7:0] B,
    output signed [15:0] Y
  );

  wire signed [15:0] A_ext = $signed({8'd0, A});
  wire signed [15:0] B_ext = B;

  wire signed [31:0] mult = A_ext * B_ext;

  // COMPENSA SCALE = 8
  assign Y = mult >>> 3;
endmodule
