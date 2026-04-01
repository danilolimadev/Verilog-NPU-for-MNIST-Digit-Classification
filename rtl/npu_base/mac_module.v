module mac_module (
    input  CLKEXT,
    input  EN_MAC,
    input  RST_MAC,
    input  [7:0] BIAS_IN,
    input  [7:0] A,              
    input  signed [7:0] B,       
    output reg signed [15:0] Y
);

    // =========================
    // EXTENSÕES
    // =========================
    wire signed [15:0] A_ext = $signed({8'd0, A});
    wire signed [15:0] B_ext = B;

    wire signed [15:0] mult_out = A_ext * B_ext;

    wire signed [15:0] bias_ext = {{8{BIAS_IN[7]}}, BIAS_IN};

    // =========================
    // REGISTRADOR
    // =========================
    always @(posedge CLKEXT or posedge RST_MAC) begin
        if (RST_MAC) begin
            //Y <= bias_ext;
            Y <= bias_ext;
        end 
        else if (EN_MAC) begin
            // 🔥 soma direta no clock
            Y <= saturate(Y + mult_out);
        end
    end

    // =========================
    // FUNÇÃO DE SATURAÇÃO
    // =========================
    function signed [15:0] saturate;
        input signed [16:0] value;
        begin
            case (value[16:15])
                2'b01: saturate = 16'h7FFF;
                2'b10: saturate = 16'h8000;
                default: saturate = value[15:0];
            endcase
        end
    endfunction

endmodule