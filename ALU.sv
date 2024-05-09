`default_nettype none
`include "Sys.sv"

import alu::*;
import params::*;
import types::*;

module ALU(
  input var logic i_clk,
  input var alu_t i_alu_op,
  input var data_t i_a,
  input var data_t i_b,
  output var data_t o_out
);

  always_comb
    case (i_alu_op)
      ALU_ADD: o_out = i_a + i_b;
      ALU_SUB: o_out = i_a - i_b;
      ALU_SLL: o_out = i_a << i_b[4:0];
      ALU_SLT: o_out = $signed(i_a) < $signed(i_b) ? 1 : 0;
      ALU_SLTU: o_out = i_a < i_b ? 1 : 0;
      ALU_XOR: o_out = i_a ^ i_b;
      ALU_SRL: o_out = i_a >> i_b;
      ALU_SRA: o_out = $signed(i_a) >>> i_b;
      ALU_OR: o_out = i_a | i_b;
      ALU_AND: o_out = i_a & i_b;
      default: $error("invalid alu op");
    endcase
endmodule
