import sys
sys.path.append('..')

import numpy as np
from PIL import Image

from BASNet.model import BASNet

import torch
import torchvision
import torch.nn as nn
import torch.nn.functional as f
from torch.autograd import Variable
from torchvision import transforms

from torch.utils.data import Dataset, DataLoader

from BASNet.data_loader import RescaleT
from BASNet.data_loader import ToTensorLab

import os
MODEL_DIR = 'BASNet/trained_models/basnet.pth'

print('>> Initializing BASNet..')
basnet = BASNet(3, 1)
basnet.load_state_dict(torch.load(MODEL_DIR))

if torch.cuda.is_available():
    print('>> CUDA Device detected..')
    basnet.cuda()
    print('>> Moved all model params and buffers to GPU..')

basnet.eval()
print('>> Set the module to evaluation mode.')

#* Normalize the input tensor
def normalize(d):
    maximum = torch.max(d)
    minimum = torch.min(d)

    return (d - minimum) / (maximum - minimum)

#* Preprocessing before feeding image to BASNet
def preprocess(image):
    label3 = np.zeros(image.shape)
    label  = np.zeros(label3.shape[0:2])

    if len(label3.shape) == 3:
        label = label3[:, :, 0]

    elif len(label3.shape) == 2:
        label = label3

    if len(image.shape) == 3 and len(label.shape) == 2:
        label = label[:, :, np.newaxis]
    
    elif len(image.shape) == 2 and len(label.shape) == 2:
        image = image[:, :, np.newaxis]
        label = label[:, :, np.newaxis]

    #* Applying rescaling and tensor conversion operation to input image
    transform = transforms.Compose([RescaleT(256), ToTensorLab(flag=0)])
    
    return transform({'image': image, 'label': label})


def run(image):
    torch.cuda.empty_cache()

    sample = preprocess(image)
    test_input = sample['image'].unsqueeze(0)
    test_input = test_input.type(torch.FloatTensor)

    if torch.cuda.is_available():
        test_input = Variable(test_input.cuda())
    
    else:
        test_input = Variable(test_input)

    d1, d2, d3, d4, d5, d6, d7, d8 = basnet(test_input)

    #* Normalization
    prediction = d1[:, 0, :, :]
    prediction = normalize(prediction)

    #* Conversion to PIL Image
    prediction = prediction.squeeze()
    prediction = prediction.cpu().data.numpy()
    image = Image.fromarray(prediction * 255).convert('RGB')

    #* Delete temporary variables
    del d1, d2, d3, d4, d5, d6, d7, d8
    
    return image