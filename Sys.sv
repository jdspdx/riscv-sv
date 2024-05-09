`default_nettype none
`ifndef PKG_PARAMS
`define PKG_PARAMS

package params;
  localparam int DATA_WIDTH = 32;
  localparam int ADDR_WIDTH = 32;
  localparam int NUM_REGS = 32;
  localparam int NUM_REGS_BITS = $clog2(NUM_REGS);
  localparam int MEM_SIZE = 256;
endpackage

package types;
  import params::*;
  typedef logic [NUM_REGS_BITS-1:0] reg_sel_t;
  typedef logic [DATA_WIDTH-1:0] data_t;
  typedef logic [ADDR_WIDTH-1:0] addr_t;
endpackage

package alu;
  typedef enum {
    ALU_ADD,
    ALU_SUB,
    ALU_SLL,
    ALU_SLT,
    ALU_SLTU,
    ALU_XOR,
    ALU_SRL,
    ALU_SRA,
    ALU_OR,
    ALU_AND
  } alu_t;

localparam bit ALU_IN_B_MUX_REG = 0;
localparam bit ALU_IN_B_MUX_DATA = 1;

endpackage

`endif
