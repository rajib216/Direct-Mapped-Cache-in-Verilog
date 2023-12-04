`timescale 1ns/1ps

module main_test();

	reg clk, rw, reset, valid_req;
	reg [31:0] data_in;
	reg [31:0] addr;

	wire [31:0] data_out;
 	wire cache_ready;
	wire hit, miss;

	wire read, write;
	assign read = (rw == 1);
	assign write= (rw == 0);


	main dut(
		.clk(clk), 
		.reset(reset),
		.rw(rw),
		.valid_req(valid_req),
		.addr(addr), 
		.dataIn(data_in), 
		.cache_ready(cache_ready),
		.hit(hit),
		.miss(miss),
		.dataOut(data_out)
	);

	wire [127:0] ram_out = dut.u0.data_out;		 // ram to cache
	wire [127:0] cache_out = dut.data_rd; 		 // cache to cpu/ram
	wire [17:0] tag = dut.u1.tag; 				 // cache tag
	wire [1:0] current_state = dut.u2.state;
	wire [1:0] next_state = dut.u2.next_state;
	wire cw_en = dut.u2.en_write; 				 // cache line write enable
	wire cr_en = dut.u2.en_read; 				 // cache line read enable
	wire mw_en = dut.u2.en_write_RAM;			 // ram write enable
	wire mr_en = dut.u2.en_read_RAM; 			 // ram read enable
	wire ram_ack = dut.u0.ram_ack; 				 // ram acknowledge
	wire set_valid = dut.u2.set_valid;
	wire dirty = dut.u1.dirty;

	initial begin
		clk <=   1'b0;
		rw <= 1'b0;
		reset <= 1'b1;
		#8;
		reset <= 1'b0;
	end

	always begin
		// read miss, allocate
		#12;
		valid_req <= 1;
		addr <= 32'h00000020;
		rw <= 1'b1;
		#8;  valid_req <= 0;
		
		// write hit
		#28;
		valid_req <= 1;
		addr <= 32'h00000020;
		data_in <= 32'h00000080;
		rw <= 1'b0;
		#8;  valid_req <= 0;
		
		// read hit
		#28;
		valid_req <= 1;
		addr <= 32'h00000020;
		rw <= 1'b1;
		#8;  valid_req <= 0;

		// write miss (clean)
		#28;
		valid_req <= 1;
		addr <= 32'h00000020;
		data_in <= 32'h00000080;
		rw <= 1'b0;
		#8;  valid_req <= 0;

		#12;
		$stop;
	end

	always #2 clk <= ~clk;

endmodule