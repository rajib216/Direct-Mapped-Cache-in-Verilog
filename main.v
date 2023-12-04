module main(clk, rw, valid_req, reset, addr, dataIn, dataOut, cache_ready, hit, miss);
    input clk, rw, reset, valid_req;           // from CPU
    input [31:0] addr;
    input [31:0] dataIn;                       // from CPU

    output [31:0] dataOut;                     // final word produced by cache for CPU
    output cache_ready;                        // taken as an input in test bench (CPU) to generate new requests only when ready
    output hit, miss;                          // to counter

    wire [127:0] data_rd, data_from_ram;       // data outputted from cache towards cpu or ram; data from ram
    wire en_read_RAM, en_write_RAM, ram_ack;
    wire en_write, en_read;   
    wire set_dirty, set_tag, set_valid;        // enables for cache
    wire write_data_sel;            
    
    wire [32:0] addr_cache2ram;
    wire mem_addr_sel;                         //=1 means from cache to ram
    wire [32:0] mem_addr;

    wire valid;        
    wire [17:0] tag;

    /* always @(posedge clk) begin
        case(addr[3:2])
            2'b00: dataOut[31:0] <= data_rd[31:0];     // word produced by cache to service CPU request
            2'b01: dataOut[31:0] <= data_rd[63:32];
            2'b10: dataOut[31:0] <= data_rd[95:64];
            2'b11: dataOut[31:0] <= data_rd[127:96];
        endcase
    end */
    //assign out = s1 ? (s0 ? d : c) : (s0 ? b : a); 
    assign dataOut = (addr[3]==0)? ((addr[2]==0)? data_rd[31:0]:data_rd[63:32]) :
                                   ((addr[2]==0)? data_rd[95:64]:data_rd[127:96]);

    assign mem_addr = (mem_addr_sel==1)?  addr_cache2ram : addr;

 
    main_memory u0(.clk(clk), .addr(mem_addr), .data_in(data_rd), .en_read(en_read_RAM), .en_write(en_write_RAM), .ram_ack(ram_ack), .data_out(data_from_ram));

    cache_mem u1(.clk(clk), .addr(addr), .en_write(en_write), .en_read(en_read), .dataIn(dataIn), .data_rd_mem(data_from_ram), .addr_cache2ram(addr_cache2ram),
                 .write_data_sel(write_data_sel), .dataOut(data_rd), .set_valid(set_valid), .valid(valid), .set_dirty(set_dirty), .dirty(dirty), .set_tag(set_tag), .tag(tag));
                

    cache_controller u2(.clk(clk), .reset(reset), .rw(rw), .addr(addr), .tag(tag), .valid(valid), .valid_req(valid_req),
                        .dirty(dirty), .ram_ack(ram_ack), .cache_ready(cache_ready), .mem_addr_sel(mem_addr_sel),
						.hit(hit), .miss(miss), .en_write(en_write), .en_read(en_read), .en_read_RAM(en_read_RAM), .en_write_RAM(en_write_RAM),
                        .set_valid(set_valid), .set_dirty(set_dirty), .set_tag(set_tag), .write_data_sel(write_data_sel));

endmodule