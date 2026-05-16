module weight_memory #(
    parameter DEPTH = 784,
    parameter DATA_WIDTH = 8
)(
    input clk,

    // write (cfg)
    input        we,
    input [9:0]  waddr,
    input [7:0]  wdata,

    // read (inference)
    input [9:0]  raddr,
    output reg [7:0] rdata
);

  reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

  always @(posedge clk)
  begin
    // write
    if (we)
      mem[waddr] <= wdata;

    // read
    rdata <= mem[raddr];
  end

endmodule