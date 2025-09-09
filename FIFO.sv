`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/09
// Design Name      : Syvel_Verification
// Module Name      : FIFO
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : FIFO Using SystemVerilog
//////////////////////////////////////////////////////////////////////////////////

module FIFO(
    // Clock & Reset
    input   logic           iClk,
    input   logic           iRst,

    // Write Data
    input   logic           iPush,
    input   logic   [7:0]   iWrData,

    // Read Data
    input   logic           iPop,
    output  logic   [7:0]   oRdData,

    // Flag
    output  logic           oFull,
    output  logic           oEmpty
    );


    /***********************************************
    // Reg & Wire
    ***********************************************/
    logic   [3:0]   wWrAddr;
    logic   [3:0]   wRdAddr;


    /***********************************************
    // Instantiation
    ***********************************************/	
    FIFO_Ctrl   U_FIFO_Ctrl (
        .iClk       (iClk),
        .iRst       (iRst),
        .iPush      (iPush),
        .oWrAddr    (wWrAddr),
        .iPop       (iPop),
        .oRdAddr    (wRdAddr),
        .oFull      (oFull),
        .oEmpty     (oEmpty)
    );

    SRAM    U_SRAM  (
        .iClk       (iClk),
        .iWrEn      (!oFull & iPush),
        .iWrAddr    (wWrAddr),
        .iWrData    (iWrData),
        .iRdEn      (!oEmpty & iPop),
        .iRdAddr    (wRdAddr),
        .oRdData    (oRdData)
    );

endmodule
