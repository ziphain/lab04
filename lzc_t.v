module stimulus;
	parameter cyc = 10;
	parameter delay = 1;

	//parameter fsdb_filename = "lzc.fsdb"; 
	parameter width = `WIDTH;
	parameter word = `WORD;
	parameter debug = `DEBUG;
	//parameter pattern;

	// read memory
	reg [width - 1 + 2:0] memory[0:15000];
	reg [width - 1 + 2:0] memory_gold[0:3000];
	integer i; // memory
	integer gold_index; 

	reg clk, rst_n, ivalid, mode;
	reg [width - 1:0] data;

	reg [128*8 - 1:0] fsdb;    // why 128????  128*8=1024
	reg [128*8 - 1:0] pattern;
	reg [128*8 - 1:0] golden;

	wire ovalid;
	wire [width * word - 1:0] zeros;

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
			//$fsdbDumpfile(fsdb);
			$fsdbDumpvars;

			if (debug == 1) begin
				$monitor($time, " CLK=%b RST_N=%b IVALID=%b DATA=%d MODE=%d | OVALID=%b ZEROS=%d width=%d word=%d", clk, rst_n, ivalid, data, mode, ovalid, zeros, width, word);
			end else begin

			end
		end

		initial begin
			clk = 1;
			rst_n = 1;

			//mode = 0;
			//
			#(cyc);
			#(delay) rst_n = 0;
			#(cyc*4) rst_n = 1;
			#(cyc*2);
			if ($value$plusargs("pattern=%s", pattern)) begin
				$readmemb(pattern, memory);
				//$readmemb(golden, memory_gold);
				for (i = 0; i < 100; i = i +1) begin
					//$display("Memory [%d] = %b", i, memory[i]);
					instru(memory[i]);
				end
			end

			
/*
			#(cyc) nop;
//
			#(cyc) load; data_in(8'd0);
			
			//#(cyc) nop;
			#(cyc); data_in(8'd16);

			#(cyc) nop;
			#(cyc) load; data_in(8'd0);
			
			#(cyc) nop;
			#(cyc) load; data_in(8'd0);
			
			#(cyc) nop;
			#(cyc);
//
*/
			#(cyc*8);
			$finish;
		end

		task nop;
			begin
				ivalid = 0;
			end
		endtask

		task load;
			begin
				ivalid = 1;
			end
		endtask

		task data_in;
			input [7:0] data1;
			begin
				data = data1;
			end
		endtask

		task instru;
			input [width - 1 +2:0] micro_instr;
			begin
				#(cyc) mode = micro_instr[width - 1 + 2];
				ivalid = micro_instr[width];
				data = micro_instr[width-1:0];
			end
		endtask
		/*
		task compare;

			gold_index += 1;
		endtask
		*/

endmodule



