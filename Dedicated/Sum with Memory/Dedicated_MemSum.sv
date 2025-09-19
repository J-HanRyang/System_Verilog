`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/18
// Design Name      : CPU_Dedicated
// Module Name      : MemSum_DP
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Sum Dedecated using Memory
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Dedicated_MemSum(
    // Clock & Reset
    input   logic           iClk,
    input   logic           iRst,

    output  logic   [7:0]   oOut
    );


    /***********************************************
    // Reg & Wire - Logic
    ***********************************************/
    logic           wRSrcSel;

    logic           wWrEn;
    logic   [1:0]   wWrAddr;
    logic   [7:0]   wWrData;

    logic   [1:0]   wRdAddr0;
    logic   [1:0]   wRdAddr1;
    logic   [7:0]   wRdData0;
    logic   [7:0]   wRdData1;


    /***********************************************
    // Instantiation
    ***********************************************/
    MemSum_Ctrl U_MemSum_Ctrl   (
        .iClk       (iClk),
        .iRst       (iRst),
        .iAlt       (wAlt),
        .oWrEn      (wWrEn),
        .oWrAddr    (wWrAddr),
        .oRdAddr0   (wRdAddr0),
        .oRdAddr1   (wRdAddr1),
        .oRSrcSel   (wRSrcSel),
        .oOutBufSel (wOutBufSel)
    );

    MemSum_DP   U_MemSum_DP (
        //.iClk       (iClk),
        //.iRst       (iRst),
        .iRSrcSel   (wRSrcSel),
        .iOufBufSel (wOutBufSel),
        .iRdData0   (wRdData0),
        .iRdData1   (wRdData1),
        .oWrData    (wWrData),
        .oOut       (oOut),
        .oAlt       (wAlt)
    );

    Register_Memory U_Memory    (
        .iClk       (iClk),
        .iWrEn      (wWrEn),
        .iWrAddr    (wWrAddr),
        .iWrData    (wWrData),
        .iRdAddr0   (wRdAddr0),
        .iRdAddr1   (wRdAddr1),
        .oRdData0   (wRdData0),
        .oRdData1   (wRdData1)
    );

endmodule
