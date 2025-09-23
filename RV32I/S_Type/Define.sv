`timescale 1ns / 1ps

// R_TYPE ALU Command {Funct7[5], Funct3}
`define ADD     4'b0000
`define SUB     4'b1000
`define SLL     4'b0001
`define SRL     4'b0101
`define SRA     4'b1101
`define SLT     4'b0010
`define SLTU    4'b0011
`define XOR     4'b0100
`define AND     4'b0111
`define OR      4'b0110

// DPCODE
`define OP_R_TYPE   7'b011_0011
`define OP_S_TYPE   7'b010_0011