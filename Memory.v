`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2023 10:39:53 PM
// Design Name: 
// Module Name: Memory
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


module Memory(
        input clk,
        input wire read_mem,        // Read enable
        input wire write_mem,       // Write enable
        input wire [10:0]addr_mem,  // Read / Write address
        input wire init,            // Initialize
        input wire Done,
        input wire [63:0]data_in,   // Data in from GB
        output reg [63:0]data_out,  // Data out for GB
        output reg done_mem         // Read / Write done signal
    );
    reg [63:0]mem[0:2047];  // Memory: 28 * 28 acts + 16 * 16 weights + 13 * 13 psums
    reg [7:0]ctr;           // Memory read / write counter (100 clk = 1 read / write)
    integer i;
    real r;
    
    // Initialize
    initial begin
        $readmemh("18054.txt", mem);
        // Create random weights
        for(i=0;i<16*16;i=i+1) begin
            r = $urandom()%100000;          // unsigned random value from 0 to 99999
            r = r/100000;                   // unsigned random value from 0 to 0.99999
            mem[800+i] = $realtobits(r);    // Stored as double-precision floating point numbers
            //f = $bitstoreal(mem[800+i]);
            //$display("%d: %f %d %f", i, r, mem[800+i], f);
        end
        ctr = 0;
    end
    
    // Counter
    always@(posedge clk)begin
        if(ctr < 8'd100 && (read_mem || write_mem)) begin
            ctr <= ctr + 1;
            done_mem <= 0;
        end
        else if(read_mem || write_mem) begin
            ctr <= 8'd0;
            done_mem <= 1;
        end
        else begin
            ctr <= 8'd0;
            done_mem <= 0;
        end
            
    end
    
    
    // Data out & data in
    always@(posedge clk)begin
        // Data out
        if(read_mem)begin
            data_out <= mem[addr_mem];
        end
        else begin
            data_out <= 8'd0;
        end
        // Data in
        if(write_mem) begin
            mem[addr_mem] <= data_in;
        end
    end
    integer k;
    always@(*)begin
        if(Done)begin
            for(k=1100 ; k<1269 ; k=k+1)begin
                $display("%f", $bitstoreal(mem[k]));
            end
        end
    end
endmodule
