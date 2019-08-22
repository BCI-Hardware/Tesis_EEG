# -*- coding: utf-8 -*-

import torch
import csv
import pandas as pd
import numpy as np

dtype = torch.float
#device = torch.device("cpu")
device = torch.device("cuda:0") # Uncomment this to run on GPU

# N is batch size; D_in is input dimension;
# H is hidden dimension; D_out is output dimension.
learning_rate = 1e-4
epochs =50000
N, D_in, H, D_out = 570, 570, 20, 2

# Load input and output data
data_id = 'type2_02_05_2019_22_49_08'
suffix = data_id + '_N' + str(H) + '_' + str(epochs) + '_' + str(learning_rate) + '_MANUAL_' + '.txt'
w1_file_name = 'output/w1_' + suffix
w2_file_name = 'output/w2_' + suffix

x0=torch.tensor(pd.read_csv('input_data/input_' + data_id + '.txt').values,device=device,dtype=dtype)
y0=torch.tensor(pd.read_csv('input_data/output_' + data_id + '.txt').values,device=device,dtype=dtype)

x = x0[:70, :]
y = y0[:70, :]

print(x.size())
print(y.size())

# Randomly initialize weights
w1 = torch.randn(D_in, H, device=device, dtype=dtype)
w2 = torch.randn(H, D_out, device=device, dtype=dtype)

## sigmoid activation function using pytorch
def sigmoid_activation(z):
    return 1 / (1 + torch.exp(-z))

## function to calculate the derivative of activation
def tanh_delta(x):
  return (1 - x.pow(2))

for t in range(epochs):
    # Forward pass: compute predicted y
    h1 = x.mm(w1)
    v1 = torch.tanh(h1)
    h2 = v1.mm(w2)
    y_pred = torch.tanh(h2)

    # Compute and print loss
    loss = (y - y_pred)
    print(t, loss.pow(2).sum().item())

    ## compute derivative of error terms
    delta_output = tanh_delta(y_pred)
    delta_hidden = tanh_delta(v1)

    ## backpass the changes to previous layers 
    d_outp = loss * delta_output
    loss_h = torch.mm(d_outp, w2.t())
    d_hidn = loss_h * delta_hidden

    # Update weights using gradient descent
    w2 += torch.mm(h1.t(), d_outp) * learning_rate
    w1 += torch.mm(x.t(), d_hidn) * learning_rate

np.savetxt(w1_file_name, w1.to("cpu").numpy(), delimiter=",")
np.savetxt(w2_file_name, w2.to("cpu").numpy(), delimiter=",")
np.savetxt('y_pred.txt', y_pred.to("cpu").numpy(), delimiter=",")
