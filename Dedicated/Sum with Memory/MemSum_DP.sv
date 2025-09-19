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
// Description      : DataPath of Sum Dedecated using Memory
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////


module MemSum_DP(
    //input   logic           iClk,
    //input   logic           iRst,
    
    input   logic           iRSrcSel,
    input   logic           iOufBufSel,

    input   logic   [7:0]   iRdData0,
    input   logic   [7:0]   iRdData1,

    output  logic   [7:0]   oWrData,
    output  logic   [7:0]   oOut,
    output  logic           oAlt
);

    // Reg & Wire - Logic
    logic   [7:0]   wAdd2Mux;

    /***********************************************
    // Instantiation
    ***********************************************/
    Mux_2x1 U_AMux_2x1  (
        .iSrcSel    (iRSrcSel),
        .iA         (8'b1),
        .iB         (wAdd2Mux),
        .oMux2Reg   (oWrData)
    );

    Comparator  U_Comp  (
        .iA     (iRdData1),
        .iB     (8'd10),
        .oAlt   (oAlt)
    );

    Adder   U_Add   (
        .iA     (iRdData0),
        .iB     (iRdData1),
        .oSum   (wAdd2Mux)
    );

    OutBuf  U_Out   (
        .iReg_Data  (iRdData0),
        .iOufBufSel (iOufBufSel),
        .oOut       (oOut)
    );

endmodule

/***********************************************
// Sub Modules
***********************************************/
module Mux_2x1 (
    input   logic           iSrcSel,
    input   logic   [7:0]   iA,
    input   logic   [7:0]   iB,
    
    output  logic   [7:0]   oMux2Reg
);

    always_comb
    begin
        oMux2Reg   = 8'b0;
        case (iSrcSel)
            1'b0    : oMux2Reg = iA;
            1'b1    : oMux2Reg = iB;
        endcase       
    end

endmodule

module Comparator (
    input   logic   [7:0]   iA,
    input   logic   [7:0]   iB,

    output  logic           oAlt
);

    assign  oAlt    = iA <= iB;

endmodule

module  Adder (
    input   logic   [7:0]   iA,
    input   logic   [7:0]   iB,

    output  logic   [7:0]   oSum
);

    assign  oSum    = iA + iB;

endmodule

module OutBuf (
    input   logic   [7:0]   iReg_Data,
    input   logic           iOufBufSel,

    output  logic   [7:0]   oOut
);

    assign  oOut    = iOufBufSel ? iReg_Data : 8'bz;

endmodule