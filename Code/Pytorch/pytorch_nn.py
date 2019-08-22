import torch
import csv
import pandas as pd
import numpy as np
import random

dtype = torch.float
#device = torch.device("cpu")
device = torch.device("cuda:0") # Uncomment this to run on GPU

# N is batch size; D_in is input dimension;
# H is hidden dimension; D_out is output dimension.
N, D_in, H, D_out = 500, 500, 2, 2
learning_rate = 1e-4
epochs =10000

# Load input and output data
data_id = '19_06_2019_00_48_39' #'02_05_2019_22_49_08'
suffix = data_id + '_N' + str(H) + '_' + str(epochs) + '_' + str(learning_rate) + '.txt'
w1_file_name = 'output/w1_' + suffix
w2_file_name = 'output/w2_' + suffix
bias1_file_name = 'output/bias1_' + suffix
bias2_file_name = 'output/bias2_' + suffix
train_indices_file_name = 'output/train_indices_' + suffix
test_indices_file_name = 'output/test_indices_' + suffix

x0=torch.tensor(pd.read_csv('input_data/input_type2_' + data_id + '.txt', header=None).values,device=device,dtype=dtype)
y0=torch.tensor(pd.read_csv('input_data/output_type2_' + data_id + '.txt', header=None).values,device=device,dtype=dtype)

total_samples = x0.size()[0];
indices = list(range(total_samples));
random.shuffle(indices);

train_length = int(round(total_samples * 0.7));
train_indices = indices[:train_length];
test_indices = indices[train_length:];

x=x0[train_indices, :]
y=y0[train_indices, :]

# Use the nn package to define our model and loss function.
model = torch.nn.Sequential(
          torch.nn.Linear(D_in, H),
          torch.nn.ReLU(),
          torch.nn.Linear(H, D_out),
          torch.nn.ReLU(),
        )
loss_fn = torch.nn.MSELoss(reduction='sum')

# Use the optim package to define an Optimizer that will update the weights of
# the model for us. Here we will use Adam; the optim package contains many other
# optimization algoriths. The first argument to the Adam constructor tells the
# optimizer which Tensors it should update.


model.cuda()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
for t in range(epochs):
    
  if t==0 or t== epochs-1:
     print("HERE")
     
  # Forward pass: compute predicted y by passing x to the model.
  y_pred = model(x)

  # Compute and print loss.
  loss = loss_fn(y_pred, y)
  print(t, loss.item())
  
  # Before the backward pass, use the optimizer object to zero all of the
  # gradients for the Tensors it will update (which are the learnable weights
  # of the model)
  optimizer.zero_grad()

  # Backward pass: compute gradient of the loss with respect to model parameters
  loss.backward()

  # Calling the step function on an Optimizer makes an update to its parameters
  optimizer.step()
  

"""
with torch.no_grad():
  np.savetxt('y_pred_type2_Adam_1e4_N30_1e-4.txt', y_pred.to("cpu").numpy(), delimiter=",")
  np.savetxt(w1_file_name, model[0].weight.to("cpu").numpy(), delimiter=",")
  np.savetxt(bias1_file_name, model[0].bias.to("cpu").numpy(), delimiter=",")
  np.savetxt(w2_file_name, model[2].weight.to("cpu").numpy(), delimiter=",")
  np.savetxt(bias2_file_name, model[2].bias.to("cpu").numpy(), delimiter=",")
 
  np.savetxt(train_indices_file_name, train_indices, delimiter=",")
  np.savetxt(test_indices_file_name, test_indices, delimiter=",")
"""