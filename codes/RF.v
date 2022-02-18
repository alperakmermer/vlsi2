`timescale 1ns / 1ps

module RF#( parameter k = 32)(
            input clk ,
            input rst ,
            input write_enable,
            input [k-1:0]Rd,
            input [4:0]Rs1_Address,
            input [4:0]Rs2_Address,
            input [4:0]Rd_Address,
            output [k-1:0]Rs1,
            output [k-1:0]Rs2    );

reg [k-1:0] R[k-1:0] ; 

wire   load[k-1:0]  ;
wire [k-1:0] muxout1[7:0] , muxout2[1:0] , Dload ;

  integer i ;

  always @ (posedge clk) begin
  R[0] <= 0 ;  //hardwire x0 to 0 
  if(rst)
  begin
  for ( i = 0 ; i<k ; i = i+1) 
    begin
    R[i] <= 0 ;
    end
  end
  
  else
  begin
  
  for ( i = 1 ; i<k ; i = i+1)
    begin
    if (load[i])
    R[i] <= Rd ;
    else
    R[i] <= R[i] ;
    end
  end
  end

RFDecoder rfdecoder ( .D(Rd_Address) , .O(Dload) ) ;

genvar j ;
generate
for ( j = 0 ; j < k ; j = j+1 )
begin
AND #(.SIZE(1)) andi ( write_enable,Dload[j],load[j]) ;
end
endgenerate

MUX32 Asel(.D0(R[0]),
       .D1(R[1]),
       .D2(R[2]),
       .D3(R[3]),
       .D4(R[4]),
       .D5(R[5]),
       .D6(R[6]),
       .D7(R[7]),
       .D8(R[8]),
       .D9(R[9]),
       .D10(R[10]),
       .D11(R[11]),
       .D12(R[12]),
       .D13(R[13]),
       .D14(R[14]),
       .D15(R[15]),
       .D16(R[16]),
       .D17(R[17]),
       .D18(R[18]),
       .D19(R[19]),
       .D20(R[20]),
       .D21(R[21]),
       .D22(R[22]),
       .D23(R[23]),
       .D24(R[24]),
       .D25(R[25]),
       .D26(R[26]),
       .D27(R[27]),
       .D28(R[28]),
       .D29(R[29]),
       .D30(R[30]),
       .D31(R[31]),
       .S(Rs1_Address),
       .O(Rs1));

MUX32 Bsel(.D0(R[0]),
       .D1(R[1]),
       .D2(R[2]),
       .D3(R[3]),
       .D4(R[4]),
       .D5(R[5]),
       .D6(R[6]),
       .D7(R[7]),
       .D8(R[8]),
       .D9(R[9]),
       .D10(R[10]),
       .D11(R[11]),
       .D12(R[12]),
       .D13(R[13]),
       .D14(R[14]),
       .D15(R[15]),
       .D16(R[16]),
       .D17(R[17]),
       .D18(R[18]),
       .D19(R[19]),
       .D20(R[20]),
       .D21(R[21]),
       .D22(R[22]),
       .D23(R[23]),
       .D24(R[24]),
       .D25(R[25]),
       .D26(R[26]),
       .D27(R[27]),
       .D28(R[28]),
       .D29(R[29]),
       .D30(R[30]),
       .D31(R[31]),
       .S(Rs2_Address),
       .O(Rs2));


endmodule
