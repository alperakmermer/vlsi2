`timescale 1ns / 1ps
module ID(input [31:0] instruction,
          output [34:0] control_word,
          output reg [31:0] immediate);
          
//////////////From Instruction////////////////////////////////////
wire [4:0] Rs1 = instruction[19:15];
wire [4:0] Rs2 = instruction[24:20];
wire [4:0] Rd = instruction[11:7];
wire [2:0] func3 = instruction[14:12];
wire [6:0] func7 = instruction[31:25];
wire [4:0] opcode = instruction[6:2];
wire [31:0] I_imm = (instruction[31]) ? {20'hfffff,instruction[31:20]}: {20'h00000,instruction[31:20]} ;
wire [31:0] S_imm = (instruction[31]) ? {20'hfffff,instruction[31:25],instruction[11:7]} : {20'h00000,instruction[31:25],instruction[11:7]};
wire [31:0] B_imm = (instruction[31]) ? {19'b1111_1111_1111_1111_111,instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0} : {19'd00000,instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
wire [31:0] U_imm = {instruction[31:12],12'h000};
wire [31:0] J_imm = (instruction[31]) ? {11'b1111_1111_111,instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0} : {11'd0,instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};

//////////To Control Word///////////////////////////////////////
reg [4:0] Rs1_Address,Rs2_Address,Rd_Address;
reg [1:0] Rd_Sel, BHW;
reg [5:0] FS;
reg [2:0] BC;
reg Rs1_Sel, Rs2_Sel, RW, MW, U, PL,JB;


assign control_word ={Rs1_Address,Rs2_Address,Rd_Address,Rs1_Sel,Rs2_Sel,Rd_Sel,RW,FS,MW,BHW,U,PL,JB,BC};
always@ (*)
begin
case(opcode)
//////////////////////////////////////LOADS //////////////////////////////////////
5'b00000 :
begin
Rs1_Address=Rs1; Rd_Address=Rd;
Rs1_Sel=0; Rs2_Sel=1; Rd_Sel=00; RW=1; MW=0; PL=0; FS=000000;
immediate = I_imm;
case(func3)
3'b000: // LB
begin
BHW=00; U=0;
end
3'b001: // LH
begin
BHW=01; U=0;
end
3'b010: // LW
begin
BHW=10; U=0;
end
3'b100: // LBU
begin
BHW=00; U=1;
end
3'b101: // LHU
begin
BHW=01; U=1;
end
endcase
end
//////////////////////////////////////STORES //////////////////////////////////////
5'b01000 :
begin
Rs1_Address=Rs1; Rs2_Address=Rs2;
Rs1_Sel=0; Rs2_Sel=1; RW=0; MW=1; PL=0; FS=6'b000000;
immediate = S_imm;
case (func3)
3'b000 :
begin
BHW=2'b00;
end
3'b001 :
begin
BHW=2'b1;
end
3'b010 :
begin
BHW=2'b10;
end
endcase
end
//////////////////////////////////////Branches //////////////////////////////////////
5'b11000 :
begin
Rs1_Address=Rs1; Rs2_Address=Rs2; Rd_Address=Rd;
Rs1_Sel=1; Rs2_Sel=1; RW=0; MW=0; PL=1; JB=0; FS=000000;
immediate = B_imm;
case (func3)
3'b000 : //BEQ
begin
BC=000;
end
3'b001 : //BNE
begin
BC=001;
end
3'b100 : //BLT
begin
BC=100;
end
3'b101 : //BGE
begin
BC=101;
end
3'b110 : //BLTU
begin
BC=110;
end
3'b111 : //BGEU
begin
BC=111;
end
endcase
end
//////////////////////////////////////Immediate shifts and ALU //////////////////////////////////////
5'b00100 :
begin
Rs1_Address=Rs1; Rd_Address=Rd;
Rs1_Sel=0; Rs2_Sel=1; Rd_Sel=01; RW=1; MW=0; PL=0;
immediate = I_imm;
case (func3)
3'b000 : //ADDI
begin
FS=000000;
end
3'b010 : //SLTI
begin
FS=6'b001011;
end
3'b011 : //SLTIU
begin
FS=0011111;
end
3'b100 : //XORI
begin
FS=6'b0100xx;
end
3'b110 : //ORI
begin
FS=6'b0110xx;
end
3'b111 : //ANDI
begin
FS=6'b0111xx;
end
3'b001 : //SLLI
begin
FS=6'b1x00xx;
end
3'b101 :
begin
case (func7)
7'b0000000: //SRLI
begin
FS=6'b1x01xx;
end
7'b0100000: //SRAI
begin
FS=6'b1x11xx;
end
endcase
end
endcase
end
//////////////////////////////////////Non-immediate Shifts and ALU //////////////////////////////////////
5'b01100 :
begin
Rs1_Address=Rs1; Rs2_Address=Rs2; Rd_Address=Rd;
Rs1_Sel=1'b0; Rs2_Sel=1'b0; Rd_Sel=2'b01; RW=1'b1; MW=1'b0; PL=1'b0;
case (func3)
3'b000 : //ADD-SUB
begin
case (func7)
7'b0000000: //ADD
begin
FS=6'b000000;
end
7'b0100000: //SUB
begin
FS=6'b000011;
end
endcase
end
3'b001 : //SLL
begin
FS=6'b1X00XX;
end
3'b010 : //SLT
begin
FS=6'b001011;
end
3'b011 : //SLTU
begin
FS=6'b001111;
end
3'b100 : //XOR
begin
FS=6'b0100XX;
end
3'b101 : //SRL-SRA
begin
case (func7)
7'b0000000: //SRL
begin
FS=6'b1X01XX;
end
7'b0100000: //SRA
begin
FS=6'b1X11XX;
end
endcase
end
3'b110 : //OR
begin
FS=6'b011XX;
end
3'b111 : //AND
begin
FS=6'b0111XX;
end
endcase
end
//////////////////////////////////////LUI ////////////////////////////////////////
5'b01101 :
begin
Rd_Address = Rd;
Rd_Sel=2'b11; RW=1'b1; MW=1'b0; PL=1'b0;
immediate = U_imm;
end
//////////////////////////////////////AUIPIC //////////////////////////////////////
5'b00101 :
begin
Rd_Address = Rd;
Rs1_Sel=1'b1; Rs2_Sel=1'b1; Rd_Sel=2'b01; RW=1'b1; MW=1'b0; PL=1'b0; FS=6'b000000;
immediate = U_imm;
end
//////////////////////////////////////JAL //////////////////////////////////////
5'b11011 :
begin
Rd_Address = Rd;
Rs1_Sel=1'b1; Rs2_Sel=1'b1; Rd_Sel=2'b10; RW=1'b1; MW=1'b0; PL=1'b1; JB=1'b1; FS=6'b000000;
immediate = J_imm;
end
//////////////////////////////////////JALR //////////////////////////////////////
5'b11001 :
begin
Rd_Address = Rd; Rs1_Address = Rs1 ;
Rs1_Sel=1'b0; Rs2_Sel=1'b1; Rd_Sel=2'b10 ; RW=1'b1; MW=1'b0; PL=1'b1; JB=1'b1; FS=6'b000000;
immediate = I_imm;
end
endcase
end
endmodule