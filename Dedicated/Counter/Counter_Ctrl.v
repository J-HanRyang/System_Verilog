`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/17
// Design Name      : CPU_Dedicated
// Module Name      : Counter_Ctrl
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Controller of Counter Dedicated
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////

module Counter_Ctrl (
    input   logic           iClk,
    input   logic           iRst,

    input   logic           iAlt10,

    output  logic           oAsrcSel,
    output  logic           oALoad,
    output  logic           oOufBufSel
);

    typedef enum bit [2:0] {
        S0,
        S1,
        S2,
        S3,
        S4
    } state_e;

    state_e state, next;


    /***********************************************
    // FSM 
    ***********************************************/
    // Current State Update
    always_ff @(posedge iClk, posedge iRst)
    begin
        if (iRst)
        begin
            state       <= S0;
        end else
        begin
            state       <= next;
        end
    end

    // Next State Decision
    always_comb
    begin
        next            = state;

        case (state)
            S0      :
                next    = S1;

            S1      :
            begin
                if (iAlt10)
                    next    = S2;
                else
                    next    = S4;
            end

            S2      :
                next    = S3;


            S3      :
                next    = S1;


            S4      :
                next    = S4;

            default :
                next    = state;
        endcase
    end

    // Output Decision
    assign  oAsrcSel    = (state == S3)                 ? 1 : 0;
    assign  oALoad      = (state == S0 || state == S3)  ? 1 : 0;
    assign  oOufBufSel  = (state == S2)                 ? 1 : 0;

endmodule
