`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/09
// Design Name      : Syvel_Verification
// Module Name      : FIFO_Ctrl
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : FIFO_Ctrl Using SystemVerilog
//////////////////////////////////////////////////////////////////////////////////

module FIFO_Ctrl(
    // Cliok & Reset
    input   logic           iClk,
    input   logic           iRst,

    // Write_Push
    input   logic           iPush,
    output  logic   [3:0]   oWrAddr,

    // Read_Pop
    input   logic           iPop,
    output  logic   [3:0]   oRdAddr,

    // Flag
    output  logic           oFull,
    output  logic           oEmpty
    );

    // Reg & Wire
    logic   [3:0]   rRdPtr_Cur;
    logic   [3:0]   rRdPtr_Nxt;

    logic   [3:0]   rWrPtr_Cur;
    logic   [3:0]   rWrPtr_Nxt;

    logic           rFull_Cur;
    logic           rFull_Nxt;

    logic           rEmpty_Cur;
    logic           rEmpty_Nxt;


    /***********************************************
    // FSM 
    ***********************************************/
    // Current State Update
    always_ff @(posedge iClk, posedge iRst)
    begin
        if (iRst)
        begin
            rWrPtr_Cur  <= 0;
            rRdPtr_Cur  <= 0;
            rFull_Cur   <= 0;
            rEmpty_Cur  <= 1;
        end else
        begin
            rWrPtr_Cur  <= rWrPtr_Nxt;
            rRdPtr_Cur  <= rRdPtr_Nxt;
            rFull_Cur   <= rFull_Nxt;
            rEmpty_Cur  <= rEmpty_Nxt;
        end
    end

    // Next State Decision
    always_comb
    begin
        rWrPtr_Nxt  = rWrPtr_Cur;
        rRdPtr_Nxt  = rRdPtr_Cur;
        rFull_Nxt   = rFull_Cur;
        rEmpty_Nxt  = rEmpty_Cur;

        case ({iPush, iPop})
            2'b00   :   ;

            2'b01   :
            begin
                if (!rEmpty_Cur)
                begin
                    rRdPtr_Nxt  = rRdPtr_Cur + 1;
                    rFull_Nxt   = 0;

                    if (rRdPtr_Nxt == rWrPtr_Cur)
                        rEmpty_Nxt  = 1;
                    else
                        rEmpty_Nxt  = 0;
                end else
                    rRdPtr_Nxt  = rRdPtr_Cur;
            end

            2'b10   :
            begin
                if (!rFull_Cur)
                begin
                    rWrPtr_Nxt  = rWrPtr_Cur + 1;
                    rEmpty_Nxt  = 0;

                    if (rWrPtr_Nxt == rRdPtr_Cur)
                        rFull_Nxt   = 1;
                    else
                        rFull_Nxt   = 0;
                end else
                    rWrPtr_Nxt  = rWrPtr_Cur;
            end

            2'b11   :
            begin
                if          (rFull_Cur)
                begin
                    rRdPtr_Nxt  = rRdPtr_Cur + 1;
                    rFull_Nxt   = 0;
                end else if (rEmpty_Cur)
                begin
                    rWrPtr_Nxt  = rWrPtr_Cur + 1;
                    rEmpty_Nxt  = 0;
                end else
                begin
                    rWrPtr_Nxt  = rWrPtr_Cur + 1;
                    rRdPtr_Nxt  = rRdPtr_Cur + 1;
                end
            end
        endcase
    end

    // Output Decision
    assign  oWrAddr = rWrPtr_Cur;
    assign  oRdAddr = rRdPtr_Cur;
    assign  oFull   = rFull_Cur;
    assign  oEmpty  = rEmpty_Cur;

endmodule
