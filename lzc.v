module LZC #(
	parameter width = `WIDTH,
	parameter word = `WORD
	//parameter cycle = `CYCLE
)(
	input wire CLK,
	input wire RST_N,
	input wire IVALID,
	input wire [width-1:0] DATA,
	input wire MODE,
	output reg [8:0] ZEROS,   // max zeros=256 (16 by 16)
	output reg OVALID
);

wire cumulative, finish; 
reg found, final, notzero, already_out, early_terminal;
reg [1:0] state, state_next;

reg [word-1:0] round;

reg [8:0] counter, each_byte_zeros;
parameter [1:0] IDLE = 2'b00;
parameter [1:0] ACCU = 2'b01;
parameter [1:0] FINISH = 2'b10;
parameter [1:0] S0 = 2'b11;

//assign cumulative = (IVALID && !found) ? 1'b1:0;
//assign finish = ((MODE && found) || (MODE && !IVALID) || (!MODE && round == 4 )) ? 1'b1:0;

// Find zeros of each input byte
always @* begin	
	if (!RST_N) begin
		each_byte_zeros = 0;
		notzero = 0;
	end else if (DATA[7] == 1'b1) begin
		each_byte_zeros = 0;
		//notzero = IVALID ? 1'b1:0;
		if (IVALID) begin
			notzero = 1'b1;
		end
	end else if (DATA[6] == 1'b1) begin
		each_byte_zeros = 1;
		//notzero = IVALID ? 1'b1:0;
		if (IVALID) begin
			notzero = 1'b1;
		end
	end else if (DATA[5] == 1'b1) begin
		each_byte_zeros = 2;
		//notzero = IVALID ? 1'b1:0;
		if (IVALID) begin
			notzero = 1'b1;
		end
	end else if (DATA[4] == 1'b1) begin
		each_byte_zeros = 3;
		//notzero = IVALID ? 1'b1:0;
		if (IVALID) begin
			notzero = 1'b1;
		end
	end else if (DATA[3] == 1'b1) begin
		each_byte_zeros = 4;
		//notzero = IVALID ? 1'b1:0;
		if (IVALID) begin
			notzero = 1'b1;
		end
	end else if (DATA[2] == 1'b1) begin
		each_byte_zeros = 5;
		//notzero = IVALID ? 1'b1:0;
		if (IVALID) begin
			notzero = 1'b1;
		end
	end else if (DATA[1] == 1'b1) begin
		each_byte_zeros = 6;
		//notzero = IVALID ? 1'b1:0;
		if (IVALID) begin
			notzero = 1'b1;
		end
	end else if (DATA[0] == 1'b1) begin
		each_byte_zeros = 7;
		//notzero = IVALID ? 1'b1:0;
		if (IVALID) begin
			notzero = 1'b1;
		end
	end else begin
		each_byte_zeros = 8;
	end
end

// DFF as buffer for 'notzero'
always @(posedge CLK or negedge RST_N) begin
//always @* begin
	if (!RST_N) begin
		found = 0;
	end else if (IVALID) begin
		found = notzero;
	end
end

// Accumulator
always @(posedge CLK or negedge RST_N)
begin
	if (!RST_N) begin
		ZEROS = 0;
		//if (MODE) begin
	end else if (IVALID && !found) begin
		ZEROS = ZEROS + each_byte_zeros;
	end else begin
		ZEROS = ZEROS + 0;
	end
end

// Counting round 
always @(posedge CLK or negedge RST_N)
begin
	if (!RST_N) begin
		round = 0;
	end else if (IVALID) begin
		round = round + 1;
	end else begin
		round = round + 0;
	end
end


// FSM: State register
// D-FF with clk, so using 'Nonblocking'
always @(posedge CLK or negedge RST_N) begin
	if (RST_N == 0) begin
		state <= IDLE;
	end else begin
		state <= state_next;
	end
end

// FSM: Next State Logic
// combinational so using 'blocking'
//always @* begin
always @(posedge CLK or negedge RST_N) begin
	case (state)
		IDLE: begin
			if (!IVALID) begin
				state_next = IDLE;
			end else begin
				state_next = ACCU;
			end
		end

		ACCU: begin
			if (round == word) begin
				OVALID = 1'b1;
				state_next = FINISH;

			end else begin
				if (MODE) begin
					if (found && IVALID) begin
						//ZEROS = counter;
						OVALID = 1'b1;
						state_next = FINISH;
					end else begin
						state_next = ACCU;
					end
				end else begin // mode = 0
					if (round == word) begin
						state_next = FINISH;
					end else begin
						state_next = ACCU;
					end
				end
			end

		end

		FINISH: begin // initial
			/*
			ZEROS = counter;
			OVALID = 1'b1;
			state_next = IDLE;
			*/
			ZEROS = 0;
			OVALID = 0;
			each_byte_zeros = 0;
			notzero = 0;
			found = 0;
			counter = 0;
			round = 0;
			state_next = IDLE;
		end

		default: begin
			
		end
	endcase
end
endmodule

