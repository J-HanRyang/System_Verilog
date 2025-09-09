`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/08
// Design Name      : Syvel_Verification
// Module Name      : ADD_SUB
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : ADD_SUB Using SystemVerilog
//////////////////////////////////////////////////////////////////////////////////

module ADD_SUB(
    input   logic   [7:0]   iA,
    input   logic   [7:0]   iB,
    input   logic           iMode,

    output  logic   [7:0]   oSum,
    output  logic           oCarry
);

    always_comb
    begin
        case (iMode)
            1'b0    : {oCarry, oSum} = iA + iB; // ADD
            1'b1    : {oCarry, oSum} = iA - iB; // SUB
            default : {oCarry, oSum} = iA + iB; 
        endcase
    end
endmodule