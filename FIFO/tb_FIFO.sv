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
//
// Revision         : 2025/09/10    Add event driver -> monitor
//                                  Scoreboard using Queue
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
    // random stimulus
    rand bit            iPush;
    rand bit    [7:0]   iWrData;
    rand bit            iPop;

    // scoreboard
    bit         [7:0]   oRdData;
    bit                 oFull;
    bit                 oEmpty;

    constraint  iWrData_limit   {
        iWrData inside  {[0:100]};
    }

    constraint  write_chance    {
        iPush   dist    {0:/60, 1:/40}; // 0 <- 60%, 1 <- 40%
        iPop    dist    {0:/40, 1:/60}; // 0 <- 40%, 1 <- 60%
    }

    task display(string name_s);
        $display("%t : [%s] : iPush = %d, iPop = %d, iWrData = %d, oRdData = %d, oFull = %d, oEmpty = %d", 
        $time, name_s, iPush, iPop, iWrData, oRdData, oFull, oEmpty);
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
    mailbox #(transaction)  gen2drv_mbox;
    virtual fifo_interface  fifo_if;
    event                   mon_next_event;

    int i = 0;

    function new(
        mailbox #(transaction)  gen2drv_mbox,
        virtual fifo_interface  fifo_if,
        event                   mon_next_event
    );
        this.gen2drv_mbox   = gen2drv_mbox;
        this.fifo_if        = fifo_if;
        this.mon_next_event = mon_next_event;
    endfunction //new()

    task reset();
        fifo_if.iRst    = 1;
        fifo_if.iPush   = 0;
        fifo_if.iPop    = 0;
        fifo_if.iWrData = 0;
        repeat(2) @(posedge fifo_if.iClk);
        fifo_if.iRst     = 0;
        $display("[DRV] reset done!");
    endtask

    task run();
        forever
        begin
            gen2drv_mbox.get(tr);   // blocking when empty in mailbox
            fifo_if.iPush   = tr.iPush;
            fifo_if.iPop    = tr.iPop;
            fifo_if.iWrData = tr.iWrData;
            tr.display("Drv");
            @(posedge fifo_if.iClk); // wait for postive iClk
            -> mon_next_event;
        end
    endtask

endclass //driver

// Monitor
class monitor;
    transaction             tr;
    virtual fifo_interface  fifo_if;
    mailbox #(transaction)  mon2scb_mbox;
    event                   mon_next_event;

    function new(
        mailbox #(transaction)  mon2scb_mbox,
        virtual fifo_interface  fifo_if,
        event                   mon_next_event
    );
        this.mon2scb_mbox   = mon2scb_mbox;
        this.fifo_if        = fifo_if;  
        this.mon_next_event = mon_next_event;
    endfunction //new()

    task run();
        forever
        begin
            @(mon_next_event);
            tr          = new();
            tr.iPush    = fifo_if.iPush;
            tr.iPop     = fifo_if.iPop;
            tr.iWrData  = fifo_if.iWrData;
            tr.oRdData  = fifo_if.oRdData;
            tr.oFull    = fifo_if.oFull;
            tr.oEmpty   = fifo_if.oEmpty;
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
    // int wr_count    = 0;

    // buffer for test
    // byte unsigned sram[1000];  // golden_data, expected_data
    integer count = 0;
    logic   [7:0]   rFifo_Queue[$:15];  // Queue $ : non_count,
    logic   [7:0]   expected_data;

    function new(
        mailbox #(transaction)  mon2scb_mbox,
        event                   gen_next_event
    );
        this.mon2scb_mbox   = mon2scb_mbox;  
        this.gen_next_event = gen_next_event;
    endfunction //new()
    
    // Scoreboard Using Queue -- Mod code
    task run();
        forever
        begin
            count++;
            mon2scb_mbox.get(tr);
            tr.display("SCB");

            // Write
            if (tr.iPush)
            begin
                if (!tr.oFull)
                begin
                    rFifo_Queue.push_back(tr.iWrData);
                    $display("[SCB] : Data Store in Queue : iWrdata = %d, Size = %d", tr.iWrData, rFifo_Queue.size());
                end else
                    $display("[SCB] : Queue is Full!! : %d", rFifo_Queue.size());
            end

            // Read
            if (tr.iPop)
            begin
                if (!tr.oEmpty)
                begin
                    expected_data   = rFifo_Queue.pop_front();
                    if (expected_data == tr.oRdData)
                    begin
                        $display("[SCB] : Data Matched : %d", tr.oRdData);
                        pass_count++;
                    end else
                    begin
                        $display("[SCB] : Data Mismatched : %d, %d", tr.oRdData, expected_data);
                        fail_count++;
                    end
                end else
                    $display("[SCB] : Queue is Empty!!");
            end

            $display("Count = %d", count);
            $display(" ");
            -> gen_next_event;
        end

        $display("=======================");
        $display("Queue = %p", rFifo_Queue);
        $display("=======================");
    endtask

    // Existing scoreboard
    // task run();
    //     forever
    //     begin
    //         count ++;
    //         mon2scb_mbox.get(tr);
    //         tr.display("SCB");
    //         if (tr.iPush && !tr.oFull)
    //         begin
    //             sram[wr_count]  = tr.iWrData;
    //             wr_count++;
    //             $display("-> oRdData = %d", tr.oRdData);
    //         end

    //         if (tr.iPop && !tr.oEmpty)
    //         begin
    //             expected_data   = tr.oRdData;
                
    //             if (expected_data == sram[rd_count])
    //             begin
    //                 $display("-> PASS | expected data = %d == oRdData = %d", expected_data, sram[rd_count]);
    //                 pass_count++;
    //             end else
    //             begin
    //                 $display("-> Fail | expected data = %d != oRdData = %d", expected_data, sram[rd_count]);
    //                 fail_count++;
    //             end

    //             rd_count++;
    //         end
    //         $display("Count = %d", count);
    //         $display(" ");
    //         -> gen_next_event;
    //     end
    // endtask

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
    event                   mon_next_event;

    function new(
        virtual fifo_interface  fifo_if
        );
        gen2drv_mbox = new();
        mon2scb_mbox = new();

        gen = new(gen2drv_mbox, gen_next_event);
        drv = new(gen2drv_mbox, fifo_if, mon_next_event);
        mon = new(mon2scb_mbox, fifo_if, mon_next_event);
        scb = new(mon2scb_mbox, gen_next_event);
    endfunction //new()

    task report();
        $display("=================================");
        $display("========== Test Report ==========");
        $display("=================================");
        $display("==       Total Test : %4d      ==", gen.total_count);
        $display("==        Read Test : %4d      ==", (scb.pass_count + scb.fail_count));
        $display("==        Pass Test : %4d      ==", scb.pass_count);
        $display("==        Fail Test : %4d      ==", scb.fail_count);
        $display("=================================");
        $display("==       Testbench Finish      ==");
        $display("=================================");
    
    endtask

    task run();
        drv.reset();
        fork
            gen.run(1000);
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
