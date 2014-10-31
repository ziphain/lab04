module stimulus;
	parameter cyc = 10;
	parameter delay = 1;

	parameter fsdb_filename = "lzc.fsdb"; 
	parameter width = `WIDTH;
	parameter word = `WORD;
	parameter debug = `DEBUG;
	parameter pattern = "lzc_w4c4.dat";


	reg clk, rst_n, ivalid, mode;
	reg [15:0] data;

	reg [128*8:0] fsdb;
	// should add reg [] pattern
	// to do ...

	wire ovalid;
	wire [5:0] zeros;

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

			$monitor($time, " CLK=%b RST_N=%b IVALID=%b DATA=%d MODE=%d | OVALID=%b ZEROS=%d width=%d word=%d", clk, rst_n, ivalid, data, mode, ovalid, zeros, width, word);
		end

		initial begin
			clk = 1;
			rst_n = 1;

			mode = 0;
			//
			#(cyc);
			#(delay) rst_n = 0;
			#(cyc*4) rst_n = 1;
			#(cyc*2);

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
endmodule



