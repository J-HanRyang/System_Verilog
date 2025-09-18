`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/18
// Design Name      : CPU_Dedicated
// Module Name      : Dedicated_Sum
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : CPU Dedicated_Processor Sum
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Dedicated_Sum(
    // Clock & Reset
    input   logic           iClk,
    input   logic           iRst,

    output  logic   [7:0]   oOut
    );


    /***********************************************
    // Reg & Wire - Logic
    ***********************************************/
    logic   wAlt;
    logic   wASrcSel;
    logic   wALoad;
    logic   wSumSrcSel;
    logic   wSumLoad;
    logic   wOutBufSel;
    logic   wAddSrcSel;

    /***********************************************
    // Instantiation
    ***********************************************/
    Sum_Ctrl    U_Sum_Ctrl  (
        .iClk       (iClk),
        .iRst       (iRst),
        .iAlt       (wAlt),
        .oASrcSel   (wASrcSel),
        .oALoad     (wALoad),
        .oSumSrcSel (wSumSrcSel),
        .oSumLoad   (wSumLoad),
        .oOufBufSel (wOutBufSel),
        .oAddSrcSel (wAddSrcSel)
    );

    Sum_DP  U_DP    (
        .iClk       (iClk),
        .iRst       (iRst),
        .iASrcSel   (wASrcSel),
        .iALoad     (wALoad),
        .iSumSrcSel (wSumSrcSel),
        .iSumLoad   (wSumLoad),
        .iOufBufSel (wOutBufSel),
        .iAddSrcSel (wAddSrcSel),
        .oAlt       (wAlt),
        .oOut       (oOut)
    );

endmodule
