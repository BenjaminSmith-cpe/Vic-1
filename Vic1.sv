module Vic1(
    input       clock,
    input       reset
);

    parameter PROGRAM_MEMORY_BASE = 0;
    parameter CONSTANT_MEMORY_BASE = 12;
    parameter VARIABLE_MEMORY_BASE = 80;

    //|
    //|
    //|
    //|======================================================================================================
    //| Control signals for B bus
    logic           H_ena,  H_OutEn;
    logic           OPC_ena,OPC_OutEn;
    logic           TOS_ena,TOS_OutEn;
    logic           CPP_ena,CPP_OutEn;
    logic           LV_ena, LV_OutEn;
    logic           SP_ena, SP_OutEn;
    logic           PC_ena, PC_OutEn;
    logic           MDR_ena,MDR_OutEn;
    logic           MAR_ena,MAR_OutEn;
    logic           MBR_ena,MBR_OutEn;

    //| outputs for registers, these are OR'd together to form the B_Bus
    logic   [31:0]  OPC_out;
    logic   [31:0]  TOS_out;
    logic   [31:0]  CPP_out;
    logic   [31:0]  LV_out ;
    logic   [31:0]  SP_out ;
    logic   [31:0]  PC_out, PC_SpecialOut;
    logic   [31:0]  MDR_out;
    logic   [31:0]  MAR_out, MAR_SpecialOut;
    logic   [31:0]  MBR_out;

    //| Micro Instruction Register components
    //|===================================================
    logic   [8:0]   ADDR;
    logic   [2:0]   JAM;
    logic   [7:0]   ALU;
    logic   [8:0]   C_CONTROL;
    logic   [2:0]   MEM;
    logic   [3:0]   B_CONTROL;     //0 = MDR, 1 = PC, 2 = MBR, 3=MBRU, 4=SP, 5 = LV, 6 = CPP, 7 = TOS, 8=OPC, 9-15 none
    logic   [35:0]  MIR, MIR_Next;
    assign  {ADDR, JAM, ALU, C_CONTROL, MEM, B_CONTROL} = MIR_Next; //concatenate into microinstruction register

    //JAM
    logic           JMPC;
    logic           JAMN;
    logic           JAMZ;
    //assign  JAM = {JMPC, JAMN, JAMZ};

    //ALU
    logic           SLL8;
    logic           SRA1;
    logic           F0;
    logic           F1;
    logic           ENA;
    logic           ENB;
    logic           INVA;
    logic           INC;
    assign  {SLL8, SRA1, F0, F1, ENA, ENB, INVA, INC} = ALU;

    //memory
    logic           WRITE;
    logic           READ;
    logic           FETCH;
    assign {WRITE, READ, FETCH} = MEM;

    //|Architectual components
    //|===================================================
    //| Busses
    logic   [31:0]   C_BUS;
    logic   [31:0]   B_BUS;
    logic   [31:0]   MemoryBus;

    //| ALU connections
    logic   [31:0]   ALU_HBUS;
    logic            N, N_Next;
    logic            Z, Z_Next;

    //| Something we need?
    logic   [7:0]    NEXT_ADDRESS = 0;

    //|Microprogram counter
    //|===================================================
    logic   [8:0]   MPC;
    assign  MPC[8] = (JAMZ && Z)||(JAMN && N)||NEXT_ADDRESS[7];

    //|Memories
    //|===================================================
    logic           [36:0]  MicroprogramStore[511:0];
    logic           [31:0]  MainMemory[255:0];

    //|
    //|
    //|Module Instantiations
    //|======================================================================================================
    ALU alu(ALU_HBUS,B_BUS,ALU,C_BUS,N_Next,Z_Next);

    assign {H_ena, OPC_ena,TOS_ena,CPP_ena,LV_ena,SP_ena,PC_ena,MDR_ena,MAR_ena} = C_CONTROL; //trigger individual registers based on C_CONTROL bus

    Register #(32'd0)H   (clock, C_BUS, H_ena  , 1'b1     , ALU_HBUS);
    Register #(32'd0)OPC (clock, C_BUS, OPC_ena, OPC_OutEn, OPC_out);
    Register #(32'd0)TOS (clock, C_BUS, TOS_ena, TOS_OutEn, TOS_out);
    Register #(32'd0)CPP (clock, C_BUS, CPP_ena, CPP_OutEn, CPP_out);
    Register #(32'd0)LV  (clock, C_BUS, LV_ena , LV_OutEn , LV_out );
    Register #(32'd0)SP  (clock, C_BUS, SP_ena , SP_OutEn , SP_out );
    Register #(32'd0)PC  (clock, C_BUS, PC_ena , PC_OutEn , PC_out , PC_SpecialOut);
    Register #(32'd4)MAR (clock, C_BUS, MAR_ena, MAR_OutEn, MAR_out, MAR_SpecialOut);
    Register #(32'd0)MBR (clock, C_BUS, MBR_ena, MBR_OutEn, MBR_out);

    //| gets special treament because need to read ram
    //| note: using the OR reduction operator "|" it ORs all the bits in a bus
    Register MDR (
    .clock(clock),

    .InEnable(|MEM|MDR_ena),
    .DataIn((READ)?MemoryBus:C_BUS),

    .OutEnable(MDR_OutEn),
    .DataOut(MDR_out)
);

    assign B_BUS = |OPC_out|TOS_out|CPP_out|LV_out |SP_out |PC_out |MDR_out|MAR_out|MBR_out; //logical or is the same as multiple sources driving bus with enable/HiZ outputs

    //|
    //|
    //| Microcode testbench
    //|======================================================================================================
    initial begin
        $readmemb("MainMemory.hex", MainMemory);
        $readmemb("MicroprogramStore.hex", MicroprogramStore);

        //| wait for tb to release reset
        #10 ;
        //| alu control bits: {F0 F1 ENA ENB INVA INC}
        //| B_Control guide 0 = MDR 1 = PC, 2 = MBR,3=MBRU 4=SP, 5 = LV, 6 = CPP,7 = TOS, 8=OPC
        //| MemConrol = write, read , fetch
        //|
        //|               ADDR      JAM ALU      C_CONTROL MEM B_CONTROL
        #4 MIR_Next = 36'b000000000_000_00000000_000000000_000_0000;
        #4 MIR_Next = 36'b000000000_000_00111001_100000000_000_0000; //H 0++
        #4 MIR_Next = 36'b000000000_000_00111001_000000010_000_0000; //MDR 0++
        #4 MIR_Next = 36'b000000000_000_00111100_010000000_000_0000; //H + MDR => OPC
        #4 MIR_Next = 36'b000000000_000_00000000_010000000_100_0000; //OPC => Memory
    end


    //|
    //|
    //| register control logic
    //|======================================================================================================
    always_ff @(posedge clock) begin
        //| enable register's output that requires the use of the B bus
        MDR_OutEn <= (B_CONTROL == 4'd0)?1'b1:1'b0;
        PC_OutEn  <= (B_CONTROL == 4'd1)?1'b1:1'b0;
        MBR_OutEn <= (B_CONTROL == 4'd2)?1'b1:1'b0;
        //MBRU_OutEn<= (B_CONTROL == 4'd3)?1'b1:1'b0;
        SP_OutEn  <= (B_CONTROL == 4'd4)?1'b1:1'b0;
        LV_OutEn  <= (B_CONTROL == 4'd5)?1'b1:1'b0;
        CPP_OutEn <= (B_CONTROL == 4'd6)?1'b1:1'b0;
        TOS_OutEn <= (B_CONTROL == 4'd7)?1'b1:1'b0;
        OPC_OutEn <= (B_CONTROL == 4'd8)?1'b1:1'b0;

        MIR <= MIR_Next;
    end

    //|
    //|
    //| Memory control logic
    //|======================================================================================================
    always_ff @(posedge clock) begin
        //| full 32-bit write to memory
        if(WRITE) begin
           MainMemory[MAR_SpecialOut] <= MDR_out;
        end

        //| full 32-bit read form memory
        if(READ) begin
            MemoryBus = MainMemory[MAR_SpecialOut];
        end

        //| 8-bit read form memory for program counter
        if(FETCH) begin
            MemoryBus = MainMemory[PC_SpecialOut];
        end
    end
endmodule