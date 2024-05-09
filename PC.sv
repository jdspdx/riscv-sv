`default_nettype none
`include "Sys.sv"

import types::*;

module PC(
  input var logic i_clk,
  input var logic i_reset_n,
  input var logic i_pc_inc,
  input var addr_t i_pc_next,
  output var addr_t o_pc
);
  addr_t pc;

  always_ff @(posedge i_clk)
    if (!i_reset_n)
      pc <= 0;
    else
      if (i_pc_inc)
        pc <= pc + 4;
      else ;

  always_comb
    o_pc = pc;

endmodule
