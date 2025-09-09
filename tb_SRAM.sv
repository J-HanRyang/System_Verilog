`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/09
// Design Name      : Syvel_Verification
// Module Name      : SRAM
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Testbench for SRAM
//////////////////////////////////////////////////////////////////////////////////


/***********************************************
// Interface
***********************************************/
interface sram_interface;
    logic           iClk;
    logic           iRst;
    logic   [3:0]   iWrAddr;
    logic   [7:0]   iWrData;
    logic           iWrEn;
    logic   [7:0]   oRdData;
endinterface //sram_interface


/***********************************************
// Class
***********************************************/
// Transation
class transaction;
    rand bit    [3:0]   iWrAddr;
    rand bit    [7:0]   iWrData;
    rand bit            iWrEn;

    bit         [7:0]   oRdData;

    task display(string name_s);
        $display("%t : [%s] : iWrEn = %d, iWrAddr %d, iWrData = %d, oRdData = %d", $time, name_s, iWrEn, iWrAddr, iWrData, oRdData);
    endtask
endclass //transaction

// Generator
class generator;
    transaction             tr;
    mailbox #(transaction)  gen2drv_mbox;
    event                   gen_next_event;

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
            tr.display("Gen");
            // Receive event
            @(gen_next_event);
        end
    endtask
endclass //generator

// Driver
class driver;
    transaction             tr;
    virtual sram_interface  sram_if;
    mailbox #(transaction)  gen2drv_mbox;

    int i = 0;

    function new(
        mailbox #(transaction)  gen2drv_mbox,
        virtual sram_interface  sram_if
    );
        this.sram_if        = sram_if;
        this.gen2drv_mbox   = gen2drv_mbox;
    endfunction //new()

    task reset();
            sram_if.iRst    = 1;
            sram_if.iWrEn   = 0;
            sram_if.iWrAddr = 0;
        for (i = 0; i < 16; i++)
        begin
            sram_if.iWrEn   = 1;
            sram_if.iWrAddr = i;
            sram_if.iWrData = 0;
            @(posedge sram_if.iClk);
        end
            sram_if.iWrAddr = 0;
            sram_if.iWrEn   = 0;
        #10 
        sram_if.iRst     = 0;
    endtask

    task run();
        forever
        begin
            gen2drv_mbox.get(tr);   // blocking when empty in mailbox
            sram_if.iWrEn   = tr.iWrEn;
            sram_if.iWrAddr = tr.iWrAddr;
            sram_if.iWrData = tr.iWrData;
            tr.display("Drv");
            @(negedge sram_if.iClk); // wait for negative iClk
        end
    endtask

endclass //driver

// Monitor
class monitor;
    transaction             tr;
    virtual sram_interface  sram_if;
    mailbox #(transaction)  mon2scb_mbox;

    function new(
        mailbox #(transaction)  mon2scb_mbox,
        virtual sram_interface  sram_if
    );
        this.mon2scb_mbox   = mon2scb_mbox;
        this.sram_if        = sram_if;  
    endfunction //new()

    task run();
        forever
        begin
            // generate transaction
            tr  = new();
            @(posedge sram_if.iClk);
            // compare for register logic output with input
            #1
            tr.iWrEn    = sram_if.iWrEn;
            tr.iWrAddr  = sram_if.iWrAddr;
            tr.iWrData  = sram_if.iWrData;
            tr.oRdData  = sram_if.oRdData;
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

    // buffer for SRAM[0:15]
    byte sram[16];  // golden_data, expected_data

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
                sram[tr.iWrAddr] = tr.iWrData;
                $display("-> Addr[%d] oRdData = %d", tr.iWrAddr, tr.oRdData);
            end else
            begin
                if (sram[tr.iWrAddr] == tr.oRdData)
                begin
                    $display("-> PASS | Addr[%d] expected data = %d == oRdData = %d", tr.iWrAddr, tr.iWrData, tr.oRdData);
                    pass_count++;
                end else
                begin
                    $display("-> Fail | Addr[%d] expected data = %d != oRdData = %d", tr.iWrAddr, tr.iWrData, tr.oRdData);
                    fail_count++;
                end
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

    function new(
        virtual sram_interface  sram_if
        );
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, sram_if);
        mon = new(mon2scb_mbox, sram_if);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction //new()

    task report();
        $display("=================================");
        $display("========== Test Report ==========");
        $display("=================================");
        $display("==       Total Test : %4d      ==", gen.total_count);
        $display("==        Pass Test : %4d      ==", scb.pass_count);
        $display("==        Fail Test : %4d      ==", scb.fail_count);
        $display("=================================");
        $display("==       Testbench Finish      ==");
        $display("=================================");
    
    endtask

    task run();
        drv.reset();
        fork
            gen.run(100);
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
module tb_SRAM();

    sram_interface  sram_interface_tb();
    environment     env;

    SRAM    U_SRAM  (
        .iClk       (sram_interface_tb.iClk),
        .iRst       (sram_interface_tb.iRst),
        .iWrAddr    (sram_interface_tb.iWrAddr),
        .iWrData    (sram_interface_tb.iWrData),
        .iWrEn      (sram_interface_tb.iWrEn),
        .oRdData    (sram_interface_tb.oRdData)
    );

    /**********************************************
    // Clock define
    **********************************************/
    initial     sram_interface_tb.iClk  = 0;
    always  #5  sram_interface_tb.iClk  = ~sram_interface_tb.iClk;   // 100MHz clock


    /****************************************************
    // Intialization & function start !!!!!!!!!!!!!!!!!!!
    ****************************************************/
    initial
    begin
        env     = new(sram_interface_tb);
        env.run();
    end
endmodule