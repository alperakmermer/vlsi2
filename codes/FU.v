`timescale 1ns / 1ps

module FU( input  [31:0] A,
           input  [31:0] B,
           input  [5:0] control_signals,
           output [31:0] F,
           output [5:0] status_signals );
           
           wire [31:0] aluResult, shiftResult;
           
           ALU alu1(.A(A),
                    .B(B),
                    .Result(aluResult),
                    .Select(control_signals[4:0]),
                    .N(status_signals[5]),
                    .V(status_signals[4]),
                    .C(status_signals[3]),
                    .Z(status_signals[2]),
                    .LT(status_signals[1]),
                    .ULT(status_signals[0]));
                    
            SHIFT shift1(.A(A),
                         .B(B),
                         .Select(control_signals[3:2]),
                         .Result(shiftResult));
                     
            MUX2 mux1(.D0(aluResult),
                      .D1(shiftResult),
                      .S(control_signals[5]),
                      .O(F));
endmodule