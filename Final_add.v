`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2023 09:32:18 PM
// Design Name: 
// Module Name: Final_add
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Final_add(
        input clk,
        input wire[4:0]wait_ctr,    // Wait counter of reading psum from GB (from controller)
        input wire[3:0]cur_state,   // Current state
        input wire[63:0]result0,    // Psum from PE0
        input wire[63:0]result1,
        input wire[63:0]result2,
        input wire[63:0]result3,
        input wire[63:0]result4,    
        input wire[63:0]result5,
        input wire[63:0]result6,    
        input wire[63:0]result7,    
        input wire[63:0]psum,       // Psum from GB
        output reg [63:0] add_result    // Final result (add_result6 + psum)
    );
    
    reg [63:0] add_result0;         // 1st layer of adder results
    reg [63:0] add_result1;
    reg [63:0] add_result2;
    reg [63:0] add_result3;
    reg [63:0] add_result4;         // 2nd layer of adder results
    reg [63:0] add_result5;
    reg [63:0] add_result6;         // 3rd layer of adder result
    reg [63:0] psum_GB;
    
    real r0;        // Real value of add_result0
    real r1;
    real r2;
    real r3;
    real r4;
    real r5;
    real r6;
    real r7;
    
    // Initialize
    initial begin
        add_result0 = 0;
        add_result1 = 0;
        add_result2 = 0;
        add_result3 = 0;
        add_result4 = 0;
        add_result5 = 0;
        add_result6 = 0;
        add_result = 0;
        psum_GB = 0;
    end
    
    // Combinational computation of real value
    always@(*)begin
        r0 = $bitstoreal(result0) + $bitstoreal(result1);
        r1 = $bitstoreal(result2) + $bitstoreal(result3);
        r2 = $bitstoreal(result4) + $bitstoreal(result5);
        r3 = $bitstoreal(result6) + $bitstoreal(result7);
        r4 = $bitstoreal(add_result0) + $bitstoreal(add_result1);
        r5 = $bitstoreal(add_result2) + $bitstoreal(add_result3);
        r6 = $bitstoreal(add_result4) + $bitstoreal(add_result5);
        r7 = $bitstoreal(add_result6) + $bitstoreal(psum_GB);
    end
    
    // Computation
    always@(posedge clk)begin
        if(cur_state == 7) begin
            // 1st layer computation
            if(wait_ctr == 0) begin
                add_result0 <= $realtobits(r0);
                add_result1 <= $realtobits(r1);
                add_result2 <= $realtobits(r2);
                add_result3 <= $realtobits(r3);
            end
            // 2nd layer computation
            else if(wait_ctr == 1) begin
                add_result4 <= $realtobits(r4);
                add_result5 <= $realtobits(r5);
            end
            // 3rd layer computation
            else if(wait_ctr == 2) begin
                add_result6 <= $realtobits(r6);
            end
            else if(wait_ctr == 10) begin
                psum_GB <= psum;
            end
            // Final computation
            else if(wait_ctr == 11) begin
                add_result <= $realtobits(r7);
            end
        end
        // Clear
        else begin
            add_result0 <= 0;
            add_result1 <= 0;
            add_result2 <= 0;
            add_result3 <= 0;
            add_result4 <= 0;
            add_result5 <= 0;
            add_result6 <= 0;
            add_result <= 0;
        end
    end
    
endmodule
