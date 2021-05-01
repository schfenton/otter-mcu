`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer: James Ratner
// 
// Create Date: 10/09/2018 07:53:15 PM
// Design Name: 
// Module Name: clk_divider_nbit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Parameterized 2^n clock divider
//
// Usage: 
//
//      clk_divider_nbit #(.n(16)) MY_DIV (
//          .clockin  (xxxx), 
//          .clockout (xxxx) 
//          );  
// 
// Dependencies: 
// 
// Created: 10-09-2018
//
// Revision (11-02-2019) 1.01 - removed typos in module name
//          (11-24-2019) 1.02 - added macro, adjusted code
//          (12-20-2020) 1.03 - changed parameter location, comments
//
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module clk_divider_nbit  #(parameter n=13) ( 
    input wire clockin, 
    output wire clockout  ); 

    reg [n:0] count; 

    always@(posedge clockin) 
    begin 
        count <= count + 1; 
    end 

    assign clockout = count[n];
	
endmodule 

`default_nettype wire