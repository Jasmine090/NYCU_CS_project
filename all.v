`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/22/2023 06:26:20 PM
// Design Name: 
// Module Name: all
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


module all(

    );
    reg clk;
    wire [63:0]data_GB_to_mem;
    wire [63:0]data_mem_to_GB;
    wire [63:0]data_PE_to_GB;//not function
    wire done_gb;
    wire done_memory;
    wire read_mem;
    wire write_mem;
    wire [10:0]addr_mem;
    wire init;
    wire read_GB;
    wire write_PE_to_GB;
    wire write_mem_to_GB;
    wire [10:0]GB_addr_mem;
    wire [10:0]GB_addr_PE0;
    wire [10:0]GB_addr_PE1;
    wire [10:0]GB_addr_PE2;
    wire [10:0]GB_addr_PE3;
    wire [10:0]GB_addr_PE4;
    wire [10:0]GB_addr_PE5;
    wire [10:0]GB_addr_PE6;
    wire [10:0]GB_addr_PE7;
    wire [10:0]GB_addr_write;
    wire [10:0]GB_addr_psum;
    wire write_w_PE;
    wire write_a_PE;
    wire shift;
    wire comp;
    wire [2:0]write_idx;
    wire [2:0]comp_idx;
    wire Done;
    wire [63:0]data_GB_PE_in0;
    wire [63:0]data_GB_PE_out0;
    wire [63:0]data_GB_PE_in1;
    wire [63:0]data_GB_PE_out1;
    wire [63:0]data_GB_PE_in2;
    wire [63:0]data_GB_PE_out2;
    wire [63:0]data_GB_PE_in3;
    wire [63:0]data_GB_PE_out3;
    wire [63:0]data_GB_PE_in4;
    wire [63:0]data_GB_PE_out4;
    wire [63:0]data_GB_PE_in5;
    wire [63:0]data_GB_PE_out5;
    wire [63:0]data_GB_PE_in6;
    wire [63:0]data_GB_PE_out6;
    wire [63:0]data_GB_PE_in7;
    wire [63:0]data_GB_PE_out7;
    wire [63:0]data_out_psum;
    wire [3:0]write_w_to_PE_ctr;
    wire [3:0]write_a_to_PE_ctr;
    wire [4:0]wait_ctr;
    wire [3:0]cur_state;
    wire clear;
    
    Controller controller(
        clk,
        done_memory,
        done_gb,
        read_mem,
        write_mem,
        addr_mem,
        init,
        read_GB,
        write_PE_to_GB,
        write_mem_to_GB,
        GB_addr_mem,
        GB_addr_PE0,
        GB_addr_PE1,
        GB_addr_PE2,
        GB_addr_PE3,
        GB_addr_PE4,
        GB_addr_PE5,
        GB_addr_PE6,
        GB_addr_PE7,
        GB_addr_write,
        GB_addr_psum,
        write_w_to_PE_ctr,
        write_a_to_PE_ctr,
        wait_ctr,
        cur_state,
        Done
    );
    
    GB gb(clk,
          read_GB, 
          write_PE_to_GB, 
          write_mem_to_GB,
          init,
          GB_addr_mem,
          GB_addr_PE0,
          GB_addr_PE1,
          GB_addr_PE2,
          GB_addr_PE3,
          GB_addr_PE4,
          GB_addr_PE5,
          GB_addr_PE6,
          GB_addr_PE7,
          GB_addr_write,
          GB_addr_psum,
          data_mem_to_GB,
          data_PE_to_GB,
          
          data_GB_to_mem,
          data_GB_PE_in0,
          data_GB_PE_in1,
          data_GB_PE_in2,
          data_GB_PE_in3,
          data_GB_PE_in4,
          data_GB_PE_in5,
          data_GB_PE_in6,
          data_GB_PE_in7,
          data_out_psum,
          done_gb
          );
          
    Memory memory(
          clk,
          read_mem,
          write_mem,
          addr_mem,
          init,
          Done,
          data_GB_to_mem,
          data_mem_to_GB,
          done_memory
        );
        
    PE_controller pc(
          clk,
          write_w_to_PE_ctr,
          write_a_to_PE_ctr,
          cur_state,
          done_gb,
          write_w_PE,
          write_a_PE,
          shift,
          comp,
          clear,
          write_idx,
          comp_idx
        );
    
    PE pe0(
        clk,
        write_w_PE,
        write_a_PE,
        comp,
        shift,
        clear,
        comp_idx,
        write_idx,
        data_GB_PE_in0,
        data_GB_PE_out0
    );
    
    PE pe1(
        clk,
        write_w_PE,
        write_a_PE,
        comp,
        shift,
        clear,
        comp_idx,
        write_idx,
        data_GB_PE_in1,
        data_GB_PE_out1
    );
    
    PE pe2(
        clk,
        write_w_PE,
        write_a_PE,
        comp,
        shift,
        clear,
        comp_idx,
        write_idx,
        data_GB_PE_in2,
        data_GB_PE_out2
    );
    
    PE pe3(
        clk,
        write_w_PE,
        write_a_PE,
        comp,
        shift,
        clear,
        comp_idx,
        write_idx,
        data_GB_PE_in3,
        data_GB_PE_out3
    );
    
    PE pe4(
        clk,
        write_w_PE,
        write_a_PE,
        comp,
        shift,
        clear,
        comp_idx,
        write_idx,
        data_GB_PE_in4,
        data_GB_PE_out4
    );
    
    PE pe5(
        clk,
        write_w_PE,
        write_a_PE,
        comp,
        shift,
        clear,
        comp_idx,
        write_idx,
        data_GB_PE_in5,
        data_GB_PE_out5
    );
    
    PE pe6(
        clk,
        write_w_PE,
        write_a_PE,
        comp,
        shift,
        clear,
        comp_idx,
        write_idx,
        data_GB_PE_in6,
        data_GB_PE_out6
    );
    
    PE pe7(
        clk,
        write_w_PE,
        write_a_PE,
        comp,
        shift,
        clear,
        comp_idx,
        write_idx,
        data_GB_PE_in7,
        data_GB_PE_out7
    );
    
    Final_add fa(
        clk,
        wait_ctr,
        cur_state,
        data_GB_PE_out0,
        data_GB_PE_out1,
        data_GB_PE_out2,
        data_GB_PE_out3,
        data_GB_PE_out4,
        data_GB_PE_out5,
        data_GB_PE_out6,
        data_GB_PE_out7,
        data_out_psum,
        data_PE_to_GB
    );
    
    initial begin
        clk = 1;
        forever begin
            #1 clk = ~clk;
        end
    end
endmodule
