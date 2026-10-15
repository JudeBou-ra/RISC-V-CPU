`timescale 1ns/1ps
module register (
    input logic clk_i, // Clock
    input logic rst_i, // Reset Pin

    // Source Register I/O (registers that act as just placeholders for real registers later)
    input logic [4:0] rs1_address_i, // source register 1
    input logic [4:0] rs2_address_i, // sourse register 2
    output logic [31:0] rs1_data_o, // output/data of source register 1
    output logic [31:0] rs2_data_o, // output/data of source reigster 2

    // Destination Register (registers that act as just placeholders for real registers later)
    input logic write_en,
    input logic [4:0] rd_address_i,
    input logic [31:0] rd_data_i 
);
    // creating registers, 32 registers, each register has 32 bits
    logic [31:0] registers [0:31]; 

    always_comb begin // starts comb logic, so whenever an input changes, they re-evalute the expressions
        if (rs1_address_i == 5'd0) begin // if the register is b'00000 the output should be 0 bc its the 0 register
            rs1_data_o = 32'd0;
        end else begin
            rs1_data_o = registers[rs1_address_i]; // grabs whatever is in the index of the register
        end

        if (rs2_address_i == 5'd0) begin // if the register is b'00000 the output should be 0
            rs2_data_o = 32'd0;
        end else begin
            rs2_data_o = registers[rs2_address_i]; // grabs whatever is in the index of the register
        end
    end

    always_ff @(posedge clk_i) begin // at the rising edge of the clock, execute this code block
        if (rst_i) begin // reset == 1, go through each register and make it 0
            for (int i = 0; i < 32; i++) begin
                registers[i] <= 32'd0;
            end
        end else if (write_en && rd_address_i != 5'd0) begin // if write enable == 1, and the result address isn't the x0 address
            registers[rd_address_i] <= rd_data_i; // go to the destination address, uses a non-blocking assignment operator
        end
    end

endmodule