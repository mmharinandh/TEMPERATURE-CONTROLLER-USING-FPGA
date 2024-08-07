`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2024 03:44:17 PM
// Design Name: 
// Module Name: sevensegment
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sevensegment(clk, reset, temp1, temp2, temp3, temp4, seg_out, seg_clk, anode);

input clk;
input reset;
input [31:0]temp1;
input [31:0]temp2;
input [31:0]temp3;
input [31:0]temp4;
output reg seg_clk;
output reg [6:0]seg_out;
output reg [3:0]anode;

reg [3:0]bcd;
reg [31:0]clkcount;
reg [1:0]seg_state;

always @(posedge clk , posedge reset)
begin
if (reset == 1)
	begin
	seg_clk <= 1'b0;
	clkcount <= 31'b0;
	end
else
	begin
	clkcount <= clkcount + 1;
	if(clkcount == 99999)
		begin
		seg_clk <= ~seg_clk;
		clkcount <= 0;
		end
	end
end

always @(posedge seg_clk)
begin
case (seg_state)
      2'b00  : begin
                  bcd <=temp1;
                  anode <= 4'b0111;
               end
      2'b01  : begin
                  bcd <=temp2;
                  anode <= 4'b1011;
               end
      2'b10  : begin
                  bcd <=temp3;
                  anode <= 4'b1101;
               end
      2'b11  : begin
                  bcd <=temp4;
                  anode <= 4'b1110;
               end
   endcase
end

always @(posedge seg_clk)
begin
case (bcd)
      4'b0000: begin
                  seg_out <= 7'b100_0000; // 0x40
               end
      4'b0001: begin
                  seg_out <= 7'b111_1001; // 0x79
               end
      4'b0010: begin
                  seg_out <= 7'b010_0100; // 0x24
               end
      4'b0011: begin
                  seg_out <= 7'b011_0000; // 0x30
               end
      4'b0100: begin
                  seg_out <= 7'b001_1001; // 0x19
               end
      4'b0101: begin
                  seg_out <= 7'b001_0010; // 0x12
               end
      4'b0110: begin
                  seg_out <= 7'b000_0010; //0x02 
               end
      4'b0111: begin
                  seg_out <= 7'b111_1000; //0x78
               end
      4'b1000: begin
                  seg_out <= 7'b000_0000;
               end
      4'b1001: begin
                  seg_out <= 7'b001_0000; // 0x10
               end
      default: begin
                  seg_out <= 7'b100_0000;
               end
endcase
end

always @(posedge seg_clk, posedge(reset))
begin
    if (reset) begin
	   seg_state <= 2'b0;
    end
   else begin
        seg_state <= seg_state +1;
   end
end
endmodule
