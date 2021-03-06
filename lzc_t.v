module stimulus;
	parameter cyc = 10;
	parameter delay = 1;

	parameter width = `WIDTH;
	parameter word = `WORD;
	parameter debug = `DEBUG;

	// read memory
	reg [width - 1 + 2:0] memory[0:15000];
	reg [8:0] memory_gold[0:3000];
	integer i; // for memory
	integer gold_index = 0; 

	reg clk, rst_n, ivalid, mode, not_match = 0;
	reg [width - 1:0] data;
	reg [8:0] golden_value;
	reg [10:0] match_counter = 0;
	reg [9:0] mismatch_count = 0;

	reg [128*8 - 1:0] fsdb;    // why 128????  128*8=1024
	reg [128*8 - 1:0] pattern;
	reg [128*8 - 1:0] golden;

	wire ovalid;
	wire [8:0] zeros; // max zeros=256 (16 by 16)

	LZC lzc01(
			.CLK(clk),
			.RST_N(rst_n),
			.IVALID(ivalid),
			.DATA(data),
			.MODE(mode),
			.OVALID(ovalid),
			.ZEROS(zeros)
	);

	always #(cyc/2) clk = ~clk;

		initial begin
			
			if ($value$plusargs("fsdb=%s", fsdb)) begin
				$fsdbDumpfile(fsdb);
			end else begin
				$fsdbDumpfile("lzc.fsdb");
			end
			$fsdbDumpvars;

			if (debug == 1) begin
				$monitor($time, " CLK=%b RST_N=%b IVALID=%b DATA=%d MODE=%d | OVALID=%b ZEROS=%d width=%d word=%d mismatch=%d", clk, rst_n, ivalid, data, mode, ovalid, zeros, width, word, mismatch_count);
			end else begin

			end
		end

		initial begin
			clk = 1;
			rst_n = 1;

			#(cyc);
			#(delay) rst_n = 0;
			#(cyc*4) rst_n = 1;
			#(cyc*2);
			if ($value$plusargs("pattern=%s", pattern)) begin
				$readmemb(pattern, memory);
				if ($value$plusargs("golden=%s", golden)) begin
					$readmemb(golden, memory_gold);
				end
				
				//
				for (i = 0; i < 23000; i = i + 1) begin
					instru(memory[i]);
					if (ovalid) begin
						get_golden(memory_gold[gold_index]);
						gold_index = gold_index + 1;

						// compare if match
						if (zeros == golden_value) begin
							match_counter = match_counter + 1;
						end else begin
							not_match = 1;
							#(cyc);
							not_match = 0;
							mismatch_count = mismatch_count + 1;
						end
					end
				end // end for loop
			end

			#(cyc*8);
			$finish;
		end
		// Get line from lzc_w4c4.dat and divide bits
		task instru;
			input [width - 1 +2:0] micro_instr;
			begin
				#(cyc) mode = micro_instr[width - 1 + 2];
				ivalid = micro_instr[width];
				data = micro_instr[width-1:0];	
			end
		endtask
		// Get line from lzc_w4c4gold.dat, for compare zeros
		task get_golden;
			input [8:0] golden_instr;
			begin
				golden_value = golden_instr[8:0];
			end
		endtask

endmodule



