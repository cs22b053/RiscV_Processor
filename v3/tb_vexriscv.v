`timescale 1ns/1ps

module tb_vexriscv;
  // 100 MHz clock
  reg clk = 0;
  always #5 clk = ~clk;

  // active-high sync reset
  reg reset = 1;
  initial begin
    repeat (10) @(posedge clk);
    reset = 0;
  end

  // Interrupts tied off
  wire timerInterrupt    = 1'b0;
  wire externalInterrupt = 1'b0;
  wire softwareInterrupt = 1'b0;

  // ==== iBus (Simple) ====
  wire        iBus_cmd_valid;
  wire        iBus_cmd_ready;
  wire [31:0] iBus_cmd_payload_pc;
  wire        iBus_rsp_valid;
  wire        iBus_rsp_payload_error;
  wire [31:0] iBus_rsp_payload_inst;

  // ==== dBus (Simple) ====
  wire        dBus_cmd_valid;
  wire        dBus_cmd_ready;
  wire        dBus_cmd_payload_wr;
  wire [3:0]  dBus_cmd_payload_mask;
  wire [31:0] dBus_cmd_payload_address;
  wire [31:0] dBus_cmd_payload_data;
  wire [1:0]  dBus_cmd_payload_size;
  wire        dBus_rsp_ready;   // NOTE: In this core, this behaves like 'rsp_valid' from memory
  wire        dBus_rsp_error;
  wire [31:0] dBus_rsp_data;

  // DUT
  VexRiscv dut (
    .iBus_cmd_valid(iBus_cmd_valid),
    .iBus_cmd_ready(iBus_cmd_ready),
    .iBus_cmd_payload_pc(iBus_cmd_payload_pc),
    .iBus_rsp_valid(iBus_rsp_valid),
    .iBus_rsp_payload_error(iBus_rsp_payload_error),
    .iBus_rsp_payload_inst(iBus_rsp_payload_inst),
    .timerInterrupt(timerInterrupt),
    .externalInterrupt(externalInterrupt),
    .softwareInterrupt(softwareInterrupt),
    .dBus_cmd_valid(dBus_cmd_valid),
    .dBus_cmd_ready(dBus_cmd_ready),
    .dBus_cmd_payload_wr(dBus_cmd_payload_wr),
    .dBus_cmd_payload_mask(dBus_cmd_payload_mask),
    .dBus_cmd_payload_address(dBus_cmd_payload_address),
    .dBus_cmd_payload_data(dBus_cmd_payload_data),
    .dBus_cmd_payload_size(dBus_cmd_payload_size),
    .dBus_rsp_ready(dBus_rsp_ready),            // memory drives a ONE-CYCLE pulse when a response is available
    .dBus_rsp_error(dBus_rsp_error),
    .dBus_rsp_data(dBus_rsp_data),
    .clk(clk),
    .reset(reset)
  );

  // Simple memory with hex init and tiny MMIO
  simple_mem #(
    .BASE_ADDR(32'h80000000),  // map memory beginning at reset PC
    .MEM_BYTES(131072),              // 128 KiB
    .HEX_INIT("mem.hex")
  ) mem (
    .clk(clk),
    .reset(reset),

    // iBus
    .i_valid(iBus_cmd_valid),
    .i_ready(iBus_cmd_ready),
    .i_addr (iBus_cmd_payload_pc),
    .i_rsp_valid(iBus_rsp_valid),
    .i_rsp_inst(iBus_rsp_payload_inst),
    .i_rsp_error(iBus_rsp_payload_error),

    // dBus
    .d_valid(dBus_cmd_valid),
    .d_ready(dBus_cmd_ready),
    .d_wr   (dBus_cmd_payload_wr),
    .d_mask (dBus_cmd_payload_mask),
    .d_addr (dBus_cmd_payload_address),
    .d_wdata(dBus_cmd_payload_data),
    .d_size (dBus_cmd_payload_size),
    .d_rsp_valid(dBus_rsp_ready),    // NOTE: wired to DUT's dBus_rsp_ready port
    .d_rsp_error(dBus_rsp_error),
    .d_rdata(dBus_rsp_data)
  );

  initial begin
    // Safety timeout
    #2000000;
    $display("TIMEOUT");
    $finish;
  end
endmodule

// -------------------------------------------------------------
// Simple single-ported word-addressable memory + basic MMIO
// For this VexRiscv Simple bus variant:
//   - iBus: cmd_valid/ready -> rsp_valid (no rsp_ready port)
//   - dBus: cmd_valid/ready -> rsp_valid (NO explicit rsp_valid port in DUT; it's named dBus_rsp_ready)
// -------------------------------------------------------------
module simple_mem #(
  // lifted declarations for ModelSim compatibility
  parameter [31:0] BASE_ADDR = 32'h80000000,
  parameter        MEM_BYTES = 131072,
  parameter        HEX_INIT  = "mem.hex"
)(
  input  wire        clk,
  input  wire        reset,

  // Instruction bus (read-only)
  input  wire        i_valid,
  output wire        i_ready,
  input  wire [31:0] i_addr,
  output reg         i_rsp_valid,
  output reg  [31:0] i_rsp_inst,
  output wire        i_rsp_error,

  // Data bus (loads/stores)
  input  wire        d_valid,
  output wire        d_ready,
  input  wire        d_wr,
  input  wire [3:0]  d_mask,
  input  wire [31:0] d_addr,
  input  wire [31:0] d_wdata,
  input  wire [1:0]  d_size,      // unused here; core handles formatting
  output reg         d_rsp_valid, // Drive to DUT.dBus_rsp_ready
  output wire        d_rsp_error,
  output reg  [31:0] d_rdata
);
  integer idx;
  integer i;
  reg [31:0] w;
  localparam WORDS = MEM_BYTES / 4;
  localparam UART_TX  = 32'hF0010000;
  localparam SIM_EXIT = 32'hF0010004;

  reg [31:0] mem [0:WORDS-1];
  initial begin
    for (i = 0; i < WORDS; i = i+1) mem[i] = 32'h00000013; // NOP (ADDI x0,x0,0)
    $readmemh(HEX_INIT, mem);
  end

  assign i_ready = 1'b1;
  assign d_ready = 1'b1;
  assign i_rsp_error = 1'b0;
  assign d_rsp_error = 1'b0;

  // Convert absolute addr to mem index (word-aligned) when in range
  function [31:0] word_index;
    input [31:0] addr;
    begin
      word_index = (addr - BASE_ADDR) >> 2;
    end
  endfunction

  function in_mem;
    input [31:0] addr;
    begin
      in_mem = (addr >= BASE_ADDR) && (addr < (BASE_ADDR + MEM_BYTES));
    end
  endfunction

  // iBus: 1-cycle latency
  always @(posedge clk) begin
    if (reset) begin
      i_rsp_valid <= 1'b0;
      i_rsp_inst  <= 32'd0;
    end else begin
      i_rsp_valid <= i_valid;
      if (i_valid) begin
        if (in_mem(i_addr)) begin
          i_rsp_inst <= mem[word_index(i_addr)];
        end else begin
          i_rsp_inst <= 32'h00000013; // NOP if out-of-range
        end
      end
    end
  end

  // dBus: accept, do write/read, then raise d_rsp_valid for one cycle
  always @(posedge clk) begin
    if (reset) begin
      d_rsp_valid <= 1'b0;
      d_rdata     <= 32'd0;
    end else begin
      d_rsp_valid <= 1'b0; // default low; pulse on responses

      if (d_valid && d_ready) begin
        // Writes
        if (d_wr) begin
          if (d_addr == UART_TX) begin
            $write("%c", d_wdata[7:0]);
          end else if (d_addr == SIM_EXIT) begin
            if (d_wdata[0]) begin
              $display("\n[SIM] PASS: SIM_EXIT=1");
            end else begin
              $display("\n[SIM] EXIT code: %0d", d_wdata);
            end
            if ($test$plusargs("STOP_ON_EXIT")) $stop; else $finish;
          end else if (in_mem(d_addr)) begin
            idx = word_index(d_addr);
            w   = mem[idx];
            if (d_mask[0]) w[7:0]   = d_wdata[7:0];
            if (d_mask[1]) w[15:8]  = d_wdata[15:8];
            if (d_mask[2]) w[23:16] = d_wdata[23:16];
            if (d_mask[3]) w[31:24] = d_wdata[31:24];
            mem[idx] = w;
          end
          d_rsp_valid <= 1'b1; // acknowledge store
        end else begin
          // Reads
          if (d_addr == UART_TX || d_addr == SIM_EXIT) begin
            d_rdata <= 32'h0;
          end else if (in_mem(d_addr)) begin
            d_rdata <= mem[word_index(d_addr)];
          end else begin
            d_rdata <= 32'h00000000;
          end
          d_rsp_valid <= 1'b1; // data is valid this cycle
        end
      end
    end
  end
endmodule
