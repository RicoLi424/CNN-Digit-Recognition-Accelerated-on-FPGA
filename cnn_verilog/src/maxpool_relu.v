
/*------------------------------------------------------------------------
 *
 *  Copyright (c) 2021 by Bo Young Kang, All rights reserved.
 *
 *  File name  : maxpool_relu.v
 *  Written by : Kang, Bo Young
 *  Written on : Oct 13, 2021
 *  Version    : 21.2
 *  Design     : (1) MaxPooling for CNN
 *							 (2) Activation Function for CNN - ReLU Function
 *
 *------------------------------------------------------------------------*/

/*-------------------------------------------------------------------
 *  Module: maxpool_relu
 *------------------------------------------------------------------*/

module maxpool_relu #(parameter CONV_BIT = 12, HALF_WIDTH = 12, HALF_HEIGHT = 12, HALF_WIDTH_BIT = 4) (
	input clk,
	input rst_n,	
	input valid_in,
	input signed [CONV_BIT - 1 : 0] conv_out_1, conv_out_2, conv_out_3,
	output reg [CONV_BIT - 1 : 0] max_value_1, max_value_2, max_value_3,
	output reg valid_out_relu
);


//（池化层1）每个通道buffer放12个max_value数据
reg signed [CONV_BIT - 1:0] buffer1 [0:HALF_WIDTH - 1];
reg signed [CONV_BIT - 1:0] buffer2 [0:HALF_WIDTH - 1];
reg signed [CONV_BIT - 1:0] buffer3 [0:HALF_WIDTH - 1];

reg [HALF_WIDTH_BIT - 1:0] pcount;
reg state;
reg flag;

always @(posedge clk) begin
	if(~rst_n) begin
		valid_out_relu <= 0;
		pcount <= 0;
		state <= 0;
		flag <= 0;
	end 
	else begin

	if(valid_in == 1'b1) begin                 //当前面buffer和cal层进行卷积时；buffer中每一排最后几个数据更新时valid_in=0,以下操作停止
		flag <= ~flag;
		if(flag == 1) begin
			pcount <= pcount + 1;             //buffer层每排卷积进行每两次后，pcount++
			if(pcount == HALF_WIDTH - 1) begin     //每行进行12次max操作（池化层1）
				state <= ~state;                  //每次池化操作的两行里的第一行操作结束后，state变1，开始两行里的第二行的对应操作
				pcount <= 0;
			end
		end

		if(state == 0) begin	// first line，两行里的第一行操作，将每个2×2的第一行的两个数比较，将较大值存进buffer[i]
			valid_out_relu <= 0;
			if(flag == 0) begin	// first input
				buffer1[pcount] <= conv_out_1;
				buffer2[pcount] <= conv_out_2;
				buffer3[pcount] <= conv_out_3;
			end 
			else begin	// second input -> comparison
				if(buffer1[pcount] < conv_out_1)
					buffer1[pcount] <= conv_out_1;
				if(buffer2[pcount] < conv_out_2)
				  buffer2[pcount] <= conv_out_2;
				if(buffer3[pcount] < conv_out_3)
				  buffer3[pcount] <= conv_out_3;
			end
		end 
		
		// second line，两行里的第二行操作，将每个2×2的第二行的第一个数与之前对应的buffer[i]里存放的较大值比较，再将较大值存进buffer[i]；
		//再将第二行的第二个数与buffer[i]比较，将较大者进行relu操作后存入buffer[i]
		else begin	
			if(flag == 0) begin	// third input -> comparison
				valid_out_relu <= 0;
				if(buffer1[pcount] < conv_out_1)
				  buffer1[pcount] <= conv_out_1;
				if(buffer2[pcount] < conv_out_2)
				  buffer2[pcount] <= conv_out_2;
			  if(buffer3[pcount] < conv_out_3)
				  buffer3[pcount] <= conv_out_3;
			end 
			else begin	// fourth input -> comparison + relu
				valid_out_relu <= 1;                       //每进行完一次2×2池化操作，输出valid_out_relu为1，作为第二个buffer层的输入
				if(buffer1[pcount] < conv_out_1) begin
					if(conv_out_1 > 0) begin
						max_value_1 <= conv_out_1;
					end 
					else begin
						max_value_1 <= 0;
					end
				end 
				else begin
					if(buffer1[pcount] > 0) begin
						max_value_1 <= buffer1[pcount];
					end 
					else begin
						max_value_1 <= 0;
					end
				end

				if(buffer2[pcount] < conv_out_2) begin
					if(conv_out_2 > 0) begin
						max_value_2 <= conv_out_2;
					end 
					else begin
						max_value_2 <= 0;
					end
				end 
				else begin
					if(buffer2[pcount] > 0) begin
						max_value_2 <= buffer2[pcount];
					end 
					else begin
						max_value_2 <= 0;
					end
				end

				if(buffer3[pcount] < conv_out_3) begin
					if(conv_out_3 > 0) begin
						max_value_3 <= conv_out_3;
					end 
					else begin
						max_value_3 <= 0;
					end
				end 
				else begin
					if(buffer3[pcount] > 0) begin
						max_value_3 <= buffer3[pcount];
					end 
					else begin
						max_value_3 <= 0;
					end
					
			end
		end		
	end
	end 
	else begin
		valid_out_relu <= 0;
	end
end
end
endmodule