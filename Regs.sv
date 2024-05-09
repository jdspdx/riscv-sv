`default_nettype none
`include "Sys.sv"

import params::*;
import types::*;

module Regs(
    input var logic i_clk,
    input var logic i_write_en,
    input var reg_sel_t i_sel_1,
    input var reg_sel_t i_sel_2,
    input var reg_sel_t i_sel_write,
    input var data_t i_write_data,
    output var data_t o_val_1,
    output var data_t o_val_2
);
    data_t regfile [NUM_REGS-1:0] ;

    initial begin
        $readmemh("hex/regs.hex", regfile);
    end

    always_comb
      if (i_sel_1 == 0)
        o_val_1 = 0;
      else
        o_val_1 = regfile[i_sel_1];

    always_comb
      if (i_sel_2 == 0)
        o_val_2 = 0;
      else
        o_val_2 = regfile[i_sel_2];

    always_ff @(posedge i_clk)
      if (i_sel_write != 0 && i_write_en)
        regfile[i_sel_write] <= i_write_data;
      else
        ;

endmodule
