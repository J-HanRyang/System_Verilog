`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/22
// Design Name      : RV32I
// Module Name      : Data_RAM
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Data_RAM
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Data_RAM(
    input   logic           iClk,

    input   logic   [2:0]   iFunct3,
    input   logic           iData_WrEn,
    input   logic   [31:0]  iData_Addr,
    input   logic   [31:0]  iData_WrData,

    output  logic   [31:0]  oData_RdData
    );

    logic   [31:0]  rData_Mem[0:15];

    always_ff @(posedge iClk)
    begin
        if (iData_WrEn)
            rData_Mem[iData_Addr] <= iData_WrData;
    end

    assign  oData_RdData = rData_Mem[iData_Addr];

endmodule