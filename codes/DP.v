`timescale 1ns / 1ps
module DP ( input  [34:0] control_word,
            input  [31:0] immediate,
            input  [31:0] PC,
            output [31:0] PCnew,
            output PCnewEnable,
            input  clk,
	    input  rst );

///////////////////////////////_ID_////////////////////////////////////////////////////////////////

        wire [4:0]  Rs1_Address = control_word[34:30];
        wire [4:0]  Rs2_Address = control_word[29:25];
	wire [4:0]  IfIdRegRd   = control_word[24:20];
        wire [31:0] Rs1;
        wire [31:0] Rs2;
        wire [31:0] in1;
        wire [31:0] in2;

        /////////FROM WB//////////////////////////////////////////
        wire [34:0] control_word_ddd;
        wire [4:0]  Rd_Address = control_word_ddd[24:20];
        wire        RW         = control_word_ddd[15];
        wire [31:0] Rd;
        /////////////////////////////////////////////////////////
        
       RF RegisterFile (.clk(clk),
                        .rst(rst),
                        .write_enable(RW),
                        .Rd(Rd),
                        .Rd_Address(Rd_Address),
                        .Rs1(Rs1),
                        .Rs1_Address(Rs1_Address),
                        .Rs2(Rs2),
                        .Rs2_Address(Rs2_Address) );

                        
       PFC ProgramFlowController (.Rs1(in1),
                                  .Rs2(in2),
                                  .PC(PC),
                                  .immediate(immediate),
                                  .PCnew(PCnew),
                                  .control_signals({control_word[19],control_word[4:0]}),
                                  .PCnewEnable(PCnewEnable) );
                                    
 ////////////////////////////////////////////////////////////////////////////////////////////////////
 
        wire [31:0] Rs1_d;
        wire [31:0] Rs2_d;      
        wire [34:0] control_word_d;
        wire [31:0] immediate_d;
        wire [31:0] PC_d;

        
        ID_EXE ppl2 (.clk(clk),
                     .rst(rst),
		     .bubble(bubble),
                     .control_word_in(control_word),
                     .control_word_out(control_word_d),
                     .Rs1_in(in1),
                     .Rs1_out(Rs1_d),
                     .Rs2_in(in2),
                     .Rs2_out(Rs2_d),
                     .immediate_in(immediate),
                     .immediate_out(immediate_d),
                     .PC_in(PC),
                     .PC_out(PC_d) );


        wire [4:0]  IdExeRegRd    = control_word_d[24:20];
	wire 	    IdExeRegWrite = control_word_d[15];
	wire [1:0]  IdExeMD       = control_word_d[17:16];
	wire [4:0]  Rs1_Address_d = control_word_d[34:30];
        wire [4:0]  Rs2_Address_d = control_word_d[29:25];
        wire 	    input1_sel    = control_word_d[19];
        wire 	    input2_sel    = control_word_d[18];
        wire [5:0]  FS            = control_word_d[14:9];       
 
 ///////////////////////////////_EXE_////////////////////////////////////////////////////////////////
               
        wire [31:0] input1, input11;
        wire [31:0] input2, input22;
        wire [31:0] FU_result;      
               
        MUX2 selA (.D0(input11),
                   .D1(PC_d),
                   .S(input1_sel),
                   .O(input1) );                                                           
                   
        MUX2 selB (.D0(input22),
                   .D1(immediate_d),
                   .S(input2_sel),
                   .O(input2) );  

	  
                    
        FU FunctionUnit (.A(input1),
                        .B(input2),
                        .F(FU_result),
                        .control_signals(FS),
                        .status_signals() );
	                        
//////////////////////////////////////////////////////////////////////////////////////////////////// 
        
        wire [34:0] control_word_dd;
        wire [31:0] immediate_dd; 
        wire [31:0] FU_result_d;
	wire [31:0] Rs2_dd;
        wire [31:0] PC_dd;
        
        EXE_MEM ppl3 ( .clk(clk),
                       .rst(rst),
         	       .control_word_in(control_word_d),
               	       .control_word_out(control_word_dd),
                       .Rs2_in(Rs2_d),
               	       .Rs2_out(Rs2_dd),
                       .immediate_in(immediate_d),
                       .immediate_out(immediate_dd),
                       .PC_in(PC_d),
                       .PC_out(PC_dd),
                       .FU_result_in(FU_result),
                       .FU_result_out(FU_result_d) );


        wire [4:0] ExeMemRegRd 	  = control_word_dd[24:20];      
        wire 	   ExeMemRegWrite = control_word_dd[15];
        wire       MW 		  = control_word_dd[8];
        wire [2:0] BHWU 	  = control_word_dd[7:5];
        wire [4:0] Rs2_Address_dd = control_word_dd[29:25];
///////////////////////////////_MEM_////////////////////////////////////////////////////////////////        
        
        wire [31:0] Mem_Data;
	wire [31:0] Mem_Data_in;
        wire [6:0]  Mem_Address;
        
        MUX2 Mem_Write_Sel(.D0('hz),
                           .D1(Mem_Data_in),
                           .S(MW),
                           .O(Mem_Data) );
                                    
         MEM DataMem (.address(FU_result_d[6:0]),
                      .data(Mem_Data),
                      .write_enable(MW),
                      .rst(rst),
                      .control_signals(BHWU) );
                                       
////////////////////////////////////////////////////////////////////////////////////////////////////   
        
        wire [31:0] Mem_Data_d;
        wire [31:0] FU_result_dd;
        wire [31:0] immediate_ddd;
        wire [31:0] PC_ddd;

 	MEM_WB ppl4 ( .clk(clk),
               	      .rst(rst),
                      .control_word_in(control_word_dd),
                      .control_word_out(control_word_ddd),
                      .immediate_in(immediate_dd),
                      .immediate_out(immediate_ddd),
                      .PC_in(PC_dd),
                      .PC_out(PC_ddd),
                      .FU_result_in(FU_result_d),
                      .FU_result_out(FU_result_dd),
                      .Mem_Data_in(Mem_Data),
                      .Mem_Data_out(Mem_Data_d) );

        wire [4:0] MemWbRegRd    = control_word_ddd[24:20];
        wire 	   MemWbRegWrite = control_word_ddd[15];       
        wire [1:0] Rd_sel        = control_word_ddd[17:16];

///////////////////////////////_WB_////////////////////////////////////////////////////////////////
                  
        MUX4 selD (.D0(Mem_Data_d),
                   .D1(FU_result_dd),
                   .D2(PC_dd),
                   .D3(immediate_ddd),
                   .S(Rd_sel),
                   .O(Rd) );
        
////////////////////////////__FORWARD_CONTROL__//////////////////////////////////////////////////// 
    	
	wire [1:0] ForwardA_exe, ForwardB_exe, ForwardA_id, ForwardB_id;
	wire Forward_mem;

        ForwardUnit forward (
			    .IfIdRegRs1(Rs1_Address),
                            .IfIdRegRs2(Rs2_Address),
			    .IdExeRegRs1(Rs1_Address_d),
                            .IdExeRegRs2(Rs2_Address_d),
                            .ExeMemRegRs2(Rs2_Address_dd),
                            .ExeMemRegRd(ExeMemRegRd),
                            .MemWbRegRd(MemWbRegRd),
			    .IdExeRegWrite(IdExeRegWrite),
                            .ExeMemRegWrite(ExeMemRegWrite),
                            .MemWbRegWrite(MemWbRegWrite),
                            .ForwardA_id(ForwardA_id),
	                    .ForwardB_id(ForwardB_id),
                            .ForwardA_exe(ForwardA_exe),
	                    .ForwardB_exe(ForwardB_exe),
			    .MemWbMD(control_word_ddd[17:16]),
			    .ExeMemMD(control_word_dd[17:16]),
			    .Rs2_sel(input2_sel),
			    .ExeMemMemWrite(control_word_dd[8]),
			    .Forward_mem(Forward_mem) );   
	                        
       MUX4 id_in1  (.D0(Rs1),
                     .D1(FU_result_d),
		     .D2(Mem_Data_d),
	             .D3(FU_result_dd),
                     .S(ForwardA_id),
                     .O(in1)); 

       MUX4 id_in2  (.D0(Rs2),
                     .D1(FU_result_d),
		     .D2(Mem_Data_d),
	             .D3(FU_result_dd),
                     .S(ForwardB_id),
                     .O(in2));    
	                     
       MUX4 exe_in1 (.D0(Rs1_d),
                     .D1(FU_result_d),
		     .D2(Mem_Data_d),
	             .D3(FU_result_dd),
                     .S(ForwardA_exe),
                     .O(input11)); 

       MUX4 exe_in2 (.D0(Rs2_d),
                     .D1(FU_result_d),
		     .D2(Mem_Data_d),
	             .D3(FU_result_dd),
                     .S(ForwardB_exe),
                     .O(input22)); 

       MUX2 mem_in  (.D0(Rs2_dd),
		     .D1(FU_result_dd),
		     .S(Forward_mem),
		     .O(Mem_Data_in) );          
	                                          
////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule