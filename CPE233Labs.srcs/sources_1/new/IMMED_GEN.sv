`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////////////


module IMMED_GEN(
    input [24:0] ir,
    output [31:0] J_type,
    output [31:0] B_type,
    output [31:0] U_type,
    output [31:0] I_type,
    output [31:0] S_type
    );
    
    assign J_type = {{12{ir[24]}}, ir[12:5], ir[13], ir[23:14], 1'b0};
    assign B_type = {{20{ir[24]}}, ir[0], ir[23:18], ir[4:1], 1'b0};
    assign U_type = {ir[24:5], 12'd0};
    assign I_type = {{21{ir[24]}}, ir[23:18], ir[17:13]};
    assign S_type = {{21{ir[24]}}, ir[23:18], ir[4:0]}; 
    
endmodule
