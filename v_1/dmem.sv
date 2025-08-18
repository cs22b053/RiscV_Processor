//
// Data Memory (RAM)
//
// - Handles load and store operations.
// - Synchronous write (on positive clock edge).
// - Asynchronous read.
//
module dmem (
    // Inputs
    input  logic         clk,
    input  logic [31:0]  addr,
    input  logic [31:0]  write_data,
    input  logic         mem_read,  // Read enable signal
    input  logic         mem_write, // Write enable signal

    // Output
    output logic [31:0]  read_data
);
    // Memory storage: 4096 x 32-bit words (16KB)
    logic [31:0] ram[4095:0];

    // Asynchronous read logic
    // We only read if mem_read is asserted, otherwise output is high-Z
    assign read_data = mem_read ? ram[addr[31:2]] : 32'bz;

    // Synchronous write logic
    always_ff @(posedge clk) begin
        if (mem_write) begin
            ram[addr[31:2]] <= write_data;
        end
    end

endmodule