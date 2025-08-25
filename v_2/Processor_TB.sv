`timescale 1ns / 1ps

module Processor_TB;
	logic clk, reset;
	Processor UUT (clk, reset);
	always #5 clk = ~clk; // 10ns period clock

    initial begin
        clk = 0;
        reset = 1;
        #10;
        reset = 0;
        #100; // Run for a few cycles

        $display("Test complete.");
        // Check the value at memory address 0. The program should have stored 25 there.
        $display("Value at memory address 0 is: %d", UUT.memory.memory[0]);
        $finish;
    end
endmodule
