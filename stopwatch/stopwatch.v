`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Create Date:    12:29:40 10/22/2015
// Module Name:    counter30
//////////////////////////////////////////////////////////////////////////////////
module stopwatch(
	input	wire clk0,
	input	wire btn,
	input	wire btn_2,
	output	wire [7:0] seg7,
	output	wire [3:0] line,
	output	wire [6:0] led
);
	assign line = 4'b0001<<ab;
	assign led  = { 2'b00, min_6_count, min_10_count };
	assign seg7 = { 1'b0, disp };

	parameter [6:0] seg7_data[0:9] = {
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

	// ダイナミック表示
	reg[6:0] disp=7'b0;
	reg[3:0] x;
	reg[1:0] ab = 1'b0;
	always @( posedge clk0 )begin
		if(c[9:0]==0)begin
			if( ab == 2'b00 )
				x <= hour_10_count;
			else if( ab == 2'b01 )
				x <= hour_3_count;
			else if( ab == 2'b10 )
				x <= min_10_count;
			else
				x <= min_6_count;
			if(x<=4'd9)
				disp <= seg7_data[x];
			else
				disp <= 7'b0000000;
			ab <= ab + 1'b1;
		end
	end

	// 停止・再開ボタン
	reg btnc = 1'b1;
	always @( posedge clk0 )begin
		if( btn )
			btnc <= 1'b1;
		if ( btn && btnc == 1'b1 )
			btnc <= 1'b0;
	end

	// 1秒生成
	reg [26:0] c = 27'b0;
	reg sec_enable = 1'b0;
	always @( posedge clk0 )begin
		if( c == 27'd99999999 && btnc == 1'b1 )begin // 100,000,000-1
			c <= 0;
			sec_enable <= 1'b1;
		end
		else begin
			c <= c + 1'b1;
			sec_enable <= 1'b0;
		end
	end

	// 分を表す10進カウンタ
	reg[3:0] min_10_count = 4'b0;
	reg min_10_enable = 1'b0;
	always @( posedge clk0 )begin
		if( sec_enable )begin
			if( min_10_count == 4'd9 )begin
				min_10_count <= 1'b0;
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
		if( btn_2 )	// 値をリセット
			min_10_count <= 1'b0;
	end

	// 分を表す6進カウンタ
	reg[2:0] min_6_count = 3'b0;
	reg min_6_enable = 1'b0;
	always @( posedge clk0 )begin
		if( min_10_enable )begin
			if( min_6_count == 3'd5 )begin
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
		if( btn_2 )	// 値をリセット
			min_6_count <= 1'b0;
	end

	// 時を表す10進カウンタ
	reg[3:0] hour_10_count = 4'b0;
	reg hour_10_enable = 1'b0;
	always @( posedge clk0 )begin
		if( min_6_enable )begin
			if( hour_10_count == 4'd9 )begin
				hour_10_count <= 1'b0;
				hour_10_enable <= 1'b1;
			end
			else if( hour_10_count == 4'd3 && hour_3_count == 2'd2 )begin
				hour_10_count <= 1'b0;
				hour_10_enable <= 1'b1;
			end
			else begin
				hour_10_count <= hour_10_count + 1'b1;
				hour_10_enable <= 1'b0;
			end
		end
		else begin
			hour_10_enable <= 1'b0;
		end
		if( btn_2 )	// 値をリセット
			hour_10_count <= 1'b0;
	end

	// 時を表す3進カウンタ
	reg[1:0] hour_3_count = 2'b0;
	always @( posedge clk0 )begin
		if( hour_10_enable )
			hour_3_count <= ( hour_3_count == 2'd2 )?1'b0:( hour_3_count + 1'b1 );
		if( btn_2 )	// 値をリセット
			hour_3_count <= 1'b0;
	end

endmodule