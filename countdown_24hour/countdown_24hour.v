`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    1:42:58 11/22/2015
// Module Name:    countdown_24hour
//////////////////////////////////////////////////////////////////////////////////
module countdown_24hour(
	input wire  clk0,
	output wire [7:0] seg7,
	output wire [3:0] line,
	output wire [6:0] led
);
	assign line = 4'b0001<<ab;
	assign led  = { 2'b00, min_6_count, min_10_count };
	assign seg7 = { 1'b0, disp };
	parameter[3:0] hour_10_change[0:9] = {4'd3, 4'd2, 4'd1, 4'd0, 4'd9, 4'd8, 4'd7, 4'd6, 4'd5, 4'd4};

	parameter [6:0] seg7_data[0:9]={
			7'b0111111, //0
			7'b0000110, //1
			7'b1011011, //2
			7'b1001111, //3
			7'b1100110, //4
			7'b1101101, //5
			7'b1111101, //6
			7'b0100111, //7
			7'b1111111, //8
			7'b1101111  //9
	};

	// ダイナミヂ�表示
	reg[6:0] disp=7'b0;
	reg[3:0] x;
	reg[1:0] ab = 1'b0;
	always @( posedge clk0 )begin
		if(c[9:0]==0)begin
			if( ab == 2'b00 )
				x <= hour_10_change[hour_10_count];
			else if( ab == 2'b01 )
				x <= 4'd2 - hour_3_count;
			else if( ab == 2'b10 )
				x <= 4'd9 - min_10_count;
			else
				x <= 4'd5 - min_6_count;
			if(x<=4'd9)
				disp <= seg7_data[x];
			else
				disp <= 7'b0000000;
			ab <= ab + 1'b1;
		end
	end

	// 1秒生�
	reg[26:0] c=27'b0;
	reg sec_enable=1'b0;
	always @( posedge clk0 )begin
		if( c==27'd499999 )begin // 100,000,000-1
			c <= 0;
			sec_enable <= 1'b1;
		end
		else begin
			c <= c + 1'b1;
			sec_enable <= 1'b0;
		end
	end

	// 刂�表�0進カウンタ
	reg[3:0] min_10_count=4'b0;
	reg min_10_enable = 1'b0;
	always @( posedge clk0 )begin
		if( sec_enable )begin
			if( min_10_count==4'd9 )begin
				min_10_count<=1'b0;
				min_10_enable <= 1'b1;
			end
			else begin
				min_10_count <= min_10_count + 1'b1;
				min_10_enable <= 1'b0;
			end
		end
		else begin
			min_10_enable <= 1'b0;
		end
	end

	// 刂�表�進カウンタ
	reg[2:0] min_6_count=3'b0;
	reg min_6_enable = 1'b0;
	always @( posedge clk0 )begin
		if( min_10_enable )begin
			if( min_6_count==3'd5 )begin
				min_6_count <= 1'b0;
				min_6_enable <= 1'b1;
			end
			else begin
				min_6_count <= min_6_count + 1'b1;
				min_6_enable <= 1'b0;
			end
		end
		else
			min_6_enable <= 1'b0;
	end

	// 時を表�0進カウンタ
	reg[3:0] hour_10_count=4'b0;
	reg hour_10_enable = 1'b0;
	always @( posedge clk0 )begin
		if( min_6_enable )begin
			if( hour_10_count==4'd3 && hour_3_count==4'd0 )begin
				hour_10_count <= hour_10_count + 1'b1;
				hour_10_enable <= 1'b1;
			end
			else if( hour_10_count==4'd3 && hour_3_count==4'd1 )begin
				hour_10_count <= hour_10_count + 1'b1;
				hour_10_enable <= 1'b1;
			end
			else if( hour_10_count==4'd3 && hour_3_count==4'd2 )begin
				hour_10_count <= 1'b0;
				hour_10_enable <= 1'b1;
			end
			else if( hour_10_count==4'd9 )
				hour_10_count <= 1'b0;
			else begin
				hour_10_count <= hour_10_count + 1'b1;
				hour_10_enable <= 1'b0;
			end
		end
		else begin
			hour_10_enable <= 1'b0;
		end
	end

	// 時を表�進カウンタ
	reg[1:0] hour_3_count=2'b0;
	always @( posedge clk0 )begin
		if( hour_10_enable )
			hour_3_count <= (hour_3_count==2'd2)?1'b0:(hour_3_count+1'b1);
	end

endmodule
