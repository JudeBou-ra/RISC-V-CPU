`timescale 1ns/1ps
module program_counter (
    input logic clk_i,
    input logic rst, // if high, reset starting address
    input logic pc_write_i, // if high, load next address
    input logic [31:0] pc_next_i,
    output logic [31:0] pc_o
);

// non-blocking for clocked logic - non-blocking checks RHS first, then schedules change for the clock
// blocking for combinational - blocking immediately changes the value before the next steps happen
// Asyncronous means whenever the rst bit is high, it will immediately start that logic
// the flip-flop is 32-bits because of the output and it turns the values in signals created and turns them into real stored values inside the flip-flop
always_ff @(posedge clk_i) begin // This is syncronous because it waits for the clock OR synchronizes with the clock
    if (rst) begin
        pc_o = 32'd0;
    end else if (pc_write_i) begin
        pc_o <= pc_next_i; // use non-blocking for assignment
    end

end

endmodule