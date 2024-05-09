`default_nettype none
`include "Sys.sv"

import params::*;
import types::*;

module Mem (
    input var logic i_clk,
    input var addr_t i_address,
    input var data_t i_data_write,
    input var logic i_write_en,
    output var data_t o_data
);
    data_t data [MEM_SIZE-1:0];

    initial begin
        $readmemh("hex/rom.hex", data);
    end

  always_ff @(posedge i_clk)
    if (i_write_en)
      data[i_address] <= i_data_write;
    else ;

  always_comb
    o_data = data[i_address];

endmodule
