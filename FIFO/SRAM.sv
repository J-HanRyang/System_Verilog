`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/09
// Design Name      : Syvel_Verification
// Module Name      : SRAM
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : SRAR Using SystemVerilog
//////////////////////////////////////////////////////////////////////////////////

module SRAM(
    input                   iClk,

    input   logic           iWrEn,
    input   logic   [3:0]   iWrAddr,
    input   logic   [7:0]   iWrData,

    input   logic           iRdEn,
    input   logic   [3:0]   iRdAddr,
    output  logic   [7:0]   oRdData
    );

    logic   [7:0]   rWrData[0:15];
    integer i;
    
    always_ff @(posedge iClk)
    begin
        if (iWrEn)
            rWrData[iWrAddr]    <= iWrData;
        // else
        //     oRdData             <= rWrData[iWrAddr];
    end

    assign  oRdData = iRdEn ? rWrData[iRdAddr] : 8'hz;
endmodule
