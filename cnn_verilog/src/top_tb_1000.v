`timescale 1ns / 1ps

module top_tb_1000;

reg clk, rst_n;
reg [7:0] pixels [0:783999];
reg [9:0] img_idx;
reg [7:0] data_in;
reg [9:0] cnt;  // num of input image (1000)
//reg [9:0] input_cnt;
reg [9:0] rand_num; // 0-1000
reg state;

wire [3:0] decision;
wire round_end;
reg [3:0] i;  // loop variable
reg [9:0] accuracy; // hit/miss count (1000)

//reg [9:0] hit_num_0,hit_num_1,hit_num_2,hit_num_3,hit_num_4,hit_num_5,hit_num_6,hit_num_7,hit_num_8,hit_num_9;
//reg [9:0] miss_num_0,miss_num_1,miss_num_2,miss_num_3,miss_num_4,miss_num_5,miss_num_6,miss_num_7,miss_num_8,miss_num_9;

reg [9:0] hit_num_of [9:0] ;
reg [9:0] miss_num_of [9:0] ;

integer seed;

/*
top_1000 u_top_1000(
.clk(clk),
.rst_n(rst_n),
.data_in(data_in),
.decision(decision),
.finish(round_end)
);*/

top u_top(
.clk(clk),
.rst_n(rst_n),
.data_in(data_in),
.decision(decision),
.finish(round_end)
);

// Clock generation
always #5 clk = ~clk;

// Read image text file
initial begin
  $readmemh("input_1000.txt", pixels);
  $readmemb("initial_for_hit_and_miss_arr.txt", hit_num_of);
  $readmemb("initial_for_hit_and_miss_arr.txt", miss_num_of);
  
  cnt <= 0;
  img_idx <= 0;
  clk <= 1'b0;
  //input_cnt <= -1;
  rst_n <= 1'b1;
  rand_num <= 1'b0;
  accuracy <= 0;
  i <= 0;
  
  seed <= 9;
  /*
  hit_num_0 <= 0;
  hit_num_1 <= 0;
  hit_num_2 <= 0;
  hit_num_3 <= 0;
  hit_num_4 <= 0;
  hit_num_5 <= 0;
  hit_num_6 <= 0;
  hit_num_7 <= 0;
  hit_num_8 <= 0;
  hit_num_9 <= 0;
  miss_num_0<= 0;
  miss_num_1<= 0;
  miss_num_2<= 0;
  miss_num_3<= 0;
  miss_num_4<= 0;
  miss_num_5<= 0;
  miss_num_6<= 0;
  miss_num_7<= 0;
  miss_num_8<= 0;
  miss_num_9<= 0;
  */

  #3
  rst_n <= 1'b0;
  
  #3
  rst_n <= 1'b1;
end

always @(posedge clk) begin
  if(~rst_n) begin

    #3
    rst_n <= 1'b1;
  end 
   else begin
    // decision done
    if(round_end == 1'b1) begin
      if(state !== 1'bx) begin
        if(cnt % 10 == 1) begin
          if(rand_num % 10 == decision) begin
            $display("%0dst input image : original value = %0d, decision = %0d at %0t ps ==> Success", cnt, rand_num % 10, decision, $time);
            accuracy <= accuracy + 1'b1;
				hit_num_of[rand_num % 10] <= hit_num_of[rand_num % 10] + 1'b1;
          end 
			 else begin
            $display("%0dst input image : original value = %0d, decision = %0d at %0t ps ==> Fail", cnt, rand_num % 10, decision, $time);
				miss_num_of[rand_num % 10] <= miss_num_of[rand_num % 10] + 1'b1;
          end
        end 
		  else if(cnt % 10 == 2) begin
          if(rand_num % 10 == decision) begin
            $display("%0dnd input image : original value = %0d, decision = %0d at %0t ps ==> Success", cnt, rand_num % 10, decision, $time);
            accuracy <= accuracy + 1'b1;
				hit_num_of[rand_num % 10] <= hit_num_of[rand_num % 10] + 1'b1;
          end 
			 else begin
            $display("%0dnd input image : original value = %0d, decision = %0d at %0t ps ==> Fail", cnt, rand_num % 10, decision, $time);
				miss_num_of[rand_num % 10] <= miss_num_of[rand_num % 10] + 1'b1;
          end
        end 
		  else if(cnt % 10 == 3) begin
          if(rand_num % 10 == decision) begin
            $display("%0drd input image : original value = %0d, decision = %0d at %0t ps ==> Success", cnt, rand_num % 10, decision, $time);
            accuracy <= accuracy + 1'b1;
				hit_num_of[rand_num % 10] <= hit_num_of[rand_num % 10] + 1'b1;
          end 
			 else begin
            $display("%0drd input image : original value = %0d, decision = %0d at %0t ps ==> Fail", cnt, rand_num % 10, decision, $time);
				miss_num_of[rand_num % 10] <= miss_num_of[rand_num % 10] + 1'b1;
          end
			end
        else begin
          if(rand_num % 10 == decision) begin
            $display("%0dth input image : original value = %0d, decision = %0d at %0t ps ==> Success", cnt, rand_num % 10, decision, $time);
            accuracy <= accuracy + 1'b1;
				hit_num_of[rand_num % 10] <= hit_num_of[rand_num % 10] + 1'b1;
          end 
			 else begin
            $display("%0dth input image : original value = %0d, decision = %0d at %0t ps ==> Fail", cnt, rand_num % 10, decision, $time);
				miss_num_of[rand_num % 10] <= miss_num_of[rand_num % 10] + 1'b1;
          end
        end
      end

      state <= 1'b0;
      rst_n <= 1'b0;
      //input_cnt <= input_cnt + 1'b1;
		
		/*if(!$value$plusargs("seed=%d", seed))begin
        seed = 0;
	   end
	   $srandom(seed);
		*/
		
      //rand_num <= $urandom_range(0, 1000);
		rand_num <= {$random(seed)} %1001 ;
		
    end

    if(state == 1'b0) begin
      //data_in <= pixels[cnt*784 + img_idx];
      data_in <= pixels[rand_num*784 + img_idx];
      //data_in <= pixel[img_idx];
      img_idx <= img_idx + 1'b1;

      if(img_idx == 10'd784) begin
        cnt <= cnt + 1'b1;

        if(cnt == 10'd1000) begin
          $display("\n\n------ Final Accuracy for 1000 Input Image ------");
          $display("Hit Rate: %d%%", accuracy/10);
			 $display("%d right out of 1000",accuracy);
			 
			 for (i=0;i<10;i=i+1) begin
			 $display("\n Number %d :\t Total: %d \t Hit: %d \t Miss: %d ",i,(hit_num_of[i]+miss_num_of[i]),hit_num_of[i],miss_num_of[i],);
			 end
			 
          $stop;
        end
        img_idx <= 0;
        state <= 1'b1;  // done
      end
    end
  end
end

endmodule
