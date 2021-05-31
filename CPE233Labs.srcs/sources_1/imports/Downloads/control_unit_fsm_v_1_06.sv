`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Schuyler Fenton, Alex Neiman
// Project Name: Experiment 7
// 
// Description: Third version of the Control Unit FSM Module for controlling write
// and read signals from instructions. Modified to handle SYS instructions for the CSR 
// and let interrupts transition to interrupt state. Adapted from CU_FSM starter template by James Ratner.
//////////////////////////////////////////////////////////////////////////////////


module CU_FSM(
    input intr,
    input clk,
    input RST,
    input [6:0] opcode,     // ir[6:0]
    input [2:0] func3,
    output logic pcWrite,
    output logic regWrite,
    output logic memWE2,
    output logic memRDEN1,
    output logic memRDEN2,
    output logic reset,
    output logic csr_WE,
    output logic int_taken
  );
    
    typedef enum logic [2:0] {
       st_INIT,
	   st_FET,
       st_EX,
       st_WB,
       st_INTR
    }  state_type; 
    state_type  NS,PS; 
      
    //- datatypes for RISC-V opcode types
    typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,        
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011,
        SYS    = 7'b1110011
    } opcode_t;
	opcode_t OPCODE;    //- symbolic names for instruction opcodes
     
	assign OPCODE = opcode_t'(opcode); //- Cast input as enum 
	 

	//- state registers (PS)
	always @ (posedge clk)  
        if (RST == 1)
            PS <= st_INIT;
        else
            PS <= NS;

    always_comb
    begin              
        //- schedule all outputs to avoid latch
        pcWrite = 1'b0;    regWrite = 1'b0;    reset = 1'b0;  
		memWE2 = 1'b0;     memRDEN1 = 1'b0;    memRDEN2 = 1'b0;
		csr_WE = 1'b0;     int_taken = 1'b0;
                   
        case (PS)

            st_INIT: //waiting state  
            begin
                pcWrite     = 1'b0;
                regWrite    = 1'b0;
                memWE2      = 1'b0;
                memRDEN1    = 1'b0;
                memRDEN2    = 1'b0;
                reset = 1'b1;                    
                NS = st_FET; 
            end

            st_FET: //waiting state  
            begin
                pcWrite     = 1'b0;
                regWrite    = 1'b0;
                memWE2      = 1'b0;
                memRDEN1    = 1'b1;
                memRDEN2    = 1'b0;
                NS = st_EX; 
            end
              
            st_EX: //decode + execute
            begin
                pcWrite = 1'b1;
                if (intr)
                    NS = st_INTR;
                else
                    NS = st_FET;
                    
				case (OPCODE)
				    LOAD:                           // lb, lbu, lh, lhu, lw,
                        begin
                            pcWrite     = 1'b0;                       
                            regWrite    = 1'b0;
                            memWE2      = 1'b0;
                            memRDEN1    = 1'b0;
                            memRDEN2    = 1'b1;     // Need to enable read access to one RAM port
                            NS = st_WB;
                        end
                    
                    STORE:                          // Reading from register and storing in memory
                        begin
                            regWrite    = 1'b0;     // do not write to reg
                            memWE2      = 1'b1;     // must write to mem
                            memRDEN1    = 1'b0;     // turn off read access
                            memRDEN2    = 1'b0;
                        end
                    
					BRANCH: 
                        begin
                            regWrite    = 1'b0;
                            memWE2      = 1'b0;
                            memRDEN1    = 1'b0;
                            memRDEN2    = 1'b0;
                        end
					
                    LUI: 
                        begin                       // load value from imm_gen into reg
                            regWrite    = 1'b1;     // only enable regWrite
                            memWE2      = 1'b0;
                            memRDEN1    = 1'b0;
                            memRDEN2    = 1'b0;
					   end
					   
					AUIPC:
					   begin
					      regWrite = 1'b1;
					   end
					
					JALR:
					   begin
					       regWrite = 1'b1;
					   end
					  
					OP_IMM:  // addi, slti, etc.
                       begin 
					       regWrite = 1'b1;
					   end
					
					OP_RG3:
					    begin
					        regWrite = 1'b1; 
					    end
					
	                JAL: 
					    begin
					        regWrite = 1'b1; 
					    end
					   
				    SYS:
				        begin
				            case (func3)
				                3'b000:
				                    begin
				                    pcWrite = 1'b1;
				                    end
				                    
				                3'b001:
				                    begin
				                    regWrite = 1'b1;
				                    csr_WE = 1'b1;
				                    end
				            endcase
				        end
                endcase
            end
               
            st_WB:
            begin
                pcWrite = 1'b1;
                regWrite = 1'b1;
                memRDEN2 = 1'b0;
                if(intr)
                    NS = st_INTR;
                else
                    NS = st_FET;
            end
            
            st_INTR: //Interrupt state, int_taken and pcWrite to trigger decoder and CSR to load mtvec
            begin
                int_taken = 1'b1;
                pcWrite = 1'b1;
                NS = st_FET;
            end
 
            default: NS = st_FET;
           
        endcase //- case statement for FSM states
    end
           
endmodule
