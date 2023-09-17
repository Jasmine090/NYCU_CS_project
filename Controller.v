`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2023 10:47:29 PM
// Design Name: 
// Module Name: Controller
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
`define mem_act_h 10'd0         // Acts: 0-783 in memory, 28 * 28 in total
`define mem_w_h 10'd800         // Weights: 800-1055 in memory, 16 * 16 in total
`define mem_psum_h 12'd1100     // Psums: 1100-1268 in memory, 13 * 13 in total
`define GB_act_h 10'd0          // Acts: 0-223 in global buffer, 28 * 8 in total
`define GB_w_h 10'd224          // Weights: 224-287 in global buffer, 8 * 8 in total
`define GB_psum_h 10'd288       // Psums: 288-456 in global buffer, 13 * 13 in total

module Controller(
        input clk,
        input done_mem,             // Read / Write done signal of memory
        input done_GB,              //Read / Write done signal of GB
        output read_mem,            // Read eneable of memory
        output write_mem,           // Write enable of memory
        output reg [63:0]addr_mem,  // Read / Write address of memory
        output init,                // Enable initialization
        output read_GB,             // Read enable of GB
        output write_PE_to_GB,      // Write from PE enable of GB 
        output write_mem_to_GB,     // Write from memory enable of GB
        output reg [63:0]GB_addr_mem,   // Read address to memory of GB
        output reg [63:0]GB_addr_PE0,   // Read address to PE of GB
        output reg [63:0]GB_addr_PE1,
        output reg [63:0]GB_addr_PE2,
        output reg [63:0]GB_addr_PE3,
        output reg [63:0]GB_addr_PE4,
        output reg [63:0]GB_addr_PE5,
        output reg [63:0]GB_addr_PE6,
        output reg [63:0]GB_addr_PE7,
        output reg [63:0]GB_addr_write, // Write address of GB
        output reg [63:0]GB_addr_psum,  // Read address of psum of GB
        output reg [3:0]write_w_to_PE_ctr,  // Write weights to PE counter
        output reg [3:0]write_a_to_PE_ctr,  // Write acts to PE counter
        output reg [4:0]wait_ctr,           // Wait for writing  psum counter
        output reg [3:0]cur_state,          // State
        output Done                         // Done signal
    );
    
    reg [6:0]write_w_to_GB_ctr;     // Write weights to GB counter
    reg [7:0]write_a_to_GB_ctr;     // Write acts to GB counter
    reg [7:0]write_PE_to_GB_ctr;    // Writing psum to GB counter -> for psum writing address
    reg [3:0]add_col_ctr;           // Add column counter during computation
    reg [3:0]add_row_ctr;           // Add row counter during computation
    reg [2:0]block_ctr;             // Weight block counter
    reg [7:0]write_result_ctr;      // Writing result to memory counter   
    
    // Combinational control signals
    assign init = (cur_state==0);
    assign read_mem = (cur_state == 1 || cur_state == 2 || cur_state == 8);
    assign write_mem = (cur_state == 9);
    assign read_GB = ((cur_state == 3 || cur_state == 4 || cur_state == 5 || cur_state == 9) || (cur_state == 7 && wait_ctr <= 11));
    assign write_PE_to_GB = (cur_state == 7 && wait_ctr > 11);
    assign write_mem_to_GB = (cur_state == 1 || cur_state == 2 || cur_state == 8);
    assign Done = (cur_state == 10);
    
    // Initialization
    initial begin
        write_w_to_GB_ctr = 0;
        write_a_to_GB_ctr = 0;
        write_w_to_PE_ctr = 0;
        write_a_to_PE_ctr = 0;
        wait_ctr = 0;
        add_col_ctr = 0;
        block_ctr = 0;
        write_result_ctr = 0;
        cur_state = 0;
        write_PE_to_GB_ctr = 0;
        add_row_ctr = 0;
    end

    // State & next state
    always@(posedge clk)begin
        if(cur_state==0) begin
            cur_state <= 1;
            block_ctr <= 0;
        end
        else if(cur_state==1) begin
            add_row_ctr <= 0;   
            // Finish 8 * 8 weight writing => next state
            if(write_w_to_GB_ctr == 63 && done_mem) begin
                cur_state <= 2;
            end
        end
        else if(cur_state==2) begin
            // Finish 28 * 8 weight writing => next state
            if(write_a_to_GB_ctr == 159 && done_mem) begin
                cur_state <= 3;
            end
        end
        else if(cur_state==3) begin
            // Finish 8 weight writing => next state
            if(write_w_to_PE_ctr == 7 && done_GB) begin
                cur_state <= 4;
            end
        end
        else if(cur_state==4) begin
            add_col_ctr <= 0;
            // Finish 8 acts writing + 8 computation => next state
            if(write_a_to_PE_ctr >= 8) begin
                cur_state <= 6;
            end
        end
        else if(cur_state==5) begin
            // Finish 1 acts writing + 8 computation => next state
            if(done_GB) begin
                cur_state <= 6;
            end
        end
        else if(cur_state==6) begin
            // Shift acts
            cur_state <= 7;
        end
        else if(cur_state==7) begin
            // Finish psum computation + writing psum to GB => next state
            if(wait_ctr > 11) begin
                // Finish psum writing
                if(done_GB) begin
                    if(add_col_ctr < 12) begin
                        add_col_ctr <= add_col_ctr + 1;
                        cur_state <= 5;
                    end
                    else begin
                        if(add_row_ctr < 12) begin
                            cur_state <= 8;
                        end
                        // Change weight block
                        else if(block_ctr < 3) begin
                            block_ctr <= block_ctr + 1;
                            cur_state <= 1;
                        end
                        // Finish all computation
                        else if(block_ctr == 3) begin
                            cur_state <= 9;
                        end
                    end
                end
            end 
        end
        else if(cur_state==8) begin
            // Finish 28 act writing => next state
            if(write_a_to_GB_ctr == 19 && done_mem) begin
                add_row_ctr <= add_row_ctr + 1;
                cur_state <= 4;
            end
        end
        else if(cur_state==9) begin
            // Finish writing all 13 * 13 result to memory => Done
            if(write_result_ctr == 169) begin
                cur_state <= 10;
            end
        end
        else begin
            cur_state <= cur_state;
        end
    end
    
    // Counters
    always@(posedge clk)begin
        if(cur_state==1) begin
            write_a_to_GB_ctr <= 0;
            write_PE_to_GB_ctr <= 0;
            wait_ctr <= 0;
            // Finish 1 weight writing to GB
            if(done_mem) begin
                write_w_to_GB_ctr <= write_w_to_GB_ctr + 1;
            end
        end
        else if(cur_state==2) begin
            write_w_to_GB_ctr <= 0;
            // Finish 1 act writing to GB
            if(done_mem) begin
                write_a_to_GB_ctr <= write_a_to_GB_ctr + 1;
            end
        end
        else if(cur_state==3) begin
            write_a_to_GB_ctr <= 0;
            // Finish 1 weight writng to PE
            if(done_GB) begin
                write_w_to_PE_ctr <= write_w_to_PE_ctr + 1;
            end
        end
        else if(cur_state==4) begin
            write_w_to_PE_ctr <= 0;
            write_a_to_GB_ctr <= 0;
            // Finish 1 act writng to PE
            if(done_GB) begin
                write_a_to_PE_ctr <= write_a_to_PE_ctr + 1;
            end
        end
        else if(cur_state==5) begin
            write_a_to_GB_ctr <= 0;
            wait_ctr <= 0;
        end
        else if(cur_state==6) begin
            write_a_to_PE_ctr <= 0;
        end
        else if(cur_state==7) begin
            wait_ctr <= wait_ctr + 1;
            // Finish 1 psum writng to GB
            if(done_GB && write_PE_to_GB) begin
                write_PE_to_GB_ctr <= write_PE_to_GB_ctr + 1;
            end
        end
        else if(cur_state==8) begin
            wait_ctr <= 0;
            // Finish 1 act writng to GB
            if(done_mem) begin
                write_a_to_GB_ctr <= write_a_to_GB_ctr + 1;
            end
        end
        else if(cur_state==9)begin
            wait_ctr <= 0;
            // Finish 1 psum writng to memory
            if(done_mem) begin
                write_result_ctr <= write_result_ctr + 1;
            end
        end
    end
    
    // Adresss (combinational)
    always@(*)begin
        if(cur_state==1) begin
            if(block_ctr == 0) begin            // Up left
                addr_mem = `mem_w_h + 16*(write_w_to_GB_ctr[6:3]) + write_w_to_GB_ctr[2:0];
            end
            else if(block_ctr == 1) begin       // Up right
                addr_mem = `mem_w_h + 16*(write_w_to_GB_ctr[6:3]) + write_w_to_GB_ctr[2:0] + 8;
            end
            else if(block_ctr == 2) begin       // Down left
                addr_mem = `mem_w_h + 16*(write_w_to_GB_ctr[6:3] + 8) + write_w_to_GB_ctr[2:0];
            end
            else if(block_ctr == 3) begin       // Down right
                addr_mem = `mem_w_h + 16*(write_w_to_GB_ctr[6:3] + 8) + write_w_to_GB_ctr[2:0] + 8;
            end
            else begin
                addr_mem = 0;
            end
            GB_addr_mem = 0;
            GB_addr_PE0 = 0;
            GB_addr_PE1 = 0;
            GB_addr_PE2 = 0;
            GB_addr_PE3 = 0;
            GB_addr_PE4 = 0;
            GB_addr_PE5 = 0;
            GB_addr_PE6 = 0;
            GB_addr_PE7 = 0;
            GB_addr_write = `GB_w_h + write_w_to_GB_ctr;
            GB_addr_psum = 0;
        end
        else if(cur_state==2) begin
            if(block_ctr == 0) begin            // Up left
                addr_mem = `mem_act_h + (write_a_to_GB_ctr / 20 * 28) + write_a_to_GB_ctr % 20;
            end
            else if(block_ctr == 1) begin       // Up right
                addr_mem = `mem_act_h + (write_a_to_GB_ctr / 20 * 28) + write_a_to_GB_ctr % 20 + 8;
            end
            else if(block_ctr == 2) begin       // Down left
                addr_mem = `mem_act_h + (write_a_to_GB_ctr / 20 * 28) + write_a_to_GB_ctr % 20 + 28 * 8;
            end
            else if(block_ctr == 3) begin       // Down right
                addr_mem = `mem_act_h + (write_a_to_GB_ctr / 20 * 28) + write_a_to_GB_ctr % 20 + 28 * 8 + 8;
            end
            else begin
                addr_mem = 0;
            end
            GB_addr_mem = 0;
            GB_addr_PE0 = 0;
            GB_addr_PE1 = 0;
            GB_addr_PE2 = 0;
            GB_addr_PE3 = 0;
            GB_addr_PE4 = 0;
            GB_addr_PE5 = 0;
            GB_addr_PE6 = 0;
            GB_addr_PE7 = 0;
            if(block_ctr == 0 || block_ctr == 2) begin
                GB_addr_write = `GB_act_h + (write_a_to_GB_ctr / 20 * 28) + write_a_to_GB_ctr % 20;
            end
            else begin
                GB_addr_write = `GB_act_h + (write_a_to_GB_ctr / 20 * 28) + write_a_to_GB_ctr % 20 + 8;
            end
            GB_addr_psum = 0;
        end
        else if(cur_state==3) begin
            addr_mem = 0;
            GB_addr_PE0 = `GB_w_h + write_w_to_PE_ctr;
            GB_addr_PE1 = `GB_w_h + write_w_to_PE_ctr + 8;
            GB_addr_PE2 = `GB_w_h + write_w_to_PE_ctr + 16;
            GB_addr_PE3 = `GB_w_h + write_w_to_PE_ctr + 24;
            GB_addr_PE4 = `GB_w_h + write_w_to_PE_ctr + 32;
            GB_addr_PE5 = `GB_w_h + write_w_to_PE_ctr + 40;
            GB_addr_PE6 = `GB_w_h + write_w_to_PE_ctr + 48;
            GB_addr_PE7 = `GB_w_h + write_w_to_PE_ctr + 56;
            GB_addr_write = 0;
            GB_addr_psum = 0;
        end
        else if(cur_state==4) begin
            addr_mem = 0;
            if(block_ctr == 0 || block_ctr == 2) begin
                GB_addr_PE0 = (`GB_act_h + write_a_to_PE_ctr + 28 * add_row_ctr) % 224;
                GB_addr_PE1 = (`GB_act_h + write_a_to_PE_ctr + 28 + 28 * add_row_ctr) % 224;
                GB_addr_PE2 = (`GB_act_h + write_a_to_PE_ctr + 56 + 28 * add_row_ctr) % 224;
                GB_addr_PE3 = (`GB_act_h + write_a_to_PE_ctr + 84 + 28 * add_row_ctr) % 224;
                GB_addr_PE4 = (`GB_act_h + write_a_to_PE_ctr + 112 + 28 * add_row_ctr) % 224;
                GB_addr_PE5 = (`GB_act_h + write_a_to_PE_ctr + 140 + 28 * add_row_ctr) % 224;
                GB_addr_PE6 = (`GB_act_h + write_a_to_PE_ctr + 168 + 28 * add_row_ctr) % 224;
                GB_addr_PE7 = (`GB_act_h + write_a_to_PE_ctr + 196 + 28 * add_row_ctr) % 224;
            end
            else if(block_ctr == 1 || block_ctr == 3) begin       // Down right
                GB_addr_PE0 = (`GB_act_h + write_a_to_PE_ctr + 28 * add_row_ctr + 8) % 224;
                GB_addr_PE1 = (`GB_act_h + write_a_to_PE_ctr + 28 + 28 * add_row_ctr + 8) % 224;
                GB_addr_PE2 = (`GB_act_h + write_a_to_PE_ctr + 56 + 28 * add_row_ctr + 8) % 224;
                GB_addr_PE3 = (`GB_act_h + write_a_to_PE_ctr + 84 + 28 * add_row_ctr + 8) % 224;
                GB_addr_PE4 = (`GB_act_h + write_a_to_PE_ctr + 112 + 28 * add_row_ctr + 8) % 224;
                GB_addr_PE5 = (`GB_act_h + write_a_to_PE_ctr + 140 + 28 * add_row_ctr + 8) % 224;
                GB_addr_PE6 = (`GB_act_h + write_a_to_PE_ctr + 168 + 28 * add_row_ctr + 8) % 224;
                GB_addr_PE7 = (`GB_act_h + write_a_to_PE_ctr + 196 + 28 * add_row_ctr + 8) % 224;
            end
            else begin
                GB_addr_PE0 = 0;
                GB_addr_PE1 = 0;
                GB_addr_PE2 = 0;
                GB_addr_PE3 = 0;
                GB_addr_PE4 = 0;
                GB_addr_PE5 = 0;
                GB_addr_PE6 = 0;
                GB_addr_PE7 = 0;
            end
            GB_addr_write = 0;
            GB_addr_psum = 0;
        end
        else if(cur_state==5) begin
            addr_mem = 0;
            if(block_ctr == 0 || block_ctr == 2) begin
                GB_addr_PE0 = (`GB_act_h + add_col_ctr + 7 + 28 * add_row_ctr) % 224;
                GB_addr_PE1 = (`GB_act_h + add_col_ctr + 7 + 28 + 28 * add_row_ctr) % 224;
                GB_addr_PE2 = (`GB_act_h + add_col_ctr + 7 + 56 + 28 * add_row_ctr) % 224;
                GB_addr_PE3 = (`GB_act_h + add_col_ctr + 7 + 84 + 28 * add_row_ctr) % 224;
                GB_addr_PE4 = (`GB_act_h + add_col_ctr + 7 + 112 + 28 * add_row_ctr) % 224;
                GB_addr_PE5 = (`GB_act_h + add_col_ctr + 7 + 140 + 28 * add_row_ctr) % 224;
                GB_addr_PE6 = (`GB_act_h + add_col_ctr + 7 + 168 + 28 * add_row_ctr) % 224;
                GB_addr_PE7 = (`GB_act_h + add_col_ctr + 7 + 196 + 28 * add_row_ctr) % 224;
            end
            else if(block_ctr == 1 || block_ctr == 3) begin       // Down right
                GB_addr_PE0 = (`GB_act_h + add_col_ctr + 15 + 28 * add_row_ctr) % 224;
                GB_addr_PE1 = (`GB_act_h + add_col_ctr + 15 + 28 + 28 * add_row_ctr) % 224;
                GB_addr_PE2 = (`GB_act_h + add_col_ctr + 15 + 56 + 28 * add_row_ctr) % 224;
                GB_addr_PE3 = (`GB_act_h + add_col_ctr + 15 + 84 + 28 * add_row_ctr) % 224;
                GB_addr_PE4 = (`GB_act_h + add_col_ctr + 15 + 112 + 28 * add_row_ctr) % 224;
                GB_addr_PE5 = (`GB_act_h + add_col_ctr + 15 + 140 + 28 * add_row_ctr) % 224;
                GB_addr_PE6 = (`GB_act_h + add_col_ctr + 15 + 168 + 28 * add_row_ctr) % 224;
                GB_addr_PE7 = (`GB_act_h + add_col_ctr + 15 + 196 + 28 * add_row_ctr) % 224;
            end
            else begin
                GB_addr_PE0 = 0;
                GB_addr_PE1 = 0;
                GB_addr_PE2 = 0;
                GB_addr_PE3 = 0;
                GB_addr_PE4 = 0;
                GB_addr_PE5 = 0;
                GB_addr_PE6 = 0;
                GB_addr_PE7 = 0;
            end
            GB_addr_write = 0;
            GB_addr_psum = 0;
        end
        else if(cur_state==7) begin
            addr_mem = 0;
            GB_addr_mem = 0;
            GB_addr_PE0 = 0;
            GB_addr_PE1 = 0;
            GB_addr_PE2 = 0;
            GB_addr_PE3 = 0;
            GB_addr_PE4 = 0;
            GB_addr_PE5 = 0;
            GB_addr_PE6 = 0;
            GB_addr_PE7 = 0;
            GB_addr_write = `GB_psum_h + write_PE_to_GB_ctr;
            GB_addr_psum = `GB_psum_h + write_PE_to_GB_ctr;
        end
        else if(cur_state==8) begin
            if(block_ctr == 0) begin            // Up left
                addr_mem = `mem_act_h + 28*8 + add_row_ctr*28 + write_a_to_GB_ctr;
            end
            else if(block_ctr == 1) begin       // Up right
                addr_mem = `mem_act_h + 28*8 + add_row_ctr*28 + write_a_to_GB_ctr + 8;
            end
            else if(block_ctr == 2) begin       // Down right
                addr_mem = `mem_act_h + 28*16 + add_row_ctr*28 + write_a_to_GB_ctr;
            end
            else if(block_ctr == 3) begin       // Down right
                addr_mem = `mem_act_h + 28*16 + add_row_ctr*28 + write_a_to_GB_ctr + 8;
            end
            else begin
                addr_mem = 0;
            end
            GB_addr_mem = 0;
            GB_addr_PE0 = 0;
            GB_addr_PE1 = 0;
            GB_addr_PE2 = 0;
            GB_addr_PE3 = 0;
            GB_addr_PE4 = 0;
            GB_addr_PE5 = 0;
            GB_addr_PE6 = 0;
            GB_addr_PE7 = 0;
            // Cover useless row in GB
            if(block_ctr == 0 || block_ctr == 2) begin
                GB_addr_write = `mem_act_h + (add_row_ctr * 28 + write_a_to_GB_ctr) % 224;
            end
            else begin
                GB_addr_write = `mem_act_h + (add_row_ctr * 28 + write_a_to_GB_ctr + 8) % 224;
            end
            GB_addr_psum = 0;
        end
        else if(cur_state==9) begin
            addr_mem = `mem_psum_h + write_result_ctr;
            GB_addr_mem = `GB_psum_h + write_result_ctr;
            GB_addr_PE0 = 0;
            GB_addr_PE1 = 0;
            GB_addr_PE2 = 0;
            GB_addr_PE3 = 0;
            GB_addr_PE4 = 0;
            GB_addr_PE5 = 0;
            GB_addr_PE6 = 0;
            GB_addr_PE7 = 0;
            GB_addr_write = 0;
            GB_addr_psum = 0;
        end
        else begin
            addr_mem = 0;
            GB_addr_mem = 0;
            GB_addr_PE0 = 0;
            GB_addr_PE1 = 0;
            GB_addr_PE2 = 0;
            GB_addr_PE3 = 0;
            GB_addr_PE4 = 0;
            GB_addr_PE5 = 0;
            GB_addr_PE6 = 0;
            GB_addr_PE7 = 0;
            GB_addr_write = 0;
            GB_addr_psum = 0;
        end
    end
    
endmodule
