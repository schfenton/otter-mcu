`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2021 04:16:20 PM
// Design Name: 
// Module Name: PC_MOD
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


module PC_MOD(
    input reset,
    input PCWrite,
    input [1:0] pcSource,
    input CLK,
    input [31:0] jalr,
    input [31:0] branch,
    input [31:0] jal,
    output [13:0] out
    );
    
    logic [31:0] data;
    logic [31:0] pc;
    logic [31:0] address_inc;
    
    mux_4t1_nb #(32) sourceMux (
        .SEL(pcSource),
        .D0(address_inc),
        .D1(jalr),
        .D2(branch),
        .D3(jal),
        .D_OUT(data)        );
        
    reg_nb #(32) PC (
        .clk(CLK),
        .clr(reset),
        .ld(PCWrite),
        .data_in(data),
        .data_out(pc)       );
    
    rca_nb #(32) Add4 (.a(pc), .b(4), .cin(0), .sum(address_inc), .co());
    
    assign out = pc[15:2];
    
endmodule
