module imem(
			  input [31:0] 	read_addr,
			  output [31:0] instruction
			  );

   reg [31:0] I_MEM_BLOCK[63:0];

   initial
     begin
	$readmemh("instructions.text", I_MEM_BLOCK);
     end

   assign instruction = I_MEM_BLOCK[read_addr[31:2]];

endmodule