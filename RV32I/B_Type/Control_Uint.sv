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
//                                  Add S-Type, Funct3 output
//                    2025/09/24    Add I-Type
//////////////////////////////////////////////////////////////////////////////////

`include "Define.sv"

module Control_Uint(
    input   logic   [31:0]  iInst_Code,

    output  logic   [2:0]   oFunct3,
    output  logic   [3:0]   oALU_Control,
    output  logic           oRegWrDataSel,
    output  logic           oALUSrcMuxSel,
    output  logic           oWrEn,
    output  logic           oData_WrEn,
    output  logic           oBranch
    );

    // Reg & Wire - Logic
    logic   [6:0]   wFunct7;
    logic   [2:0]   wFunct3;
    logic   [6:0]   wOPcode;
    logic   [4:0]   wControl;


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
                wControl        = 5'b00100;
            end

            `OP_S_TYPE  :   // S-Type
            begin
                oALU_Control    = `ADD;
                wControl        = 5'b01010;
            end

            `OP_IL_TYPE :   // I-Type1
            begin
                oALU_Control    = `ADD;
                wControl        = 5'b11100;
            end

            `OP_I_TYPE  :   // I-Type2 (I+R)
            begin
                if (wFunct3 == 3'b101)
                    oALU_Control    = {wFunct7[5], wFunct3};
                else
                    oALU_Control    = {1'b0, wFunct3};

                wControl        = 5'b01100;
            end

            `OP_B_TYPE  :   //B_Type
            begin
                oALU_Control    = {1'b0, wFunct3};
                wControl        = 5'b00001;
            end

            default     : 
            begin
                oALU_Control    = 4'bx;
                wControl        = 5'b00000;
            end
        endcase
    end

    assign  {oRegWrDataSel, oALUSrcMuxSel, oWrEn, oData_WrEn, oBranch}  = wControl;
    
endmodule