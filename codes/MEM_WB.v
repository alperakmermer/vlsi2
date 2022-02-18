module MEM_WB( input clk,
               input rst,
               input [34:0] control_word_in,
               output reg [34:0] control_word_out,
               input [31:0] PC_in,
               output reg [31:0] PC_out,
               input [31:0] immediate_in,
               output reg [31:0] immediate_out,
               input [31:0] FU_result_in,
               output reg [31:0] FU_result_out,
               input [31:0] Mem_Data_in,
               output reg [31:0] Mem_Data_out );
               
               always@(posedge clk) begin
                    if ( rst ) begin
                        control_word_out <= 35'h000000000;
                        immediate_out    <= 32'h00000000;
                        PC_out           <= 32'h00000000;
                        FU_result_out    <= 32'b00000000;
                        Mem_Data_out     <= 32'h00000000;
                    end
                    else begin
                        control_word_out <= control_word_in;
                        immediate_out    <= immediate_in;
                        PC_out           <= PC_in;
                        FU_result_out    <= FU_result_in;
                        Mem_Data_out     <= Mem_Data_in;
                    end
               end


endmodule