`default_nettype none
`include "Sys.sv"

import params::*;
import alu::*;
import types::*;

class RandVars;
  randc data_t alu_a;
  randc data_t alu_b;
  rand e_alu_op alu_op;
endclass

module ALUBench;
  logic clk;
  data_t alu_out;
  data_t alu_a;
  data_t alu_b;
  e_alu_op alu_op;

  always_ff #5 clk <= ~clk;

  RandVars vars = new();

  function automatic void f_rand_op(RandVars vars);
    if (vars.randomize() == 0) ;
    else ;
    alu_a = vars.alu_a;
    alu_b = vars.alu_b;
    alu_op = vars.alu_op;
    #10;
    case (alu_op)
      ADD: assert (alu_out == alu_a + alu_b);
      SUB: assert (alu_out == alu_a - alu_b);
      XOR: assert (alu_out == (alu_a ^ alu_b));
      OR: assert (alu_out == (alu_a | alu_b));
      AND: assert (alu_out == (alu_a & alu_b));
      NOT: assert (alu_out == ~alu_a);
      INC: assert (alu_out == (alu_a + 1));
      INC4: assert (alu_out == (alu_a + 4));
      DEC: assert (alu_out == (alu_a - 1));
      default: $fatal;
    endcase
  endfunction

  ALU u_alu(
    .i_clk(clk),
    .i_alu_op(alu_op),
    .i_a(alu_a),
    .i_b(alu_b),
    .o_out(alu_out)
  );

  initial begin
    $dumpfile("alu.vcd");
    $dumpvars(0, alu_bench);

    for (int i = 0; i < 10; i++) begin
      f_rand_op(vars);
    end
    $finish;
  end
endmodule
