`timescale 1ns/1ps
// combonational logic
module instr_decoder_tb;

    logic [31:0] instruction;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [4:0] dest_reg, rs1, rs2;
    logic [31:0] imm;
    logic R, U, S, I, B, J;

    instruction_decoder dut (
        .instruction_i(instruction),
        .opcode_o(opcode),
        .funct3_o(funct3),
        .funct7_o(funct7),
        .dest_reg_o(dest_reg),
        .rs1_o(rs1),
        .rs2_o(rs2),
        .imm_o(imm),
        .R(R), .U(U), .S(S), .I(I), .B(B), .J(J)
    );

    task automatic check_decoder (
        input logic [31:0] instruction_val,
        input logic [31:0] expected_imm
    );
        instruction = instruction_val;
        #1;

        // === : compares the entire value including X and Z and always gives a 1 or 0
        assert (imm === expected_imm)
            else $fatal (1, "Instruction %h: expected immediate %h, got %h", instruction_val, expected_imm, imm);
    endtask


    initial begin
        // ADD x3, x1, 5
        check_decoder ({12'd5, 5'd1, 3'b000, 5'd3, 7'b0010011}, 32'd5);

        // SUB x3, x1, 8 (Just adding -8 using twos compliment)
        // 1st val: -8, 2nd val: reg 1, 3rd val: funct3 (selects ADDI),4th val: reg 3, 5th val: opcode
        check_decoder({12'hFF8, 5'd1, 3'b000, 5'd3, 7'b0010011},32'hFFFF_FFF8);

    end



endmodule