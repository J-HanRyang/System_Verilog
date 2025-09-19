`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/19
// Design Name      : 
// Module Name      : Datapath
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      :
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module DataPath(
    input   logic           iClk,
    input   logic           iRst,
    input   logic   [31:0]  iInst_OPcode,
    input   logic   [3:0]   iControl,
    input   logic           iWrEn,

    output  logic   [31:0]  oInst_RdAddr
);

    logic   [31:0]  wRegfile_RdData1;
    logic   [31:0]  wRegfile_RdData2;
    logic   [31:0]  wALU_Result;

    Register_File   U_Reg_File  (
        .iClk       (iClk),
        .iWrEn      (iWrEn),
        .iWrAddr    (iInst_OPcode[11:7]),
        .iWrData    (wALU_Result),
        .iRdAddr1   (iInst_OPcode[24:20]),
        .iRdAddr2   (iInst_OPcode[19:15]),
        .oRdData1   (wRegfile_RdData1),
        .oRdData2   (wRegfile_RdData2)
    );

    Program_Counter U_PC(
        .iClk   (iClk),
        .iRst   (iRst),
        .iD     (oInst_RdAddr),
        .oPC    (oInst_RdAddr)
    );

    ALU U_ALU   (
        .iControl   (iControl),
        .iA         (wRegfile_RdData1),
        .iB         (wRegfile_RdData2),
        .oResult    (wALU_Result)
    );
    
endmodule


/***********************************************
// Sub Modules
***********************************************/
module Program_Counter (
    input   logic           iClk,
    input   logic           iRst,
    input   logic   [31:0]  iD,

    output  logic   [31:0]  oPC
);

    logic   [31:0]  wPC_4;

    Register    U_PC_REG    (
        .iClk   (iClk),
        .iRst   (iRst),
        .iD     (wPC_4),
        .oQ     (oPC)
);

    assign  wPC_4 = oPC + 4;

endmodule

module Register (
    input   logic           iClk,
    input   logic           iRst,

    input   logic   [31:0]  iD,

    output  logic   [31:0]  oQ
);

    always_ff @(posedge iClk, posedge iRst )
    begin
        if (iRst)
            oQ  <= 0;
        else
            oQ  <= iD;
    end

endmodule

module Register_File (
    input   logic           iClk,

    input   logic           iWrEn,
    input   logic   [4:0]   iWrAddr,
    input   logic   [31:0]  iWrData,

    input   logic   [4:0]   iRdAddr1,
    input   logic   [4:0]   iRdAddr2,
    output  logic   [31:0]  oRdData1,
    output  logic   [31:0]  oRdData2
);

    // Reg & Wire - Logic
    logic   [31:0]  rReg_File[0:31];

    initial
    begin
        rReg_File[0]    = 32'd0;
        rReg_File[1]    = 32'd1;
        rReg_File[2]    = 32'd2;
        rReg_File[3]    = 32'd3;
        rReg_File[4]    = 32'd4;
        rReg_File[5]    = 32'd5;
        rReg_File[6]    = 32'd6;
        rReg_File[7]    = 32'd7;
        rReg_File[8]    = 32'd8;
        rReg_File[9]    = 32'd9;
        rReg_File[10]   = 32'hf0_00_00_00;
        rReg_File[14]   = 32'd14;
    end

    always_ff @(posedge iClk)
    begin
        if (iWrEn)
            rReg_File[iWrAddr]  <= iWrData;
    end

    assign  oRdData1    = rReg_File[iRdAddr1];
    assign  oRdData2    = rReg_File[iRdAddr2];

endmodule

module ALU (
    input   logic   [3:0]   iControl,
    input   logic   [31:0]  iA,
    input   logic   [31:0]  iB,
    
    output  logic   [31:0]  oResult
);

    enum    logic   [3:0] {
        ADD,
        SUB,
        SLL,
        SRL,
        SRA,
        SLT,
        SLTU,
        XOR,
        OR,
        AND
    }   eAlu_OP;

    always_comb
    begin
        case (iControl)
            ADD     : oResult = iA + iB;
            SUB     : oResult = iA - iB;
            SLL     : oResult = iA << iB;
            SRL     : oResult = iA >> iB;
            SRA     : oResult = $signed(iA) >>> iB;
            SLT     : oResult = iA < iB;
            SLTU    : oResult = iA < iB;
            XOR     : oResult = iA ^ iB;
            OR      : oResult = iA | iB;
            AND     : oResult = iA & iB;
            default : oResult = 32'bx;
        endcase    
    end

endmodule