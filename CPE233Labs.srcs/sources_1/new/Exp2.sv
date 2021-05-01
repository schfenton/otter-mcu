`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Alex Neiman, Schuyler Fenton 
// 
// Design Name: CPE233 Experiment 2
// Description: Defines and instantiates a ProgramCounter module to store and
// manipulate the address of an OTTER_MEMORY instance.
//////////////////////////////////////////////////////////////////////////////////

module Exp2(
    input reset,
    input PCWrite,
    input [1:0] pcSource,
    input clk,
    output [31:0] ir
    );
    
    logic [31:0] pc;
    
    ProgramCounterMod PC(
        .reset(reset),
        .PCWrite(PCWrite),
        .pcSource(pcSource),
        .clk(clk),
        .pc(pc)
        );
        
    Memory OTTER_MEMORY(
        .MEM_CLK    (clk),
        .MEM_RDEN1  (1),
        .MEM_RDEN2  (0),
        .MEM_WE2    (0),
        .MEM_ADDR1  (pc[15:2]),
        .MEM_ADDR2  (0),
        .MEM_DIN2   (0),
        .MEM_SIZE   (2),
        .MEM_SIGN   (0),
        .IO_IN      (0),
        .IO_WR      (),
        .MEM_DOUT1  (ir),
        .MEM_DOUT2  ()
        );
    
endmodule

module ProgramCounter(
    input reset,
    input PCWrite,
    input [1:0] pcSource,
    input clk,
    output logic [31:0] pc
    );
    
    logic [31:0] t1; // Output from RCA
    logic [31:0] t2; // Output from Mux into PC reg
    
    //MUX for pcSource to select instruction inputs
    mux_4t1_nb  #(.n(32)) Mux_PCSourceSelector  (
        .SEL   (pcSource), 
        .D0    (t1), 
        .D1    (32'h00004444), 
        .D2    (32'h00008888), 
        .D3    (32'h0000cccc),
        .D_OUT (t2)
        );
        
    //Register to store address
    reg_nb_sclr #(.n(32)) PC_Reg (
        .data_in  (t2), 
        .ld       (PCWrite), 
        .clk      (clk), 
        .clr      (reset), 
        .data_out (pc)
        );
        
    //Ripple adder increments current address by four to load on the next cycle
    rca_nb #(.n(32)) PC_Add_Four (
        .a   (pc), 
        .b   (32'd4), 
        .cin (1'd0), 
        .sum (t1)
        );
        
endmodule
