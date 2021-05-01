`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineers: Schuyler Fenton and Alex Neiman 
// 
// Create Date: 05/01/2021 02:00:46 PM
// Design Name: Otter MCU
// Module Name: OTTER_MCU
// 
// Revision: 1
//
// Otter RISC V MCU
// 
//////////////////////////////////////////////////////////////////////////////////


module OTTER_MCU(
    input RST,
    input intr,
    input clk,
    input [31:0] iobus_in,
    output [31:0] iobus_out,
    output [31:0] iobus_addr,
    output iobus_wr
    );
    
    // Memory
    logic [31:0] ir;
    
    // Program counter
    logic [31:0] pc;
    
    // Immediate generator output
    logic [31:0] I_type;
    logic [31:0] J_type;
    logic [31:0] B_type;
    
    // Branch address generator output
    logic [31:0] jalr;
    logic [31:0] branch;
    logic [31:0] jal;  
    
    
    Memory OTTER_MEMORY(        // Memory
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
    
    IMMED_GEN IG(               // Immediate generator
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
        .pc(pc),
        .rs(32'h0000000c),   // change
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
        
    
endmodule
