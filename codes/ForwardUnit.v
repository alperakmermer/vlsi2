`timescale 1ns / 1ps

module ForwardUnit(
    input [4:0] IfIdRegRs1,
    input [4:0] IfIdRegRs2,
    input [4:0] IdExeRegRs1,
    input [4:0] IdExeRegRs2,
    input [4:0] ExeMemRegRs2,
    input [4:0] ExeMemRegRd,
    input [4:0] MemWbRegRd,
    input IdExeRegWrite,
    input ExeMemRegWrite,
    input MemWbRegWrite,
    input [1:0] ExeMemMD,
    input [1:0] MemWbMD,
    output reg [1:0] ForwardA_id,
    output reg [1:0] ForwardB_id,
    output reg [1:0] ForwardA_exe,
    output reg [1:0] ForwardB_exe,
    input Rs2_sel,
    input ExeMemMemWrite,
    output reg Forward_mem   );
    		

	always@ (*)
	begin 
	
	  	if ( (ExeMemRegRs2 == MemWbRegRd) && (ExeMemMemWrite) ) Forward_mem = 1'b1;
		else Forward_mem = 1'b0; 

	end

	always@ (*)
	begin 
	
	  	if (ExeMemRegWrite && (ExeMemRegRd != 0 ) && (ExeMemRegRd == IdExeRegRs1) && (ExeMemMD == 2'b01) )  //FUresult_d str ekle
			ForwardA_exe = 2'b01;
		else if (MemWbRegWrite && (MemWbRegRd != 0 ) && (MemWbRegRd == IdExeRegRs1) && (ExeMemRegRd != IdExeRegRs1) && ( MemWbMD == 2'b00) ) //Mem_Data_d
			ForwardA_exe = 2'b10 ;
		else if (MemWbRegWrite && (MemWbRegRd != 0 ) && (MemWbRegRd == IdExeRegRs1) && (ExeMemRegRd != IdExeRegRs1) && ( MemWbMD == 2'b01) ) //FUresult_dd
			ForwardA_exe = 2'b11;		
		else 	ForwardA_exe = 2'b00;

		if (ExeMemRegWrite && (ExeMemRegRd != 0 ) && (ExeMemRegRd == IdExeRegRs2) && (ExeMemMD == 2'b01)  )  //FUresult_d
			ForwardB_exe = 2'b01;
		else if (MemWbRegWrite && (MemWbRegRd != 0 ) && (MemWbRegRd == IdExeRegRs2) && (ExeMemRegRd != IdExeRegRs2) && ( MemWbMD == 2'b00)   ) //Mem_Data_d
			ForwardB_exe = 2'b10 ;
		else if (MemWbRegWrite && (MemWbRegRd != 0 ) && (MemWbRegRd == IdExeRegRs2) && (ExeMemRegRd != IdExeRegRs2) && ( MemWbMD == 2'b01)  ) //FUresult_dd
			ForwardB_exe = 2'b11;		
		else 	ForwardB_exe = 2'b00;

	end

	always@ (*)
	begin
	
	  	if (ExeMemRegWrite && (ExeMemRegRd != 0 ) && (ExeMemRegRd == IfIdRegRs1) && (ExeMemMD == 2'b01) )  //FUresult_d str ekle
			ForwardA_id = 2'b01;
		else if (MemWbRegWrite && (MemWbRegRd != 0 ) && (MemWbRegRd == IfIdRegRs1) && (ExeMemRegRd != IfIdRegRs1) && ( MemWbMD == 2'b00) ) //Mem_Data_d
			ForwardA_id = 2'b10 ;
		else if (MemWbRegWrite && (MemWbRegRd != 0 ) && (MemWbRegRd == IfIdRegRs1) && (ExeMemRegRd != IfIdRegRs1) && ( MemWbMD == 2'b01) ) //FUresult_dd
			ForwardA_id = 2'b11;		
		else 	ForwardA_id = 2'b00;

		if (ExeMemRegWrite && (ExeMemRegRd != 0 ) && (ExeMemRegRd == IfIdRegRs2) && (ExeMemMD == 2'b01)  )  //FUresult_d str ekle
			ForwardB_id = 2'b01;
		else if (MemWbRegWrite && (MemWbRegRd != 0 ) && (MemWbRegRd == IfIdRegRs2) && (ExeMemRegRd != IfIdRegRs2) && ( MemWbMD == 2'b00)  ) //Mem_Data_d
			ForwardB_id = 2'b10 ;
		else if (MemWbRegWrite && (MemWbRegRd != 0 ) && (MemWbRegRd == IfIdRegRs2) && (ExeMemRegRd != IfIdRegRs2) && ( MemWbMD == 2'b01)  ) //FUresult_dd
			ForwardB_id = 2'b11;		
		else 	ForwardB_id = 2'b00;

	end

	
	
endmodule