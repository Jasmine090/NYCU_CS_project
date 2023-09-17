`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/29/2023 04:44:31 PM
// Design Name: 
// Module Name: PE
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


module PE(
        input clk,
        input wire write_w_PE,  // Wrrite weight enable
        input wire write_a_PE,  // Wrrite act enable
        input wire comp,        // Compute signal
        input wire shift,       // Shift signal
        input wire clear,       // Clear signal
        input wire[2:0]comp_idx,    // Compute index of weight / act registers
        input wire[2:0]write_idx,   // Write index of weight / act registers
        input wire[63:0] data_in,   // Data in from GB
        output reg[63:0] data_out   // Data out for Final Add
    );
    
    reg [63:0] psum;
    reg [63:0] acts[7:0];
    reg [63:0] w[7:0];
    real r;
    real zero = 0;
    
    initial begin
        psum = $realtobits(zero);
        data_out = 0;
    end
    integer i;
    always@(posedge clk)begin
        if(shift)begin
            for(i=0 ; i<7 ; i=i+1)begin
                acts[i] <= acts[i+1];
            end
        end
        else if(write_w_PE)begin
            w[write_idx] <= data_in;
        end
        else if(write_a_PE)begin
            acts[write_idx] <= data_in;
            
        end
    end
    
    always@(*)begin
        r = $bitstoreal(w[comp_idx]) * acts[comp_idx] + $bitstoreal(psum);
    end
    
    always@(posedge clk)begin
        if(comp)begin
            if(comp_idx == 7)begin
                data_out <= $realtobits(r);
            end
            if(write_idx != 0) begin
                psum <= $realtobits(r);
            end
        end
        else if(clear)begin
            psum <= $realtobits(zero);
            data_out <= 0;
        end
    end
    
endmodule
