`timescale 1ns/1ps

module branch_unit_tb;

    logic branch_i; // whether a branch command was called
    logic [2:0] funct3_i; // clarificiation of the Branch command
    logic [31:0] rs1_i; // register 1
    logic [31:0] rs2_i; // register 2
    logic branch_cond; // if the branch condition was met

    localparam logic [2:0]
        BEQ  = 3'b000,
        BNE  = 3'b001,
        BLT  = 3'b100,
        BGE  = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111;

    branch_unit dut ( // device under test, assigning the branch signals to the ports
        .branch_i(branch_i),
        .funct3_i(funct3_i),
        .rs1_i(rs1_i),
        .rs2_i(rs2_i),
        .branch_cond(branch_cond)
    );

    task automatic check_branch ( // an automated test formatter
        input string test_name,
        input logic branch_enable,
        input logic [2:0] funct3,
        input logic [31:0] rs1,
        input logic [31:0] rs2,
        input logic expected
    );
        branch_i = branch_enable;
        funct3_i = funct3;
        rs1_i = rs1;
        rs2_i = rs2;

        #1; // waits once cycle

        assert (branch_cond === expected)
            else $fatal(1, "%s: expected branch_cond=%b, got %b",
                        test_name, expected, branch_cond);

        $display("PASS: %s", test_name);
    endtask

    initial begin
        branch_i = 1'b0;
        funct3_i = BEQ;
        rs1_i = '0;
        rs2_i = '0;

        check_branch("BEQ equal",1'b1, BEQ,32'd5, 32'd5, 1'b1);
        check_branch("BEQ not equal",1'b1, BEQ,32'd5, 32'd6, 1'b0);
        check_branch("BNE not equal",1'b1, BNE,32'd5, 32'd6, 1'b1);
        check_branch("BNE equal", 1'b1, BNE,32'd5, 32'd5, 1'b0);

        check_branch("BLT negative < positive",1'b1, BLT, 32'hFFFF_FFFF, 32'd1, 1'b1);
        check_branch("BLT positive < negative",1'b1, BLT, 32'd1, 32'hFFFF_FFFF,1'b0);
        check_branch("BGE positive >= negative",1'b1, BGE, 32'd1, 32'hFFFF_FFFF, 1'b1);
        check_branch("BGE negative >= positive",1'b1, BGE, 32'hFFFF_FFFF,32'd1, 1'b0);

        check_branch("BLTU positive < unsigned max",
                                             1'b1, BLTU, 32'd1, 32'hFFFF_FFFF, 1'b1);
        check_branch("BLTU unsigned max < positive",
                                             1'b1, BLTU, 32'hFFFF_FFFF, 32'd1, 1'b0);
        check_branch("BGEU unsigned max >= positive",
                                             1'b1, BGEU, 32'hFFFF_FFFF,32'd1,1'b1);
        check_branch("BGEU positive >= unsigned max",
                                             1'b1, BGEU, 32'd1, 32'hFFFF_FFFF, 1'b0);

        check_branch("branch disabled", 1'b0, BEQ,  32'd5, 32'd5,1'b0);
        check_branch("unsupported funct3",1'b1, 3'b010, 32'd5, 32'd5, 1'b0);

        $display("All branch unit tests passed!");
        $finish;
    end

endmodule