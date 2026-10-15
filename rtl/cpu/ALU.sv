`timescale 1ns/1ps
module ALU #(
    parameter int WIDTH = 32
) (
    input  logic [WIDTH-1:0] a_i, // another input
    input  logic [WIDTH-1:0] b_i, // one input
    input  logic [3:0]      alu_op_i, // op code for the ALU operation
    output logic [WIDTH-1:0] result_o, // result of the ALU operation
    output logic            zero_o // tells us if the result is 0
);

    localparam int SHIFT_WIDTH = $clog2(WIDTH); // gives ceiling of log2(WIDTH) for shift amount width

    // These are starter encodings, not mandated RISC-V instruction encodings.
    // Keep the decoder and this ALU in agreement.
    typedef enum logic [3:0] {
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
        ALU_PASS_B = 4'hA
    } alu_op_t;

    always_comb begin
        // Keep this assignment (or an equivalent default) to prevent
        //       inferred latches while you fill in the operation cases.
        result_o = '0;

        case (alu_op_i)
            ALU_ADD: begin
                //       wraparound behavior.
                result_o = a_i + b_i;
            end
            ALU_SUB: begin
                result_o = a_i - b_i;
            end
            ALU_AND: begin
                result_o = a_i & b_i;
            end
            ALU_OR: begin
                result_o = a_i | b_i;
            end
            ALU_XOR: begin
                result_o = a_i ^ b_i;
            end
            ALU_SLL: begin
                // shifts logically
                result_o = a_i << b_i[SHIFT_WIDTH-1:0]; // use the last 5 bits of b_i to determine shift amount for a_i
            end
            ALU_SRL: begin
                // shifts logically
                result_o = a_i >> b_i[SHIFT_WIDTH-1:0]; // >> exclusively used for logic because it removes signed bit
            end
            ALU_SRA: begin
                // Shift right arithmatically, so use a signed bit
                result_o = $signed(a_i) >>> b_i[SHIFT_WIDTH-1:0]; // >>> preserves the signed bit used for arithmatic
            end
            ALU_SLT: begin
                // set less than, it compares the signed versions of the input (from registers) a and b and then gives 1 if a is less than
                if ($signed(a_i) < $signed(b_i)) begin
                    result_o = 1; 
                end
                else begin
                    result_o = 0;
                end
            end
            ALU_SLTU: begin
                // Set result_o to 1 or 0 using an unsigned comparison.
                if (a_i < b_i) begin
                    result_o = 1;
                end
                else begin
                    result_o = 0;
                end
            end
            ALU_PASS_B: begin
                // Pass b_i through unchanged (useful for LUI datapaths).
                result_o = b_i;
            end
            default: begin
                // Unsupported operation: retain the defined zero result.
                result_o = '0;
            end
        endcase

        zero_o = (result_o == '0);
    end

endmodule
