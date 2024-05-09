`default_nettype none
`include "Sys.sv"

import params::*;
import types::*;

class RandVars;
  randc data_t write_1;
  randc data_t write_2;
  randc regsel_t regsel_1;
  randc regsel_t regsel_2;
endclass

module RegsBench;
  logic clk;

  always_ff #5 clk <= ~clk;

  RandVars vars = new();

  data_t write_data;
  regsel_t regsel_write;
  regsel_t regsel_1;
  regsel_t regsel_2;
  data_t regval_1;
  data_t regval_2;
  logic write_en;

  Regs u_regs(
    .i_clk(clk),
    .i_write_en(ctl_write),
    .i_write_data(write_data),
    .i_regsel_1(regsel_1),
    .i_regsel_2(regsel_2),
    .i_regsel_write(regsel_write),
    .o_regval_1(regval_1),
    .o_regval_2(regval_2)
  );

  function automatic void f_double_write_assert(RandVars vars);
    if (vars.randomize() == 0);
    else ;
    regsel_write = vars.regsel_1;
    write_data = vars.write_1;
    write_en = 1;
    #10;
    regsel_write = vars.regsel_2;
    write_data = vars.write_2;
    write_en = 1;
    #10;
    write_en = 0;
    regsel_1 = vars.regsel_1;
    regsel_2 = vars.regsel_2;
    #10;
    if (regsel_1 == regsel_2 && regsel_1 != 0) begin
      assert (
        regval_1 == regval_2 &&
        (regval_1 == vars.write_1 || regval_1 == vars.write_2)
      );
      end else begin
      assert (regval_1 == vars.write_1 || (regsel_1 == 0 && regval_1 == 0));
      assert (regval_2 == vars.write_2 || (regsel_2 == 0 && regval_2 == 0));
    end
  endfunction

  initial begin
    $dumpfile("regs_bench.vcd");
    $dumpvars(0, regs_bench);

    for (int i = 0; i < NUM_REGS*2; i++) begin
      f_double_write_assert(vars);
    end
    $finish;
  end


endmodule
