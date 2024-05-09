`default_nettype none
`include "Sys.sv"

import params::*;
import types::*;
import alu::*;

module Top(
  input var logic i_clk,
  input var logic i_reset_n
  );

  // PC
  addr_t pc;
  addr_t pc_next;
  logic pc_inc;

  // Mem
  addr_t mem_addr;
  data_t mem_data;
  data_t pipe_data;
  data_t mem_data_write;
  logic mem_write_en;

  // Reg
  data_t reg_write_data;
  reg_sel_t reg_sel_write;
  reg_sel_t reg_sel_1;
  reg_sel_t reg_sel_2;
  data_t reg_val_1;
  data_t reg_val_2;
  logic reg_write_en;

  // ALU
  alu_t alu_op;
  data_t alu_out;
  data_t alu_in_b;
  logic alu_in_b_mux;

  always_comb
    case (alu_in_b_mux)
      ALU_IN_B_MUX_REG: alu_in_b = reg_val_2;
      ALU_IN_B_MUX_DATA: alu_in_b = u_pipeline.o_data;
      default: $error("unhandled in b mux");
    endcase

  Regs u_regs(
    .i_clk(i_clk),
    .i_write_en(reg_write_en),
    .i_sel_1(reg_sel_1),
    .i_sel_2(reg_sel_2),
    .i_sel_write(reg_sel_write),
    .i_write_data(alu_out),
    .o_val_1(reg_val_1),
    .o_val_2(reg_val_2)
  );

  Mem u_mem(
    .i_clk(i_clk),
    .i_address(u_pipeline.o_addr), // TODO mux with (regval + imm)
    .i_data_write(mem_data_write),
    .i_write_en(mem_write_en),
    .o_data(mem_data)
  );

  PC u_pc(
    .i_clk(i_clk),
    .i_reset_n(i_reset_n),
    .i_pc_inc(u_pipeline.o_pc_inc),
    .i_pc_next(pc_next),
    .o_pc(pc)
  );

  ALU u_alu(
    .i_clk(i_clk),
    .i_alu_op(alu_op),
    .i_a(reg_val_1),
    .i_b(alu_in_b),
    .o_out(alu_out)
  );

  Pipeline u_pipeline(
    .i_clk(i_clk),
    .i_reset_n(i_reset_n),
    .i_pc(u_pc.o_pc),
    .i_data(u_mem.o_data),
    .o_addr(mem_addr),
    .o_pc_inc(pc_inc),
    .o_reg_sel_1(reg_sel_1),
    .o_reg_sel_2(reg_sel_2),
    .o_reg_sel_write(reg_sel_write),
    .o_alu(alu_op),
    .o_reg_write_en(reg_write_en),
    .o_mem_write_en(mem_write_en),
    .o_data(pipe_data),
    .o_alu_in_b_mux(alu_in_b_mux)
  );
endmodule
