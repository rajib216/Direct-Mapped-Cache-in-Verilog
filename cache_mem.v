module cache_mem(clk, addr, en_write, en_read, dataIn, data_rd_mem, write_data_sel, dataOut, addr_cache2ram,
                 set_valid, valid, set_dirty, dirty, set_tag, tag);

    input clk, en_read, en_write;
    input [31:0] addr;
    input write_data_sel;
    input [31:0] dataIn;                    // word to write from CPU 
    input [127:0] data_rd_mem;              // blocks to read from RAM for allocation
    input set_valid, set_dirty, set_tag;	// enable writing/setting auxilary arrays

    output reg [127:0] dataOut;
    output reg [32:0] addr_cache2ram;
    output reg valid, dirty;
    output reg [17:0] tag;

    parameter BLOCKS = 1024;       // # blocks in cache (hence 10 bit index)
    parameter WORDS= 4;            // # words in a block (hence 2 bit block offset)
    parameter SIZE = 32;           // 32 bit processor (hence 2 bit byte offset)
    parameter BLOCK_SIZE = 128;    // size of one block in bits = 4*32
    parameter TAG_SIZE = 18;       // tag size = address(32)-index(10)-block offset(2)-byte offset(2)

    reg [BLOCK_SIZE-1: 0] cache_data [BLOCKS-1: 0];     // registers for the DATA in cache
    reg [TAG_SIZE-1: 0] tag_array [BLOCKS-1: 0];        // for all tags in cache
    reg valid_array [BLOCKS-1: 0];                      // VALID flag array
    reg dirty_array [BLOCKS-1: 0];                      // dirty flag array
    reg [9:0] index;                                    // 10 bit index
    
	// Initializing valid bits for all cache lines to '0'
	initial begin
		$readmemh("valid_init.txt",valid_array);
    end
	
    always @(posedge clk) begin
        index = addr[31:4] % BLOCKS;     // direct mapping, block address in ram modulo number of blocks in cache
        if(set_valid)   begin
            valid_array[index] <= 1;
        end

        if(set_tag)   begin
            tag_array[index][TAG_SIZE-1: 0] <= addr[31:14];
        end

        if(set_dirty)  dirty_array[index] <= 1;
        else  dirty_array[index] <= 0;

        tag[TAG_SIZE-1: 0] <= tag_array[index][TAG_SIZE-1: 0];      // no read enable on the tag array
        valid <= valid_array[index];
        dirty <= dirty_array[index];
    end

    always @(posedge clk) begin 
        if(en_write)  begin                              // logic for filling cache lines from CPU or RAM
            if(write_data_sel==1)  begin                 // write relevant word in cache line from CPU
                case(addr[3:2])
                2'b00: cache_data[index][31:0]   <= dataIn;
                2'b01: cache_data[index][63:32]  <= dataIn;
                2'b10: cache_data[index][95:64]  <= dataIn;
                2'b11: cache_data[index][127:96] <= dataIn;
                endcase
            end
            else  cache_data[index][127:0] <= data_rd_mem[127:0];       // allocate block from RAM
        end

        if(en_read)  begin
            addr_cache2ram <= {tag[TAG_SIZE-1: 0], index, 4'b0000};
            dataOut <= cache_data[index][127:0];        // updates data on latch to be read from cache
        end
    end

endmodule
