`timescale 1ns / 1ps

module HazardDetect( input [4:0] Rs1_address ,
		     input [4:0] Rs2_address ,
	             input [4:0]IfIdRegRd ,
	             input [1:0]IfIdMD ,
		     input IfIdRegWrite ,
		     input PL, JB,
	             output reg bubble    );

always@ (*)
begin

if ( (IfIdMD == 2'b00 || (PL && ~JB ) ) && (IfIdRegWrite) &&  ( (IfIdRegRd == Rs1_address) || (IfIdRegRd == Rs2_address)) )// && ( ~Rs2_sel) )
    bubble = 1'b1 ;
else 
    bubble = 1'b0 ;
 
end

endmodule