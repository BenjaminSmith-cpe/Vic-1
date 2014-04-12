module VIC1_TB();

    logic clock = 0;
    logic reset = 1;

    //| Generate clock
    always #1 clock <= ~clock;

    //|
    Vic1 DUT(
        .clock(clock),
        .reset(reset)
    );

    initial begin
            reset = 1'b1;
        #10 reset = 1'b0;
    end
endmodule