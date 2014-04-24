//`define BIPUSH

module VIC1_TB();

    logic clock = 0;
    logic reset = 1;

    //| Generate clock
    always begin
        #1 clock <= ~clock;
    end

    //|
    Vic1 DUT(
        .clock(clock),
        .reset(reset)
    );

    initial begin
        $readmemb("MainMemory.hex", DUT.MainMemory);
        $readmemb("MicroprogramStore.hex", DUT.MicroprogramStore);

           reset = 1'b1;
        #4 reset = 1'b0;

        /*||    Microinstruction table (further reference on pg297)
        notes: microinstruction starts at the memory address in the opcode.

        Hex     Mnemonic            Meaning
        0x10    BIPUSH byte         Push byte onto stack
        0x59    DUP                 Copy top word on stack and push onto stack
        0xA7    GOTO offset         Unconditional branch
        0x60    IADD                Pop two words from stack; push their sum
        0x7E    IAND                Pop two words from stack; push Boolean AND
        0x99    IFEQ offset         Pop word from stack and branch if it is zero
        0x9B    IFLT offset         Pop word from stack and branch if it is less than zero
        0x9F    IF ICMPEQ offset    Pop two words from stack; branch if equal
        0x84    IINC varnum const   Add a constant to a local variable
        0x15    ILOAD varnum        Push local variable onto stack
        0xB6    INVOKEVIRTUAL disp  Invoke a method
        0x80    IOR                 Pop two words from stack; push Boolean OR
        0xAC    IRETURN             Return from method with integer value
        0x36    ISTORE varnum       Pop word from stack and store in local variable
        0x64    ISUB                Pop two words from stack; push their difference
        0x13    LDC W               index Push constant from constant pool onto stack
        0x00    NOP                 Do nothing
        0x57    POP                 Delete word on top of stackds
        0x5F    SWAP                Swap the two top words on the stack
        0xC4    WIDE                Prefix instruction; next instruction has a 16-bit index
        */

        //| alu control bits: {F0 F1 ENA ENB INVA INC}
        //| B_Control guide 0 = MDR 1 = PC, 2 = MBR,3=MBRU 4=SP, 5 = LV, 6 = CPP,7 = TOS, 8=OPC
        //| C_Control guide {H_ena, OPC_ena,TOS_ena,CPP_ena,LV_ena,SP_ena,PC_ena,MDR_ena,MAR_ena}
        //| Mem = {write, read , fetch}
        //|

        //| BIPUSH microinstruction (0x10)
        //| =======================================================================================================================================
        //|           N-ADDR JAM     ALU          C_CONTROL     MEM     B_CONTROL
        `ifdef BIPUSH
           DUT.MBR.DataContents = 32'd46;
           DUT.MIR = {10'd0, 3'b000, 8'b00000000, 9'b000000000, 3'b000, 4'd0};
        #4 DUT.MIR = {10'd0, 3'b000, 8'b00110101, 9'b000001001, 3'b000, 4'd4}; //increment SP for new value location, load into MAR
        #2 DUT.MIR = {10'd0, 3'b000, 8'b00110101, 9'b000000100, 3'b000, 4'd1}; //increment PC and load into PC register
        #2 DUT.MIR = {10'd0, 3'b000, 8'b00010100, 9'b001000010, 3'b100, 4'd3};
        `endif

        //| Main1 microinstruction (0x??)
        //| =======================================================================================================================================
        //|           N-ADDR JAM     ALU          C_CONTROL     MEM     B_CONTROL

    end
endmodule