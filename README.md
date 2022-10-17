# CNN-Digit-Recognition-on-FPGA
**_Explanation on .v modules_** 
  
**Convolutional Layer 1**  
`-clk:` Clock input.  
`-rst_n:` Asynchronous reset signal, active low.  
`-data_in:` Read the MNIST text file as input, transmit the value of each pixel which ranges from 0 to 255 andrepresented by 8 bits.  
`-conv_out_#:` The result value of the convolution operation performed by the convolutional layer 1.  
`-valid_out_conv:` After each convolution and updating a row of data, the output is 1, and it is passed to the max pooling layer to start the pooling operation.  
  * **_conv1_buf_**:  
`-data_in`: Read the MNIST text file as input, transmit the value of each pixel, the value of each pixel ranges from 0 to 255, represented by 8 bits.  
`-data_out_#`: Since the size of the convolution kernel is (5, 5, 3), there are 5×5=25 data outputs each time. Each is 8 bits, and the 25 data output each time is used as the input of a convolution operation. Verilog cannot pass a two-dimensional array to the port, so it uses 25 output variables to pass it to the output port.  
`-valid_out_buf`: As the enable signal of the Calc module after the buffer, it is used to control the subsequent convolution calculation.  

    A buffer of size 28×5=140 to carry the data of the convolution operation is used here. In the first 140 clock cycles, waiting for the first 140 data to be loaded, the buffer is full at this time, during this process `-valid_out_buf` is always 0, and the Calc module does not work. Then `-valid_out_buf` becomes 1, move the 5×5 filter in the buffer in the order from left to right, and determine the output value `data_out_#`. If the right end of the filter crosses the buffer, that is, it enters the invalid area, and assigns `valid_out_buf` to 0 . If filter is moved to the far right, it will be moved to the far left again, `valid_out_buf` becomes 1 again, and the Calc module starts working again. Filter moves from left to right and repeats the above process. During this process, the size of the buffer is fixed at 140. After loading the first 140 pieces of data, the data is updated one clock, and from the 141st piece of data, it enters the index 0, 1, 2... Overwrite the original data in it. Therefore, a separate mode setting is required, and the corresponding relationship between data_out and the data in the Buffer is changed after every fixed clock cycle.The distribution of output values in each mode is shown below:     
  ![image](https://user-images.githubusercontent.com/114987225/196122331-b5987db3-b380-4521-adab-46e2bf88e8a0.png)
  ![image](https://user-images.githubusercontent.com/114987225/196122359-acab712a-b702-470f-8425-f10310ff344f.png)
  ![image](https://user-images.githubusercontent.com/114987225/196122373-aa2aed26-59cb-4b1f-8497-d74ffcc2043e.png)
  ![image](https://user-images.githubusercontent.com/114987225/196122386-935e56c1-96af-4ed6-8889-e55ca820853e.png)
  ![image](https://user-images.githubusercontent.com/114987225/196122412-76ff0154-02db-4937-b13d-5d4ca17f84b8.png)
  
  * **_conv1_calc_**:   
`valid_in:   Enable signal, connected to valid_out_buf in Buffer module.
`data_in_#:` The 25 'data_out_#' output by the Buffer module each time.
`conv_out_#:` After the convolution operation is performed, the convolution output obtained by adding the bias value to the result value. The size of the filter is (5, 5, 3), so there are 3 channels and therefore 3 corresponding output ports. 
`valid_out_calc:` Connect directly to the 'valid_out_buf' of the Buffer layer as the output.

     Use the system command $readmemh to read the weights and biases text file and store them in a two-dimensional array. The 25 data output by the Buffer layer in each round is used as the input of the convolution calculation, and the convolution operation is performed with the weight value, and then the bias is added to obtain the output. Although the handwritten digit image is a black and white picture and only needs a single channel, in order to not lose generality and improve accuracy, we still uses three channels to convolve it, so three sets of different weights and convolutions are used for 25 sets of data separately, and three sets of convolution operation outputs are obtained.
     
**1st Maxpool_relu**  
`valid_in:` Connected to the valid output signal of the previous convolutional layer, the module performs two different operations according to the value of `valid_in`.
`conv_out_#:` Take the 3 12-bit convolution outputs of the previous convolutional layer as input data.
`max_value_#:` For each maximum pooling operation, the maximum value is selected from a range of (2, 2) in the feature map, and the final output is obtained after passing it through the ReLU function. Because there are 3 channels, there are 3 outputs. .
`valid_out_relu:` Connect to valid_in of Buffer in convolutional layer 2, as a control signal to control the operation of Buffer in convolutional layer 2

      Since the filter size is (2, 2), a pooling operation will compare a total of 2×2=4 input data values. Perform segmentation operation according to the two control signals of state and flag, first compare the two data in the first line in (2, 2), and load the larger value into the buffer; then put the second line in (2, 2) A number is compared with the value in the buffer, and the larger value is loaded into the buffer; finally, the last number in (2, 2) is compared with the value in the buffer, and the corresponding operation of ReLU is performed on the larger one, that is If it is a positive value, it will not change, if it is a negative value, let it be 0. Each time a 3-channel 2×2 pooling operation is performed, the output valid_out_relu is 1, and the pooling layer 1 performs a total of 12 3-channel 2×2 pooling operations.




