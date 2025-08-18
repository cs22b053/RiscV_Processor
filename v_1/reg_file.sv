module reg_file(
    input  logic        clk,
    input  logic        rst,
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    input  logic [4:0]  rd_addr,
    input  logic [31:0] rd_wdata,
    input  logic        rd_wen,

    output logic [31:0] rs1_rdata,
    output logic [31:0] rs2_rdata
);

    // 32 registers, each 32 bits wide
    logic [31:0] registers [31:0];

    // Sequential logic with SystemVerilog always_ff
    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset all registers to zero
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end
        else if (rd_wen && (rd_addr != 5'b0)) begin
            // Write to register file (except x0 which is hardwired to 0)
            registers[rd_addr] <= rd_wdata;
        end
    end

    // Asynchronous read ports
    assign rs1_rdata = (rs1_addr == 5'b0) ? 32'b0 : registers[rs1_addr];
    assign rs2_rdata = (rs2_addr == 5'b0) ? 32'b0 : registers[rs2_addr];

endmodule
