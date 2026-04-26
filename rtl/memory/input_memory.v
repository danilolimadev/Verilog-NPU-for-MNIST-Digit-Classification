module input_memory #(
    parameter DEPTH = 784,
    parameter DATA_WIDTH = 8
)(
    input clk,

    // WRITE (AXI)
    input        we,
    input [9:0]  waddr,
    input [7:0]  wdata,

    // READ (PROCESSAMENTO)
    input [9:0]  raddr,
    output reg [7:0] rdata
);

  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  always @(posedge clk)
  begin
    if (we)
      mem[waddr] <= wdata;

    rdata <= mem[raddr];
  end

endmodule