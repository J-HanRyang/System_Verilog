`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company          : Semicon_Academi
// Engineer         : Jiyun_Han
// 
// Create Date	    : 2025/09/08
// Design Name      : Syvel_Verification
// Module Name      : tb_ADD_SUB
// Target Devices   : Basys3
// Tool Versions    : 2020.2
// Description      : testbench for ADD_SUB
//////////////////////////////////////////////////////////////////////////////////


/***********************************************
//  Interface
***********************************************/
interface ADD_SUB_intf;
    logic   [7:0]   iA;
    logic   [7:0]   iB;
    logic           iMode;
    logic   [7:0]   oSum;
    logic           oCarry;
endinterface // ADD_SUB_intf


/***********************************************
//  Class
***********************************************/
// stimulus list
class transaction;
    rand bit    [7:0]   iA;
    rand bit    [7:0]   iB;
    rand bit            iMode;
endclass //transaction


// generator : stimulus 생성 객체
class generator;
    // transaction handler : tr
    transaction tr;

    // gen2drv_mbox는 genetor에서 driver로 보내는 통신 box(buffer, 객체)
    mailbox #(transaction /* transaction datatype */) gen2drv_mbox;

    function new(mailbox #(transaction) gen2drv_mbox_arg);
        this.gen2drv_mbox = gen2drv_mbox_arg;   // 외부에서 받아와서 내부에 연결
    endfunction //new()

    task run(int count);
        repeat(count)
        begin
            tr = new();             // class transaction tr을 동적 할당
            tr.randomize();         // transaction내의 rand 키워드를 가진 변소는 random값을 생성시켜주는 멤버함달
            gen2drv_mbox.put(tr);   // generator가 transatcion tr로 동적 할당한 후 mail_box를 통해 driver에게 전달
        end
    endtask

endclass //generator

// Driver
class driver;
    // ADD_SUB_intf 인터페이스 객체를 ADD_SUB_if 이름으로 가상으로 인스턴스
    virtual ADD_SUB_intf    ADD_SUB_if;
    mailbox #(transaction) gen2drv_mbox;

    function new(
        mailbox #(transaction)  gen2drv_mbox_arg,
        virtual ADD_SUB_intf    ADD_SUB_if_drv_arg
    );
        this.gen2drv_mbox   = gen2drv_mbox_arg;
        this.ADD_SUB_if     = ADD_SUB_if_drv_arg;
    endfunction //new()

    task reset();
        ADD_SUB_if.iA       = 0;
        ADD_SUB_if.iB       = 0;
        ADD_SUB_if.iMode    = 0;
        #10;
    endtask

    task run();
        forever 
        begin    
            // generator에서 동적할당된 transaction tr을 받아오기 위한 handler
            transaction tr_driver;
            gen2drv_mbox.get(tr_driver);
            ADD_SUB_if.iA       = tr_driver.iA;
            ADD_SUB_if.iB       = tr_driver.iB;
            ADD_SUB_if.iMode    = tr_driver.iMode;
            #10;
        end
    endtask
endclass //driver

// Environment : 전체 test 환경을 관리
class environment;
    // handle 성성
    generator   gen;
    driver      drv;
    mailbox     #(transaction) gen2drv_mbox;

    function new(virtual ADD_SUB_intf ADD_SUB_if_env_arg);
        gen2drv_mbox = new();
        gen = new(gen2drv_mbox);
        drv = new(gen2drv_mbox, ADD_SUB_if_env_arg);
    endfunction //new()

    task run();
        drv.reset();
        fork
            gen.run(10);
            drv.run();
        join_any    // join_any : 하나가 끝나면 끝.
        #50 $stop;
    endtask
endclass //environment


/***********************************************
//  Testbench
***********************************************/
module tb_ADD_SUB();
    // Handler of class environment 
    environment     env;
    ADD_SUB_intf    ADD_SUB_interface();

    ADD_SUB U_ADD_SUB   (
        .iA     (ADD_SUB_interface.iA),
        .iB     (ADD_SUB_interface.iB),
        .iMode  (ADD_SUB_interface.iMode),
        .oSum   (ADD_SUB_interface.oSum),
        .oCarry (ADD_SUB_interface.oCarry)
    );

    initial
    begin
        // instance environment class
        env = new(ADD_SUB_interface);
        // environment class run
        env.run();
    end

endmodule
