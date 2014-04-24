module Vic1(
    input       clock,
    input       reset
);

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
    logic                   MBRU_OutEn;

    //| outputs for registers, these are OR'd together to form the B_Bus
    logic   [31:0]  OPC_out;
    logic   [31:0]  TOS_out;
    logic   [31:0]  CPP_out;
    logic   [31:0]  LV_out ;
    logic   [31:0]  SP_out ;
    logic   [31:0]  PC_out,  PC_SpecialOut; //special out is a workaround so memory can
    logic   [31:0]  MDR_out;
    logic   [31:0]  MAR_out, MAR_SpecialOut;
    logic   [31:0]  MBR_out;
    logic   [7:0]   MBRU_out;

    assign MBRU_out = (MBRU_OutEn)?MBR.DataContents[7:0]:8'b0;

    //| Micro Instruction Register components
    //|===================================================
    logic   [8:0]   NEXT_ADDRESS;
    logic   [2:0]   JAM;
    logic   [7:0]   ALU;
    logic   [8:0]   C_CONTROL;
    logic   [2:0]   MEM;
    logic   [3:0]   B_CONTROL;     //0 = MDR, 1 = PC, 2 = MBR, 3=MBRU, 4=SP, 5 = LV, 6 = CPP, 7 = TOS, 8=OPC, 9-15 none
    logic   [35:0]  MIR;
    assign  {NEXT_ADDRESS, JAM, ALU, C_CONTROL, MEM, B_CONTROL} = MIR; //concatenate into microinstruction register

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

    //|Microprogram counter
    //|===================================================
    logic   [8:0]   MPC, MPC_NEXT;
    assign  MPC_NEXT[8] = (JAMZ && Z)||(JAMN && N)||NEXT_ADDRESS[7];

    //|Memories
    //|===================================================
    logic           [36:0]  MicroprogramStore[511:0];
    logic           [31:0]  MainMemory       [255:0];

    //|
    //|
    //|Module Instantiations
    //|======================================================================================================
    ALU alu(ALU_HBUS,B_BUS,ALU,C_BUS,N_Next,Z_Next);

    assign {H_ena, OPC_ena,TOS_ena,CPP_ena,LV_ena,SP_ena,PC_ena,MDR_ena,MAR_ena} = C_CONTROL; //trigger individual registers based on C_CONTROL bus

    Register #(32'd0  )H   (clock, C_BUS, H_ena  , 1'b1     , ALU_HBUS);
    Register #(32'd0  )OPC (clock, C_BUS, OPC_ena, OPC_OutEn, OPC_out);
    Register #(32'd0  )TOS (clock, C_BUS, TOS_ena, TOS_OutEn, TOS_out);
    Register #(32'd0  )CPP (clock, C_BUS, CPP_ena, CPP_OutEn, CPP_out);
    Register #(32'd100)LV  (clock, C_BUS, LV_ena , LV_OutEn , LV_out );
    Register #(32'd150)SP  (clock, C_BUS, SP_ena , SP_OutEn , SP_out );
    Register #(32'd0  )PC  (clock, C_BUS, PC_ena , PC_OutEn , PC_out , PC_SpecialOut);
    Register #(32'd4  )MAR (clock, C_BUS, MAR_ena, MAR_OutEn, MAR_out, MAR_SpecialOut);
    Register #(32'd0  )MBR (clock, C_BUS, MBR_ena, MBR_OutEn, MBR_out, MBR_SpecialOut);

    //| gets special treament because of the constraints on RAM archetecture
    //| note: using the OR reduction operator "|" it ORs all the bits in a bus
    Register MDR (
    .clock(clock),

    .InEnable(READ|MDR_ena),
    .DataIn((READ)?MemoryBus:C_BUS),

    .OutEnable(MDR_OutEn),
    .DataOut(MDR_out),
    .AlwaysOnDataOut(MDR_SpecialOut)
);

    assign B_BUS = |OPC_out|TOS_out|CPP_out|LV_out |SP_out |PC_out |MDR_out|MAR_out|MBR_out|MBRU_out; //logical or is the same as multiple sources driving bus with enable/HiZ outputs

    //|
    //|
    //| register control logic
    //|======================================================================================================
    always_comb begin//@(negedge clock) begin
        //| enable register's output that requires the use of the B bus
        MDR_OutEn <= (B_CONTROL == 4'd0)?1'b1:1'b0;
        PC_OutEn  <= (B_CONTROL == 4'd1)?1'b1:1'b0;
        MBR_OutEn <= (B_CONTROL == 4'd2)?1'b1:1'b0;
        MBRU_OutEn<= (B_CONTROL == 4'd3)?1'b1:1'b0;
        SP_OutEn  <= (B_CONTROL == 4'd4)?1'b1:1'b0;
        LV_OutEn  <= (B_CONTROL == 4'd5)?1'b1:1'b0;
        CPP_OutEn <= (B_CONTROL == 4'd6)?1'b1:1'b0;
        TOS_OutEn <= (B_CONTROL == 4'd7)?1'b1:1'b0;
        OPC_OutEn <= (B_CONTROL == 4'd8)?1'b1:1'b0;
    end

    //always_ff @(negedge clock) begin
    //    MIR <= MicroprogramStore[MPC++];
    //end

    //|
    //|
    //| Memory control logic
    //|======================================================================================================
    always_ff @(posedge clock) begin
        //| full 32-bit write to memory
        if(WRITE) begin
           MainMemory[MAR_SpecialOut] <= MDR_SpecialOut;
        end

        //| full 32-bit read form memory
        if(READ) begin
            MemoryBus = MainMemory[MAR_SpecialOut];
        end

        //| 8-bit read form memory for program counter
        if(FETCH) begin
            MBR.DataContents = MainMemory[PC_SpecialOut];
        end
    end
endmodule