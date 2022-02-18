`timescale 1ns / 1ps

module SHIFT( input  [31:0] A,
              input  [31:0] B,
              input  [1:0]  Select, 
              output [31:0] Result);
              
    wire s ; 
    
    wire [31:0] reverseIn , reverseOut ;
    wire [31:0] Input ;
    
    wire [31:0] lvl0 , lvl1 , lvl2 , lvl3 , lvl4 ; 
    wire [31:0] lvl0o , lvl1o , lvl2o , lvl3o , lvl4o ; 
     
     genvar i ; 
     for (i = 0 ; i<32 ; i = i+1 )
     begin
     assign reverseIn[i] = A[31-i] ;
     end
     
    assign Input = (Select[0]) ? A : reverseIn ; 
    assign s = (Select[1]) ? A[31] : 1'b0 ; 
    assign lvl4 = {s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,s,Input[31:16]} ;
    assign lvl3 = {s,s,s,s,s,s,s,s,lvl4o[31:8]} ;
    assign lvl2 = {s,s,s,s,lvl3o[31:4]} ;
    assign lvl1 = {s,s,lvl2o[31:2]} ;
    assign lvl0 = {s,lvl1o[31:1]} ;
    
      MUX2 shift16_mux (.D0(Input), .D1(lvl4) , .S(B[4]), .O(lvl4o) ) ;
      MUX2 shift8_mux (.D0(lvl4o), .D1(lvl3) , .S(B[3]), .O(lvl3o) ) ;
      MUX2 shift4_mux (.D0(lvl3o), .D1(lvl2) , .S(B[2]), .O(lvl2o) ) ;
      MUX2 shift2_mux (.D0(lvl2o), .D1(lvl1) , .S(B[1]), .O(lvl1o) ) ;
      MUX2 shift1_mux (.D0(lvl1o), .D1(lvl0) , .S(B[0]), .O(lvl0o) ) ;
      
      
     
     for (i = 0 ; i<32 ; i = i+1 )
     begin
     assign reverseOut[i] = lvl0o[31-i] ;
     end
   
   assign Result = (Select[0]) ? lvl0o : reverseOut ;
  
endmodule
