`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:   Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 01/16/2020 11:41:46 AM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench file for Experiment 3
// 
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created
//          1.01 - modified comments 
//          1.02 - made shifts fail if shift > 5 bits
//                 added to non-specified outputs
//          1.03 - added comments
//     
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb( );

   wire [31:0] result; 
   reg   [3:0] alu_fun; 
   reg  [31:0] srcA,srcB; 
   
ALU  my_alu (
    .alu_fun  (alu_fun),
    .OP_1     (srcA),
    .OP_2     (srcB),
    .RESULT   (result)
    );
   
   initial 
   begin
   
      alu_fun = 0;     // addition
      srcA = 32'd25; 
      srcB = 32'd26;       
      
      #20             // subtraction
      alu_fun = 8; 
      srcA = 32'd25; 
      srcB = 32'd26;          
      
      #20             // subtraction
      alu_fun = 8; 
      srcA = 32'hFFFFFFFFF; 
      srcB = 32'd1;    
     
       #20             // OR
      alu_fun = 6; 
      srcA = 32'h0000AAAA; 
      srcB = 32'h00005555;   
      
       #20             // AND
      alu_fun = 7; 
      srcA = 32'h0000AAAA; 
      srcB = 32'h00005555;   

       #20             // XOR
      alu_fun = 4; 
      srcA = 32'h0000AAAA; 
      srcB = 32'h00005555;    

       #20             // shift right
      alu_fun = 5; 
      srcA = 32'h0000FF00; 
      srcB = 32'h00000085;   
      
       #20             // shift left
      alu_fun = 1; 
      srcA = 32'h0000FF00; 
      srcB = 32'h00000085;
      
       #20             // shift right arithmetic
      alu_fun = 13; 
      srcA = 32'h8000FF00; 
      srcB = 32'h00000085;          
        
       #20             // set if less than signed
      alu_fun = 2; 
      srcA = 32'h8000FF00; 
      srcB = 32'h00000005;    

       #20             // set if less than unsigned
      alu_fun = 3; 
      srcA = 32'h8000FF00; 
      srcB = 32'h00000005; 
      
       #20             // load upper immediate
      alu_fun = 9; 
      srcA = 32'h0000FF00; 
      srcB = 32'h00000FFF;      
      
      #20              // not specified
      alu_fun = 15; 
      srcA = 32'h0000FF00; 
      srcB = 32'h00000FFF;  

      #20              // not specified
      alu_fun = 14; 
      srcA = 32'h0000FF00; 
      srcB = 32'h00000FFF;  	  
     
   end  

endmodule