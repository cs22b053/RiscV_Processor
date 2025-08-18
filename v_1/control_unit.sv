//
// Main Control Unit
//
// - Decodes the instruction's opcode.
// - Generates the primary control signals for the datapath.
//
module control_unit (
    // Input
    input  logic [6:0] opcode,

    // Outputs
    output logic       branch,    // Is this a branch instruction?
    output logic       mem_read,  // Read from data memory?
    output logic       mem_to_reg,// Data to register file from memory or ALU?
    output logic [1:0] alu_op,    // ALU operation type (for ALU Control)
    output logic       mem_write, // Write to data memory?
    output logic       alu_src,   // ALU operand B from register or immediate?
    output logic       reg_write  // Write to register file?
);
    // Default values are for an unknown instruction (do nothing)
    always_comb begin
        // Set default values to prevent latches
        branch     = 1'b0;
        mem_read   = 1'b0;
        mem_to_reg = 1'b0;
        alu_op     = 2'b00; // R-type
        mem_write  = 1'b0;
        alu_src    = 1'b0; // Default to reading from register file
        reg_write  = 1'b0;

        case (opcode)
            // R-type (add, sub, etc.)
            7'b0110011: begin
                reg_write  = 1'b1;
                // All other signals are default (0)
            end
            // I-type (lw)
            7'b0000011: begin
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_op     = 2'b01; // I-type (add for address calc)
                alu_src    = 1'b1;
                reg_write  = 1'b1;
            end
            // S-type (sw)
            7'b0100011: begin
                mem_write  = 1'b1;
                alu_op     = 2'b01; // I-type (add for address calc)
                alu_src    = 1'b1;
                // reg_write is 0
            end
            // B-type (beq)
            7'b1100011: begin
                branch     = 1'b1;
                alu_op     = 2'b10; // B-type (subtract for compare)
                // alu_src is 0
            end
            // I-type (addi)
            7'b0010011: begin
                reg_write  = 1'b1;
                alu_src    = 1'b1;
                alu_op     = 2'b01; // I-type
            end
            // U-type (lui)
            7'b0110111: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = 2'b11; // LUI-type
            end
             // J-type (jal)
            7'b1101111: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
                // Add specific handling for JAL if needed, for now treat like U-type
                // for alu_src and reg_write
            end
            // I-type (jalr)
            7'b1100111: begin
                reg_write = 1'b1;
                alu_src = 1'b1;
            end
            default: begin
                // Use default values
            end
        endcase
    end
endmodule