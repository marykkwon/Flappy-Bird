`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:40:47 05/08/2019 
// Design Name: 
// Module Name:    debounce 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module debounce(
    input btn_i,
    output reg btn_o,
    input clk,
	 input rst
    );
	 reg [16:0] clk_count;
	 wire [17:0] clk_sig;
	 reg clk_en;
	 reg clk_en_d;
	 reg [2:0] btn_hist;
	
	// Timing Signal
	assign clk_sig = clk_count + 1;
	always @(posedge clk) begin
		if (rst) begin
			clk_count <= 0;
			clk_en_d <= 0;
			clk_en <= 0;
		end else begin
			clk_count <= clk_sig[16:0];
			clk_en <= clk_sig[17];
			clk_en_d <= clk_en;
		end
	end
	
	// Instruction History
	always @(posedge clk) begin
		if (rst) begin
			btn_hist <= 0;
		end else if (clk_en) begin
			btn_hist[2:0] <= {btn_i, btn_hist[2:1]};
		end
	end
	
	// Detecting posedge
	wire btn_pos;
	assign btn_pos = ~ btn_hist[0] & btn_hist[1];
	always @(posedge clk) begin
		if (rst) begin
			btn_o <= 0;
		end else if (clk_en_d) begin
			btn_o <= btn_pos;
		end else begin
			btn_o <= 0;
		end
	end

endmodule
