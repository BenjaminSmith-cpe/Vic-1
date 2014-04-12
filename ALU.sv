module ALU (
	input					[31:0]		A,
	input					[31:0]		B,
	input					[7:0]		Control,
	output		logic		[31:0]		Answer = 0,
	output		logic					N,
	output		logic					Z
);

	assign N = Answer[31];
	assign Z = (Answer == 32'd0) ? 1: 0;

	always_comb	begin
		//|Control is {F0 F1 ENA ENB INVA INC}
		case (Control)
				//| A
				8'b00011000: Answer <= A;

				//| B
				8'b00010100: Answer <= B;

				//| ~A
				8'b00011010: Answer <= ~A;

				//| ~B
				8'b00101100: Answer <= ~B;

				//| A + B
				8'b00111100: Answer <= A + B;

				//| A + B + 1
				8'b00111101: Answer <= A + B + 1;

				//| A + 1
				8'b00111001: Answer <= A + 1;

				//| B + 1
				8'b00110101: Answer <= B + 1;

				//| B - A
				8'b00111111: Answer <= B - A;

				//| B - 1
				8'b00110110: Answer <= B - 1;

				//| -A
				8'b00111011: Answer <= ~A + 31'd1;

				//|	A AND B
				8'b00001100: Answer <= A & B;

				//| A OR B
				8'b00011100: Answer <= A | B;

				//| 0
				8'b00010000: Answer <= 32'd0;

				//| 1
				8'b00110001: Answer <= 32'd1;

				//| -1
				8'b00110010: Answer <= ~32'd1 + 32'd1;
		endcase
	end
endmodule