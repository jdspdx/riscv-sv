`default_nettype none
`include "Sys.sv"

import params::*;
import types::*;
import alu::*;

typedef enum {
  FETCH,
  DECODE,
  EXEC,
  MEM,
  WRITE
} state_t;

typedef struct packed {
  bit [6:0] op;
  bit [31:7] word;
} inst_w_t;

typedef struct packed {
  bit [6:0] op;
  bit [11:7] rd;
  bit [14:12] funct3;
  bit [19:15] rs1;
  bit [24:20] rs2;
  bit [31:25] funct7;
} inst_r_t;

typedef struct packed {
  bit [6:0] op;
  bit [11:7] rd;
  bit [14:12] funct3;
  bit [19:15] rs1;
  bit signed [31:20] imm;
} inst_i_t;

typedef struct packed {
  bit [6:0] op;
  bit [11:7] imm4_0;
  bit [14:12] funct3;
  bit [19:15] rs1;
  bit [24:20] rs2;
  bit [31:25] imm11_5;
} inst_s_t;

typedef union {
  inst_r_t r;
  inst_i_t i;
  inst_s_t s;

  inst_w_t w;
} inst_t;

localparam bit [6:0] OP_R = 7'b0110011;
localparam bit [6:0] OP_I = 7'b0010011;
localparam bit [6:0] OP_S = 7'b0100011;

// R type ops
localparam bit [2:0] OP_R_ADD_SUB = 3'b000;

localparam bit [2:0] OP_R_SLL = 3'b001;
localparam bit [2:0] OP_R_SLT = 3'b010;
localparam bit [2:0] OP_R_SLTU = 3'b011;
localparam bit [2:0] OP_R_XOR = 3'b100;
localparam bit [2:0] OP_R_SRL_SRA = 3'b101;
localparam bit [2:0] OP_R_OR = 3'b110;
localparam bit [2:0] OP_R_AND = 3'b111;

// I type ops
localparam bit [2:0] OP_I_ADDI = 3'b000;
localparam bit [2:0] OP_I_SLTI = 3'b010;
localparam bit [2:0] OP_I_SLTIU = 3'b011;
localparam bit [2:0] OP_I_XORI = 3'b100;
localparam bit [2:0] OP_I_ORI = 3'b110;
localparam bit [2:0] OP_I_ANDI = 3'b111;
localparam bit [2:0] OP_I_SLLI = 3'b001;
localparam bit [2:0] OP_I_SRLI_SRAI = 3'b101;

localparam bit [2:0] OP_S_SB = 3'b000;


function automatic inst_t f_decode_r(data_t word);
  inst_t inst;
  inst.r.op = word[6:0];
  inst.r.rd = word[11:7];
  inst.r.funct3 = word[14:12];
  inst.r.rs1 = word[19:15];
  inst.r.rs2 = word[24:20];
  inst.r.funct7 = word[31:25];
  return inst;
endfunction

function automatic inst_t f_decode_i(data_t word);
  inst_t inst;
  inst.i.op = word[6:0];
  inst.i.rd = word[11:7];
  inst.i.funct3 = word[14:12];
  inst.i.rs1 = word[19:15];
  inst.i.imm = word[31:20];
  return inst;
endfunction

function automatic inst_t f_decode_s(data_t word);
  inst_t inst;
  inst.s.op = word[6:0];
  inst.s.imm4_0 = word[11:7];
  inst.s.funct3 = word[14:12];
  inst.s.rs1 = word[19:15];
  inst.s.rs2 = word[24:20];
  inst.s.imm11_5 = word[31:25];
  return inst;
endfunction

function automatic inst_t f_decode(data_t word);
  case (word[6:0])
    OP_R: return f_decode_r(word);
    OP_I: return f_decode_i(word);
    OP_S: return f_decode_s(word);
    default: $error("unhandled instruction type");
  endcase
endfunction

