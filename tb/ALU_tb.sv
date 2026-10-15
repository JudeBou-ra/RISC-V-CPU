`timescale 1ns/1ps

module ALU_tb;

logic [31:0] a_i;
logic [31:0] b_i;
logic [3:0] alu_op_i;
logic [31:0] result_o;
logic zero_o;

localparam logic [3:0]
    ALU_ADD = 4'h0,
    ALU_SUB = 4'h1,
    ALU_AND = 4'h2,
    ALU_OR = 4'h3,
    ALU_XOR = 4'h4,
    ALU_SLL = 4'h5,
    ALU_SRL = 4'h6,
    ALU_SRA = 4'h7,
    ALU_SLT = 4'h8,
    ALU_SLTU  = 4'h9,
    ALU_PASS_B = 4'hA;

ALU #(.WIDTH(32)) dut ( // creates an ALU object to test on, sets ALU width parameter to 32 bits, dut = Device under test
    // syntax: .module_port_name(testbench_signal)
    .a_i(a_i),
    .b_i(b_i),
    .alu_op_i(alu_op_i),
    .result_o(result_o),
    .zero_o(zero_o)
);

task automatic check_alu (
    input string test_name,
    input logic [3:0] operation,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [31:0] expected_result
);

a_i = a;
b_i = b;
alu_op_i = operation;

#1;

// == : may return X if the unknowns affect the comparison
// === : compares the entire value including X and Z and always gives a 1 or 0
// %s: prints a string filled with test_name
// %h: prints a hexadecimal number, filled with both, expected, and result_o
assert (result_o === expected_result) // always returns 0, or 1, and compares all bits including X and Z
    else $fatal(1, "%s expected %h, got %h", test_name, expected_result, result_o);

assert (zero_o === (expected_result == 32'd0))
    else $fatal(1, "%s: incorrect zero flag", test_name);

$display("PASS: %s", test_name);
endtask

initial begin
    a_i = '0;
    b_i = '0;
    alu_op_i = ALU_ADD;

    check_alu ("ALU ADD", ALU_ADD, 32'd5, 32'd10, 32'd15);
    check_alu ("ALU SUB", ALU_SUB, 32'd10, 32'd5, 32'd5);
    check_alu ("ALU ZERO", ALU_SUB, 32'd5, 32'd5, 32'd0);
    check_alu ("ALU ADD weaparound", ALU_ADD, 32'hFFFF_FFFF, 32'd1, 32'd0);

    check_alu ("ALU AND", ALU_AND, 32'd5, 32'd1, 32'd1);
    check_alu ("ALU OR", ALU_OR, 32'd5, 32'd3, 32'd7);
    check_alu ("ALU XOR", ALU_XOR, 32'd5, 32'd3, 32'd6);

    // shift left and right, logic and arithmatic
    check_alu("ALU SLL", ALU_SLL, 32'd1, 32'd3, 32'd8);
    check_alu("ALU SRL", ALU_SRL, 32'h80000000, 32'd1, 32'h40000000);
    check_alu("ALU SRA", ALU_SRA, 32'h80010000, 32'd1, 32'hC0008000);

    // less than check for logic and arithmatic
    check_alu("ALU SLT", ALU_SLT, 32'h80010000, 32'h80001000, 32'd0);
    check_alu("ALU SLTU", ALU_SLTU, 32'h80010000, 32'h80001000, 32'd0);

    check_alu("ALU PASS B", ALU_PASS_B, 32'd84, 32'd93, 32'd93);

    
    check_alu("ALU 5 bit b_i shift", ALU_SLL, 32'h00010000, 32'h00001000, 32'h00010000);

    check_alu("SLT equal",  ALU_SLT,  32'd5, 32'd5, 32'd0);
    check_alu("SLTU equal", ALU_SLTU, 32'd5, 32'd5, 32'd0);
    
    // shifting by 0
    check_alu("SLL by 0", ALU_SLL, 32'h8000_0001, 32'd0, 32'h8000_0001);
    check_alu("SRL by 0", ALU_SRL, 32'h8000_0001, 32'd0, 32'h8000_0001);
    check_alu("SRA by 0", ALU_SRA, 32'h8000_0001, 32'd0, 32'h8000_0001);

    // shifting by 31
    check_alu("SLL by 31", ALU_SLL,32'h0000_0001, 32'd31, 32'h8000_0000);
    check_alu("SRL by 31", ALU_SRL,32'h8000_0000, 32'd31, 32'h0000_0001);
    check_alu("SRA negative by 31", ALU_SRA,32'h8000_0000, 32'd31, 32'hFFFF_FFFF);
    check_alu("SRA positive by 31", ALU_SRA, 32'h7FFF_FFFF, 32'd31, 32'h0000_0000);

    // unsupported
    check_alu("ALU Unsupported B", 4'hB, 32'h80010000, 32'h80001000, 32'd0);
    check_alu("ALU Unsupported F", 4'hF, 32'h80010000, 32'h80001000, 32'd0);
    $display("All ALU tests passed!");
    $finish;
end



endmodule