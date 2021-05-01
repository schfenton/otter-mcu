//////////////////////////////////////////////////////////////////////////////////
// Engineers: Schuyler Fenton, Kerr Allan, Kunj Shah
// Project Name: Experiment 1
// Module Name: EXP1_CKT
// Description: Top level module for Experiment 1, Part A. Creates and
// configures instances of all modules used.
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module EXP1_CKT(
    input BTN,
    input CLK,
    output [3:0] ANODES, 
    output [7:0] SEGMENTS, 
    output [3:0] LEDS
    );
    
    //initialize wires for connections between modules
    logic sclk;
    logic done;
    logic en;
    logic set;
    logic clr;
    logic [14:0] newreg;
    logic [14:0] oldreg;
    logic [14:0] rcasum;
    logic [14:0] ramdata; 
    logic [14:0] dispdata;
    logic [14:0] fibnum;
    logic [3:0] addy;
    
    //clock divider divides 100 MHz board clock by 2^25
    clk_2n_div_test #(.n(25)) MY_DIV (
          .clockin   (CLK), 
          .fclk_only (0),          
          .clockout  (sclk)   );
          
    fib_fsm FSM_inst (
        .done(done), 
        .clk(sclk), 
        .btn(BTN), 
        .en(en), 
        .clr(clr), 
        .set(set));
    
    //new_num register instanced to hold last sum    
    reg_nb #(15) new_num ( 
        .data_in(fibnum), 
        .clk(sclk), 
        .clr(0), 
        .ld(en), 
        .data_out(newreg));
    
    //old_num register holds the second newest sum
    reg_nb #(15) old_num (
        .data_in(newreg), 
        .clk(sclk), 
        .clr(0), 
        .ld(en), 
        .data_out(oldreg));
   
    //ripple carry adder sums the register values
    rca_nb #(15) fib_add (
        .a(newreg), 
        .b(oldreg), 
        .cin(0), 
        .sum(rcasum), 
        .co());
    
    //mux instanced so that the "set" signal can force the first two numbers in the
    //sequence as "1"
    mux_2t1_nb #(15) summux (
        .SEL(set), 
        .D0(rcasum), 
        .D1(15'b000000000000001), 
        .D_OUT(fibnum));
    
    cntr_up_clr_nb #(4) memcount (
        .clk(sclk), 
        .clr(clr), 
        .up(~(en & ~fibnum[0])), 
        .count(addy), 
        .rco(done));
    
    ram_single_port #(4, 15) RAM (
        .clk(sclk), 
        .addr(addy), 
        .we(en & fibnum[0]), 
        .data_in(fibnum), 
        .data_out(ramdata));
    
    mux_2t1_nb #(15) displaymux (
        .SEL(en), 
        .D0(ramdata), 
        .D1(fibnum), 
        .D_OUT(dispdata));
    
    univ_sseg sseg (
        .clk(CLK), 
        .cnt1(dispdata[13:0]), 
        .cnt2(0), .dp_en(0), 
        .dp_sel(0), 
        .mod_sel(2'b10), 
        .sign(0), 
        .valid(1), 
        .ssegs(SEGMENTS), 
        .disp_en(ANODES));
        
    assign LEDS = addy;
    
endmodule
