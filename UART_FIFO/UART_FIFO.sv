`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/11
// Design Name      : UART_FIFO
// Module Name      : UART_FIFO
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : UART + FIFO Top module
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module UART_FIFO(
    // Clock & Reset
    input   logic           iClk,
    input   logic           iRst,

    // UART
    input   logic           iRx,
    output  logic           oTx,
    output  logic   [7:0]   oRx_Tx_Data
    );


    /***********************************************
    // Reg & Wire
    ***********************************************/
    // UART
    logic           wTx_Empty;
    logic   [7:0]   wTx_Data;
    logic           wTx_Busy;
    logic   [7:0]   wRx_Data;
    logic           wRx_Done;

    // FIFO
    logic           wTx_Full;
    logic           wRx_Empty;
    logic   [7:0]   wRx_Tx_Data;


    /***********************************************
    // Instantiation
    ***********************************************/
    UART    U_UART  (
        .iClk       (iClk),
        .iRst       (iRst),
        .iTx_Start  (!wTx_Empty),
        .iTx_Data   (wTx_Data),
        .oTx        (oTx),
        .oTx_Busy   (wTx_Busy),
        .iRx        (iRx),
        .oRx_Data   (wRx_Data),
        .oRx_Done   (wRx_Done)
    );

    FIFO    U_Rx_FIFO   (
        .iClk       (iClk),
        .iRst       (iRst),
        .iPush      (wRx_Done),
        .iWrData    (wRx_Data),
        .iPop       (!wTx_Full),
        .oRdData    (wRx_Tx_Data),
        .oFull      (),
        .oEmpty     (wRx_Empty)
    );

    FIFO    U_Tx_FIFO   (
        .iClk       (iClk),
        .iRst       (iRst),
        .iPush      (!wRx_Empty),
        .iWrData    (wRx_Tx_Data),
        .iPop       (!wTx_Busy),
        .oRdData    (wTx_Data),
        .oFull      (wTx_Full),
        .oEmpty     (wTx_Empty)
    );

    assign  oRx_Tx_Data = wRx_Tx_Data;

endmodule
