`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/19
// Design Name      : 
// Module Name      : Control_Unit
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      :
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module RV32I_Top(
    // Clock & Reset
    input   logic   iClk,
    input   logic   iRst
    );


    /***********************************************
    // Reg & Wire - Logic
    ***********************************************/
    logic   [31:0]  wRdData;
    logic   [3:0]   wControl;
    logic           wWrEn;
    logic   [31:0]  wRdAddr;

    /***********************************************
    // Instantiation
    ***********************************************/	
    Inst_ROM    U_ROM   (
        .iRdAddr    (wRdAddr),
        .oRdData    (wRdData)
    );

    Control_Uint    U_Ctrl  (
        .iInst_OPcode   (wRdData),
        .oControl       (wControl),
        .oWrEn          (wWrEn)
    );

    DataPath    U_DP    (
        .iClk           (iClk),
        .iRst           (iRst),
        .iInst_OPcode   (wRdData),
        .iControl       (wControl),
        .iWrEn          (wWrEn),
        .oInst_RdAddr   (wRdAddr)
    );

endmodule