module Pipeline(
  input var logic i_clk,
  input var logic i_reset_n,
  input var addr_t i_pc,
  input var data_t i_data,
  output var addr_t o_addr,
  output var logic o_pc_inc,
  output var reg_sel_t o_reg_sel_1,
  output var reg_sel_t o_reg_sel_2,
  output var reg_sel_t o_reg_sel_write,
  output var alu_t o_alu,
  output var logic o_reg_write_en,
  output var logic o_mem_write_en,
  output var logic o_alu_in_b_mux,
  output var data_t o_data
);
  state_t state;
  data_t inst_word;
  inst_t inst;
  logic f71;
  logic mem_write_en;
  logic reg_write_en;

  function automatic void f_seq_fetch();
    inst_word <= i_data;
    state <= DECODE;
  endfunction

  function automatic void f_seq_decode();
    if (inst.w.op == OP_S)
      mem_write_en <= 1;
    else
      mem_write_en <= 0;
    state <= MEM;
  endfunction

  function automatic void f_comb_decode_r(inst_r_t inst);
    o_reg_sel_1 = inst.rs1;
    o_reg_sel_2 = inst.rs2;
    o_reg_sel_write = inst.rd;
    o_alu_in_b_mux = ALU_IN_B_MUX_REG;

    f71 = inst.funct7[1:1];

    case (inst.funct3)
      OP_R_ADD_SUB: o_alu = f71 ? ALU_ADD : ALU_SUB;
      OP_R_SLL: o_alu = ALU_SLL;
      OP_R_SLT: o_alu = ALU_SLT;
      OP_R_SLTU: o_alu = ALU_SLTU;
      OP_R_XOR: o_alu = ALU_XOR;
      OP_R_SRL_SRA: o_alu = f71 ? ALU_SRL : ALU_SRA;
      OP_R_OR: o_alu = ALU_OR;
      OP_R_AND: o_alu = ALU_AND;
      default: $error("unhandled r op3");
    endcase
  endfunction

  function automatic void f_comb_decode_i(inst_i_t inst);
    o_reg_sel_1 = inst.rs1;
    o_reg_sel_write = inst.rd;
    o_alu_in_b_mux = ALU_IN_B_MUX_DATA;

    if (inst.funct3 == OP_I_SRLI_SRAI)
      o_data = {{27{inst.imm[25]}},inst.imm[24:20]};
    else
      o_data = {{20{inst.imm[31]}},inst.imm};

    case (inst.funct3)
      OP_I_ADDI: o_alu = ALU_ADD;
      OP_I_SLTI: o_alu = ALU_SLT;
      OP_I_SLTIU: o_alu = ALU_SLTU;
      OP_I_XORI: o_alu = ALU_XOR;
      OP_I_ORI: o_alu = ALU_OR;
      OP_I_ANDI: o_alu = ALU_AND;
      OP_I_SLLI: o_alu = ALU_SLL;
      OP_I_SRLI_SRAI: o_alu = inst.imm[30] ? ALU_SRL : ALU_SRA;
      default: $error("unhandled i op3");
    endcase
  endfunction

  function automatic void f_comb_decode_s(inst_s_t inst);
    o_reg_sel_1 = inst.rs1;
    o_reg_sel_2 = inst.rs2;

    o_data = {20'b0,{inst.imm11_5,inst.imm4_0}};

  endfunction

  function automatic void f_comb_decode(data_t inst_word);
    inst = f_decode(inst_word);
    case (inst.w.op)
      OP_R: f_comb_decode_r(inst.r);
      OP_I: f_comb_decode_i(inst.i);
      OP_S: f_comb_decode_s(inst.s);
      default: $error("unhandled op in f_comb_decode");
    endcase
  endfunction

  // State execution
  always_ff @(posedge i_clk)
    if (!i_reset_n)
      state <= FETCH;
    else
      case (state)
        FETCH: f_seq_fetch();
        DECODE: f_seq_decode();
        EXEC: state <= MEM;
        MEM: begin //TODO move to function
          state <= WRITE;
          mem_write_en <= 0;
        end
        WRITE: begin // TODO move to function
          state <= WRITE;
          reg_write_en <= 0; // TODO need to set as needed in decode
        end
        default: $error("bad state");
      endcase


  always_comb
    case (inst.w.op)
      default: o_addr = i_pc;
    endcase


  always_comb
    case (state)
      DECODE: f_comb_decode(inst_word);
      default: ;
    endcase

  always_comb
    o_reg_write_en = (state == WRITE && reg_write_en) ? 1 : 0;

  always_comb
    o_mem_write_en = (state == MEM && mem_write_en) ? 1 : 0;


  // PC increment
  always_comb
    if (state == FETCH)
      o_pc_inc = 1;
    else
      o_pc_inc = 0;

endmodule
