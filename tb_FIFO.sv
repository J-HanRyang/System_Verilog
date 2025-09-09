`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/09
// Design Name      : Syvel_Verification
// Module Name      : FIFO
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Testbench for FIFO
//////////////////////////////////////////////////////////////////////////////////


/***********************************************
// Interface
***********************************************/
interface fifo_interface;
    logic           iClk;
    logic           iRst;
    logic           iPush;
    logic   [7:0]   iWrData;
    logic           iPop;
    logic   [7:0]   oRdData;
    logic           oFull;
    logic           oEmpty;
endinterface //fifo_interface


/***********************************************
// Class
***********************************************/
// Transation
class transaction;
    rand bit            iPush;
    rand bit    [7:0]   iWrData;
    rand bit            iPop;

    bit         [7:0]   oRdData;
    bit                 oFull;
    bit                 oEmpty;

    task display(string name_s);
        $display("%t : [%s] : iWrData = %d, oRdData = %d", $time, name_s, iWrData, oRdData);
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
    virtual fifo_interface  fifo_if;
    mailbox #(transaction)  gen2drv_mbox;

    int i = 0;

    function new(
        mailbox #(transaction)  gen2drv_mbox,
        virtual fifo_interface  fifo_if
    );
        this.fifo_if        = fifo_if;
        this.gen2drv_mbox   = gen2drv_mbox;
    endfunction //new()

    task reset();
        fifo_if.iRst    = 1;
        fifo_if.iPush   = 0;
        fifo_if.iPop    = 0;
        fifo_if.iWrData = 0;
        #10 
        fifo_if.iRst     = 0;
    endtask

    task run();
        forever
        begin
            gen2drv_mbox.get(tr);   // blocking when empty in mailbox
            fifo_if.iPush   = tr.iPush;
            fifo_if.iPop    = tr.iPop;
            fifo_if.iWrData = tr.iWrData;
            tr.display("Drv");
            @(negedge fifo_if.iClk); // wait for negative iClk
        end
    endtask

endclass //driver

// Monitor
class monitor;
    transaction             tr;
    virtual fifo_interface  fifo_if;
    mailbox #(transaction)  mon2scb_mbox;

    function new(
        mailbox #(transaction)  mon2scb_mbox,
        virtual fifo_interface  fifo_if
    );
        this.mon2scb_mbox   = mon2scb_mbox;
        this.fifo_if        = fifo_if;  
    endfunction //new()

    task run();
        forever
        begin
            // generate transaction
            tr  = new();
            @(posedge fifo_if.iClk);
            // compare for register logic output with input
            #1
            tr.iPush    = fifo_if.iPush;
            tr.iPop     = fifo_if.iPop;
            tr.iWrData  = fifo_if.iWrData;
            tr.oRdData  = fifo_if.oRdData;
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

    int pass_count  = 0;
    int fail_count  = 0;
    int wr_count    = 0;
    int rd_count    = 0;

    // buffer for test
    byte wr_ram[100];  // golden_data, expected_data
    byte rd_ram[100];

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
            if          (tr.iPush)
            begin
                wr_ram[wr_count]    = tr.iWrData;
                wr_count++;
            end else if (tr.iPop)
            begin
                rd_ram[rd_count]    = tr.oRdData;
                rd_count++;
                $display("-> oRdData = %d", tr.oRdData);
            end

            if (rd_ram[rd_count] == wr_ram[rd_count])
            begin
                $display("-> PASS | expected data = %d == oRdData = %d", tr.iWrData, tr.oRdData);
                pass_count++;
            end else
            begin
                $display("-> Fail | expected data = %d != oRdData = %d", tr.iWrData, tr.oRdData);
                fail_count++;
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
        virtual fifo_interface  fifo_if
        );
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, fifo_if);
        mon = new(mon2scb_mbox, fifo_if);
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
module tb_FIFO();

    fifo_interface  fifo_interface_tb();
    environment     env;

    FIFO    U_FIFO  (
        .iClk       (fifo_interface_tb.iClk),
        .iRst       (fifo_interface_tb.iRst),
        .iPush      (fifo_interface_tb.iPush),
        .iWrData    (fifo_interface_tb.iWrData),
        .iPop       (fifo_interface_tb.iPop),
        .oRdData    (fifo_interface_tb.oRdData),
        .oFull      (fifo_interface_tb.oFull),
        .oEmpty     (fifo_interface_tb.oEmpty)
    );

    /**********************************************
    // Clock define
    **********************************************/
    initial     fifo_interface_tb.iClk  = 0;
    always  #5  fifo_interface_tb.iClk  = ~fifo_interface_tb.iClk;   // 100MHz clock


    /****************************************************
    // Intialization & function start !!!!!!!!!!!!!!!!!!!
    ****************************************************/
    initial
    begin
        env = new(fifo_interface_tb);
        env.run();
    end

endmodule