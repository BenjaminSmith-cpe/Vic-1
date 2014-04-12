module Register(
    input                   clock,
    input           [31:0]  DataIn,
    input                   InEnable,
    input                   OutEnable,

    output  logic   [31:0]  DataOut,

    output  logic   [31:0]  AlwaysOnDataOut
);

    parameter DataContentsInitial = 0;

    logic           [31:0]  DataContents = DataContentsInitial;

    assign AlwaysOnDataOut = DataContents;

    always_ff @(posedge clock) begin //| possible problem here, data will always take two clock cycles to pass though register.
        if(InEnable ) DataContents <= DataIn;
        if(OutEnable) DataOut <= DataContents;
        else DataOut <= 32'b0;
    end
endmodule