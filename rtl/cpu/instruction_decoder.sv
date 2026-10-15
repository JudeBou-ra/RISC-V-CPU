`timescale 1ns/1ps
// combinational logic
module instruction_decoder(

    input logic [31:0] instruction_i,

    // instruction fields
    output logic [6:0] opcode_o,
    output logic [2:0] funct3_o,
    output logic [6:0] funct7_o,

    // registers
    output logic [4:0] dest_reg_o,
    output logic [4:0] rs1_o,
    output logic [4:0] rs2_o,

    // for immediate
    output logic [31:0] imm_o,

    // enum types
    output logic R,
    output logic U,
    output logic S,
    output logic I,
    output logic B,
    output logic J
);

assign opcode_o = instruction_i[6:0];

assign funct3_o = instruction_i[14:12];
assign funct7_o = instruction_i[31:25];

assign rs1_o = instruction_i[19:15];
assign rs2_o = instruction_i[24:20];
assign dest_reg_o = instruction_i[11:7];

// specific types
assign R = {opcode_o[6], opcode_o[5], opcode_o[4], opcode_o[2]} == 4'b0110;
assign U = {opcode_o[6], opcode_o[4], opcode_o[3], opcode_o[2]} == 4'b0101;
assign S = {opcode_o[6], opcode_o[5], opcode_o[4]} == 3'b010;
assign J = {opcode_o[6], opcode_o[5], opcode_o[4], opcode_o[3]} == 4'b1101;
assign B = opcode_o[6:2] == 5'b11000;
assign I = (opcode_o[6:2] == 5'b00100) ||
           (opcode_o[6:2] == 5'b00000) ||
           (opcode_o[6:2] == 5'b11001);

always_comb begin
    imm_o = 32'b0;
    
    if (I) begin
        // preserves the immediate signed two's compliment value
        // concatenates the 20 bits with the signed bits value, and the 12 bits from [31:20]
        imm_o = {{20{instruction_i[31]}}, instruction_i[31:20]}; // {20{instruction_i[31]} - replication operator, replications the single bit (instruction_i[31]) 20 times
    end else if (S) begin
        imm_o = {{20{instruction_i[31]}}, instruction_i[31:25], instruction_i[11:7]};
    end else if (B) begin
        imm_o = {{20{instruction_i[31]}}, instruction_i[7], instruction_i[30:25], instruction_i[11:8], 1'b0};
    end else if (U) begin
        imm_o = {instruction_i[31], instruction_i[30:25], instruction_i[24:21], instruction_i[20], instruction_i[19:12], 12'b0};
    end else if (J) begin
        imm_o = {{12{instruction_i[31]}}, instruction_i[19:12], instruction_i[20], instruction_i[30:25], instruction_i[24:21], 1'b0};
    end else begin
        imm_o = 0;
    end


end



endmodule