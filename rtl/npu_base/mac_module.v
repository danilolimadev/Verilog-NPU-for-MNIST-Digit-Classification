module mac_module (
    input  CLKEXT,
    input  EN_MAC,
    input  RST_MAC,
    input  [7:0] BIAS_IN,
    input  [7:0] A,              // 🔥 unsigned pixel
    input  signed [7:0] B,       // 🔥 signed weight
    output reg signed [15:0] Y
);

    // multiplicação correta
    wire signed [15:0] mult_out;
    assign mult_out = $signed({1'b0, A}) * B;

    // extensão
    wire signed [16:0] acc_ext  = {Y[15], Y};
    wire signed [16:0] mult_ext = {mult_out[15], mult_out};

    wire signed [16:0] add_out = acc_ext + mult_ext;

    // saturação
    reg signed [15:0] sat_out;
    always @(*) begin
        case (add_out[16:15])
            2'b01: sat_out = 16'h7FFF;
            2'b10: sat_out = 16'h8000;
            default: sat_out = add_out[15:0];
        endcase
    end

    // 🔥 bias com sinal correto
    wire signed [15:0] bias_ext;
    assign bias_ext = {{8{BIAS_IN[7]}}, BIAS_IN};

    // FF correto
    always @(posedge CLKEXT) begin
        if (RST_MAC)
            Y <= bias_ext;
        else if (EN_MAC)
            Y <= sat_out;
    end

endmodule