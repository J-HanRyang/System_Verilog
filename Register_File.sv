`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/08
// Design Name      : Syvel_Verification
// Module Name      : Register_File
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Register_File Using SystemVerilog
//////////////////////////////////////////////////////////////////////////////////

module Register_File(
    input   logic           iClk,
    input   logic           iRst,
    
    input   logic           iWrEn,
    input   logic   [7:0]   iWrData,

    output  logic   [7:0]   oRdData
    );

    // Inner Logic
    logic   [7:0]   rWrData;

    always_ff @(posedge iClk, posedge iRst )
    begin
        if (iRst)
            rWrData <= 0;
        else
        begin
            if (iWrEn)
                rWrData <= iWrData;
            // else
            //     oRdData <= rWrData;
        end
    end

    assign  oRdData = rWrData;

endmodule