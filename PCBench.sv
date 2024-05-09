`default_nettype none
`include "Sys.sv"

import alu::*;
import types::*;

class RandVars;
endclass

module PCBench;
  logic clk;
  logic reset_n;
  logic ctl_advance_pc;
  addr_t pc;
  addr_t next_pc;


  always_ff #5 clk <= ~clk;

  RandVars vars = new();

  PC u_pc(
    .i_clk(clk),
    .i_reset_n(reset_n),
    .i_next_pc(next_pc),
    .i_ctl_advance(ctl_advance_pc),
    .o_pc(pc)
  );

  initial begin
    $dumpfile("pc.vcd");
    $dumpvars(0, pc_bench);

    reset_n = 0;
    #10;
    assert (pc == 0);

    reset_n = 1;
    next_pc = 4;
    ctl_advance_pc = 1;
    #10;
    assert (pc == 4);


    $finish;
  end
endmodule
