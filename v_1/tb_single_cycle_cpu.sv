module tb_single_cycle_cpu;

    // Testbench signals
    logic clk;
    logic rst;

    // Wires to connect to CPU outputs
    logic [31:0] pc_out;
    logic [31:0] instruction;
    logic [31:0] alu_result_out;

    // Instantiate the CPU
    single_cycle_cpu dut (
        .clk(clk),
        .rst(rst),
        .pc_out(pc_out),
        .instruction(instruction),
        .alu_result_out(alu_result_out)
    );

    // Clock generator: 100MHz clock (10ns period)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        // 1. Initialize signals
        clk = 0;
        rst = 1; // Assert reset

        // 2. Pulse reset
        #10;
        rst = 0; // De-assert reset

        // 3. Run for a few cycles to let the program execute
        #100;

        // 4. Check the results
        // Our program stores the result (25) at memory address 0.
        // We can look inside the data memory to verify.
        $display("Test complete.");
        $display("Value at memory address 0 is: %d", dut.DMEM.ram[0]);
        // The value should be 25 (0x19 in hex)

        // 5. Stop the simulation
        $finish;
    end

endmodule