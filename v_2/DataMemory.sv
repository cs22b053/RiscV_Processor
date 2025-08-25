module DataMemory(
    input  logic [31:0] addr, wdata,
    input  logic [2:0]  mask,
    input  logic        wr_en, rd_en, clk,
    output logic [31:0] rdata
);
    logic [31:0] memory [1023:0];   // 1 KB memory
    logic [31:0] data, write_data;

    // Read logic
    always_comb begin
        data  = memory[addr[31:2]];
        rdata = 32'b0;
        if (rd_en) begin
            case (mask)
                3'b000: case (addr[1:0]) // LB (signed)
                    0: rdata = {{24{data[7]}},   data[7:0]};
                    1: rdata = {{24{data[15]}},  data[15:8]};
                    2: rdata = {{24{data[23]}},  data[23:16]};
                    3: rdata = {{24{data[31]}},  data[31:24]};
                endcase
                3'b001: case (addr[1])   // LH (signed)
                    0: rdata = {{16{data[15]}},  data[15:0]};
                    1: rdata = {{16{data[31]}},  data[31:16]};
                endcase
                3'b010: rdata = data;   // LW
                3'b100: case (addr[1:0]) // LBU
                    0: rdata = {24'b0, data[7:0]};
                    1: rdata = {24'b0, data[15:8]};
                    2: rdata = {24'b0, data[23:16]};
                    3: rdata = {24'b0, data[31:24]};
                endcase
                3'b101: case (addr[1])   // LHU
                    0: rdata = {16'b0, data[15:0]};
                    1: rdata = {16'b0, data[31:16]};
                endcase
            endcase
        end
    end

    // Write data prep
    always_comb begin
        write_data = memory[addr[31:2]];
        if (wr_en) begin
            case (mask)
                3'b000: case (addr[1:0]) // SB
                    0: write_data[7:0]   = wdata[7:0];
                    1: write_data[15:8]  = wdata[7:0];
                    2: write_data[23:16] = wdata[7:0];
                    3: write_data[31:24] = wdata[7:0];
                endcase
                3'b001: case (addr[1])   // SH
                    0: write_data[15:0]  = wdata[15:0];
                    1: write_data[31:16] = wdata[15:0];
                endcase
                3'b010: write_data = wdata; // SW
            endcase
        end
    end

    // Write on clock edge
    always_ff @(negedge clk) begin
        if (wr_en)
            memory[addr[31:2]] <= write_data;
    end
endmodule

