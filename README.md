# CNN-Digit-Recognition-on-FPGA
**_Explanation on .v modules_** 
  
**Convolutional Layer 1**  
`-clk:` Clock input.  
`-rst_n:` Asynchronous reset signal, active low.  
`-data_in:` Read the MNIST text file as input, transmit the value of each pixel which ranges from 0 to 255 andrepresented by 8 bits.  
`-conv_out_#:` The result value of the convolution operation performed by the convolutional layer 1.  
`-valid_out_conv:` After each convolution and updating a row of data, the output is 1, and it is passed to the max pooling layer to start the pooling operation.  
  * **_con1_buf_**:  
`-data_in`: Read the MNIST text file as input, transmit the value of each pixel, the value of each pixel ranges from 0 to 255, represented by 8 bits.  
`-data_out_#`: Since the size of the convolution kernel is (5, 5, 3), there are 5×5=25 data outputs each time. Each is 8 bits, and the 25 data output each time is used as the input of a convolution operation. Verilog cannot pass a two-dimensional array to the port, so it uses 25 output variables to pass it to the output port.  
`-valid_out_buf`: As the enable signal of the Calc module after the buffer, it is used to control the subsequent convolution calculation.  

    A buffer of size 28×5=140 to carry the data of the convolution operation is used here. In the first 140 clock cycles, waiting for the first 140 data to be loaded, the buffer is full at this time, during this process `-valid_out_buf` is always 0, and the Calc module does not work. Then `-valid_out_buf` becomes 1, move the 5×5 filter in the buffer in the order from left to right, and determine the output value `data_out_#`. If the right end of the filter crosses the buffer, that is, it enters the invalid area, and assigns `valid_out_buf` to 0 . If filter is moved to the far right, it will be moved to the far left again, `valid_out_buf` becomes 1 again, and the Calc module starts working again. Filter moves from left to right and repeats the above process. During this process, the size of the buffer is fixed at 140. After loading the first 140 pieces of data, the data is updated one clock, and from the 141st piece of data, it enters the index 0, 1, 2... Overwrite the original data in it. Therefore, a separate mode setting is required, and the corresponding relationship between data_out and the data in the Buffer is changed after every fixed clock cycle.The distribution of output values in each mode is shown below:     
  ![image](https://user-images.githubusercontent.com/114987225/196122331-b5987db3-b380-4521-adab-46e2bf88e8a0.png)
  ![image](https://user-images.githubusercontent.com/114987225/196122359-acab712a-b702-470f-8425-f10310ff344f.png)
  ![image](https://user-images.githubusercontent.com/114987225/196122373-aa2aed26-59cb-4b1f-8497-d74ffcc2043e.png)
  ![image](https://user-images.githubusercontent.com/114987225/196122386-935e56c1-96af-4ed6-8889-e55ca820853e.png)
  ![image](https://user-images.githubusercontent.com/114987225/196122412-76ff0154-02db-4937-b13d-5d4ca17f84b8.png)





