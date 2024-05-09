`default_nettype none

module TopBench;

logic clk;
logic reset_n;
integer cycle_count = 0;

Top u_uut (
    .i_clk(clk),
    .i_reset_n(reset_n)
);

initial begin
  $dumpfile("vcd/top.vcd");
  $dumpvars(0, mod_top_tb);

  reset_n = 0;
  #10;
  reset_n = 1;
end

always_ff #5 clk <= ~clk;

always_ff @(posedge clk)
  if (cycle_count >= 10) $finish;
  else cycle_count <= cycle_count + 1;

endmodule
