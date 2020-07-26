import torch
import numpy as np
import torch.nn as nn
import torch.nn.functional as F
import sklearn
from sklearn.metrics import accuracy_score
from numpy import loadtxt, savetxt
import random

dataset = np.genfromtxt('Data/SequenceBuyData.csv', delimiter=',') #Make sure to save the csv as a csv file again in MS Excel
PATH = "./"

row_count = sum(1 for row in dataset)

trainingData = dataset[0:round(row_count*0.7),]
testingData = dataset[round(row_count*0.7):row_count,:]

train_window = 100 #tw

training_seq = trainingData[:,0:99]
training_label = trainingData[:,100]
testing_seq = testingData[:,0:99]
testing_label = testingData[:,100]

#Converting arrays to Tensors
training_seq = torch.from_numpy(training_seq).type(torch.FloatTensor)
training_label = torch.from_numpy(training_label).type(torch.LongTensor)

testing_seq = torch.from_numpy(testing_seq).type(torch.FloatTensor)
testing_label = torch.from_numpy(testing_label).type(torch.LongTensor)

inout_seq = []
l = len(trainingData)
for i in range(l):
    train_seq = training_seq[i]
    train_label = training_label[i]
    inout_seq.append((train_seq ,train_label))


#print(inout_seq[:1])

class LSTM(nn.Module): #My new LSTM class inherits methods and functions from nn.Module.
    def __init__(self, input_size=1, hidden_layer_size=100, output_size=1): #hidden_layer_size = sequence length.
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
loss_function = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.001)

epochs = 30

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
torch.save(model.state_dict(), './rnn_model.pth')
print("Done.")
