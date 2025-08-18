module imm_gen (
    // Input
    input  logic [31:0] instruction,

    // Output
    output logic [31:0] immediate
);
    // The opcode determines the immediate format
    logic [6:0] opcode = instruction[6:0];


    always_comb begin
        case (opcode)
            // I-type (Loads, jalr, and immediate arithmetic)
            7'b0000011, 7'b0010011, 7'b1100111:
                // imm[11:0] from instr[31:20], sign-extended from instr[31]
                immediate = {{20{instruction[31]}}, instruction[31:20]};

            // S-type (Stores)
            7'b0100011:
                // imm[11:0] assembled from instr[31:25] and instr[11:7]
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

            // B-type (Branches)
            7'b1100011:
                // imm[12:1] assembled and shifted, sign-extended
                immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

            // U-type (lui, auipc)
            7'b0110111, 7'b0010111:
                // imm[31:12] from instr[31:12], with lower 12 bits as 0
                immediate = {instruction[31:12], 12'b0};

            // J-type (jal)
            7'b1101111:
                // imm[20:1] assembled and shifted, sign-extended
                immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

            default:
                immediate = 32'bx;
        endcase
    end
endmodule