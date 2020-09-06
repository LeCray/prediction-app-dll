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

for i in range(x_test_count):
    test_seq = testing_seq[i]
    test_label = testing_label[i]
    inout_seq.append((test_seq ,test_label))


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
model.load_state_dict(torch.load('./rnn_model_v3.pth'))



for i in range(100):
    random.shuffle(inout_seq)
    correct = 0
    total = 0

    with torch.no_grad():
        for seq, label in inout_seq:
            y_pred = model(seq)
            #print("Prediction: ", round(y_pred.item(), 5), "|",  "Label: ", label.item())

            if y_pred >= 0.5:
                y_pred = 1
            else:
                y_pred = 0

            #print("Prediction: ", y_pred, ",",  "Label: ", label.item())

            if y_pred == label:
                correct += 1

            total += 1

    print("Correct: ", correct)
    print("Total: ", total)
    print("Accuracy:", round((100 * correct / total),2), "%")
    print("=================")
