module IF_ID(   input clk,
                input rst,
                input flush,
                input bubble,
                input [34:0] control_word_in,
                output reg [34:0] control_word_out,
                input [31:0] immediate_in,
                output reg [31:0] immediate_out,
                input [31:0] PC_in,
                output reg [31:0] PC_out);


                // if rst / flsuh / bbulbe
                always@(posedge clk) begin
                    if ( rst | flush | bubble) begin
                        control_word_out <= 35'h000000000; 
                        immediate_out <= 32'h00000000;
                        PC_out <= 32'h00000000;
                    end
                    else begin
                        control_word_out <= control_word_in; 
                        immediate_out <= immediate_in;
                        PC_out <= PC_in;
                    end
                end
               



endmodule