`timescale 1ns/1ps

module control_unit(
    input logic [6:0] opcode_i,
    input logic [2:0] funct3_i,
    input logic [6:0] funct7_i,

    // Decode-stage controls; carry these through pipeline registers to their use stage.
    output logic alu_src_pc_o,   // Use PC as ALU input A (AUIPC/JAL target)
    output logic alu_src_imm_o,  // Use immediate as ALU input B
    output logic [3:0] alu_op_o,
    output logic branch_o,       // Conditional branch; funct3 selects condition
    output logic jump_o,         // JAL/JALR redirect the PC
    output logic mem_read_o,     // Read data memory (MEM stage)
    output logic mem_write_o,    // Write data memory (MEM stage)
    output logic reg_write_o,    // Write destination register (WB stage)
    output logic [1:0] wb_sel_o   // 00=ALU, 01=memory, 10=PC+4
);

    // define all of our operations
    localparam logic [6:0] OP_LOAD = 7'b0000011;
    localparam logic [6:0] OP_IMM = 7'b0010011;
    localparam logic [6:0] OP_AUIPC = 7'b0010111;
    localparam logic [6:0] OP_STORE = 7'b0100011;
    localparam logic [6:0] OP_REG = 7'b0110011;
    localparam logic [6:0] OP_LUI = 7'b0110111;
    localparam logic [6:0] OP_BRANCH = 7'b1100011;
    localparam logic [6:0] OP_JALR = 7'b1100111;
    localparam logic [6:0] OP_JAL = 7'b1101111;

    localparam logic [3:0] ALU_ADD = 4'h0;
    localparam logic [3:0] ALU_SUB = 4'h1;
    localparam logic [3:0] ALU_AND = 4'h2;
    localparam logic [3:0] ALU_OR  = 4'h3;
    localparam logic [3:0] ALU_XOR = 4'h4;
    localparam logic [3:0] ALU_SLL = 4'h5;
    localparam logic [3:0] ALU_SRL = 4'h6;
    localparam logic [3:0] ALU_SRA = 4'h7;
    localparam logic [3:0] ALU_SLT = 4'h8;
    localparam logic [3:0] ALU_SLTU = 4'h9;
    localparam logic [3:0] ALU_PASS_B = 4'hA;

    always_comb begin
        // initially sets everything to 0 to stop unknown behavior
        alu_src_pc_o = 1'b0;
        alu_src_imm_o = 1'b0;
        alu_op_o = ALU_ADD;
        branch_o = 1'b0;
        jump_o = 1'b0;
        mem_read_o = 1'b0;
        mem_write_o = 1'b0;
        reg_write_o = 1'b0;
        wb_sel_o = 2'b00;

        case (opcode_i) // initializes for cases
            OP_REG, OP_IMM: begin // if its the opcode for OP_REG or OP_IMM, use this branch
                alu_src_imm_o = (opcode_i == OP_IMM); // assigning the alu src to 1 if the operation uses immediates, 0 else

                case (funct3_i) // checks the funct3_i for cases
                    3'b000: begin // ADD and SUB operations
                        if (opcode_i == OP_REG && funct7_i == 7'b0100000) begin // specifically using funct7 for specificity
                            alu_op_o = ALU_SUB; // funct7 reflects an ALU_sub
                            reg_write_o = 1'b1;
                        end else if (opcode_i == OP_IMM || funct7_i == 7'b0000000) begin // funct7 reflects an ADD op
                            alu_op_o = ALU_ADD; // assigns op as ADD
                            reg_write_o = 1'b1; // enables writing to the registers
                        end
                    end
                    3'b001: begin // Shift Left Logical (SLL) operations
                        if (funct7_i == 7'b0000000) begin
                            alu_op_o = ALU_SLL;
                            reg_write_o = 1'b1;
                        end
                    end
                    3'b010: begin // Set Less Than (signed) SLT
                        if (opcode_i == OP_IMM || funct7_i == 7'b0000000) begin // Whether its IMM or R-type it works
                            alu_op_o = ALU_SLT;
                            reg_write_o = 1'b1;
                        end
                    end
                    3'b011: begin // SLT (unsigned)
                        if (opcode_i == OP_IMM || funct7_i == 7'b0000000) begin // same idea as ^
                            alu_op_o = ALU_SLTU;
                            reg_write_o = 1'b1;
                        end
                    end
                    3'b100: begin // Bitwise XOR
                        if (opcode_i == OP_IMM || funct7_i == 7'b0000000) begin // works with both I-type and R-type
                            alu_op_o = ALU_XOR;
                            reg_write_o = 1'b1;
                        end
                    end
                    3'b101: begin // Shift Right Logical / Arithmetic (SRL or SRA / SRLI or SRAI)
                        if (funct7_i == 7'b0100000) // funct7 bits for SRA
                            alu_op_o = ALU_SRA;
                        else if (funct7_i == 7'b0000000) begin // funct7 bits for SRL
                            alu_op_o = ALU_SRL;
                            reg_write_o = 1'b1;
                        end
                        if (funct7_i == 7'b0100000 &&
                            (opcode_i == OP_REG || opcode_i == OP_IMM)) // ensures that the write signal is 1 regardless of R or I types
                            reg_write_o = 1'b1;
                    end
                    3'b110: begin // Bitwise OR
                        if (opcode_i == OP_IMM || funct7_i == 7'b0000000) begin // works for both I and R type
                            alu_op_o = ALU_OR;
                            reg_write_o = 1'b1;
                        end
                    end
                    3'b111: begin // bitwise AND
                        if (opcode_i == OP_IMM || funct7_i == 7'b0000000) begin // works for both I and R type
                            alu_op_o = ALU_AND;
                            reg_write_o = 1'b1;
                        end
                    end
                    default: ; // nothing happens if nothing matches
                endcase
            end

            // NON-ARITHMETIC operations
            // wb_select
            // 00 : ALU result
            // 01 : Data read from memory
            // 10 : PC + 4 (increments PC)


            OP_LOAD: begin // Load data from memory
                alu_src_imm_o = 1'b1; // uses immediate value instead of register
                mem_read_o = 1'b1; // reads from memory using address from ALU
                reg_write_o = 1'b1; // allows write operations to the register
                wb_sel_o = 2'b01; // write back selection signal, tells the writeback mux which value to send to the reg
            end
            OP_STORE: begin // Store data to memory
                alu_src_imm_o = 1'b1; // uses immediate value instead of register
                mem_write_o = 1'b1; // enables the write signal
            end
            OP_BRANCH: begin // branch
                alu_op_o = ALU_SUB; // use subtraction to see if the two numbers are equal
                case (funct3_i)
                // b000 = BEQ (Branch if equal)
                // b001 = BNE (Branch is Not Equal)
                // b100 = BLT (Branch if less than signed)
                // b101 = BGE (Branch if Greater Than or Equal signed)
                // b110 = BLTU (Branch if Less than Unsigned)
                // b111 = BGEU (Branch if greater than or equal unsigned)
                    3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111:
                        branch_o = 1'b1;
                    default: ;
                endcase
            end
            OP_JAL: begin
                alu_src_pc_o = 1'b1;
                alu_src_imm_o = 1'b1;
                jump_o = 1'b1;
                reg_write_o = 1'b1;
                wb_sel_o = 2'b10;
            end
            OP_JALR: begin
                alu_src_imm_o = 1'b1;
                jump_o = (funct3_i == 3'b000);
                reg_write_o = jump_o;
                wb_sel_o = jump_o ? 2'b10 : 2'b00;
            end
            OP_AUIPC: begin
                alu_src_pc_o = 1'b1;
                alu_src_imm_o = 1'b1;
                reg_write_o = 1'b1;
            end
            OP_LUI: begin
                alu_src_imm_o = 1'b1;
                alu_op_o = ALU_PASS_B;
                reg_write_o = 1'b1;
            end
            default: ;
        endcase
    end


endmodule