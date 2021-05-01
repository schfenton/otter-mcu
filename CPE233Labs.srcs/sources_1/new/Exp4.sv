`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Alex Neiman, Schuyler Fenton 
// 
// Design Name: CPE233 Experiment 2
// Description: Defines and instantiates a ProgramCounter module to store and
// manipulate the address of an OTTER_MEMORY instance.
//////////////////////////////////////////////////////////////////////////////////

module Exp4(
    input PCWrite,
    input [1:0] pcSource,
    input clk,
    input rst,
    output [31:0] u_type_imm,
    output [31:0] s_type_imm
    );
    
    logic [31:0] ir;
    logic [31:0] pc;
    logic [31:0] I_type;
    logic [31:0] J_type;
    logic [31:0] B_type;
    logic [31:0] jalr;
    logic [31:0] branch;
    logic [31:0] jal;    
    
    IMMED_GEN IG(
        .ir(ir[31:7]),
        .U_type(u_type_imm),
        .I_type(I_type),
        .S_type(s_type_imm),
        .J_type(J_type),
        .B_type(B_type)
        );
        
    BRANCH_ADDR_GEN BAG(
        .J_type(J_type),
        .B_type(B_type),
        .I_type(I_type),
        .pc(pc-32'd4),     // Minus four: simulation only...change later
        .rs(32'h0000000c),
        .jal(jal),
        .branch(branch),
        .jalr(jalr)
    );
    
    ProgramCounterMod ProgramCounterMod(
        .reset(rst),
        .PCWrite(PCWrite),
        .pcSource(pcSource),
        .clk(clk),
        .pc(pc),
        .jalr(jalr),
        .branch(branch),
        .jal(jal)
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

module ProgramCounterMod(
    input reset,
    input PCWrite,
    input [1:0] pcSource,
    input clk,
    input [31:0] jal,
    input [31:0] branch,
    input [31:0] jalr,
    output logic [31:0] pc
    );
    
    logic [31:0] next_addr; // Output from RCA
    logic [31:0] load_addr; // Output from Mux into PC reg
    
    //MUX for pcSource to select instruction inputs
    mux_4t1_nb  #(.n(32)) Mux_PCSourceSelector  (
        .SEL   (pcSource), 
        .D0    (next_addr), 
        .D1    (jalr), 
        .D2    (branch), 
        .D3    (jal),
        .D_OUT (load_addr)
        );
        
    //Register to store address
    reg_nb_sclr #(.n(32)) PC_Reg (
        .data_in  (load_addr), 
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
        .sum (next_addr)
        );
        
endmodule
