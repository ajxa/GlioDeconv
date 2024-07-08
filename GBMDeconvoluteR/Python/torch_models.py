import torch
import torch.nn as nn
import torch.nn.functional as F


class MLP2h(nn.Module):
    def __init__(self, input_size, h1=512, h2=256, p_dropout=0):
        super(MLP2h, self).__init__()
        self.fc1 = nn.Linear(input_size, h1)
        self.fc2 = nn.Linear(h1, h2)
        self.out = nn.Linear(h2, 1)
        self.dropout = nn.Dropout(p_dropout)
        
    def forward(self, x):
        x = self.dropout(x)
        x = self.fc1(x)
        x = F.relu(x)
        x = self.fc2(x)
        x = F.relu(x)
        x = self.out(x)
        return x
    