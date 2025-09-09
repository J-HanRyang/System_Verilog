`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/08
// Design Name      : Syvel_Verification
// Module Name      : tb_Register_File
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : testbench for Register_File
//
// Revision         : 2025/09/09    Add Send Class
//                                  - monitor, scoreboard
//////////////////////////////////////////////////////////////////////////////////


/***********************************************
// Interface
***********************************************/
interface reg_interface;
    logic           iClk;
    logic           iRst;
    logic           iWrEn;
    logic   [7:0]   iWrData;
    logic   [7:0]   oRdData;
endinterface //reg_interface


/***********************************************
// Class
***********************************************/
// Transaction
class transaction;
    rand bit            iWrEn;
    rand bit    [7:0]   iWrData;

    bit         [7:0]   oRdData;

    task display(string name_s);
        $display("%t : [%s] : iWrEn = %d, iWrData = %d, oRdData = %d", $time, name_s, iWrEn, iWrData, oRdData);
    endtask

endclass //transaction

// Generator
class generator;
    transaction             tr;
    mailbox #(transaction)  gen2drv_mbox;

    // Event를 받기 위해 생성
    event gen_next_event;

    int total_count = 0;

    function new(
        mailbox #(transaction)  gen2drv_mbox,
        event                   gen_next_event
    );
        this.gen2drv_mbox   = gen2drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction //new()

    task run(int count);
        repeat (count)
        begin
            total_count++;
            tr  = new();
            // tr.randomize();
            assert(tr.randomize())
            else $display("[GEN] tr.randomize() error!!!!!");          
            gen2drv_mbox.put(tr);
            tr.display("[Gen]");
            // Receive event
            @(gen_next_event);
        end
    endtask
    
endclass //generator

// Driver
class driver;
    transaction             tr;
    virtual reg_interface   reg_if;
    mailbox #(transaction)  gen2drv_mbox;

    // Event를 보내기 위해 생성
    // event gen_next_event;

    function new(
        mailbox #(transaction)  gen2drv_mbox,
        virtual reg_interface   reg_if
        // event                   gen_next_event
    );
        this.reg_if         = reg_if;
        this.gen2drv_mbox   = gen2drv_mbox;
        // this.gen_next_event = gen_next_event;
    endfunction //new()

    task reset();
        reg_if.iRst     = 1;
        reg_if.iWrEn    = 0;
        reg_if.iWrData  = 0;
        #10 
        reg_if.iRst     = 0;
    endtask

    task run();
        forever
        begin
            gen2drv_mbox.get(tr);   // blocking when empty in mailbox
            reg_if.iWrEn    = tr.iWrEn;
            reg_if.iWrData  = tr.iWrData;
            tr.display("[Drv]");
            @(negedge reg_if.iClk); // wait for negative iClk
            // Send event
            // ->gen_next_event;
        end
    endtask

endclass //driver

// Monitor
class monitor;
    transaction             tr;
    virtual reg_interface   reg_if;
    mailbox #(transaction)  mon2scb_mbox;

    function new(
        mailbox #(transaction)  mon2scb_mbox,
        virtual reg_interface   reg_if
    );
        this.mon2scb_mbox   = mon2scb_mbox;
        this.reg_if         = reg_if;  
    endfunction //new()

    task run();
        forever
        begin
            // generate transaction
            tr  = new();
            #2
            tr.iWrEn    = reg_if.iWrEn;
            tr.iWrData  = reg_if.iWrData;
            // compare for register logic output with input
            @(posedge reg_if.iClk);
            #1
            tr.oRdData  = reg_if.oRdData;
            tr.display("MON");
            mon2scb_mbox.put(tr);
        end
    endtask

endclass //monitor

// Scoreboard
class scoreboard;
    transaction             tr;
    mailbox #(transaction)  mon2scb_mbox;
    event                   gen_next_event;

    int pass_count = 0;
    int fail_count = 0;

    function new(
        mailbox #(transaction)  mon2scb_mbox,
        event                   gen_next_event
    );
        this.mon2scb_mbox   = mon2scb_mbox;  
        this.gen_next_event = gen_next_event;
    endfunction //new()
    
    task run();
        forever
        begin    
            // pass fail decision
            mon2scb_mbox.get(tr);
            tr.display("SCB");
            if (tr.iWrEn)
            begin
                if (tr.iWrData == tr.oRdData)
                begin
                    $display("-> PASS | expected data = %d == oRdData = %d", tr.iWrData, tr.oRdData);
                    pass_count++;
                end else
                begin
                    $display("-> Fail | expected data = %d != oRdData = %d", tr.iWrData, tr.oRdData);
                    fail_count++;
                end
            end else
            begin
                $display("-> oRdData = %d", tr.oRdData);
            end
            -> gen_next_event;
        end
    endtask

endclass //scoreboard

// Environment
class environment;
    generator   gen;
    driver      drv;
    monitor     mon;
    scoreboard  scb;

    mailbox #(transaction)  gen2drv_mbox;
    mailbox #(transaction)  mon2scb_mbox;
    event                   gen_next_event;

    function new(virtual reg_interface  reg_if);
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, reg_if);
        mon = new(mon2scb_mbox, reg_if);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction //new()

    task report();
        $display("=================================");
        $display("========== Test Report ==========");
        $display("=================================");
        $display("==       Total Test : %d       ==", gen.total_count);
        $display("==        Pass Test : %d       ==", scb.pass_count);
        $display("==        Fail Test : %d       ==", scb.fail_count);
        $display("=================================");
        $display("==       Testbench Finish      ==");
        $display("=================================");
    
    endtask

    task run();
        drv.reset();
        fork
            gen.run(10);
            drv.run();
            mon.run();
            scb.run();
        join_any
        #10
        report();
        $stop;
    endtask

endclass //environment


/***********************************************
// Testbench
***********************************************/	
module tb_Register_File();

    reg_interface   reg_interface_tb();
    environment     env; 

    
    Register_File   U_Memory    (
        .iClk       (reg_interface_tb.iClk),
        .iRst       (reg_interface_tb.iRst),
        .iWrEn      (reg_interface_tb.iWrEn),
        .iWrData    (reg_interface_tb.iWrData),
        .oRdData    (reg_interface_tb.oRdData)
    );

    /**********************************************
    // Clock define
    **********************************************/
    initial     reg_interface_tb.iClk   = 0;
    always  #5  reg_interface_tb.iClk   = ~reg_interface_tb.iClk;   // 100MHz clock


    /****************************************************
    // Intialization & function start !!!!!!!!!!!!!!!!!!!
    ****************************************************/
    initial
    begin
        env     = new(reg_interface_tb);
        env.run();
    end
endmodule
