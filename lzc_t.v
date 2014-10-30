module stimulus;
	parameter cyc = 10;
	parameter delay = 1;

	reg clk, rst_n, ivalid, mode;
	reg [7:0] data;

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
			$fsdbDumpfile("lzc.fsdb");
			$fsdbDumpvars;

			$monitor($time, " CLK=%b RST_N=%b IVALID=%b DATA=%d MODE=%d | OVALID=%b ZEROS=%d ", clk, rst_n, ivalid, data, mode, ovalid, zeros);
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
			#(cyc) load; data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc) nop;
			#(cyc);

			#(cyc) load; data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd64);
			#(cyc);		data_in(8'd0);
			#(cyc) nop;
			#(cyc);

			#(cyc) load; data_in(8'd128);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd2);
			#(cyc) nop;
			#(cyc);

			#(cyc) load; data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc) nop;
			#(cyc);

			mode = 1;


// Non-continue input 4-bytes
			#(cyc) load; data_in(8'd1);
			
			#(cyc); data_in(8'd0);

			#(cyc) nop;
			#(cyc) load; data_in(8'd1);
			
			#(cyc) nop;
			#(cyc) load; data_in(8'd32);
			
			#(cyc) nop;
			#(cyc);
//

			#(cyc) load; data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd16);
			#(cyc);		data_in(8'd0);
			#(cyc) nop;
			#(cyc);

			#(cyc) load; data_in(8'd0);
			#(cyc);		data_in(8'd128);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc) nop;
			#(cyc);

			#(cyc) load; data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd64);
			#(cyc);		data_in(8'd0);
			#(cyc) nop;
			#(cyc);

			#(cyc) load; data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc);		data_in(8'd0);
			#(cyc) nop;
			#(cyc);

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



