module cache_controller(clk, reset, addr, tag, valid, dirty, ram_ack, cache_ready, rw, valid_req,
						hit, miss, en_write, en_read, en_read_RAM, en_write_RAM, set_valid, set_dirty, set_tag, write_data_sel, mem_addr_sel);

input clk, reset; 
input rw, valid_req;		      // req type from CPU, read=1
input [31:0] addr; 
input [17:0] tag;     // tag = 32 - 10 - 2 - 2 = 18 bits
input valid, dirty;
input ram_ack;  

output hit, miss;                                 // cache hit/miss, out to counter 
output reg mem_addr_sel;                              // address to ram from cache or cpu
output reg en_write;                       	  	  // enable cache to be written by cpu or RAM
output reg en_read;                               // enable cache to be read by cpu or RAM
output reg en_read_RAM;                           // request data from RAM
output reg en_write_RAM;                          // write to RAM via write buffer		
output reg set_valid, set_dirty, set_tag;		
output reg write_data_sel;
output reg cache_ready;

reg [1:0] state;                                  // current state
reg [1:0] next_state;                             // next state
wire read, write;
   
// State definition
parameter Idle = 2'b00;
parameter CompareTag = 2'b01;
parameter WriteBack = 2'b10;
parameter Allocate = 2'b11;

assign hit  = (write||read) & ((tag==addr[31:14]) & valid);
assign miss = ~hit;   
assign read = (rw == 1);
assign write= (rw == 0);

/*****       Write Buffer Counter     *****/
/*wire WB_ready;    // =1 after 8 cycles, write buffer finish.
reg count8;       // 8times
counter_n #(.n(8), .counter_bits(3) )  counter8(  // takes 8 cycles to transfer a block (0f 8 words)
				.clk(clk),
				.r(count8),
				.en(en_write_RAM),
				.co(WB_ready),      // high when finished
				.q()); */


/*****       State Transition      *****/
always@(posedge clk)
	begin
	if(reset)  state = Idle;       // blocking
	else  state = next_state;         

	case(state)
		Idle: 	begin 
				// if cache access requests from CPU, then compare tag
				  if(valid_req)	 next_state <= CompareTag;
			  	  else  next_state <= Idle;
				end

		CompareTag: begin 
					/*   cache hit   */
					  if(hit)	next_state <= Idle;    
					
					/*   cache miss  */
					  else begin 
						  if (dirty)  next_state <= WriteBack;    // dirty read or dirty write, need to update main mem block from cache line
						  else  next_state <= Allocate;			  // write or read clean, just allocate a line and read/write data										
						end
					end
									 
		Allocate: begin
					
					// data-loading from RAM finished
					if(ram_ack)  next_state <= CompareTag;  
					
					// stall until finish
					else  next_state <= Allocate;            
				  end
				
		WriteBack: begin

					// assume a infinite write buffer, no worry about a stall due to small room 
					 if(ram_ack)  next_state <= Allocate;   	   // if was read miss, go to Allocate state upon finishing update

					// stall until finished writing to RAM
					 else  next_state <= WriteBack;            // if was write miss, write directly to RAM via write buffer (no-write-allocate)
				   end
				   
		endcase
	end

	/*****       Control signals       *****/

	// initialize signals
always @ (posedge clk) 
    begin
      if(reset) begin 
	  		next_state <= 2'b00;
			en_write <= 0;	en_read <= 0;  
			en_write_RAM <= 0;  en_read_RAM <= 0;
			set_valid <= 0; set_tag <= 0; set_dirty <= 0;
			write_data_sel <= 0;
			cache_ready <= 1; mem_addr_sel <= 0;
	  end
	end

always @ (posedge clk) 
    begin  
		if(state == Idle) cache_ready <= 1;   //00

		else if(state == CompareTag)  //01
			begin
			cache_ready <= 0; 		// busy, not taking new reqs
			// enable cache line to be written from cpu, set dirty, valid, tag
			if(hit & write)  begin  en_write <= 1;  set_dirty <= 1;  write_data_sel <= 1;  end     
     	    else  en_write <= 0;        		 // miss, don't enable cache yet
	  		if(hit & read)   begin  en_read <= 1;   end        
        	else  en_read <= 0;
   		 	end

		else if(state == WriteBack)   //10
        	begin 
				en_write_RAM <= 1;          	 // write to RAM from cache line
				mem_addr_sel <= 1;               
				en_read <= 1;
				if(ram_ack)  begin  en_write_RAM <= 0;  en_read <=0;  set_dirty <= 0;  mem_addr_sel <= 0;  end
			end

		else if(state == Allocate)    //11
        	begin   
				en_read_RAM <= 1;                // start reading from RAM
				en_write <= 1;
				write_data_sel <= 0;
				set_tag <= 1;                    // enable to change tag as well as data
				set_valid <= 1;					 // set valid bit to 1
       	   		if(ram_ack) begin
					set_tag <= 0;
					set_valid <= 0;
					en_read_RAM <= 0;  		     // if load data from RAM is finish
					en_write <= 0;
				end
       	 	end
		
        else  {en_read_RAM, en_write_RAM} <= 2'b0;
	end

endmodule