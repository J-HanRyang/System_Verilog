`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/18
// Design Name      : CPU_Dedicated
// Module Name      : Register_Memory
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Memory
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Register_Memory(
    input   logic           iClk,

    input   logic           iWrEn,
    input   logic   [1:0]   iWrAddr,
    input   logic   [7:0]   iWrData,

    input   logic   [1:0]   iRdAddr0,
    input   logic   [1:0]   iRdAddr1,

    output  logic   [7:0]   oRdData0,
    output  logic   [7:0]   oRdData1
    );

    logic   [7:0] rMemory[0:3];

    always_ff @(posedge iClk)
    begin
        rMemory[0]  <= 0;

        if (iWrEn && (iWrAddr != 0))
            rMemory[iWrAddr]    <= iWrData;
    end

    // assign  oRdData0 = (iRdAddr0 == 2'd0) ? 8'b0 : rMemory[iRdAddr0];
    // assign  oRdData1 = (iRdAddr1 == 2'd0) ? 8'b0 : rMemory[iRdAddr1];
    assign  oRdData0 = rMemory[iRdAddr0];
    assign  oRdData1 = rMemory[iRdAddr1];
    
endmodule
