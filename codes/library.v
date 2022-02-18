`timescale 1ns / 1ps
module AND#(parameter SIZE = 32)
            ( input  [SIZE-1:0] A,
              input  [SIZE-1:0] B,
              output [SIZE-1:0] Result );
            
            assign Result = A & B;

endmodule

module OR( input  [31:0] A,
           input  [31:0] B,
           output [31:0] Result );
            
           assign Result = A | B;

endmodule

module XOR( input  [31:0] A,
            input  [31:0] B,
            output [31:0] Result );
            
            assign Result = A ^ B;

endmodule

module CLA #(parameter SIZE = 8)
            ( input  [SIZE-1:0] x,
              input  [SIZE-1:0] y,
              input  ci,
              output cout,
              output overflow,
              output [SIZE-1:0] s );

            (* dont_touch="true" *) wire [SIZE-1:0] g , p ;
            (* dont_touch="true" *) wire [SIZE:0] c ;
            
            assign c[0] = ci ;
            
            genvar i ;
            generate 
                for (i=0 ; i<SIZE ; i=i+1)
                begin
                    assign g[i]   = x[i] & y[i] ;
                    assign p[i]   = x[i] ^ y[i] ;
                    assign c[i+1] = g[i] | (p[i] & c[i]) ;
                    assign s[i]   = x[i] ^ y[i] ^ c[i] ;
                end
            endgenerate
            
            assign overflow = c[SIZE] ^ c[SIZE-1];
            assign cout = c[SIZE] ;

endmodule

module ADD( input [31:0] A,
            input [31:0] B,
            input Cin,
            output [31:0] Result,
            output C,
            output V );
            
            wire w1, w2, w3;
            
            CLA cla1(.x(A[31:24]),
                     .y(B[31:24]),
                     .ci(w1),
                     .cout(C),
                     .overflow(V),
                     .s(Result[31:24]));
            CLA cla2(.x(A[23:16]),
                     .y(B[23:16]),
                     .ci(w2),
                     .cout(w1),
                     .overflow(),
                     .s(Result[23:16]));
            CLA cla3(.x(A[15:8]),
                     .y(B[15:8]),
                     .ci(w3),
                     .cout(w2),
                     .overflow(),
                     .s(Result[15:8]));
            CLA cla4(.x(A[7:0]),
                     .y(B[7:0]),
                     .ci(Cin),
                     .cout(w3),
                     .overflow(),
                     .s(Result[7:0]));                                   
endmodule

module SLT( input A_MSB,
            input B_MSB,
            input addResult_MSB,
            output [31:0] sltuResult,
            output [31:0] sltResult,
            output LT,
            output ULT );
             
            MUX4 mux1(.D0({31'b0,addResult_MSB}),
                      .D1(32'h0000_0001),
                      .D2(32'h0000_0000),
                      .D3({31'b0,addResult_MSB}),
                      .S({A_MSB,B_MSB}),
                      .O(sltuResult));
                     
            MUX4 mux2(.D0({31'b0,addResult_MSB}),
                      .D1(32'h0000_0000), 
                      .D2(32'h0000_0001),
                      .D3({31'b0,addResult_MSB}),
                      .S({A_MSB,B_MSB}),
                      .O(sltResult));    
                     
                     assign LT  = sltResult[0]; 
                     assign ULT = sltuResult[0];
           
endmodule

module INVERS( input [31:0] x,
               output[31:0] y );
            
               assign y=~x;
endmodule  

module ZERO_DETECTOR ( input  [31:0] x,
                       output  y);
                       
                       assign y = ~(|x);
        
endmodule

module BRANCH_COMPARATOR ( input [31:0] A,
                           input [31:0] B,
                           output Z,
                           output LT,
                           output ULT );
                           
                           assign Z = (A==B) ? 1 : 0;
                           assign ULT = (A<B) ? 1 : 0;
                           assign LT = (A[31]~^B[31]) ? ULT : ( (A[31]) ? 1 : 0);                          
endmodule


module MUX2 #( parameter k = 32)
             ( input[k-1:0] D0,
               input[k-1:0] D1,
               input S,
               output reg [k-1:0]O );
    
               always@* begin
                   case (S)
                       1'b0 : O = D0;
                       1'b1 : O = D1;
                   endcase
               end
    
endmodule

module MUX4 #( parameter k = 32)
             ( input[k-1:0] D0,
               input[k-1:0] D1,
               input[k-1:0] D2,
               input[k-1:0] D3,
               input[1:0] S,
               output reg [k-1:0] O );

                 always@* begin
                   case (S)
                       2'b00 : O = D0;
                       2'b01 : O = D1;
                       2'b10 : O = D2;
                       2'b11 : O = D3;
                   endcase
               end

endmodule

module MUX8 #( parameter k = 32)
             ( input[k-1:0] D0,
               input[k-1:0] D1,
               input[k-1:0] D2,
               input[k-1:0] D3,
               input[k-1:0] D4,
               input[k-1:0] D5,
               input[k-1:0] D6,
               input[k-1:0] D7,
               input[2:0] S,
               output reg [k-1:0]O );

               always@* begin
                   case (S)
                       3'b000 : O = D0;
                       3'b001 : O = D1;
                       3'b010 : O = D2;
                       3'b011 : O = D3;
                       3'b100 : O = D4;
                       3'b101 : O = D5;
                       3'b110 : O = D6;
                       3'b111 : O = D7;
                   endcase
               end
endmodule

module MUX32 #( parameter k = 32)
             ( input[k-1:0] D0,
               input[k-1:0] D1,
               input[k-1:0] D2,
               input[k-1:0] D3,
               input[k-1:0] D4,
               input[k-1:0] D5,
               input[k-1:0] D6,
               input[k-1:0] D7,
               input[k-1:0] D8,
               input[k-1:0] D9,
               input[k-1:0] D10,
               input[k-1:0] D11,
               input[k-1:0] D12,
               input[k-1:0] D13,
               input[k-1:0] D14,
               input[k-1:0] D15,
               input[k-1:0] D16,
               input[k-1:0] D17,
               input[k-1:0] D18,
               input[k-1:0] D19,
               input[k-1:0] D20,
               input[k-1:0] D21,
               input[k-1:0] D22,
               input[k-1:0] D23,
               input[k-1:0] D24,
               input[k-1:0] D25,
               input[k-1:0] D26,
               input[k-1:0] D27,
               input[k-1:0] D28,
               input[k-1:0] D29,
               input[k-1:0] D30,
               input[k-1:0] D31,
               input[4:0] S,
               output reg [k-1:0]O );

               always@* begin
                   case (S)
                       5'd0 : O = D0;
                       5'd1 : O = D1;
                       5'd2 : O = D2;
                       5'd3 : O = D3;
                       5'd4 : O = D4;
                       5'd5 : O = D5;
                       5'd6 : O = D6;
                       5'd7 : O = D7;
                       5'd8 : O = D8;
                       5'd9 : O = D9;
                       5'd10 : O = D10;
                       5'd11 : O = D11;
                       5'd12 : O = D12;
                       5'd13 : O = D13;
                       5'd14 : O = D14;
                       5'd15 : O = D15;
                       5'd16 : O = D16;
                       5'd17 : O = D17;
                       5'd18 : O = D18;
                       5'd19 : O = D19;
                       5'd20 : O = D20;
                       5'd21 : O = D21;
                       5'd22 : O = D22;
                       5'd23 : O = D23;
                       5'd24 : O = D24;
                       5'd25 : O = D25;
                       5'd26 : O = D26;
                       5'd27 : O = D27;
                       5'd28 : O = D28;
                       5'd29 : O = D29;
                       5'd30 : O = D30;
                       5'd31 : O = D31;
                   endcase
               end
endmodule

module RFDecoder ( 
input [4:0]D ,
                   output reg [31:0] O );


                always@(*)
                begin
                    case(D)
                    5'd0 : O = 32'h0000_0001 ; 
                    5'd1 : O = 32'h0000_0002 ; 
                    5'd2 : O = 32'h0000_0004 ; 
                    5'd3 : O = 32'h0000_0008 ; 
                    5'd4 : O = 32'h0000_0010 ; 
                    5'd5 : O = 32'h0000_0020 ; 
                    5'd6 : O = 32'h0000_0040 ; 
                    5'd7 : O = 32'h0000_0080 ; 
                    5'd8 : O = 32'h0000_0100 ; 
                    5'd9 : O = 32'h0000_0200 ; 
                    5'd10 : O = 32'h0000_0400 ; 
                    5'd11 : O = 32'h0000_0800 ; 
                    5'd12 : O = 32'h0000_1000 ; 
                    5'd13 : O = 32'h0000_2000 ; 
                    5'd14 : O = 32'h0000_4000 ; 
                    5'd15 : O = 32'h0000_8000 ; 
                    5'd16 : O = 32'h0001_0000 ; 
                    5'd17 : O = 32'h0002_0000 ; 
                    5'd18 : O = 32'h0004_0000 ; 
                    5'd19 : O = 32'h0008_0000 ; 
                    5'd20 : O = 32'h0010_0000 ; 
                    5'd21 : O = 32'h0020_0000 ; 
                    5'd22 : O = 32'h0040_0000 ; 
                    5'd23 : O = 32'h0080_0000 ; 
                    5'd24 : O = 32'h0100_0000 ; 
                    5'd25 : O = 32'h0200_0000 ; 
                    5'd26 : O = 32'h0400_0000 ; 
                    5'd27 : O = 32'h0800_0000 ; 
                    5'd28 : O = 32'h1000_0000 ; 
                    5'd29 : O = 32'h2000_0000 ; 
                    5'd30 : O = 32'h4000_0000 ; 
                    5'd31 : O = 32'h8000_0000 ;
                    endcase
                end
endmodule
