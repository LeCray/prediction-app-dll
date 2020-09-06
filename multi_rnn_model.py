import torch
import numpy as np
import torch.nn as nn
import torch.nn.functional as F
import sklearn
from sklearn.metrics import accuracy_score
from numpy import loadtxt, savetxt, array, hstack
import random

features_dataset = np.genfromtxt('Data/FeaturesBuyData.csv', delimiter=',') #Make sure to save the csv as a csv file again in MS Excel
labels_dataset = np.genfromtxt('Data/LabelsBuyData.csv', delimiter=',') #Make sure to save the csv as a csv file again in MS Excel
PATH = "./"

row_count = sum(1 for row in features_dataset)

x = list()
for i in range(0,row_count,2):
    seq_x1 = features_dataset[i,:-1]
    seq_x2 = features_dataset[i+1,:-1]

    seq_x1 = seq_x1.reshape((len(seq_x1), 1))
    seq_x2 = seq_x2.reshape((len(seq_x2), 1))

    seq_x = hstack((seq_x1, seq_x2))
    x.append(seq_x)

x = array(x)

y = labels_dataset[:]
y = y.reshape(len(y), 1)

#Converting arrays to Tensors
x = torch.from_numpy(x).type(torch.FloatTensor)
y = torch.from_numpy(y).type(torch.LongTensor)

x_count = sum(1 for row in x)

training_seq = x[0:round(x_count*0.7),]
testing_seq = x[round(x_count*0.7):x_count,:]

x_train_count = sum(1 for row in training_seq)
x_test_count = sum(1 for row in testing_seq)

training_label = y[0:x_train_count].squeeze()
testing_label = y[x_train_count:].squeeze()

#print(len(training_label))
#print(len(testing_label))

inout_seq = []

for i in range(x_train_count):
    train_seq = training_seq[i]
    train_label = training_label[i]
    inout_seq.append((train_seq ,train_label))

#print(inout_seq[0])
#print(inout_seq[1])
#print(inout_seq[2])

class LSTM(nn.Module): #My new LSTM class inherits methods and functions from nn.Module.
    def __init__(self, input_size=2, hidden_layer_size=10, output_size=1): #hidden_layer_size = sequence length.
        super().__init__()                                                  #i.e. how many hidden states are created.
        self.hidden_layer_size = hidden_layer_size

        self.lstm = nn.LSTM(input_size, hidden_layer_size)

        self.linear = nn.Linear(hidden_layer_size, output_size) #Fully connected layer maps output of LSTM layer to desired
                                                                #output size.
        self.hidden_cell = (torch.zeros(1,1,self.hidden_layer_size), torch.zeros(1,1,self.hidden_layer_size))


    def forward(self, input_seq):
        lstm_out, self.hidden_cell = self.lstm(input_seq.view(len(input_seq) ,1, -1), self.hidden_cell)
        predictions = self.linear(lstm_out.view(len(input_seq), -1))
        return predictions[-1]

model = LSTM()
#model.load_state_dict(torch.load('./rnn_model.pth'))
loss_function = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

epochs = 100

for i in range(epochs):
    for seq, labels in inout_seq:

        #model.hidden_cell needs to be defined for backwards pass. I don't know why.
        model.hidden_cell = (torch.zeros(1,1,model.hidden_layer_size), torch.zeros(1,1,model.hidden_layer_size))

        # zero the parameter gradients
        optimizer.zero_grad()

        # forward + backward + optimize
        y_pred = model(seq)
        single_loss = loss_function(y_pred.squeeze(), labels.float())
        single_loss.backward()
        optimizer.step()

        #running_loss += loss.item()

    if i%2 == 1:
        print(f'epoch: {i:3} loss: {single_loss.item():10.8f}')

#print(f'epoch: {i:3} loss: {single_loss.item():10.10f}')

print("Saving model...")
torch.save(model.state_dict(), './rnn_model_v4.pth')
print("Done.")
