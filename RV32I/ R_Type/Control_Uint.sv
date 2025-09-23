`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/19
// Design Name      : 
// Module Name      : Control_Unit
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      :
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Control_Uint(
    input   logic   [31:0]  iInst_OPcode,

    output  logic   [3:0]   oControl,
    output  logic           oWrEn
    );

    // Reg & Wire - Logic
    logic   [6:0]   wFunc7;
    logic   [2:0]   wFunc3;
    logic   [6:0]   wOPcode;

    assign  wFunc7  = iInst_OPcode[31:25];
    assign  wFunc3  = iInst_OPcode[14:12];
    assign  wOPcode = iInst_OPcode[6:0];

    // Function
    always_comb
    begin
        case (wOPcode)
            7'b011_0011 :
            begin
                case ({wFunc7, wFunc3})
                    10'b0000000_000 : oControl = 4'b0000;    // ADD
                    10'b0100000_000 : oControl = 4'b0001;    // SUB
                    10'b0000000_001 : oControl = 4'b0010;    // SLL
                    10'b0000000_101 : oControl = 4'b0011;    // SRL
                    10'b0100000_101 : oControl = 4'b0100;    // SRA
                    10'b0000000_010 : oControl = 4'b0101;    // SLT
                    10'b0000000_011 : oControl = 4'b0110;    // SLTU
                    10'b0000000_100 : oControl = 4'b0111;    // XOR
                    10'b0000000_110 : oControl = 4'b1000;    // OR
                    10'b0000000_111 : oControl = 4'b1001;    // AND
                    default         : oControl = 4'bx;
                endcase
            end

            default     :
                oControl = 4'bx;
        endcase
    end

    // Write Enable
    always_comb
    begin
        case (wOPcode)
            7'b011_0011 : oWrEn = 1'b1;
            default     : oWrEn = 1'b0;
        endcase
    end

endmodule
