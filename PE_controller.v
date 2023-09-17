`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2023 08:27:59 PM
// Design Name: 
// Module Name: PE_controller
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


module PE_controller(
    input clk,
    input wire [3:0]write_w_to_PE_ctr,      // Write weights counter from controller
    input wire [3:0]write_a_to_PE_ctr,      // Write acts counter from controller
    input wire [2:0]state,                  // Current state
    input wire done_GB,                     // Read / Write done signal of GB
    output wire write_w_PE,                 // Wrrite weight enable for PE
    output wire write_a_PE,                 // Write act enable for PE
    output wire shift,                      // Shift signal for PE
    output wire comp,                       // Compute signal for PE
    output reg clear,                       // Clear signal for PE
    output reg [2:0]write_idx,              // Write index of weight / act registers in PE
    output reg [2:0]comp_idx                // Compute index of weight / act registers in PE
    );
    
    reg [3:0]ctr;       // Counter for state 4
    reg [3:0]last_ctr;  // To differentiate the change of write_a_to_PE_ctr
    
    // Combinational signals
    assign write_w_PE = (state == 3 && write_w_to_PE_ctr < 8);                          // Wrrite weight enable for PE
    assign write_a_PE = ((state == 4 && write_a_to_PE_ctr < 8) || (state == 5));        // Write act enable for PE
    assign shift = (state == 6);                                                        // Shift signal for PE
    assign comp = ((state == 4 && last_ctr != write_a_to_PE_ctr) || (state == 5 && (ctr < 7 || done_GB)));  // Compute signal for PE
      
    // Initialize
    initial begin
        ctr = 0;
        last_ctr = 0;
    end
    
    // Write index & Compute index (combinational)
    always@(*)begin
        if(state == 3) begin
            if(write_w_to_PE_ctr < 8) begin
                write_idx = write_w_to_PE_ctr;
            end
            else begin
                write_idx = 0;
            end
        end
        else if(state == 4) begin
            if(write_a_to_PE_ctr > 0) begin
                comp_idx = write_a_to_PE_ctr - 1;
            end
            else begin
                comp_idx = 0;
            end
            if(write_a_to_PE_ctr < 8) begin
                write_idx = write_a_to_PE_ctr;
            end
            else begin
                write_idx = 0;
            end
        end
        else if(state == 5) begin
            write_idx = 7;
            if(ctr < 7) begin
                comp_idx = ctr;
            end
            else if(done_GB) begin
                comp_idx = 7;
            end
            else begin
                comp_idx = 0;
            end
        end
        else begin
            write_idx = 0;
            comp_idx = 0;
        end
    end
    
    // Counters
    always@(posedge clk)begin
        if(state == 4)begin
            last_ctr <= write_a_to_PE_ctr;      
        end
        else if(state == 5)begin
            if(ctr < 8)begin
                ctr <= ctr +1;
            end
        end
        else if(state == 6)begin
            ctr <= 0;
        end
        if(state == 7 && done_GB)begin
            clear <= 1;
        end
        else begin
            clear <= 0;
        end
    end
    
endmodule
