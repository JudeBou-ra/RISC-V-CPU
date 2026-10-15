`timescale 1ns/1ps

module tb_register_file;
    
    logic clk_i;
    logic rst_i;

    logic [4:0] rs1_address_i;
    logic [4:0] rs2_address_i;

    logic [31:0]  rs1_data_o;
    logic [31:0] rs2_data_o;

    logic write_en;
    logic [4:0] rd_address_i;
    logic [31:0] rd_data_i;

    // dut = Device Under Test, and it is the name of the register we created
    register dut (
        clk_i,
        rst_i,
        rs1_address_i,
        rs2_address_i,
        rs1_data_o,
        rs2_data_o,
        write_en,
        rd_address_i,
        rd_data_i
    );

    // clock switches every 5 nanoseconds
    initial clk_i = 0;
    always #5 clk_i = ~clk_i;

    // test bench starts here
    initial begin
        rst_i = 1;
        write_en = 0;

        rs1_address_i = 0;
        rs2_address_i = 0;
        rd_address_i = 0;
        rd_data_i = 0;

        @(posedge clk_i); // wait for the rising edge
        @(negedge clk_i); // wait for the falling edge

        rst_i = 0;

        // TODO: Test writing into register x5
        write_en = 1'b1;
        rd_address_i = 5'b00101;
        rd_data_i = 32'd42;

        @(posedge clk_i);
        @(negedge clk_i);

        write_en = 1'b0;

        rs1_address_i = 5'd5;
        #1;

        assert(rs1_data_o == 32'd42)
            else $fatal(1, "ERROR: Register x5 does not contain 42");

        $display("PASS: Register x5 contains 42");
        // TODO: Test reading from register x5
        rs1_address_i = 5'd5;

        #1; // have time for combinational logic to catch up

        assert (rs1_data_o == 32'd42)
            else $fatal(1, "ERROR: Register x5 does not contain 42");

        $display("PASS: Register x5 does contain 42");


        // TODO: Test that x0 always returns zero
        write_en = 1'b1;
        rd_address_i = 5'b00000;
        rd_data_i = 32'd5;

        @(posedge clk_i);
        @(negedge clk_i);

        write_en = 1'b0;
        
        rs1_address_i = 5'd0;
        #1;

        assert(rs1_data_o == 32'd0)
            else $fatal(1, "ERROR: Register x0 does not contain 0");
        $display("PASS: Register x0 contains 0");
        $finish;

    end

endmodule