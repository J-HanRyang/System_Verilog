`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/18
// Design Name      : CPU_Dedicated
// Module Name      : Sum_Ctrl
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Controller of Sum Dedecated
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Sum_Ctrl(
    input   logic           iClk,
    input   logic           iRst,

    input   logic           iAlt,

    output  logic           oASrcSel,
    output  logic           oALoad,
    
    output  logic           oSumSrcSel,
    output  logic           oSumLoad,
    output  logic           oOufBufSel,

    output  logic           oAddSrcSel
    );
    
    typedef enum bit [2:0] {
        S0,
        S1,
        S2,
        S3,
        S4,
        S5
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
        next    = state;

        case (state)
            S0      :
                next    = S1;

            S1      :
            begin
                if  (iAlt)
                    next    = S2;
                else
                    next    = S4;
            end

            S2      :
                next    = S3;

            S3      :
                next    = S1;

            S4      :
                next    = S5;

            S5      :
                next    = S5;
        endcase
    end

    // Output Decision
    assign  oASrcSel    = (state == S3)                 ? 1 : 0;
    assign  oALoad      = (state == S0 || state == S3)  ? 1 : 0;

    assign  oSumSrcSel  = (state == S2)                 ? 1 : 0;
    assign  oSumLoad    = (state == S0 || state == S2)  ? 1 : 0;
    assign  oOufBufSel  = (state == S4)                 ? 1 : 0;
    
    assign  oAddSrcSel  = (state == S3)                 ? 0 :
                          (state == S2)                 ? 1 : 0;

endmodule
