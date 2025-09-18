`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/17
// Design Name      : CPU_Dedicated
// Module Name      : Dedicated_Processor
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : CPU Dedicated_Processor Counter
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Dedicated_Counter (
    // Clock & Reset
    input   logic           iClk,
    input   logic           iRst,

    output  logic   [7:0]   oOut
    );


    /***********************************************
    // Reg & Wire - Logic
    ***********************************************/
    logic           wAsrcSel;
    logic           wALoad;
    logic           wOutBufSel;
    logic           wAlt10;


    /***********************************************
    // Instantiation
    ***********************************************/	
    Counter_Ctrl    U_Counter_Ctrl    (
        .iClk       (iClk),
        .iRst       (iRst),
        .iAlt10     (wAlt10),
        .oAsrcSel   (wAsrcSel),
        .oALoad     (wALoad),
        .oOufBufSel (wOutBufSel)
    );

    Counter_DP    U_Counter_DP    (
        .iClk       (iClk),
        .iRst       (iRst),
        .iAsrcSel   (wAsrcSel),
        .iALoad     (wALoad),
        .iOufBufSel (wOutBufSel),
        .oAlt10     (wAlt10),
        .oOut       (oOut)
    );


endmodule
