`timescale 1ns/1ps

module branch_unit (
    input logic branch_i, // determines when a branch operation was called
    input logic [2:0] funct3_i,
    input logic [31:0] rs1_i,
    input logic [31:0] rs2_i,
    output logic branch_cond
);


always_comb begin 
    branch_cond = 1'b0;

    if (branch_i) begin
        case (funct3_i)
            3'b000: branch_cond = (rs1_i == rs2_i); // BEQ (Branch equal)
            3'b001: branch_cond = (rs1_i != rs2_i); // BNE (Branch Not Equal)
            3'b100: branch_cond = ($signed(rs1_i) < $signed(rs2_i)); // BLT (Branch Less Than)
            3'b101: branch_cond = ($signed(rs1_i) >= $signed(rs2_i)); // BGE (Branch Greater Equal)
            3'b110: branch_cond = (rs1_i < rs2_i); // BLTU (Branch Less Than Unsigned)
            3'b111: branch_cond = (rs1_i >= rs2_i); // BGEU (Branch Greater Than Unsigned)
            default: branch_cond = 1'b0; // Default Branch
        endcase

    end


end


endmodule