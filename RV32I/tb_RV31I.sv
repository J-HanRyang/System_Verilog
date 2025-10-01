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

module tb_RV31I();
    logic   iClk;
    logic   iRst;

    /***********************************************
    // Instantiation
    ***********************************************/	
    RV32I_Top U_Top (
        .iClk   (iClk),
        .iRst   (iRst)
    );


    /***********************************************
    // Clock define
    **********************************************/
    initial     iClk    = 1'b0;
    always  #5  iClk    = ~iClk;   // 100MHz clock


    /****************************************************
    // Intialization & function start !!!!!!!!!!!!!!!!!!!
    ****************************************************/
    initial
    begin
        #0  iRst = 1;
        #10 iRst = 10;

        #600
        $stop;
    end

endmodule