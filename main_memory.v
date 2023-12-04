//`timescale 1ns/1ps
module main_memory(clk, addr, data_in, en_read, en_write,
				    ram_ack, data_out);

input clk;
input [127:0] data_in;
input [31:0] addr;
input en_read;
input en_write;

output reg [127:0] data_out;
output reg ram_ack;

reg [27:0] index;         // 32-4 = 28b index, where the block is in ram 
reg [127:0] ram [4095:0]; 
integer count;

initial begin
	ram_ack = 0;
	$readmemh("ram_data.txt",ram);
	count = 0;
end


always @(posedge clk) 
begin
	if(en_write||en_read) begin        // valid request
		index <= addr[31:4];
		count <= count+1;
		if(en_write)  ram[index] <= data_in;
		else  data_out <= ram[index];
		if(count == 2) begin
			count <= 0;
			ram_ack <= 1;
		end
	end
	else ram_ack <= 0;
end

always @(negedge clk)                   // prevents 11 -> 01 misbehaviour
begin
	if((en_write||en_read)==0) begin  
		ram_ack <= 0;
	end
end

endmodule