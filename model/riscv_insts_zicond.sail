/*=======================================================================================*/
/*  This Sail RISC-V architecture model, comprising all files and                        */
/*  directories except where otherwise noted is subject the BSD                          */
/*  two-clause license in the LICENSE file.                                              */
/*                                                                                       */
/*  SPDX-License-Identifier: BSD-2-Clause                                                */
/*=======================================================================================*/

function clause currentlyEnabled(Ext_Zicond) = hartSupports(Ext_Zicond)

union clause instruction = ZICOND_RTYPE : (regidx, regidx, regidx, zicondop)

mapping clause encdec = ZICOND_RTYPE(rs2, rs1, rd, CZERO_EQZ)
  <-> 0b0000111 @ encdec_reg(rs2) @ encdec_reg(rs1) @ 0b101 @ encdec_reg(rd) @ 0b0110011
  when currentlyEnabled(Ext_Zicond)
mapping clause encdec = ZICOND_RTYPE(rs2, rs1, rd, CZERO_NEZ)
  <-> 0b0000111 @ encdec_reg(rs2) @ encdec_reg(rs1) @ 0b111 @ encdec_reg(rd) @ 0b0110011
  when currentlyEnabled(Ext_Zicond)

mapping zicond_mnemonic : zicondop <-> string = {
  CZERO_EQZ <-> "czero.eqz",
  CZERO_NEZ <-> "czero.nez"
}

mapping clause assembly = ZICOND_RTYPE(rs2, rs1, rd, op)
  <-> zicond_mnemonic(op) ^ spc() ^ reg_name(rd) ^ sep() ^ reg_name(rs1) ^ sep() ^ reg_name(rs2)

function clause execute (ZICOND_RTYPE(rs2, rs1, rd, CZERO_EQZ)) = {
  let value = X(rs1);
  let condition = X(rs2);
  let result : xlenbits = if condition == zeros() then zeros() else value;
  X(rd) = result;
  RETIRE_SUCCESS
}

function clause execute (ZICOND_RTYPE(rs2, rs1, rd, CZERO_NEZ)) = {
  let value = X(rs1);
  let condition = X(rs2);
  let result : xlenbits = if condition != zeros() then zeros() else value;
  X(rd) = result;
  RETIRE_SUCCESS
}
