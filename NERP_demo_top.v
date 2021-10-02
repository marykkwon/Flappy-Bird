`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:25 03/19/2013 
// Design Name: 
// Module Name:    NERP_demo_top 
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
module NERP_demo_top(
	input wire clk,			//master clock = 50MHz
	input wire rst,			//right-most pushbutton for reset
    input wire jump_button_raw,
	output wire [6:0] seg,	//7-segment display LEDs
	output wire [3:0] an,	//7-segment display anode enable
	output wire dp,			//7-segment display decimal point
	output reg [2:0] red,	//red vga output - 3 bits
	output reg [2:0] green,//green vga output - 3 bits
	output reg [1:0] blue,	//blue vga output - 2 bits
	output wire hsync,		//horizontal sync out
	output wire vsync,			//vertical sync out
    output reg [3:0] lives
	);
    
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch

parameter BIRD_I = 8;
parameter N_OBS = 8;
parameter SPACE = 140;

// 7-segment clock interconnect
wire segclk;

// VGA display clock interconnect
wire dclk;

// disable the 7-segment decimal points
assign dp = 1;

// display position
wire [9:0] hc;
wire [9:0] vc;

// game data
reg [9:0] score;
reg playing;

// game objects
reg [9:0] minX [9:0];
reg [9:0] minY [9:0];
reg [9:0] maxX [9:0];
reg [9:0] maxY [9:0];
reg [7:0] color [9:0];

// score display
reg [3:0] digitL;
reg [3:0] digitML;
reg [3:0] digitMR;
reg [3:0] digitR;

// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.clr(rst),
	.segclk(segclk),
	.dclk(dclk)
	);

// 7-segment display controller
segdisplay U2(
	.segclk(segclk),
	.clr(rst),
    .digitL(digitL),
    .digitML(digitML),
    .digitMR(digitMR),
    .digitR(digitR),
	.seg(seg),
	.an(an)
	);

// VGA controller
vga640x480 U3(
	.dclk(dclk),
	.clr(rst),
	.hsync(hsync),
	.vsync(vsync),
    .hc(hc),
    .vc(vc)
	);
wire jump_btn;
// Jump Button
debounce jump_debounce(
    .btn_i(jump_button_raw),
    .btn_o(jump_btn),
    .clk(clk),
    .rst(rst)
);

function [7:0] check_bounds;
    input [9:0] miX, miY, maX, maY, x, y;
    input [7:0] c;
    if (x >= miX + hbp && x <= maX + hbp && y >= miY + vbp && y <= maY + vbp)
        check_bounds = c;
    else
        check_bounds = 0;
endfunction

reg [21:0] clk_count;
reg ani_clk;
reg ani_clk_d;
reg [3:0] i;
reg [3:0] jump_duration;
reg stopped;

reg [9:0] offsets [3:0];
reg [9:0] offset1;
reg [9:0] offset2;
reg [9:0] offset3;
reg [9:0] offset4;
reg [9:0] newoffset;

reg [3:0] offsetNum;

reg [9:0] blink_count;

always @(posedge clk) begin
if (rst) begin
    clk_count = 0;
    ani_clk = 0;
    ani_clk_d = 0;
    jump_duration = 0;
	 score = 0;
	 lives = 2;
	 
	 playing = 1;
    
    // Obstacles
    
    offset1 = 30;
    offset2 = 140;
    offset3 = 70;
    offset4 = 90;
    offsets[0] = 30;
    offsets[1] = 140;
    offsets[2] = 70;
    offsets[3] = 90;
    offsetNum = 0;
    
    // Obstacle 1
    minX[0] = 640 - 30;
    maxX[0] = 640;
    minY[0] = 0;
    maxY[0] = 150 + offsets[0];
    color[0] = 'b00011100;
    
    minX[1] = 640 - 30;
    maxX[1] = 640;
    minY[1] = 210 + offsets[0];
    maxY[1] = 480;
    color[1] = 'b00011100;

    // Obstacle 2
    minX[2] = 640 - 30 - SPACE;
    maxX[2] = 640 - SPACE;
    minY[2] = 0;
    maxY[2] = 150 + offsets[1];
    color[2] = 'b00011100;
    
    minX[3] = 640 - 30 - SPACE;
    maxX[3] = 640 - SPACE;
    minY[3] = 210 + offsets[1];
    maxY[3] = 480;
    color[3] = 'b00011100;
    
    // Obstacle 3
    minX[4] = 640 - 30 - SPACE * 2;
    maxX[4] = 640 - SPACE * 2;
    minY[4] = 0;
    maxY[4] = 150 + offsets[2];
    color[4] = 'b00011100;
    
    minX[5] = 640 - 30 - SPACE * 2;
    maxX[5] = 640 - SPACE * 2;
    minY[5] = 210 + offsets[2];
    maxY[5] = 480;
    color[5] = 'b00011100;
    
    // Obstacle 4
    minX[6] = 640 - 30 - SPACE * 3;
    maxX[6] = 640 - SPACE * 3;
    minY[6] = 0;
    maxY[6] = 150 + offsets[3];
    color[6] = 'b00011100;
    
    minX[7] = 640 - 30 - SPACE * 3;
    maxX[7] = 640 - SPACE * 3;
    minY[7] = 210 + offsets[3];
    maxY[7] = 480;
    color[7] = 'b00011100;
    
    // Bird
    minX[8] = 30;
    maxX[8] = 40;
    minY[8] = 0 + 200;
    maxY[8] = 10 + 200;
    color[8] = 'b11100011;
    
    // Powerup
    minX[9] = 640 - 30 - 80;
    maxX[9] = 640 - 30 - 70;
    minY[9] = 240;
    maxY[9] = 250;
    color[9] = 'b11111111;
    
end else begin
    clk_count = clk_count + 1;
    ani_clk_d = ani_clk;
    if (clk_count >= 1500000) begin
        clk_count = 0;
        ani_clk = ~ani_clk;
    end
    
    // digit display
    digitL = (lives / 10) % 10;
    digitML = (lives) % 10;
    digitMR = (score / 10) % 10;
    digitR = (score) % 10;
    
    // animation tick
    if (ani_clk & ~ani_clk_d) begin
    blink_count = blink_count + 1;

    if (playing) begin
        // Obstacle Collision Check
        for (i = 0; i < N_OBS; i = i + 1) begin
            if (!(maxX[BIRD_I] < minX[i] || maxX[i] < minX[BIRD_I]
             || maxY[BIRD_I] < minY[i] || maxY[i] < minY[BIRD_I])) begin
                if (lives == 0) begin
                    playing = 0;
                end else begin
                    if (i % 2 == 0) begin
                        minX[i] = 640 - 30;
                        maxX[i] = 640;
                        minX[i+1] = 640 - 30;
                        maxX[i+1] = 640;
                    end else begin
                        minX[i] = 640 - 30;
                        maxX[i] = 640;
                        minX[i-1] = 640 - 30;
                        maxX[i-1] = 640;
                    end
                    lives = lives - 1;
                end
            end
        end
        
        // Powerup collision check
        if (!(maxX[BIRD_I] < minX[9] || maxX[9] < minX[BIRD_I]
             || maxY[BIRD_I] < minY[9] || maxY[9] < minY[BIRD_I])) begin
                lives = lives + 1;
                minX[9] = 640 - 30 - 80;
                maxX[9] = 640 - 30 - 70;
            end
    
        // Obstacle Movement
        for (i = 0; i < N_OBS; i = i + 2) begin
            if (minX[i] == 0) begin
                minX[i] = 640 - 30;
                maxX[i] = 640;
                minX[i+1] = 640 - 30;
                maxX[i+1] = 640;
                score = score + 1;
                
                // randomize y
                //minY[i] = 150 + $urandom%150;
                
                    maxY[i] = 150 + offsets[offsetNum];
                    minY[i+1] = 210 + offsets[offsetNum];
                    offsetNum = offsetNum + 1;
                
                //maxY[i+1] = 150 + $urandom%150;
            end else begin
                minX[i] = minX[i] - 1;
                maxX[i] = maxX[i] - 1;
                minX[i+1] = minX[i+1] - 1;
                maxX[i+1] = maxX[i+1] - 1;
            end
        end
        
        // Bird Movement
        if (jump_button_raw) jump_duration = 6;
        
        if (jump_duration > 0 && minY[BIRD_I] >= 2) begin
            jump_duration = jump_duration - 1;
            minY[BIRD_I] = minY[BIRD_I] - 3;
            maxY[BIRD_I] = maxY[BIRD_I] - 3;
        end else
        if (maxY[BIRD_I] <= 480) begin
            minY[BIRD_I] = minY[BIRD_I] + 1;
            maxY[BIRD_I] = maxY[BIRD_I] + 1;
        end
        // Powerup Movement
        if (minX[9] == 0) begin
            minX[9] = 640 - 30 - 80;
            maxX[9] = 640 - 30 - 70;
            minY[9] = 240;
            maxY[9] = 250;
        end else begin
            minX[9] = minX[9] - 1;
            maxX[9] = maxX[9] - 1;
        end
    end else if (blink_count >= 10) begin
        blink_count = 0;
        for (i = 0; i < 10; i = i + 1) begin
            color[i] = ~color[i];
        end
    end
    end
    
        



    
end
end


always @(*) begin
    if (vc >= vbp && vc < vfp && hc >= hbp && hc < hfp) begin
        {red, green, blue} = check_bounds(minX[0], minY[0], maxX[0], maxY[0], hc, vc, color[0]) |
                    check_bounds(minX[1], minY[1], maxX[1], maxY[1], hc, vc, color[1]) |
                    check_bounds(minX[2], minY[2], maxX[2], maxY[2], hc, vc, color[2]) |
                    check_bounds(minX[3], minY[3], maxX[3], maxY[3], hc, vc, color[3]) |
                    check_bounds(minX[4], minY[4], maxX[4], maxY[4], hc, vc, color[4]) |
                    check_bounds(minX[5], minY[5], maxX[5], maxY[5], hc, vc, color[5]) |
                    check_bounds(minX[6], minY[6], maxX[6], maxY[6], hc, vc, color[6]) |
                    check_bounds(minX[7], minY[7], maxX[7], maxY[7], hc, vc, color[7]) |
                    check_bounds(minX[8], minY[8], maxX[8], maxY[8], hc, vc, color[8]) |
                    check_bounds(minX[9], minY[9], maxX[9], maxY[9], hc, vc, color[9]);
                    end
    else
        {red, green, blue} = 0;
end



endmodule
