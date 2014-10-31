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
	output reg [5:0] ZEROS,
	output reg OVALID
);

wire cumulative, finish; 
reg found, final, notzero, already_out;
reg [1:0] state, state_next;

reg [2:0] round;

reg [5:0] counter, each_byte_zeros;
parameter [1:0] IDLE = 2'b00;
parameter [1:0] ACCU = 2'b01;
parameter [1:0] FINISH = 2'b10;
parameter [1:0] S0 = 2'b11;

assign cumulative = (IVALID && !found) ? 1'b1:0;
assign finish = ((MODE && found) || (MODE && !IVALID) || (!MODE && round == 4 )) ? 1'b1:0;

// Find zeros of each input byte
always @* begin	
	if (!RST_N) begin
		each_byte_zeros = 0;
		notzero = 0;
	end else if (DATA[7] == 1'b1) begin
		each_byte_zeros = 0;
		notzero = 1'b1;
	end else if (DATA[6] == 1'b1) begin
		each_byte_zeros = 1;
		notzero = 1'b1;
	end else if (DATA[5] == 1'b1) begin
		each_byte_zeros = 2;
		notzero = 1'b1;
	end else if (DATA[4] == 1'b1) begin
		each_byte_zeros = 3;
		notzero = 1'b1;
	end else if (DATA[3] == 1'b1) begin
		each_byte_zeros = 4;
		notzero = 1'b1;
	end else if (DATA[2] == 1'b1) begin
		each_byte_zeros = 5;
		notzero = 1'b1;
	end else if (DATA[1] == 1'b1) begin
		each_byte_zeros = 6;
		notzero = 1'b1;
	end else if (DATA[0] == 1'b1) begin
		each_byte_zeros = 7;
		notzero = 1'b1;
	end else begin
		each_byte_zeros = 8;
	end
end

// DFF as buffer for 'notzero'
always @(posedge CLK or negedge RST_N)
begin
	if (!RST_N) begin
		found = 0;
	end else begin
		found = notzero;
	end
end

// Accumulator
always @(posedge CLK or negedge RST_N)
begin
	if (!RST_N) begin
		counter = 0;
	end else if (cumulative) begin
		counter = counter + each_byte_zeros;
	end else begin
		counter = counter + 0;
	end
end

// Counting round 
always @(posedge CLK or negedge RST_N)
begin
	if (!RST_N) begin
		round = 0;
		already_out = 0;
	end else if (IVALID) begin
		round = round + 1;
	end else begin
		round = round + 0;
	end
end


// Output 
always @* begin
	if (!RST_N) begin
		ZEROS = 0;
		OVALID = 0;
	end else if (finish && final) begin
		ZEROS = counter;
		if (round == 4 && MODE && already_out) begin
			OVALID = 0;
		end else begin
			OVALID = 1'b1;
		end
	end else begin
		ZEROS = 0;
		OVALID = 0;
	end
end

always @(negedge IVALID)
begin
	if (!MODE && round == 4) begin
		ZEROS = counter;
		OVALID = 1'b1;
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
always @* begin
	case (state)
		IDLE: begin
			ZEROS = 0;
			OVALID = 0;
			if (cumulative) begin
				state_next = ACCU;
			end else begin
				state_next = IDLE;
			end
		end

		ACCU: begin
			if (finish) begin
				final = 1;
				already_out = 1;
				if (MODE && IVALID && ACCU) begin
					state_next = S0;
				end else begin
					state_next = FINISH;
					final = 1;
				end
			end else begin
				state_next = ACCU;
			end
		end

		S0: begin
			if (MODE && round != 4) begin
					already_out = 1;
				end else begin
					already_out = 0;
			end
			if (MODE && IVALID && ACCU) begin
				state_next = S0;
				final = 0;
			end else begin
				state_next = FINISH;
			end
		end

		FINISH: begin
			// initial
			found = 0;
			counter = 0;
			final = 0;
			notzero = 0;
			if (already_out && round != 4) begin
				round = round + 0;
			end else begin
				round = 0;
				already_out = 0;
			end
			state_next = IDLE;
		end

		default: begin
			OVALID = 0;
			state_next = IDLE;
		end
	endcase
end
endmodule

