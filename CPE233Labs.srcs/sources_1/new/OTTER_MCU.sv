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
    
    // FUTURE (CSR)
    logic [31:0] CSR_reg;
    
    // Memory
    logic [31:0] ir;
    logic [31:0] mem_data;
    
    // Program counter
    logic [31:0] pc;
    logic [31:0] next_addr;
    
    //CU_DCDR
    logic [3:0] alu_fun;
    logic alu_srcA;
    logic [1:0] alu_srcB;
    logic [1:0] pcSource;
    logic [1:0] rf_wr_sel;
    
    //CU_FSM
    logic PCWrite;
    logic regWrite;
    logic memRDEN1;
    logic memRDEN2;
    logic memWE2;
    logic reset;
    
    // Immediate generator output
    logic [31:0] U_type;
    logic [31:0] I_type;
    logic [31:0] S_type;
    logic [31:0] J_type;
    logic [31:0] B_type;
    
    // Branch address generator output
    logic [31:0] jalr;
    logic [31:0] branch;
    logic [31:0] jal;
    
    //REG_FILE
    logic [31:0] rs1;
    logic [31:0] rs2;
    //REG_FILE_MUX
    logic [31:0] wd_load;
    
    //BRANCH_COND_GEN
    logic br_eq = (rs1 == rs2);
    logic br_lt = ($signed(rs1) < $signed(rs2));
    logic br_ltu = (rs1 < rs2);
    
    //ALU
    logic [31:0] alu_result;
    //SRCA_MUX
    logic [31:0] srcA;
    //SRCB_MUX
    logic [31:0] srcB;
    
    
    Memory OTTER_MEMORY(        // Memory
        .MEM_CLK    (clk),
        .MEM_RDEN1  (memRDEN1),
        .MEM_RDEN2  (memRDEN2),
        .MEM_WE2    (memWE2),
        .MEM_ADDR1  (pc[15:2]),
        .MEM_ADDR2  (alu_result),
        .MEM_DIN2   (rs2),
        .MEM_SIZE   (ir[13:12]),
        .MEM_SIGN   (ir[14]),
        .IO_IN      (iobus_in),
        .IO_WR      (iobus_wr),
        .MEM_DOUT1  (ir),
        .MEM_DOUT2  (mem_data)
        );
        
    ProgramCounterMod ProgramCounterMod(
        .reset(reset),
        .PCWrite(PCWrite),
        .pcSource(pcSource),
        .clk(clk),
        .pc(pc),
        .jalr(jalr),
        .branch(branch),
        .jal(jal),
        .next_addr(next_addr)
        );
        
     CU_DCDR my_cu_dcdr(
        .br_eq     (br_eq), 
        .br_lt     (br_lt), 
        .br_ltu    (br_ltu),
        .opcode    (ir[6:0]),    //-  ir[6:0]
        .func7     (ir[30]),    //-  ir[30]
        .func3     (ir[14:12]),    //-  ir[14:12] 
        .alu_fun(alu_fun),
        .alu_srcA(alu_srcA),
        .alu_srcB(alu_srcB),
        .pcSource(pcSource),
        .rf_wr_sel(rf_wr_sel)   );
    
    CU_FSM CU_FSM(
        .RST(RST),
        .intr(intr),
        .clk(clk),
        .opcode(ir[6:0]),     // ir[6:0]
        .pcWrite(PCWrite),
        .regWrite(regWrite),
        .memWE2(memWE2),
        .memRDEN1(memRDEN1),
        .memRDEN2(memRDEN2),
        .reset(reset)
    );
    
    IMMED_GEN IG(               // Immediate generator
        .ir(ir[31:7]),
        .U_type(U_type),
        .I_type(I_type),
        .S_type(S_type),
        .J_type(J_type),
        .B_type(B_type)
        );
        
    BRANCH_ADDR_GEN BAG(
        .J_type(J_type),
        .B_type(B_type),
        .I_type(I_type),
        .pc(pc),
        .rs(rs1),
        .jal(jal),
        .branch(branch),
        .jalr(jalr)
    );
    
    // Mux that goes into the reg file
    mux_4t1_nb  #(.n(32)) WD_Load_MUX  (
        .SEL   (rf_wr_sel), 
        .D0    (next_addr), 
        .D1    (0), 
        .D2    (mem_data), 
        .D3    (alu_result),
        .D_OUT (wd_load)
        ); 
    
    RegFile REG_FILE(
        .clk(clk),
        .en(regWrite),
        .wd(wd_load),
        .adr1(ir[19:15]),
        .adr2(ir[24:20]),
        .wa(ir[11:7]),
        .rs1(rs1),
        .rs2(rs2)
    );
    
    
    // Mux A (srcA), goes into ALU
    mux_2t1_nb  #(.n(32)) ALU_srcA_MUX  (
        .SEL   (alu_srcA), 
        .D0    (rs1), 
        .D1    (U_type), 
        .D_OUT (srcA)
    );
        
    // Mux B (srcB), also goes into ALU
    mux_4t1_nb  #(.n(32)) ALU_srcB_MUX  (
        .SEL   (alu_srcB),
        .D0    (rs2),
        .D1    (I_type),
        .D2    (S_type),
        .D3    (pc),
        .D_OUT (srcB)
    );
        
    ALU ALU (
        .OP_1(srcA),
        .OP_2(srcB),
        .alu_fun(alu_fun),
        .RESULT(alu_result)
    );
    
    // Mapping IO and stuff
    assign iobus_addr = alu_result;
    assign iobus_out = rs2;
    
    
endmodule
