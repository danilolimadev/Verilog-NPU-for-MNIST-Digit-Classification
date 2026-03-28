module final_classifier (
    input  [4:0] pair_results,
    output reg [3:0] digit   // 0–9
);

    always @(*) begin
        case (pair_results)

            // todos ganharam o segundo neurônio
            5'b11111: digit = 9;

            // exemplos possíveis
            5'b01111: digit = 7;
            5'b00111: digit = 5;
            5'b00011: digit = 3;
            5'b00001: digit = 1;

            // fallback
            default: digit = 0;

        endcase
    end

endmodule