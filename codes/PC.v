`timescale 1ns / 1ps
module PC ( input PCnewEnable,bubble,
            input clk,rst,
            input [31:0] PCnew, //DPdan geliyo 
            output reg [31:0] PC //aluya ve roma gidecek,
            );	
	
        always @(posedge clk)
        begin
            if (rst == 1)
                PC <= 32'h00000000;
            else
            begin
                if( PCnewEnable ) PC <= PCnew;
                else if (bubble) PC <= PC ;                
                else PC <= PC + 32'h0000_0004;
            end          
        end

        
        endmodule
