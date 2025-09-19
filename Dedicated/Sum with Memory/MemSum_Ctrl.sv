`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/18
// Design Name      : CPU_Dedicated
// Module Name      : MemSum_Ctrl
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Controller of Sum Dedecated using Memory
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module MemSum_Ctrl(
    input   logic           iClk,
    input   logic           iRst,

    input   logic           iAlt,

    // Memory
    output  logic           oWrEn,
    output  logic   [1:0]   oWrAddr,
    output  logic   [1:0]   oRdAddr0,
    output  logic   [1:0]   oRdAddr1,

    // DP
    output  logic           oRSrcSel,
    output  logic           oOutBufSel
    );

    typedef enum bit [2:0]  {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5,
        S6,
        S7
    }   state_e;

    state_e state, next;

    /***********************************************
    // FSM 
    ***********************************************/
    // Current State Update
    always_ff @(posedge iClk, posedge iRst)
    begin
        if (iRst)
            state   <= S0;
        else 
            state   <= next;
    end

    // Next State Decision
    always_comb
    begin
        case (state)
            S0      :
                next    = S1;
            
            S1      :
                next    = S2;

            S2      :
                next    = S3;

            S3      :
            begin
                if (iAlt)
                    next    = S4;
                else
                    next    = S6;
            end
            
            S4      :
                next    = S5;

            S5      :
                next    = S3;

            S6      :
                next    = S7;

            S7      :
                next    = S7;
        endcase
    end

    // Output Decision
    assign  oWrEn       = (state == S0 ||
                           state == S1 ||
                           state == S2 ||
                           state == S4 ||
                           state == S5  )   ? 2'd1 : 2'd0;

    assign  oWrAddr     = (state == S0)     ? 2'd1 :
                          (state == S1 ||
                           state == S5)     ? 2'd2 :
                          (state == S2 ||
                           state == S4)     ? 2'd3 : 2'd0;

    assign  oRdAddr0    = (state == S5)     ? 2'd1 :
                          (state == S4 ||
                           state == S6)     ? 2'd3 : 2'd0;

    assign  oRdAddr1    = (state == S3 ||
                           state == S4 ||
                           state == S5)     ? 2'd2 : 2'd0;

    assign  oRSrcSel    = (state == S1 ||
                           state == S2 ||
                           state == S4 ||
                           state == S5)     ? 2'd1 : 2'd0;

    assign  oOutBufSel  = (state == S6)     ? 2'd1 : 2'd0;

endmodule
