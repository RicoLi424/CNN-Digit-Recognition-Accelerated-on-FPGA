`timescale 1ns / 1ps

module top_tb;

reg clk, rst_n;
reg [7:0] pixels [0:783];
reg [9:0] img_idx;
reg [7:0] data_in;
wire [3:0] decision;
wire finish;

//wire valid_out_1, valid_out_2, valid_out_3, valid_out_4, valid_out_5, valid_out_6;

top u_top(
.clk(clk),
.rst_n(rst_n),
.data_in(data_in),
.decision(decision),
.finish(finish)
);


// Clock generation
always #5 clk = ~clk;

// Read image text file
initial begin
  $readmemh("2_0.txt", pixels);
  clk <= 1'b0;
  rst_n <= 1'b1;
  #3 
  rst_n <= 1'b0;
  #3
  rst_n <= 1'b1;
end

always @(posedge clk) begin
  if(~rst_n) begin
    img_idx <= 0;
  end 
  else begin
    if(img_idx < 10'd784) begin
      img_idx <= img_idx + 1'b1;
    end
    data_in <= pixels[img_idx];
  end
end

endmodule
