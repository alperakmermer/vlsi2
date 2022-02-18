`timescale 1ns / 1ps

module PROCESSOR(input clk,
                 input rst,
          	 input WRITE_INSTRUCTION,
          	 input [31:0] INS,
          	 input [9:0] ADDR,
          	 input INS_MEM_RST);

            wire [31:0] PC, PCnew, immediate;
            wire [34:0] control_word;
            wire PCnewEnable, bubble ;
            
            CU ControlUnit (.clk(clk),
                            .rst(rst),
                            .WRITE_INSTRUCTION(WRITE_INSTRUCTION),
                            .ADDR(ADDR),
                            .INS_MEM_RST(INS_MEM_RST),
                            .INS(INS),
                            .PC(PC),
                            .PCnew(PCnew),
                            .PCnewEnable(PCnewEnable),
                           // .bubble(bubble),
                            .control_word(control_word),
                            .immediate(immediate));
                            
            DP DataPath(.clk(clk),
                        .rst(rst),
                        .control_word(control_word),
                        .immediate(immediate),
                        .PC(PC),
                        .PCnew(PCnew),
                       // .bubble(bubble),
                        .PCnewEnable(PCnewEnable));
                        
               
endmodule