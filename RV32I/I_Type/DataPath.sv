`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/19
// Design Name      : RV32I
// Module Name      : Datapath
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Datapath of RISC-V 32I
//
// Revision 	    : 2025/09/22    Update ALU (ADD Define File)
//////////////////////////////////////////////////////////////////////////////////

`include "Define.sv"

module DataPath(
    input   logic           iClk,
    input   logic           iRst,

    input   logic   [31:0]  iInst_Code,
    input   logic   [31:0]  iData_RdData,
    input   logic   [3:0]   iALU_Control,
    input   logic           iRegWrDataSel,
    input   logic           iALUSrcMuxSel,
    input   logic           iWrEn,

    output  logic   [31:0]  oInst_RdAddr,
    output  logic   [31:0]  oData_Addr,
    output  logic   [31:0]  oData_WrData
);

    /***********************************************
    // Reg & Wire - Logic
    ***********************************************/
    logic   [31:0]  wRegfile_RdData1;
    logic   [31:0]  wRegfile_RdData2;
    logic   [31:0]  wRegWrDataOut;
    logic   [31:0]  wALU_Result;
    logic   [31:0]  wImm_Ext;
    logic   [31:0]  wALUSrcMux_Out;


    /***********************************************
    // Instantiation
    ***********************************************/
    Program_Counter U_PC(
        .iClk       (iClk),
        .iRst       (iRst),
        .iPC_Data   (oInst_RdAddr),
        .oPC        (oInst_RdAddr)
    );

    Register_File   U_Reg_File  (
        .iClk       (iClk),
        .iWrEn      (iWrEn),
        .iWrAddr    (iInst_Code[11:7]),
        .iWrData    (wRegWrDataOut),
        .iRdAddr1   (iInst_Code[19:15]),
        .iRdAddr2   (iInst_Code[24:20]),
        .oRdData1   (wRegfile_RdData1),
        .oRdData2   (wRegfile_RdData2)
    );

    Mux_2x1 U_RegWrDataMux  (
        .iSel   (iRegWrDataSel),
        .iX0    (wALU_Result),
        .iX1    (iData_RdData),
        .oY     (wRegWrDataOut)
    );

    ALU U_ALU   (
        .iALU_Control   (iALU_Control),
        .iA             (wRegfile_RdData1),
        .iB             (wALUSrcMux_Out),
        .oALU_Result    (wALU_Result)
    );

    Entend  U_Extend    (
        .iInst_Code (iInst_Code),
        .oImm_Ext   (wImm_Ext)
    );
    
    Mux_2x1 U_ALUSrcMux (
        .iSel   (iALUSrcMuxSel),
        .iX0    (wRegfile_RdData2),
        .iX1    (wImm_Ext),
        .oY     (wALUSrcMux_Out)
    );


    assign  oData_Addr      = wALU_Result;
    assign  oData_WrData    = wRegfile_RdData2;
    
endmodule


/***********************************************
// Sub Modules
***********************************************/
module Program_Counter (
    input   logic           iClk,
    input   logic           iRst,
    input   logic   [31:0]  iPC_Data,

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
        rReg_File[17]   = 32'hdd_dd_dd_dd;
        rReg_File[18]   = 32'hee_ee_ee_dd;
        rReg_File[19]   = 32'hff_ff_ff_ff;
        rReg_File[20]   = 32'd20;
        rReg_File[21]   = 32'd21;
        rReg_File[22]   = 32'd22;
    end

    always_ff @(posedge iClk)
    begin
        if (iWrEn)
            rReg_File[iWrAddr]  <= iWrData;
    end

    assign  oRdData1    = (iRdAddr1 != 0) ? rReg_File[iRdAddr1] : 0;
    assign  oRdData2    = (iRdAddr2 != 0) ? rReg_File[iRdAddr2] : 0;

endmodule

module ALU (
    input   logic   [3:0]   iALU_Control,
    input   logic   [31:0]  iA,
    input   logic   [31:0]  iB,
    
    output  logic   [31:0]  oALU_Result
);

    always_comb
    begin
        case (iALU_Control)
            `ADD    : oALU_Result   = iA + iB;
            `SUB    : oALU_Result   = iA - iB;
            `SLL    : oALU_Result   = iA << iB[4:0]; 
            `SRL    : oALU_Result   = iA >> iB[4:0];
            `SRA    : oALU_Result   = $signed(iA) >>> iB[4:0];
            `SLT    : oALU_Result   = $signed(iA) < $signed(iB);
            `SLTU   : oALU_Result   = iA < iB;
            `XOR    : oALU_Result   = iA ^ iB;
            `OR     : oALU_Result   = iA | iB;
            `AND    : oALU_Result   = iA & iB;
            default : oALU_Result   = 32'bx;
        endcase    
    end

endmodule

module Entend (
    input   logic   [31:0]  iInst_Code,
    
    output  logic   [31:0]  oImm_Ext
);

    // Reg & Wire
    logic   [6:0]   wOPcode; 

    assign  wOPcode = iInst_Code[6:0];

    always_comb
    begin
        case (wOPcode)
            `OP_R_TYPE  : oImm_Ext  = 32'bx;
            `OP_S_TYPE  : oImm_Ext  = {{20{iInst_Code[31]}}, iInst_Code[31:25], iInst_Code[11:7]};
            `OP_IL_TYPE : oImm_Ext  = {{20{iInst_Code[31]}}, iInst_Code[31:20]};
            default     : oImm_Ext  = 32'bx;
        endcase
    end

endmodule

module Mux_2x1 (
    input   logic           iSel,
    input   logic   [31:0]  iX0,    // 0 : Regfile_RdData2
    input   logic   [31:0]  iX1,    // 1 : Imm[31:0]

    output  logic   [31:0]  oY
);

    assign  oY = iSel ? iX1 : iX0;

endmodule