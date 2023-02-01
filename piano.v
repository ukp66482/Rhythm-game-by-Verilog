`define TimeExpire_keypad 32'd500000
`define TimeExpire_dot 32'd5000
`define TimeExpire_4Hz 32'd12500000
`define TimeExpire_Random 32'd30000000
`define TimeExpire_2Hz 32'd2500000
`define TimeExpire_20Hz 32'd25000000
`define TimeExpire_Round 35'd2000000000
`define TimeExpire_1Hz 32'd50000000
`define TimeExpire_twosec 32'd200000000
`define TimeExpire_atferend 35'd2000000000

module piano(dot_row,dot_col,clk,rst,keypad_row,keypad_col,sevenout1,sevenout2,sevenout3,sevenout4);
  
  input clk,rst;
  input [3:0]keypad_col;
    
  
  output reg [3:0]keypad_row;
  output reg [7:0]dot_row;
  output reg [15:0]dot_col;
  output reg [6:0]sevenout1;
  output reg [6:0]sevenout2;
  output reg [6:0]sevenout3;
  output reg [6:0]sevenout4;
    
  reg [15:0]dot_col1;
  reg [15:0]dot_col2;
  reg [15:0]dot_col3;
  reg [15:0]dot_col4;
  reg [31:0]keyDelay;
  reg [31:0]count_keypad;
  reg [4:0]keypadBuf;
  reg [2:0]row_count;
  reg [31:0]count_matrix;
  reg [31:0]count_down;
  reg [31:0]count_random;
  reg [31:0]count_time;
  reg [15:0]dot_random1 = 16'd0;
  reg [15:0]dot_random2 = 16'd0;
  reg [15:0]dot_random3 = 16'd0;
  reg [15:0]dot_random4 = 16'd0;
  reg [15:0]lfsr;
  reg [15:0]dot_point1= 16'd0;
  reg [15:0]dot_point2= 16'd0;
  reg [15:0]dot_point3= 16'd0;
  reg [15:0]dot_point4= 16'd0;
  reg [15:0]dot_point5= 16'd0;
  reg [15:0]dot_point6= 16'd0;
  reg [15:0]dot_point7= 16'd0;
  reg [15:0]dot_point8= 16'd0;
   reg [15:0]dot_pointt1= 16'd0;
  reg [15:0]dot_pointt2= 16'd0;
  reg [15:0]dot_pointt3= 16'd0;
  reg [15:0]dot_pointt4= 16'd0;
  reg [15:0]dot_pointt5= 16'd0;
  reg [15:0]dot_pointt6= 16'd0;
  reg [15:0]dot_pointt7= 16'd0;
  reg [15:0]dot_pointt8= 16'd0;
  reg [9:0]points1 = 10'd0;
  reg [9:0]points2 = 10'd0;
  reg [9:0]points3 = 10'd0;
  reg [9:0]points4 = 10'd0;
  reg [9:0]points = 10'd0;
  reg [32:0]count_button;
  reg button1,button2,button3,button4;
  reg [31:0]count_points;
  reg [3:0]ten_digit;
  reg [3:0]unit_digit;
  reg [3:0]time_ten_digit;
  reg [3:0]time_unit_digit;
  reg [7:0]temp;
  reg [7:0]temp_time;
  reg [8:0]Time = 9'd40;
  reg [34:0]round;
  reg Timeup=1'd0;
  reg grade=1'd0;
  reg [34:0]grade_count;
  reg [31:0]flash_count;
  reg flash=1'd0;
  reg endgame=1'd0;
  
	always @(posedge clk, negedge rst)begin  //LFSR to generate random number
		if (!rst)begin
			lfsr = 16'hfeac;
		end else begin
			lfsr = {lfsr[14:0], lfsr[15] ^ lfsr[0]};
		end
	end
  
	always@(posedge clk or negedge rst)begin  //button judgment
		if(!rst)begin
			keypad_row <= 4'b1110;
			keyDelay <= 4'b1110;
			button1<= 0;
			button2<= 0;
			button3<= 0;
			button4<= 0;
		end else begin
			if(keyDelay == `TimeExpire_keypad)begin
				keyDelay = 32'd0;
				case({keypad_row, keypad_col})
					8'b1110_1110 : begin
											if(dot_col4[0]) button4 <=1;
											else button4 <=0;
										end
    
					8'b1101_1110 : begin
											if(dot_col3[0]) button3 <=1;
											else button3 <=0;
										end
    
					8'b1011_1110 : begin
											if(dot_col2[0]) button2 <=1;
											else button2 <=0;
										end
    
					8'b0111_1110 : begin
											if(dot_col1[0]) button1 <=1;
											else button1 <=0;
										end
    
							default:begin
										button1 <= 0;
										button2 <= 0;
										button3 <= 0;
										button4 <= 0;
									  end
			   endcase
				case(keypad_row)
					4'b1110 : keypad_row <= 4'b1101;
					4'b1101 : keypad_row <= 4'b1011;
					4'b1011 : keypad_row <= 4'b0111;
					4'b0111 : keypad_row <= 4'b1110;
					default: keypad_row <= 4'b1110;
				endcase
    
	      end else begin
				keyDelay <= keyDelay + 1'b1;
			end
 
		end
	end
	
  
	always @(posedge clk or negedge rst)begin //calculate points
		if(!rst)begin
			points1 <= 10'd0;
			points2 <= 10'd0;
			points3 <= 10'd0;
			points4 <= 10'd0;
		end else begin
				if(count_points == `TimeExpire_2Hz)begin
					count_points <=32'd0;
					if( button1)begin
						points1 <= points1 + 10'd1;
					end else if( button2)begin
						points2 <= points2 + 10'd1;
					end else if( button3)begin
						points3 <= points3 + 10'd1;
					end else if( button4)begin
						points4 <= points4 + 10'd1;
					end else begin
						points1 <= points1;
						points2 <= points2;
						points3 <= points3;
						points4 <= points4;
					end
			end else begin 
				count_points <= count_points+1'b1;
			end
		end 
	end
  

	always @(posedge clk or negedge rst)begin //Seven-segment display points
		if(!rst)begin
			sevenout1 <= 7'b1000000;
			sevenout2 <= 7'b1000000;
			unit_digit <= 4'd0;
			ten_digit <= 4'd0;
			points<=10'b0;
		end else begin 
			points <= points1 + points2 + points3 + points4;
			if(points >= 90)begin
				ten_digit <= 4'd9;
				unit_digit <= points-10'd90;
			end else if(points >= 80)begin
				ten_digit <= 4'd8;
				unit_digit <= points-10'd80;
			end else if(points >= 70)begin
				ten_digit <= 4'd7;
				unit_digit <= points-10'd70;
			end else if(points >= 60)begin
				ten_digit <= 4'd6;
				unit_digit <= points-10'd60;
			end else if(points >= 50)begin
				ten_digit <= 4'd5;
				unit_digit <= points-10'd50;
			end else if(points >= 40)begin
				ten_digit <= 4'd4;
				unit_digit <= points-10'd40;
			end else if(points >= 30)begin
				ten_digit <= 4'd3;
				unit_digit <= points-10'd30;
			end else if(points >= 20)begin
				ten_digit <= 4'd2;
				unit_digit <= points-10'd20;
			end else if(points >= 10)begin
				ten_digit <= 4'd1;
				unit_digit <= points-10'd10;
			end else begin
				unit_digit <= points;
			end
		case(unit_digit)
			4'd0: sevenout1 = 7'b1000000; 
			4'd1: sevenout1 = 7'b1111001; 
			4'd2: sevenout1 = 7'b0100100;
			4'd3: sevenout1 = 7'b0110000; 
			4'd4: sevenout1 = 7'b0011001; 
			4'd5: sevenout1 = 7'b0010010; 
			4'd6: sevenout1 = 7'b0000010; 
			4'd7: sevenout1 = 7'b1111000; 
			4'd8: sevenout1 = 7'b0000000;
			4'd9: sevenout1 = 7'b0010000; 
			default: sevenout1 <= sevenout1;
		endcase
		case(ten_digit)
			4'd0: sevenout2 = 7'b1000000; 
			4'd1: sevenout2 = 7'b1111001; 
			4'd2: sevenout2 = 7'b0100100;
			4'd3: sevenout2 = 7'b0110000; 
			4'd4: sevenout2 = 7'b0011001; 
			4'd5: sevenout2 = 7'b0010010; 
			4'd6: sevenout2 = 7'b0000010; 
			4'd7: sevenout2 = 7'b1111000; 
			4'd8: sevenout2 = 7'b0000000;
			4'd9: sevenout2 = 7'b0010000; 
			default: sevenout2 <= sevenout2;
		endcase
		case(ten_digit)
								4'd0: begin
										 dot_pointt1 <= 16'b0000111100000000;
										 dot_pointt2 <= 16'b0000100100000000;
										 dot_pointt3 <= 16'b0000100100000000;
										 dot_pointt4 <= 16'b0000100100000000;
										 dot_pointt5 <= 16'b0000100100000000;
										 dot_pointt6 <= 16'b0000100100000000;
										 dot_pointt7 <= 16'b0000100100000000;
										 dot_pointt8 <= 16'b0000111100000000;
										
								end
								4'd1: begin
										 dot_pointt1 <= 16'b0000011000000000;
										 dot_pointt2 <= 16'b0000111000000000;
										 dot_pointt3 <= 16'b0000011000000000;
										 dot_pointt4 <= 16'b0000011000000000;
										 dot_pointt5 <= 16'b0000011000000000;
										 dot_pointt6 <= 16'b0000011000000000;
										 dot_pointt7 <= 16'b0000011000000000;
										 dot_pointt8 <= 16'b0000111100000000;
										
								end
								4'd2: begin
										 dot_pointt1 <= 16'b0000111100000000;
										 dot_pointt2 <= 16'b0000000100000000;
										 dot_pointt3 <= 16'b0000000100000000;
										 dot_pointt4 <= 16'b0000110100000000;
										 dot_pointt5 <= 16'b0000101100000000;
										 dot_pointt6 <= 16'b0000100000000000;
										 dot_pointt7 <= 16'b0000100000000000;
										 dot_pointt8 <= 16'b0000111100000000;
										
								end
								4'd3: begin
								
										 dot_pointt1 <= 16'b0000111100000000;
										 dot_pointt2 <= 16'b0000111100000000;
										 dot_pointt3 <= 16'b0000000100000000;
										 dot_pointt4 <= 16'b0000111100000000;
										 dot_pointt5 <= 16'b0000111100000000;
										 dot_pointt6 <= 16'b0000000100000000;
										 dot_pointt7 <= 16'b0000111100000000;
										 dot_pointt8 <= 16'b0000111100000000;
										
								end
								4'd4: begin
										 dot_pointt1 <= 16'b0000100100000000;
										 dot_pointt2 <= 16'b0000100100000000;
										 dot_pointt3 <= 16'b0000100100000000;
										 dot_pointt4 <= 16'b0000100100000000;
										 dot_pointt5 <= 16'b0000111100000000;
										 dot_pointt6 <= 16'b0000000100000000;
										 dot_pointt7 <= 16'b0000000100000000;
										 dot_pointt8 <= 16'b0000000100000000;
										
								end
								4'd5: begin
										 dot_pointt1 <= 16'b0000111100000000;
										 dot_pointt2 <= 16'b0000100000000000;
										 dot_pointt3 <= 16'b0000100000000000;
										 dot_pointt4 <= 16'b0000101100000000;
										 dot_pointt5 <= 16'b0000110100000000;
										 dot_pointt6 <= 16'b0000000100000000;
										 dot_pointt7 <= 16'b0000000100000000;
										 dot_pointt8 <= 16'b0000111100000000;
										
								end
								4'd6: begin
										 dot_pointt1 <= 16'b0000111100000000;
										 dot_pointt2 <= 16'b0000100000000000;
										 dot_pointt3 <= 16'b0000100000000000;
										 dot_pointt4 <= 16'b0000100000000000;
										 dot_pointt5 <= 16'b0000111100000000;
										 dot_pointt6 <= 16'b0000100100000000;
										 dot_pointt7 <= 16'b0000100100000000;
										 dot_pointt8 <= 16'b0000111100000000;
										
								end
								4'd7: begin
										 dot_pointt1 <= 16'b0000111100000000;
										 dot_pointt2 <= 16'b0000000100000000;
										 dot_pointt3 <= 16'b0000000100000000;
										 dot_pointt4 <= 16'b0000000100000000;
										 dot_pointt5 <= 16'b0000000100000000;
										 dot_pointt6 <= 16'b0000000100000000;
										 dot_pointt7 <= 16'b0000000100000000;
										 dot_pointt8 <= 16'b0000000100000000;
										
								end
								4'd8: begin
										 dot_pointt1 <= 16'b0000111100000000;
										 dot_pointt2 <= 16'b0000100100000000;
										 dot_pointt3 <= 16'b0000100100000000;
										 dot_pointt4 <= 16'b0000101100000000;
										 dot_pointt5 <= 16'b0000110100000000;
										 dot_pointt6 <= 16'b0000100100000000;
										 dot_pointt7 <= 16'b0000100100000000;
										 dot_pointt8 <= 16'b0000111100000000;
										
								end
								4'd9: begin
								
										 dot_pointt1 <= 16'b0000111100000000;
										 dot_pointt2 <= 16'b0000100100000000;
										 dot_pointt3 <= 16'b0000100100000000;
										 dot_pointt4 <= 16'b0000101100000000;
										 dot_pointt5 <= 16'b0000110100000000;
										 dot_pointt6 <= 16'b0000000100000000;
										 dot_pointt7 <= 16'b0000000100000000;
										 dot_pointt8 <= 16'b0000111100000000;
										
								end
								default: begin
										 dot_pointt1 <= dot_pointt1;
										 dot_pointt2 <= dot_pointt2;
										 dot_pointt3 <= dot_pointt3;
										 dot_pointt4 <= dot_pointt4;
										 dot_pointt5 <= dot_pointt5;
										 dot_pointt6 <= dot_pointt6;
										 dot_pointt7 <= dot_pointt7;
										 dot_pointt8 <= dot_pointt8;
										 end
							endcase
						case(unit_digit)
								4'd0: begin
										 dot_point1 <=dot_pointt1 |16'b00001111000;
										 dot_point2 <=dot_pointt2 |16'b00001001000;
										 dot_point3 <=dot_pointt3 |16'b00001001000;
										 dot_point4 <=dot_pointt4 |16'b00001001000;
										 dot_point5 <=dot_pointt5 |16'b00001001000;
										 dot_point6 <=dot_pointt6 |16'b00001001000;
										 dot_point7 <=dot_pointt7 |16'b00001001000;
										 dot_point8 <=dot_pointt8 |16'b00001111000;
										
								end
								4'd1: begin
										 dot_point1 <=dot_pointt1 | 16'b000000000110000;
										 dot_point2 <=dot_pointt2 | 16'b000000001110000;
										 dot_point3 <=dot_pointt3 | 16'b000000000110000;
										 dot_point4 <=dot_pointt4 | 16'b000000000110000;
										 dot_point5 <=dot_pointt5 | 16'b000000000110000;
										 dot_point6 <=dot_pointt6 | 16'b000000000110000;
										 dot_point7 <=dot_pointt7 | 16'b000000000110000;
										 dot_point8 <=dot_pointt8 | 16'b000000001111000;
										
								end
								4'd2: begin
										 dot_point1 <=dot_pointt1 | 16'b00001110000;
										 dot_point2 <=dot_pointt2 | 16'b00000001000;
										 dot_point3 <=dot_pointt3 | 16'b00000001000;
										 dot_point4 <=dot_pointt4 | 16'b00001101000;
										 dot_point5 <=dot_pointt5 | 16'b00001011000;
										 dot_point6 <=dot_pointt6 | 16'b00001000000;
										 dot_point7 <=dot_pointt7 | 16'b00001000000;
										 dot_point8 <=dot_pointt8 | 16'b00001111000;
										
								end
								4'd3: begin
								
										 dot_point1 <=dot_pointt1 | 16'b00001111000;
										 dot_point2 <=dot_pointt2 | 16'b00001111000;
										 dot_point3 <=dot_pointt3 | 16'b00000001000;
										 dot_point4 <=dot_pointt4 | 16'b00001111000;
										 dot_point5 <=dot_pointt5 | 16'b00001111000;
										 dot_point6 <=dot_pointt6 | 16'b00000001000;
										 dot_point7 <=dot_pointt7 | 16'b00001111000;
										 dot_point8 <=dot_pointt8 | 16'b00001111000;
										
								end
								4'd4: begin
										 dot_point1 <=dot_pointt1 | 16'b00001001000;
										 dot_point2 <=dot_pointt2 | 16'b00001001000;
										 dot_point3 <=dot_pointt3 | 16'b00001001000;
										 dot_point4 <=dot_pointt4 | 16'b00001001000;
										 dot_point5 <=dot_pointt5 | 16'b00001111000;
										 dot_point6 <=dot_pointt6 | 16'b00000001000;
										 dot_point7 <=dot_pointt7 | 16'b00000001000;
										 dot_point8 <=dot_pointt8 | 16'b00000001000;
										
								end
								4'd5: begin
										 dot_point1 <=dot_pointt1 | 16'b00001111000;
										 dot_point2 <=dot_pointt2 | 16'b00001000000;
										 dot_point3 <=dot_pointt3 | 16'b00001000000;
										 dot_point4 <=dot_pointt4 | 16'b00001011000;
										 dot_point5 <=dot_pointt5 | 16'b00001101000;
										 dot_point6 <=dot_pointt6 | 16'b00000001000;
										 dot_point7 <=dot_pointt7 | 16'b00000001000;
										 dot_point8 <=dot_pointt8 | 16'b00001111000;
										
								end
								4'd6: begin
										 dot_point1 <=dot_pointt1 | 16'b00001111000;
										 dot_point2 <=dot_pointt2 | 16'b00001000000;
										 dot_point3 <=dot_pointt3 | 16'b00001000000;
										 dot_point4 <=dot_pointt4 | 16'b00001000000;
										 dot_point5 <=dot_pointt5 | 16'b00001111000;
										 dot_point6 <=dot_pointt6 | 16'b00001001000;
										 dot_point7 <=dot_pointt7 | 16'b00001001000;
										 dot_point8 <=dot_pointt8 | 16'b00001111000;
										
								end
								4'd7: begin
										 dot_point1 <=dot_pointt1 | 16'b00001111000;
										 dot_point2 <=dot_pointt2 | 16'b00000001000;
										 dot_point3 <=dot_pointt3 | 16'b00000001000;
										 dot_point4 <=dot_pointt4 | 16'b00000001000;
										 dot_point5 <=dot_pointt5 | 16'b00000001000;
										 dot_point6 <=dot_pointt6 | 16'b00000001000;
										 dot_point7 <=dot_pointt7 | 16'b00000001000;
										 dot_point8 <=dot_pointt8 | 16'b00000001000;
										
								end
								4'd8: begin
										 dot_point1 <=dot_pointt1 | 16'b000000001111000;
										 dot_point2 <=dot_pointt2 | 16'b000000001001000;
										 dot_point3 <=dot_pointt3 | 16'b000000001001000;
										 dot_point4 <=dot_pointt4 | 16'b000000001011000;
										 dot_point5 <=dot_pointt5 | 16'b000000001101000;
										 dot_point6 <=dot_pointt6 | 16'b000000001001000;
										 dot_point7 <=dot_pointt7 | 16'b000000001001000;
										 dot_point8 <=dot_pointt8 | 16'b000000001111000;
										
								end
								4'd9: begin
								
										 dot_point1 <=dot_pointt1 | 16'b000000001111000;
										 dot_point2 <=dot_pointt2 | 16'b000000001001000;
										 dot_point3 <=dot_pointt3 | 16'b000000001001000;
										 dot_point4 <=dot_pointt4 | 16'b000000001011000;
										 dot_point5 <=dot_pointt5 | 16'b000000001101000;
										 dot_point6 <=dot_pointt6 | 16'b000000000001000;
										 dot_point7 <=dot_pointt7 | 16'b000000000001000;
										 dot_point8 <=dot_pointt8 | 16'b000000001111000;
										
								end
								default: begin
										 dot_point1 <= dot_point1;
										 dot_point2 <= dot_point2;
										 dot_point3 <= dot_point3;
										 dot_point4 <= dot_point4;
										 dot_point5 <= dot_point5;
										 dot_point6 <= dot_point6;
										 dot_point7 <= dot_point7;
										 dot_point8 <= dot_point8;
										 end
							endcase
		end
  end
  
	always@(posedge clk or negedge rst)begin  		//seven segment count down
		if(!rst)begin
			sevenout3 <= 7'b1000000;
			sevenout4 <= 7'b0011001;
			time_unit_digit <= 4'd0;
			time_ten_digit <= 4'd0;
			temp_time <= 8'd0;
		end else begin 
				temp_time <= Time;
				if(Time>=40)begin
					time_ten_digit <= 4'd4;
					time_unit_digit <= temp_time - 8'd40;
				end else if(Time >= 30)begin
					time_ten_digit <= 4'd3;
					time_unit_digit <= temp_time - 8'd30;
				end else if(Time >= 20)begin
					time_ten_digit <= 4'd2;
					time_unit_digit <= temp_time - 8'd20;
				end else if(Time >= 10)begin
					time_ten_digit <= 4'd1;
					time_unit_digit <= temp_time - 8'd10;
				end else if(Time >=0)begin
					time_ten_digit <= 4'd0;
					time_unit_digit <= temp_time;
				end	
			
			case(time_unit_digit)
				4'd0: sevenout3 = 7'b1000000; 
				4'd1: sevenout3 = 7'b1111001; 
				4'd2: sevenout3 = 7'b0100100;
				4'd3: sevenout3 = 7'b0110000; 
				4'd4: sevenout3 = 7'b0011001; 
				4'd5: sevenout3 = 7'b0010010; 
				4'd6: sevenout3 = 7'b0000010; 
				4'd7: sevenout3 = 7'b1111000; 
				4'd8: sevenout3 = 7'b0000000;
				4'd9: sevenout3 = 7'b0010000; 
				default: sevenout3 <= sevenout3;
			endcase
			case(time_ten_digit)
				4'd0: sevenout4 = 7'b1000000; 
				4'd1: sevenout4 = 7'b1111001; 
				4'd2: sevenout4 = 7'b0100100;
				4'd3: sevenout4 = 7'b0110000; 
				4'd4: sevenout4 = 7'b0011001; 
				4'd5: sevenout4 = 7'b0010010; 
				4'd6: sevenout4 = 7'b0000010; 
				4'd7: sevenout4 = 7'b1111000; 
				4'd8: sevenout4 = 7'b0000000;
				4'd9: sevenout4 = 7'b0010000; 
				default: sevenout4 <= sevenout4;
			endcase
		end
	end
  
	always @(posedge clk or negedge rst)begin //dot matrix graph generator
		if(!rst)begin
			dot_col1<=16'b0000000000000000;
			dot_col2<=16'b0000000000000000;
			dot_col3<=16'b0000000000000000;
			dot_col4<=16'b0000000000000000;
			count_random <= 32'd0;
		end else begin 
				if(count_down == `TimeExpire_4Hz)begin
					dot_col1<= ((dot_col1>>1))|dot_random1;
					dot_col2<= ((dot_col2>>1))|dot_random2;
					dot_col3<= ((dot_col3>>1))|dot_random3;
					dot_col4<= ((dot_col4>>1))|dot_random4;
					dot_random1<= 16'b0000000000000000;
					dot_random2<= 16'b0000000000000000;
					dot_random3<= 16'b0000000000000000;
					dot_random4<= 16'b0000000000000000;
					count_down <= 32'd0;
				end else begin
					count_down <= count_down + 32'd1;
				end
				if(count_random == `TimeExpire_Random)begin
					case(lfsr%4)
						8'd0 : dot_random1 <= 16'b1100000000000000;
						8'd1 : dot_random2 <= 16'b1100000000000000;
						8'd2 : dot_random3 <= 16'b1100000000000000;
						8'd3 : dot_random4 <= 16'b1100000000000000;
						default:;
					endcase
					count_random <= 32'd0;
				end else begin
					count_random <= count_random + 32'd1;
				end
		end
	end
  
  always @(posedge clk or negedge rst)begin //Time and End Game
		if(!rst)begin
			round <= 35'd0;
			Timeup <= 1'd0;
			Time <= 8'd40;
			count_time <= 32'd0;
			grade_count<=35'd0;
			flash_count<=32'd0;
			endgame<=1'd0;
		end else begin
			if(round == `TimeExpire_Round)begin
				Timeup <= 1'd1;
			end else begin
				round <= round + 35'd1;
			end
			if(count_time == `TimeExpire_1Hz && Time > 8'd0)begin
				Time <= Time - 8'd1;
				count_time <= 32'd0;
			end else begin
				count_time <= count_time + 32'd1;
			end
			if(Timeup==1'd1)begin
				if(grade_count==`TimeExpire_twosec)begin
					endgame<=1'd1;
				end else begin
					grade_count <= grade_count+35'd1;
				end
				if(flash_count==`TimeExpire_20Hz)begin
					flash_count<=32'd0;
					if(flash==1'd0)begin
						flash<=1'd1;
					end else begin
						flash<=1'd0;
					end
				end else begin
					flash_count<=flash_count+32'd1;
				end
			end
	
		end
  end
  
  always @(posedge clk or negedge rst)begin //dot matrix display
		if(!rst)begin
         row_count <= 3'd0;
         dot_row <= 8'b0;
			count_matrix <= 32'd0;
			dot_row <= 8'b00000000;
			dot_col <= 8'b00000000;
      end else begin 
            if(count_matrix == `TimeExpire_dot)begin
                row_count <= row_count + 3'd1;
					 count_matrix <= 32'd0;
                if(endgame)begin
							case(row_count)
							3'd0 : dot_row <= 8'b01111111;
							3'd1 : dot_row <= 8'b10111111;
							3'd2 : dot_row <= 8'b11011111;
							3'd3 : dot_row <= 8'b11101111;
							3'd4 : dot_row <= 8'b11110111;
							3'd5 : dot_row <= 8'b11111011;
							3'd6 : dot_row <= 8'b11111101;
							3'd7 : dot_row <= 8'b11111110;
						endcase
						case(row_count)
							3'd0 : dot_col <= 16'b0000000000000000;
							3'd1 : dot_col <= 16'b0000000000000000;
							3'd2 : dot_col <= 16'b0111010010111000;
							3'd3 : dot_col <= 16'b0100011010100100;
							3'd4 : dot_col <= 16'b0111010010100100;
							3'd5 : dot_col <= 16'b0100010110100100;
							3'd6 : dot_col <= 16'b0111010010111000;
							3'd7 : dot_col <= 16'b0000000000000000;
						endcase
					 end 
					else if(Timeup&&flash)begin
					case(row_count)
							3'd0 : dot_row <= 8'b01111111;
							3'd1 : dot_row <= 8'b10111111;
							3'd2 : dot_row <= 8'b11011111;
							3'd3 : dot_row <= 8'b11101111;
							3'd4 : dot_row <= 8'b11110111;
							3'd5 : dot_row <= 8'b11111011;
							3'd6 : dot_row <= 8'b11111101;
							3'd7 : dot_row <= 8'b11111110;
						endcase
						case(row_count)
						
							3'd0 : dot_col <= dot_point1;
							3'd1 : dot_col <= dot_point2;
							3'd2 : dot_col <= dot_point3;
							3'd3 : dot_col <= dot_point4;
							3'd4 : dot_col <= dot_point5;
							3'd5 : dot_col <= dot_point6;
							3'd6 : dot_col <= dot_point7;
							3'd7 : dot_col <= dot_point8;
							endcase
					end else if (Timeup) begin
					case(row_count)
							3'd0 : dot_row <= 8'b01111111;
							3'd1 : dot_row <= 8'b10111111;
							3'd2 : dot_row <= 8'b11011111;
							3'd3 : dot_row <= 8'b11101111;
							3'd4 : dot_row <= 8'b11110111;
							3'd5 : dot_row <= 8'b11111011;
							3'd6 : dot_row <= 8'b11111101;
							3'd7 : dot_row <= 8'b11111110;
						endcase
						case(row_count)
							3'd0 : dot_col <= 16'b0000000000000000;
							3'd1 : dot_col <= 16'b0000000000000000;
							3'd2 : dot_col <= 16'b0000000000000000;
							3'd3 : dot_col <= 16'b0000000000000000;
							3'd4 : dot_col <= 16'b0000000000000000;
							3'd5 : dot_col <= 16'b0000000000000000;
							3'd6 : dot_col <= 16'b0000000000000000;
							3'd7 : dot_col <= 16'b0000000000000000;
							endcase
					end
					else begin
						case(row_count)
							3'd0 : dot_row <= 8'b01111111;
							3'd1 : dot_row <= 8'b10111111;
							3'd2 : dot_row <= 8'b11011111;
							3'd3 : dot_row <= 8'b11101111;
							3'd4 : dot_row <= 8'b11110111;
							3'd5 : dot_row <= 8'b11111011;
							3'd6 : dot_row <= 8'b11111101;
							3'd7 : dot_row <= 8'b11111110;
						endcase
						case(row_count)
							3'd0 : dot_col <= dot_col1;
							3'd1 : dot_col <= dot_col1;
							3'd2 : dot_col <= dot_col2;
							3'd3 : dot_col <= dot_col2;
							3'd4 : dot_col <= dot_col3;
							3'd5 : dot_col <= dot_col3;
							3'd6 : dot_col <= dot_col4;
							3'd7 : dot_col <= dot_col4; 
						endcase
					 end	
            end else begin
                count_matrix <= count_matrix + 32'd1;
            end
       end
	end

endmodule