`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/05/2021 02:09:23 PM
// Design Name: 
// Module Name: exp_1_sim
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


module exp_1_sim;
    logic BTN;
    logic CLK;
    logic  [7:0] SEGMENTS = 8'b00000000;
    logic  [3:0] ANODES = 4'b0000;
    logic  [3:0] LEDS = 4'b0000;
    
    EXP1_CKT Exp1_inst(.BTN(BTN),.CLK(CLK),.SEGMENTS(SEGMENTS),.ANODES(ANODES),.LEDS(LEDS));
    //clk_2n_div_test #4 slow_clock (.clockin(CLK),.clockout(SCLK));
    
 always
 begin
    CLK = 1'B0;
    #5
    CLK= 1'B1;
    #5;
 end
 
 initial
 begin
    BTN = 1'B0;
    #102
    BTN= 1'B1;
    #5
    BTN=1'B0;
 end 
 
endmodule