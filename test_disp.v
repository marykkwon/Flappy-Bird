`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:28:31 05/22/2019
// Design Name:   NERP_demo_top
// Module Name:   C:/Users/152/Downloads/NERP_demo/test_disp.v
// Project Name:  NERP_demo
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: NERP_demo_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test_disp;

	// Inputs
	reg clk;
	reg rst;

	// Outputs
	wire [6:0] seg;
	wire [3:0] an;
	wire dp;
	wire [2:0] red;
	wire [2:0] green;
	wire [1:0] blue;
	wire hsync;
	wire vsync;

	// Instantiate the Unit Under Test (UUT)
	NERP_demo_top uut (
		.clk(clk), 
		.rst(rst), 
		.seg(seg), 
		.an(an), 
		.dp(dp), 
		.red(red), 
		.green(green), 
		.blue(blue), 
		.hsync(hsync), 
		.vsync(vsync)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;

		// Wait 100 ns for global reset to finish
		#100;
        rst = 0;
        
		// Add stimulus here

	end
    always #10 clk = ~clk;
      
endmodule

