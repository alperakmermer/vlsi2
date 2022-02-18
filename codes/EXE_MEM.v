module EXE_MEM( input clk,
               input rst,
               input [34:0] control_word_in,
               output reg [34:0] control_word_out,
               input [31:0] PC_in,
               output reg [31:0] PC_out,
               input [31:0] immediate_in,
               output reg [31:0] immediate_out,
               input [31:0] Rs2_in,
               output reg [31:0] Rs2_out,
               input [31:0] FU_result_in,
               output reg [31:0] FU_result_out );
               
               always@(posedge clk) begin
                    if ( rst ) begin
                        control_word_out   <= 35'h000000000;
                        Rs2_out            <= 32'h00000000;
                        immediate_out      <= 32'h00000000;
                        PC_out             <= 32'h00000000;
                        FU_result_out      <= 32'h00000000;
                    end
                    else begin
                        control_word_out   <= control_word_in;
                        Rs2_out            <= Rs2_in;
                        immediate_out      <= immediate_in;
                        PC_out             <= PC_in;
                        FU_result_out      <= FU_result_in;
                    end
               end


endmodule