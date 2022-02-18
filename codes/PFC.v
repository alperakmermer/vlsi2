`timescale 1ns / 1ps

module PFC(input [31:0] PC,
           input [31:0] immediate,
           input [31:0] Rs1,
           input [31:0] Rs2,
           input [5:0] control_signals,
           output [31:0] PCnew,
           output PCnewEnable
           );
           
          wire  Z,LT,ULT;
          wire  Rs1_Sel = control_signals[5];
          wire  [2:0] BC = control_signals[2:0];
          wire  PL = control_signals[4];
          wire  JB = control_signals[3];
          wire JALR = PL & JB & ~(Rs1_Sel);
          wire [31:0] A;
           
           BRANCH_COMPARATOR branch (.A(Rs1),
                                     .B(Rs2),
                                     .Z(Z),
                                     .LT(LT),
                                     .ULT(ULT));
                                 
                                 
            MUX8 #(1) BCmux (.D0(Z), // BEQ
                        .D1(~Z), // BNE
                        .D2(1'bz),
                        .D3(1'bz),
                        .D4(LT), // BLT
                        .D5(~LT), // BGE
                        .D6(ULT), // BLTU
                        .D7(~ULT), //BGEU
                        .S(BC),
                        .O(Condition));
                        
           assign PCnewEnable = (PL) ? ( (JB) ? 1 : Condition) : 0; 
           
           MUX2 Asel(.D0(PC),
                     .D1(Rs1),
                     .S(JALR),
                     .O(A));
             
            
           ADD PC_ADD (.A(A),
                       .B(immediate),
                       .Cin(1'b0),
                       .Result(PCnew),
                       .C(),
                       .V());
endmodule
