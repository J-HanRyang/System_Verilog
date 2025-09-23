`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/19
// Design Name      : RV32I
// Module Name      : Inst_ROM
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Instrucion ROM
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Inst_ROM(
    input   logic   [31:0]  iRdAddr,

    output  logic   [31:0]  oRdData
    );

    // Reg & Wire - Logic
    logic   [31:0]  rRom[0:63];

    initial
    begin
        // Funct7_Rs2_Rs1_Funct3_Rd_Opcode
        rRom[0]     = 32'b0000000_00010_00001_000_00101_0110011;    // ADD 1 + 2 = 3
        rRom[1]     = 32'b0100000_01000_01001_000_00111_0110011;    // SUB 9 - 8 = 1
        rRom[2]     = 32'b0000000_00001_01000_001_00111_0110011;    // SLL 8 << 1 = 16 
        rRom[3]     = 32'b0000000_00001_01000_101_00111_0110011;    // SRL 8 >> 1 = 4
        rRom[4]     = 32'b0100000_00010_01010_101_00111_0110011;    // SRA 32'hf0_00_00_00 >>> 2 = fc_00_00_00 
        rRom[5]     = 32'b0000000_01000_01001_010_00111_0110011;    // SLT 9 < 8 = 0
        rRom[6]     = 32'b0000000_01001_01000_011_00111_0110011;    // SLTU 8 < 9 = 1
        rRom[7]     = 32'b0000000_01110_01000_100_00111_0110011;    // XOR 1000 ^ 1110 = 0110 (6)
        rRom[8]     = 32'b0000000_01110_01000_110_00111_0110011;    // OR  1000 | 1110 = 1110 (14)
        rRom[9]     = 32'b0000000_01110_01000_111_00111_0110011;    // AND 1000 & 1110 = 1000 (8)
        
        // Imm_Rs2_Rs1_Funct3_Imm_Opcode
        rRom[10]    = 32'b0000000_10011_10100_000_00010_0100011;    // SB (Store Byte) 19 20 -> 20 + ff
        rRom[11]    = 32'b0000000_10011_10101_001_00010_0100011;    // SH (Store Half) 19 21 -> 21 + ff_ff
        rRom[12]    = 32'b0000000_10011_10110_010_00010_0100011;    // SW (Store Word) 19 22 -> 22 + ff_ff_ff_ff
    end

    assign  oRdData = rRom[iRdAddr[31:2]];

endmodule