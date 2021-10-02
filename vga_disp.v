`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:56:55 05/20/2019 
// Design Name: 
// Module Name:    vga_disp 
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

module vga_disp(
    input [9:0] hc,
    input [9:0] vc,
    input [9:0] minX [9:0],
    input [9:0] minY [9:0],
    input [9:0] maxX [9:0],
    input [9:0] maxY [9:0],
    input [7:0] color [9:0],
    output reg [2:0] R,
    output reg [2:0] G,
    output reg [1:0] B
    );
    
    parameter hbp = 144; 	// end of horizontal back porch
    parameter hfp = 784; 	// beginning of horizontal front porch
    parameter vbp = 31; 		// end of vertical back porch
    parameter vfp = 511; 	// beginning of vertical front porch
    
    function [7:0] check_bounds;
        input [9:0] miX, miY, maX, maY, x, y;
        input [7:0] c;
        if (x >= miX && x <= maX && y >= miY && y <= maY)
            check_bounds = c;
        else
            check_bounds = 0;
    endfunction
    
    always @(*) begin
        if (vc >= vbp && vc < vfp && hc >= hbp && hc < hfp)
            {R, G, B} = check_bounds(minX[0], minY[0], maxX[0], maxY[0], hc, vc, color[0]) |
                        check_bounds(minX[1], minY[1], maxX[1], maxY[1], hc, vc, color[1]) |
                        check_bounds(minX[2], minY[2], maxX[2], maxY[2], hc, vc, color[2]) |
                        check_bounds(minX[3], minY[3], maxX[3], maxY[3], hc, vc, color[3]) |
                        check_bounds(minX[4], minY[4], maxX[4], maxY[4], hc, vc, color[4]) |
                        check_bounds(minX[5], minY[5], maxX[5], maxY[5], hc, vc, color[5]) |
                        check_bounds(minX[6], minY[6], maxX[6], maxY[6], hc, vc, color[6]) |
                        check_bounds(minX[7], minY[7], maxX[7], maxY[7], hc, vc, color[7]) |
                        check_bounds(minX[8], minY[8], maxX[8], maxY[8], hc, vc, color[8]) |
                        check_bounds(minX[9], minY[9], maxX[9], maxY[9], hc, vc, color[9]);
        else
            {R, G, B} = 0;
    end


endmodule
