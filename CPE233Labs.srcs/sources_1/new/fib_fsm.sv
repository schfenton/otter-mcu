`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineers: Schuyler Fenton, Kerr Allan, Kunj Shah
// Project Name: Experiment 1
// Module Name: fib_fsm
// Description: Finite State Module that handles the sequencing for filling the RAM  // with the generated Fibonacci sequence.
//////////////////////////////////////////////////////////////////////////////////


module fib_fsm(
    input clk,
    input btn,
    input done,
    output logic en,
    output logic clr,
    output logic set
    );
    
    parameter [3:0]
    DISPLAY = 2'b00,
    VAL = 2'b01,
    VAL2 = 2'b10,
    FILL = 2'b11;
    
    logic [1:0] NS;
    logic [1:0] PS = DISPLAY; //initializes FSM to DISPLAY state
    
    always_ff @(posedge clk)
        begin
            PS <= NS;
        end
    
    always_comb
        begin
        en = 0; clr = 0; set = 0; //initializes output signals to 0 before case eval
        case(PS)
            DISPLAY:
            begin
            
            en = 0; clr = 0; set = 0; //all outputs low while in DISPLAY state
            
	     if(btn)
                begin
                clr = 1; //if the button is pressed, clr is set high on the transition
                         //to async reset the memory address  counter
                NS = VAL; //transition to val state
                end
            else
                begin
                NS = DISPLAY; //stay in display state if button not pressed
                end
            end
            
            VAL:
            begin
            en = 1; clr = 0; set = 1; //make en high to start writing to ram and set
                                      //high to force first number to be 1
            NS = VAL2; //set next state to VAL2 unconditionally
            end
            
            VAL2:
            begin
            en = 1; clr = 0; set = 1; //do same as first state for second number
            NS = FILL; //set next state to FILL unconditionally
            end
            
            FILL:
            begin
            en = 1; clr = 0; set = 0; //en high to write to ram, but set is low to
                                      //let numbers be generated 
            if(done)
                begin
                NS = DISPLAY; //set FSM back to DISPLAY state if RAM is full
                end
            else
                begin
                NS = FILL; //otherwise stay in FILL
                end
            end
        default:
            NS = DISPLAY;
        endcase
        end
endmodule
