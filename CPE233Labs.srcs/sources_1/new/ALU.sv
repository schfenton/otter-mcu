`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////

module ALU(
    input [31:0] OP_1,
    input [31:0] OP_2,
    input [3:0] alu_fun,
    output logic [31:0] RESULT
    );
    
    always_comb
        begin
        case(alu_fun)
            4'b0000: //add
                RESULT = $signed(OP_1) + $signed(OP_2);
            
            4'b1000: //sub
                RESULT =  $signed(OP_1) - $signed(OP_2);
                
            4'b0110: //or
                RESULT = OP_2 | OP_1;
                
            4'b0111: //and
                RESULT = OP_1 & OP_2;
                
            4'b0100: //xor
                RESULT = (OP_1 & ~OP_2) | (OP_2 & ~OP_1);
             
            4'b0101: //srl
                RESULT = OP_1 >> OP_2[4:0];
                
            4'b0001: //sll
                RESULT = OP_1 << OP_2[4:0];
                
            4'b1101: //sra
                RESULT = $signed(OP_1) >>> OP_2[4:0];
            
            4'b0010: //slt
                begin
                if($signed(OP_1) < $signed(OP_2))
                    RESULT = 1;    
                else
                    RESULT = 0;
                end
            
            4'b0011: //sltu
                begin
                if(OP_1 < OP_2)
                    RESULT = 1;    
                else
                    RESULT = 0;
                end
                
            4'b1001: //lui
                RESULT = OP_1;
            
            default:
                RESULT = 32'hDEADBEEF; //-559038737
        endcase
        end
endmodule
