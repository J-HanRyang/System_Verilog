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
// Description      : DataPath of Counter Dedecated
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Counter_DP  (
    input   logic           iClk,
    input   logic           iRst,

    input   logic           iAsrcSel,
    input   logic           iALoad,
    input   logic           iOufBufSel,

    output  logic           oAlt10,
    output  logic   [7:0]   oOut
);


    // Reg & Wire
    logic   [7:0]   wMux2Areg;
    logic   [7:0]   wAregOut;
    logic   [7:0]   wAdd2Mux;
    logic           wComp2Out;

    // Instance
    Mux_2x1 U_Mux_2x1   (
        .iAsrcSel   (iAsrcSel),
        .iA         (8'b0),
        .iB         (wAdd2Mux),
        .oMux2Areg  (wMux2Areg)
    );

    Areg    U_Areg  (
        .iClk   (iClk),
        .iRst   (iRst),
        .iALoad (iALoad),
        .iD     (wMux2Areg),
        .oQ     (wAregOut)
    );

    Comparator  U_Comp  (
        .iA     (wAregOut),
        .iB     (8'd10),
        .oAlt10 (oAlt10)
    );

    Adder   U_Add   (
        .iA     (wAregOut),
        .iB     (8'h1),
        .oSum   (wAdd2Mux)
    );

    OutBuf  U_Out   (
        .iAreg_Data (wAregOut),
        .iOufBufSel (iOufBufSel),
        .oOut       (oOut)
    );

endmodule


/***********************************************
// Sub Modules 2
***********************************************/
module Mux_2x1 (
    input   logic           iAsrcSel,
    input   logic   [7:0]   iA,
    input   logic   [7:0]   iB,
    
    output  logic   [7:0]   oMux2Areg
);

    always_comb
    begin
        oMux2Areg   = 8'b0;
        case (iAsrcSel)
            1'b0    : oMux2Areg = iA;
            1'b1    : oMux2Areg = iB;
        endcase       
    end

endmodule

module Areg (
    input   logic           iClk,
    input   logic           iRst,

    input   logic           iALoad,
    input   logic   [7:0]   iD,

    output  logic   [7:0]   oQ
);

    always_ff @(posedge iClk, posedge iRst )
    begin
        if (iRst)
            oQ  <= 0;
        else
        begin
            if (iALoad)
                oQ  <= iD;
            else
                oQ  <= oQ;
        end
    end

endmodule

module Comparator (
    input   logic   [7:0]   iA,
    input   logic   [7:0]   iB,

    output  logic           oAlt10
);

    assign  oAlt10  = iA < iB;

endmodule

module  Adder (
    input   logic   [7:0]   iA,
    input   logic   [7:0]   iB,

    output  logic   [8:0]   oSum
);

    assign  oSum    = iA + iB;

endmodule

module OutBuf (
    input   logic   [7:0]   iAreg_Data,
    input   logic           iOufBufSel,

    output  logic   [7:0]   oOut
);

    assign  oOut    = iOufBufSel ? iAreg_Data : 8'bz;
endmodule
