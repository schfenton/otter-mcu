`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 04:25:58 PM
// Design Name: 
// Module Name: BRANCH_ADDR_GEN
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


module BRANCH_ADDR_GEN(
    input [31:0] J_type,
    input [31:0] B_type,
    input [31:0] I_type,
    input [31:0] rs,
    input [31:0] pc,
    output [31:0] jal,
    output [31:0] branch,
    output [31:0] jalr
    );
    
    assign jal = pc + J_type;
    assign branch = pc + B_type;
    
    assign jalr = rs + I_type;
    
endmodule
