module mac_module (
    input  CLKEXT,
    input  EN_MAC,
    input  RST_MAC,
    input  [7:0] BIAS_IN,
    input  [7:0] A,              
    input  signed [7:0] B,       
    output reg signed [15:0] Y   // 🔥 mantém 16 bits na saída
);

    // =========================
    // EXTENSÕES (32 bits)
    // =========================
    wire signed [31:0] A_ext = $signed({24'd0, A});
    wire signed [31:0] B_ext = B;

    wire signed [31:0] mult_out = A_ext * B_ext;

    wire signed [31:0] bias_ext = {{24{BIAS_IN[7]}}, BIAS_IN};

    // =========================
    // ACUMULADOR INTERNO (🔥 CORREÇÃO REAL)
    // =========================
    reg signed [31:0] acc;

    // =========================
    // REGISTRADOR
    // =========================
    always @(posedge CLKEXT or posedge RST_MAC) begin
        if (RST_MAC) begin
            acc <= bias_ext <<< 5;
            Y   <= 0;
        end 
        else if (EN_MAC) begin
            acc <= acc + (mult_out >>> 5);
            Y   <= acc >>> 6;
        end
    end

endmodule