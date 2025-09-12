`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/11
// Design Name      : UART_FIFO
// Module Name      : tb_UART_FIFO
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : Testbench for UART_FIFO
//
// Revision 	    : 
//////////////////////////////////////////////////////////////////////////////////


/***********************************************
// Interface
***********************************************/
interface uart_interface;
    logic   iClk;
    logic   iRst;
    logic   iRx;
    logic   oTx;
endinterface //uart_interface


/***********************************************
// Class
***********************************************/
// Transaction
class transaction;
    // random stimulus
    rand bit    [7:0]   iSend_Data;

    // scoreboard
    bit         [7:0]   oReceive_Data;

    task display(string name_s);
        $display("%t : [%s] : iSend_Data = %d, oReceive_Data = %d", $time, name_s, iSend_Data, oReceive_Data);
    endtask
endclass //transaction

// Generator
class generator;
    transaction             tr;
    mailbox #(transaction)  gen2drv_mbox;
    mailbox #(transaction)  gen2scb_mbox;
    // event                   gen_next_event;

    parameter   B_TICK  =   (100_000_000 / 9600) * 10;

    int total_count = 0;

    function new(
        mailbox #(transaction)  gen2drv_mbox,
        mailbox #(transaction)  gen2scb_mbox
        // event                   gen_next_event
    );
        this.gen2drv_mbox   = gen2drv_mbox;
        this.gen2scb_mbox   = gen2scb_mbox;
        // this.gen_next_event = gen_next_event;
    endfunction //new()

    task run(int count);
        repeat(count)
        begin
            total_count++;
            tr  = new();
            assert(tr.randomize())
            else $display("[GEN] tr.randomize() error!!!!!");
            gen2drv_mbox.put(tr);
            gen2scb_mbox.put(tr);
            // @gen_next_event;
            #(B_TICK*10);
            tr.display("GEN");
        end
    endtask

endclass //generator

// Driver
class driver;
    transaction             tr;
    mailbox #(transaction)  gen2drv_mbox;
    virtual uart_interface  uart_if;
    
    parameter   B_TICK  =   (100_000_000 / 9600) * 10;

    function new(
        mailbox #(transaction)  gen2drv_mbox,
        virtual uart_interface  uart_if
    );
        this.gen2drv_mbox   = gen2drv_mbox;
        this.uart_if        = uart_if;
    endfunction //new()

    task reset();
        uart_if.iRst    = 1;
        uart_if.iRx     = 1;
        repeat(2) @(posedge uart_if.iClk);
        uart_if.iRst    = 0;
        $display("[DRV] reset done!");
    endtask

    task run();
        forever
        begin
            gen2drv_mbox.get(tr);

            // Start
            uart_if.iRx = 0;
            #B_TICK;

            // Data
            for (int i = 0; i < 8; i++)
            begin
                uart_if.iRx = tr.iSend_Data[i];
                #B_TICK;
            end

            // Stop
            uart_if.iRx = 1;
            #B_TICK;

            tr.display("DRV");
            @(posedge uart_if.iClk);
        end
    endtask

endclass //driver

// Monitor
class monitor;
    transaction             tr;
    mailbox #(transaction)  mon2scb_mbox;
    virtual uart_interface  uart_if;

    parameter   B_TICK  =   (100_000_000 / 9600) * 10;

    function new(
        mailbox #(transaction)  mon2scb_mbox,
        virtual uart_interface  uart_if
    );
        this.mon2scb_mbox   = mon2scb_mbox;
        this.uart_if        = uart_if;
    endfunction //new()

    task run();
        forever
        begin
            tr      = new();
            @(negedge uart_if.oTx);

            // Start
            #(B_TICK/2);
            
            // Data
            for (int i = 0; i < 8; i++)
            begin
                #B_TICK;
                tr.oReceive_Data[i] = uart_if.oTx;
            end

            // Stop
            #B_TICK;
            if (uart_if.oTx == 1)
                $display("Send Done!!");
            else
                $display("Send Error!!");

            tr.display("MON");
            mon2scb_mbox.put(tr);
        end
    endtask

endclass //monitor

// Scoreboard
class scoreboard;
    transaction             tr_expected;
    transaction             tr_actual;
    mailbox #(transaction)  gen2scb_mbox;
    mailbox #(transaction)  mon2scb_mbox;
    // event                   gen_next_event;

    int rCount  = 0;
    int rPass   = 0;
    int rFail   = 0;

    function new(
        mailbox #(transaction)  gen2scb_mbox,
        mailbox #(transaction)  mon2scb_mbox
        // event                   gen_next_event
    );
        this.gen2scb_mbox   = gen2scb_mbox;
        this.mon2scb_mbox   = mon2scb_mbox;
        // this.gen_next_event = gen_next_event;
    endfunction //new()

    task run();
        forever
        begin
            logic   [7:0]   rExpected_Data;
            logic   [7:0]   rActual_Data;

            gen2scb_mbox.get(tr_expected);
            mon2scb_mbox.get(tr_actual);

            rExpected_Data  = tr_expected.iSend_Data;
            rActual_Data    = tr_actual.oReceive_Data;
            tr_actual.display("SCB");

            if(rActual_Data == rExpected_Data)
            begin
                $display("Data Receive Success!!");
                $display("Send_Data = %d, Receive_Data = %d", rExpected_Data, rActual_Data);
                rPass++;
            end else
            begin
                $display("Data Receive Fail!!");
                $display("Send_Data = %d, Receive_Data = %d", rExpected_Data, rActual_Data);
                rFail++;
            end

            $display("=======================");
            $display("Count = %d", rCount+1);
            $display("=======================");
            $display(" ");
            rCount++;
            // -> gen_next_event;
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
    mailbox #(transaction)  gen2scb_mbox;
    mailbox #(transaction)  mon2scb_mbox;
    // event                   gen_next_event;

    function new(
        virtual uart_interface  uart_if
    );
        gen2drv_mbox = new();
        gen2scb_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen2scb_mbox/*, gen_next_event*/);
        drv = new(gen2drv_mbox, uart_if);
        mon = new(mon2scb_mbox, uart_if);
        scb = new(gen2scb_mbox, mon2scb_mbox/*, gen_next_event*/);
    endfunction //new()

    task report();
        $display("=================================");
        $display("========== Test Report ==========");
        $display("=================================");
        $display("==       Total Test : %4d      ==", gen.total_count);
        $display("==        Pass Test : %4d      ==", scb.rPass);
        $display("==        Fail Test : %4d      ==", scb.rFail);
        $display("=================================");
        $display("==       Testbench Finish      ==");
        $display("=================================");
    endtask

    task run();
        int TEST_COUNT = 10;
        drv.reset();
        fork
            gen.run(TEST_COUNT);
            drv.run();
            mon.run();
            scb.run();
        join_none

        wait(gen.total_count    == TEST_COUNT);
        wait(scb.rCount         == TEST_COUNT);
        #1000
        report();
        $finish;
    endtask
endclass //environment


/***********************************************
// Testbench
***********************************************/	
module tb_UART_FIFO();

    uart_interface  uart_if_tb();
    environment     env;

    UART_FIFO   U_UART_FIFO (
        .iClk   (uart_if_tb.iClk),
        .iRst   (uart_if_tb.iRst),
        .iRx    (uart_if_tb.iRx),
        .oTx    (uart_if_tb.oTx)
    );


    /**********************************************
    // Clock define
    **********************************************/
    initial     uart_if_tb.iClk  = 0;
    always  #5  uart_if_tb.iClk  = ~uart_if_tb.iClk;   // 100MHz clock


    /****************************************************
    // Intialization & function start !!!!!!!!!!!!!!!!!!!
    ****************************************************/
    initial
    begin
        env = new(uart_if_tb);
        env.run();
    end

endmodule