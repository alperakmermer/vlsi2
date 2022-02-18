`timescale 1ns / 1ps
module MEM 
  # (parameter ADDR_WIDTH = 7,
     parameter DEPTH = 32 //2^(ADDR_WIDTH-2)
    )
  ( input [ADDR_WIDTH-1:0] address,
    inout  [31:0] data,
    input  [2:0] control_signals,
    input  write_enable,
    input  rst  );
  
  integer i;
  reg [31:0] 	tmp_data;
  reg [31:0] 	mem [DEPTH-1:0];
  wire [1:0]    BHW;
  wire          U;
  
  assign    BHW = control_signals[2:1] ;
  assign     U = control_signals[0];
  
  always @ * begin
    if (rst)  //RST
    begin
    for (i=0; i<DEPTH; i = i+1) 
        begin
            mem[i] <= 0;
        end
    end
    else 
    if (write_enable) begin //WRITE
        case (BHW)
        2'b00 : begin //store byte ;SB
            case (address[1:0])
            2'b00 : mem[address>>2] <= {mem[address>>2][31:8],data[7:0]};
            2'b01 : mem[address>>2] <= {mem[address>>2][31:16],data[7:0],mem[address>>2][7:0]};
            2'b10 : mem[address>>2] <= {mem[address>>2][31:24],data[7:0],mem[address>>2][15:0]};
            2'b11 : mem[address>>2] <= {data[7:0],mem[address>>2][23:0]};
            endcase  
        end
        2'b01 : begin //store half word ;SH
            case (address[1])
            1'b0 : mem[address>>2] <= {mem[address>>2][31:16],data[15:0]};
            1'b1 : mem[address>>2] <= {data[15:0],mem[address>>2][15:0]};
            endcase
        end
        2'b10 : mem[address>>2] <= data;   //store word ; SW
        endcase
    end
  end
  
  always @ * begin //READ
    if (!write_enable) begin
    	case (BHW)
        2'b00 : begin //BYTE
            case (U)
            1'b0 : begin //load byte ; LB
                case (address[1:0]) 
                2'b00 : tmp_data <= {24'h000000,mem[address>>2][7:0]};
                2'b01 : tmp_data <= {24'h000000,mem[address>>2][15:8]};
                2'b10 : tmp_data <= {24'h000000,mem[address>>2][7:0]};
                2'b11 : tmp_data <= {24'h000000,mem[address>>2][7:0]};
                endcase  
            end
            1'b1 : begin //load byte upper ; LBU
                case (address[1:0]) 
                2'b00 : tmp_data <= {mem[address>>2][7:0],24'h000000};
                2'b01 : tmp_data <= {mem[address>>2][15:8],24'h000000};
                2'b10 : tmp_data <= {mem[address>>2][7:0],24'h000000};
                2'b11 : tmp_data <= {mem[address>>2][7:0],24'h000000};
                endcase 
            end
            endcase
        end
        2'b01 : begin // HALF WORD
            case (U)
            1'b0 : begin //load half word ; LH
                case (address[1])
                1'b0 : tmp_data <= {16'h0000,mem[address>>2][15:0]};
                1'b1 : tmp_data <= {16'h0000,mem[address>>2][31:16]};
                endcase
            end
            1'b1 : begin //load half word upper ; LHU
                case (address[1])
                1'b0 : tmp_data <= {mem[address>>2][15:0],16'h0000};
                1'b1 : tmp_data <= {mem[address>>2][31:16],16'h0000};
                endcase
            end
            endcase
        end
        2'b10 : tmp_data <= mem[address>>2];  // WORD ; LW 
        endcase
  end
  end
  assign data  = (~write_enable) ? tmp_data : 'hz;
endmodule