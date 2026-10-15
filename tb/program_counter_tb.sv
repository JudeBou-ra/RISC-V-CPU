`timescale 1ns/1ps

module pc_tb;

    logic clk_i;
    logic rst; // if high, reset starting address
    logic pc_write_i; // if high, load next address
    logic [31:0] pc_next_i;
    logic [31:0] pc_o;

    program_counter dut (
        .clk_i(clk_i), // .clk_i is the port name from our module, the (clk_i) is the signal from the tb
        .rst(rst),
        .pc_write_i(pc_write_i),
        .pc_next_i(pc_next_i),
        .pc_o(pc_o)
    );

    // clock switches every 5 nanoseconds
    initial clk_i = 0;
    always #5 clk_i = ~clk_i;

    initial begin
        rst = 1;
        pc_write_i = 0;
        pc_next_i = 0;

        @(negedge clk_i);
        rst = 0;

        pc_write_i = 1;
        pc_next_i = 32'd4;
        @(negedge clk_i);
        assert (pc_o == 32'd4) else $fatal(1, "Load failed");

        pc_write_i = 0;
        pc_next_i = 32'd8;
        @(negedge clk_i);
        assert (pc_o == 32'd4) else $fatal(1, "Hold failed");

        $finish;
    end

endmodule