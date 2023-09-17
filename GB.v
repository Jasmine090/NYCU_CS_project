`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2023 10:10:34 PM
// Design Name: 
// Module Name: GB
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


module GB(
        input wire clk,
        input wire read_GB,         // Read enable
        input wire write_PE_to_GB,  // Write from PE enable
        input wire write_mem_to_GB, // Write from memory enable
        input wire init,            // Initialize
        input wire [10:0]addr_mem,  // Read address for memory
        input wire [10:0]addr_PE0,  // Read address for PE
        input wire [10:0]addr_PE1,
        input wire [10:0]addr_PE2,
        input wire [10:0]addr_PE3,
        input wire [10:0]addr_PE4,
        input wire [10:0]addr_PE5,
        input wire [10:0]addr_PE6,
        input wire [10:0]addr_PE7,
        input wire [10:0]addr_write,    // Write address
        input wire [10:0]addr_psum,     // Read address for psum
        input wire [63:0]data_in_mem,   // Data in from memory
        input wire [63:0]data_in_PE,    // Dara in from PEs
        
        output reg [63:0]data_out_mem,  // Data out for memory
        output reg [63:0]data_out_PE0,  // Data out for PE
        output reg [63:0]data_out_PE1,
        output reg [63:0]data_out_PE2,
        output reg [63:0]data_out_PE3,
        output reg [63:0]data_out_PE4,
        output reg [63:0]data_out_PE5,
        output reg [63:0]data_out_PE6,
        output reg [63:0]data_out_PE7,
        output reg [63:0]data_out_psum, // Data out for psum
        output wire done_GB             // Read / Write done signal
    );
    
    reg [63:0]buffer[511:0];        // Buffer
    reg [3:0]read_GB_ctr;           // Read counter (10 clk = 1 read)
    reg [3:0]write_PE_to_GB_ctr;    // Write from PE counter (10 clk = 1 write)
    reg [3:0]write_mem_to_GB_ctr;   // Write from memory counter (10 clk = 1 write)
    
    integer i;
    
    initial begin
        for(i=0 ; i<512 ; i=i+1)
            buffer[i] <= 0;         // Initialize
    end
    
    // Combinational signal
    assign done_GB = ((read_GB_ctr == 10) || (write_PE_to_GB_ctr == 10) || (write_mem_to_GB_ctr == 10));
    
    // Counters
    always@(posedge clk)begin
        // Read counters
        if(read_GB) begin
            if(read_GB_ctr < 10) begin
                read_GB_ctr <= read_GB_ctr + 1;
            end
            else begin
                read_GB_ctr <= 0;
            end
        end
        else begin
            read_GB_ctr <= 0;
        end
        // Write from PE counter
        if(write_PE_to_GB) begin
            if(write_PE_to_GB_ctr < 10) begin
                write_PE_to_GB_ctr <= write_PE_to_GB_ctr + 1;
            end
            else begin
                write_PE_to_GB_ctr <= 0;
            end
        end
        else begin
            write_PE_to_GB_ctr <= 0;
        end
        // Write from memory counter
        if(write_mem_to_GB) begin
            if(write_mem_to_GB_ctr < 10) begin
                write_mem_to_GB_ctr <= write_mem_to_GB_ctr + 1;
            end
            else begin
                write_mem_to_GB_ctr <= 0;
            end
        end
        else begin
            write_mem_to_GB_ctr <= 0;
        end
    end
    
    // Data out (Combinational)
    always@(*)begin
        if(read_GB) begin
            data_out_mem = buffer[addr_mem];
            data_out_PE0 = buffer[addr_PE0];
            data_out_PE1 = buffer[addr_PE1];
            data_out_PE2 = buffer[addr_PE2];
            data_out_PE3 = buffer[addr_PE3];
            data_out_PE4 = buffer[addr_PE4];
            data_out_PE5 = buffer[addr_PE5];
            data_out_PE6 = buffer[addr_PE6];
            data_out_PE7 = buffer[addr_PE7];
            data_out_psum = buffer[addr_psum];
        end
        else begin
            data_out_mem = 0;
            data_out_PE0 = 0;
            data_out_PE1 = 0;
            data_out_PE2 = 0;
            data_out_PE3 = 0;
            data_out_PE4 = 0;
            data_out_PE5 = 0;
            data_out_PE6 = 0;
            data_out_PE7 = 0;
            data_out_psum = 0;
        end
   end
   
   // Data in
   always@(posedge clk)begin  
        if(write_mem_to_GB)begin
            buffer[addr_write] <= data_in_mem;
        end
        else if(write_PE_to_GB)begin
            buffer[addr_write] <= data_in_PE;
        end
    end
    
endmodule
