import torch
import torch.nn as nn

inputs = torch.Tensor(1, 1, 28, 28)
print('张量大小 : {}'.format(inputs.shape))

conv1 = nn.Conv2d(1, 32, 3, padding=1)
print('First Convolution Shape')
print(conv1)

conv2 = nn.Conv2d(32, 64, kernel_size=3, padding=1)
print('Second Convolution Shape')
print(conv2)

pool = nn.MaxPool2d(2)
print('Max Pooling Shape')
print(pool)

out = conv1(inputs)
print('First Convolution Output Data Shape')
print(out.shape)

out = pool(out)
print('First Max Pooling Output Data Shape')
print(out.shape)

out = conv2(out)
print('Second Convolution Output Data Shape')
print(out.shape)

out = pool(out)
print('Second Max Pooling Output Data Shape')
print(out.shape)

out = out.view(out.size(0), -1) 
print('Flatten Output Data Shape')
print(out.shape)

fc = nn.Linear(3136, 10) # input_dim = 3,136, output_dim = 10
out = fc(out)
print('FC Output Data Shape')
print(out.shape)
