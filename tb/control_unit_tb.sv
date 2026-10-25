`timescale 1ns/1ps

module control_unit_tb;

    // creates the signals we are going to be using for this tb
    logic [6:0] opcode_i;
    logic [2:0] funct3_i;
    logic [6:0] funct7_i;

    logic       alu_src_pc_o;
    logic       alu_src_imm_o;
    logic [3:0] alu_op_o;
    logic       branch_o;
    logic       jump_o;
    logic       mem_read_o;
    logic       mem_write_o;
    logic       reg_write_o;
    logic [1:0] wb_sel_o;

    // Names the instructions the DUT will be using
    localparam logic [6:0]
        OP_LOAD   = 7'b0000011,
        OP_IMM    = 7'b0010011,
        OP_AUIPC  = 7'b0010111,
        OP_STORE  = 7'b0100011,
        OP_REG    = 7'b0110011,
        OP_LUI    = 7'b0110111,
        OP_BRANCH = 7'b1100011,
        OP_JALR   = 7'b1100111,
        OP_JAL    = 7'b1101111;

    // gives a value to all the ALU operations
    localparam logic [3:0]
        ALU_ADD    = 4'h0,
        ALU_SUB    = 4'h1,
        ALU_AND    = 4'h2,
        ALU_OR     = 4'h3,
        ALU_XOR    = 4'h4,
        ALU_SLL    = 4'h5,
        ALU_SRL    = 4'h6,
        ALU_SRA    = 4'h7,
        ALU_SLT    = 4'h8,
        ALU_SLTU   = 4'h9,
        ALU_PASS_B = 4'hA;


    // {alu_src_pc, alu_src_imm, alu_op, branch, jump,
    //  mem_read, mem_write, reg_write, wb_sel}
    // control values for all the operations needed, sends values where they should be
    localparam logic [12:0]
        CTRL_DEFAULT = {1'b0, 1'b0, ALU_ADD,    1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00},
        CTRL_R_ADD   = {1'b0, 1'b0, ALU_ADD,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_R_SUB   = {1'b0, 1'b0, ALU_SUB,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_R_SLL   = {1'b0, 1'b0, ALU_SLL,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_R_SLT   = {1'b0, 1'b0, ALU_SLT,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_R_SLTU  = {1'b0, 1'b0, ALU_SLTU,   1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_R_XOR   = {1'b0, 1'b0, ALU_XOR,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_R_SRL   = {1'b0, 1'b0, ALU_SRL,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_R_SRA   = {1'b0, 1'b0, ALU_SRA,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_R_OR    = {1'b0, 1'b0, ALU_OR,     1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_R_AND   = {1'b0, 1'b0, ALU_AND,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_I_ADD   = {1'b0, 1'b1, ALU_ADD,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_I_XOR   = {1'b0, 1'b1, ALU_XOR,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_I_SRL   = {1'b0, 1'b1, ALU_SRL,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_I_SRA   = {1'b0, 1'b1, ALU_SRA,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_LOAD    = {1'b0, 1'b1, ALU_ADD,    1'b0, 1'b0, 1'b1, 1'b0, 1'b1, 2'b01},
        CTRL_STORE   = {1'b0, 1'b1, ALU_ADD,    1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 2'b00},
        CTRL_BRANCH  = {1'b0, 1'b0, ALU_SUB,    1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00},
        CTRL_JAL     = {1'b1, 1'b1, ALU_ADD,    1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10},
        CTRL_JALR    = {1'b0, 1'b1, ALU_ADD,    1'b0, 1'b1, 1'b0, 1'b0, 1'b1, 2'b10},
        CTRL_JALR_INVALID = {1'b0, 1'b1, ALU_ADD, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00},
        CTRL_BRANCH_INVALID = {1'b0, 1'b0, ALU_SUB, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 2'b00},
        CTRL_AUIPC   = {1'b1, 1'b1, ALU_ADD,    1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00},
        CTRL_LUI     = {1'b0, 1'b1, ALU_PASS_B, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 2'b00};

    // connects the tb signals we created to the actual device under test
    control_unit dut (
        .opcode_i(opcode_i),
        .funct3_i(funct3_i),
        .funct7_i(funct7_i),
        .alu_src_pc_o(alu_src_pc_o),
        .alu_src_imm_o(alu_src_imm_o),
        .alu_op_o(alu_op_o),
        .branch_o(branch_o),
        .jump_o(jump_o),
        .mem_read_o(mem_read_o),
        .mem_write_o(mem_write_o),
        .reg_write_o(reg_write_o),
        .wb_sel_o(wb_sel_o)
    );

    // used as a test formatter, easy so you don't have to keep writing tests
    task automatic check_control(
        input string test_name,
        input logic [6:0] opcode, // Identifies instruction category
        input logic [2:0] funct3, // finds specific instruction
        input logic [6:0] funct7, // further distinguishes instructions
        input logic [12:0] expected // expected output
    );
        logic [12:0] actual; // actual output given
        begin
            opcode_i = opcode;
            funct3_i = funct3;
            funct7_i = funct7;
            #1; // wait 1 sim time

            // uses combinational logic, so whenever these values change, control signals are updated

            actual = {
                alu_src_pc_o, alu_src_imm_o, alu_op_o, branch_o, jump_o,
                mem_read_o, mem_write_o, reg_write_o, wb_sel_o
            }; // combines all these 1 bit signals into a 13 bit actual value

            // insures correct control signals are outputted for the specifci instruction
            assert (actual === expected)
                else $fatal(1, "%s: expected %b, got %b", test_name, expected, actual);

            $display("PASS: %s", test_name);
        end
    endtask

    initial begin
        opcode_i = '0;
        funct3_i = '0;
        funct7_i = '0;

        // R-type ALU operations (funct3 selects the operation)
        check_control("R-type ADD",  OP_REG, 3'b000, 7'b0000000, CTRL_R_ADD);
        check_control("R-type SUB",  OP_REG, 3'b000, 7'b0100000, CTRL_R_SUB);
        check_control("R-type SLL",  OP_REG, 3'b001, 7'b0000000, CTRL_R_SLL);
        check_control("R-type SLT",  OP_REG, 3'b010, 7'b0000000, CTRL_R_SLT);
        check_control("R-type SLTU", OP_REG, 3'b011, 7'b0000000, CTRL_R_SLTU);
        check_control("R-type XOR",  OP_REG, 3'b100, 7'b0000000, CTRL_R_XOR);
        check_control("R-type SRL",  OP_REG, 3'b101, 7'b0000000, CTRL_R_SRL);
        check_control("R-type SRA",  OP_REG, 3'b101, 7'b0100000, CTRL_R_SRA);
        check_control("R-type OR",   OP_REG, 3'b110, 7'b0000000, CTRL_R_OR);
        check_control("R-type AND",  OP_REG, 3'b111, 7'b0000000, CTRL_R_AND);

        // I-type ALU operations use an immediate as ALU input B
        check_control("ADDI",  OP_IMM, 3'b000, 7'b0000000, CTRL_I_ADD);
        check_control("XORI",  OP_IMM, 3'b100, 7'b0000000, CTRL_I_XOR);
        check_control("SRLI",  OP_IMM, 3'b101, 7'b0000000, CTRL_I_SRL);
        check_control("SRAI",  OP_IMM, 3'b101, 7'b0100000, CTRL_I_SRA);

        // Memory operations choose immediate addressing, and loads write back data
        check_control("LW", OP_LOAD, 3'b010, 7'b0000000, CTRL_LOAD);
        check_control("SW", OP_STORE, 3'b010, 7'b0000000, CTRL_STORE);

        // All six standard conditional-branch funct3 values are supported
        check_control("BEQ",  OP_BRANCH, 3'b000, 7'b0000000, CTRL_BRANCH);
        check_control("BNE",  OP_BRANCH, 3'b001, 7'b0000000, CTRL_BRANCH);
        check_control("BLT",  OP_BRANCH, 3'b100, 7'b0000000, CTRL_BRANCH);
        check_control("BGE",  OP_BRANCH, 3'b101, 7'b0000000, CTRL_BRANCH);
        check_control("BLTU", OP_BRANCH, 3'b110, 7'b0000000, CTRL_BRANCH);
        check_control("BGEU", OP_BRANCH, 3'b111, 7'b0000000, CTRL_BRANCH);

        // Jumps write PC+4 back to rd, JALR only accepts funct3=000
        check_control("JAL",         OP_JAL,  3'b000, 7'b0000000, CTRL_JAL);
        check_control("JALR",        OP_JALR, 3'b000, 7'b0000000, CTRL_JALR);
        check_control("Invalid JALR", OP_JALR, 3'b001, 7'b0000000, CTRL_JALR_INVALID);

        // Upper immediate instructions select their respective ALU inputs
        check_control("AUIPC", OP_AUIPC, 3'b000, 7'b0000000, CTRL_AUIPC);
        check_control("LUI",   OP_LUI,   3'b000, 7'b0000000, CTRL_LUI);

        // Invalid encodings should not accidentally enable side effects
        check_control("Invalid R-type funct7", OP_REG, 3'b000, 7'b0000001, CTRL_DEFAULT);
        check_control("Invalid branch funct3", OP_BRANCH, 3'b010, 7'b0000000, CTRL_BRANCH_INVALID);
        check_control("Unsupported opcode", 7'b1111111, 3'b000, 7'b0000000, CTRL_DEFAULT);

        $display("All control unit tests passed!");
        $finish;
    end

endmodule
