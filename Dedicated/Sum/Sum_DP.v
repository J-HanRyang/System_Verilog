`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/18
// Design Name      : CPU_Dedicated
// Module Name      : Sum_DP
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : DataPath of Sum Dedecated
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////


module Sum_DP(
    input   logic           iClk,
    input   logic           iRst,

    // Areg
    input   logic           iASrcSel,
    input   logic           iALoad,

    // Sum_Reg
    input   logic           iSumSrcSel,
    input   logic           iSumLoad,
    input   logic           iOufBufSel,

    // Adder
    input   logic           iAddSrcSel,

    output  logic           oAlt,
    output  logic   [7:0]   oOut
    );

    /***********************************************
    // Parameter
    ***********************************************/
    parameter   Start_Num   = 0;
    parameter   End_Num     = 10;

    /***********************************************
    // Reg & Wire - Logic
    ***********************************************/
    // Areg
    logic   [7:0]   wAdd2Mux;
    logic   [7:0]   wMux2Areg;
    logic   [7:0]   wAregOut;

    // SumReg
    logic   [7:0]   wMux2SumReg;
    logic   [7:0]   wSumRegOut;

    // Add
    logic   [7:0]   wMux2Add;


    /***********************************************
    // Instantiation
    ***********************************************/
    // Areg
    Mux_2x1 U_AMux_2x1  (
        .iSrcSel    (iASrcSel),
        .iA         (Start_Num),
        .iB         (wAdd2Mux),
        .oMux2Reg   (wMux2Areg)
    );

    Reg     U_Areg  (
        .iClk   (iClk),
        .iRst   (iRst),
        .iLoad  (iALoad),
        .iD     (wMux2Areg),
        .oQ     (wAregOut)
    );

    Comparator  U_Comp  (
        .iA     (wAregOut),
        .iB     (End_Num),
        .oAlt   (oAlt)
    );

    // Sum_Reg
    Mux_2x1 U_SumMux_2x1    (
        .iSrcSel    (iSumSrcSel),
        .iA         (8'b0),
        .iB         (wAdd2Mux),
        .oMux2Reg   (wMux2SumReg)
    );

    Reg     U_SumReg    (
        .iClk   (iClk),
        .iRst   (iRst),
        .iLoad  (iSumLoad),
        .iD     (wMux2SumReg),
        .oQ     (wSumRegOut)
    );

    OutBuf  U_Out   (
        .iReg_Data  (wSumRegOut),
        .iOufBufSel (iOufBufSel),
        .oOut       (oOut)
    );

    // Adder
    Mux_2x1 U_AddMux    (
        .iSrcSel    (iAddSrcSel),
        .iA         (8'b1),
        .iB         (wSumRegOut),
        .oMux2Reg   (wMux2Add)
    );

    Adder   U_Add   (
        .iA     (wMux2Add),
        .iB     (wAregOut),
        .oSum   (wAdd2Mux)
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

module Reg (
    input   logic           iClk,
    input   logic           iRst,

    input   logic           iLoad,
    input   logic   [7:0]   iD,

    output  logic   [7:0]   oQ
);

    always_ff @(posedge iClk, posedge iRst )
    begin
        if (iRst)
            oQ  <= 0;
        else
        begin
            if (iLoad)
                oQ  <= iD;
            else
                oQ  <= oQ;
        end
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
