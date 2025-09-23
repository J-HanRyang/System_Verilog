`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/19
// Design Name      : RV32I
// Module Name      : Control_Unit
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Control_Unit of RISC-V 32I
//
// Revision 	    : 2025/09/22    Modify oALU_Control 
//                                  Add S-Type
//////////////////////////////////////////////////////////////////////////////////

`include "Define.sv"

module Control_Uint(
    input   logic   [31:0]  iInst_Code,

    output  logic   [2:0]   oFunct3,
    output  logic   [3:0]   oALU_Control,
    output  logic           oALUSrcMuxSel,
    output  logic           oWrEn,
    output  logic           oData_WrEn
    );

    // Reg & Wire - Logic
    logic   [6:0]   wFunct7;
    logic   [2:0]   wFunct3;
    logic   [6:0]   wOPcode;
    logic   [2:0]   wControl;


    assign  wFunct7 = iInst_Code[31:25];
    assign  wFunct3 = iInst_Code[14:12];
    assign  wOPcode = iInst_Code[6:0];

    assign  oFunct3 = wFunct3;

    // Function
    always_comb
    begin
        case (wOPcode)
            `OP_R_TYPE  :   // R-Type
            begin
                oALU_Control    = {wFunct7[5], wFunct3};
                wControl        = 3'b010;
            end

            `OP_S_TYPE  :   // S-Type
            begin
                oALU_Control    = `ADD;
                wControl        = 3'b101;
            end

            default     : 
            begin
                oALU_Control    = 4'bx;
                wControl        = 3'b000;
            end
        endcase
    end

    assign  {oALUSrcMuxSel, oWrEn, oData_WrEn}  = wControl;
    
endmodule