`timescale 1ns / 1ps
module CU  (input  clk,
            input  rst,
            input  WRITE_INSTRUCTION,
            input  [31:0] INS,
            input  [9:0] ADDR,
            input  INS_MEM_RST,
            input  PCnewEnable,
            input  [31:0] PCnew,
            output [31:0] PC,
            output [34:0] control_word,
            output [31:0] immediate);
            
        wire [34:0] control_word_;
        wire [31:0] instruction;
        wire [31:0] immediate_;
        wire [9:0] address;
        wire [31:0] PC_;
	wire bubble;
	
        ID InstDecoder(.instruction(instruction),
                       .control_word(control_word_),
                       .immediate(immediate_));
        
        
        PC ProgCounter(.clk(clk),
                        .rst(rst),
                        .bubble(bubble),
                        .PCnew(PCnew),
                        .PCnewEnable(PCnewEnable),
                        .PC(PC_));
        
        MUX2#(.k(10)) Mem_Addr_Sel(.D0(PC_[9:0]),
                                    .D1(ADDR),
                                    .S(WRITE_INSTRUCTION),
                                    .O(address));
                                    
        MUX2           Mem_Data_Sel(.D0(32'hz),
                                    .D1(INS),
                                    .S(WRITE_INSTRUCTION),
                                    .O(instruction));
                                    
      MEM #(.ADDR_WIDTH(10), .DEPTH(256)) 
                   ProgMem (.address(address),
                            .data(instruction),
                            .write_enable(WRITE_INSTRUCTION),
                            .rst(INS_MEM_RST),
                            .control_signals(3'b100));
                                    
        IF_ID ppl1 (.clk(clk),
                    .rst(rst),
                    .flush(PCnewEnable),
                    .bubble(bubble),
                    .control_word_in(control_word_),
                    .control_word_out(control_word),
                    .immediate_in(immediate_),
                    .immediate_out(immediate),
                    .PC_in(PC_),
                    .PC_out(PC));

       HazardDetect hd(.Rs1_address(control_word_[34:30]) ,
                       .Rs2_address(control_word_[29:25]) ,
                       .IfIdRegRd(control_word[24:20]) ,
                       .IfIdRegWrite(control_word[15]) ,
		       .IfIdMD(control_word[17:16]),
		       .PL(control_word_[4]),
		       .JB(control_word_[3]),
                       .bubble(bubble) );  
endmodule