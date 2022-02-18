`timescale 1ns / 1ps

module ALU( input  [31:0] A,
            input  [31:0] B,
            output [31:0] Result,
            output N,C,V,Z,LT,ULT,
            input  [4:0] Select
            );
      
            wire [31:0] andResult, orResult, xorResult, addResult, sltuResult, sltResult, invB, b;
            wire C1,V1;
            
            AND AND(.A(A),
                    .B(B),
                    .Result(andResult));
                    
            OR  OR(.A(A),
                   .B(B),
                   .Result(orResult));
                   
            XOR XOR(.A(A),
                    .B(B),
                    .Result(xorResult));
            
            INVERS INV(.x(B),
                       .y(invB));
                       
            MUX2 selB(.D1(invB),
                      .D0(B),
                      .O(b),
                      .S(Select[1]));
            
            ADD ADD(.A(A),
                    .B(b),
                    .Result(addResult),
                    .Cin(Select[0]),
                    .C(C1),
                    .V(V1));
                    
                    assign C = C1&(~Select[4]);
                    assign V = V1&(~Select[4]);
            
            SLT SLT(.A_MSB(A[31]),
                    .B_MSB(B[31]),
                    .addResult_MSB(addResult[31]),
                    .sltuResult(sltuResult),
                    .sltResult(sltResult),
                    .LT(LT),
                    .ULT(ULT));
            
            MUX8 selResult(.D0(addResult),
                           .D1(32'hz),
                           .D2(sltResult),
                           .D3(sltuResult),
                           .D4(xorResult),
                           .D5(32'hz),
                           .D6(orResult),
                           .D7(andResult),
                           .S(Select[4:2]),
                           .O(Result));
            
            ZERO_DETECTOR zeroDetect(.x(Result),
                                     .y(Z));
            
            assign N = Result[31];
            
            
endmodule