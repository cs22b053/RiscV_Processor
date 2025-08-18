`timescale 1ns/1ps

module tb_reg_file;

    // Testbench signals
    logic clk;
    logic rst;
    logic [4:0] rs1_addr, rs2_addr, rd_addr;
    logic [31:0] rd_wdata;
    logic rd_wen;
    logic [31:0] rs1_rdata, rs2_rdata;

    // Instantiate the DUT (Device Under Test)
    reg_file dut (
        .clk       (clk),
        .rst       (rst),
        .rs1_addr  (rs1_addr),
        .rs2_addr  (rs2_addr),
        .rd_addr   (rd_addr),
        .rd_wdata  (rd_wdata),
        .rd_wen    (rd_wen),
        .rs1_rdata (rs1_rdata),
        .rs2_rdata (rs2_rdata)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    // Test procedure
    initial begin
        // Initialize
        clk = 0;
        rst = 1;
        rd_wen = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        rd_addr  = 0;
        rd_wdata = 0;

        // Apply reset
        #10;
        rst = 0;

        // Write 0xAAAA_BBBB to register 1
        @(posedge clk);
        rd_wen   = 1;
        rd_addr  = 5'd1;
        rd_wdata = 32'hAAAA_BBBB;

        // Write 0x1234_5678 to register 2
        @(posedge clk);
        rd_addr  = 5'd2;
        rd_wdata = 32'h1234_5678;

        // Disable write
        @(posedge clk);
        rd_wen = 0;

        // Read back register 1 and register 2
        rs1_addr = 5'd1;
        rs2_addr = 5'd2;

        #10;
        $display("Read reg1 = %h (expected AAAA_BBBB)", rs1_rdata);
        $display("Read reg2 = %h (expected 1234_5678)", rs2_rdata);

        // Check x0 register (should always be zero)
        rs1_addr = 5'd0;
        #10;
        $display("Read reg0 = %h (expected 0)", rs1_rdata);

        // End simulation
        #20;
        $finish;
    end

endmodule
