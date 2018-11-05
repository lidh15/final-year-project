# -*- coding: utf-8 -*-
"""
Created on Sat Nov  3 21:52:26 2018

@author: user
"""

from os import listdir
import numpy as np

dataPath = './Data/'
dataFiles = listdir(dataPath)
channels = 7
dataLen = {'rein':800,'conf':650,'oddb':400}
outliers = 5000
dataVar = []
for i in range(channels):
    dataVar.append([])
for dataFile in dataFiles:
    if dataFile.endswith('.npz'):
        npzFile = np.load(dataPath+dataFile)
        data = npzFile['data']
#        print(np.min(data),np.max(data))
        for i in range(data.shape[0]):
            for j in range(channels):
                sampleVar = np.var(data[i,:,j])
                if sampleVar > outliers:
                    print(dataFile,i)
                    break
                else:
                    dataVar[j].append(sampleVar)
        npzFile.close()

#dataVar = np.asarray(dataVar)
#np.save('dataVar.npy', dataVar)

## p23 conflict task 1 epoch 51,52,53,54 will be dprecated.
#data = np.load(dataPath+'p23conf1.912epochs.npz')
#newdata = np.zeros((908,dataLen['conf'],channels),dtype='float32')
#newdata[:51] = data['data'][:51]
#newdata[51:] = data['data'][55:]
#newstimuli = [str(sti) for sti in data['stimuli'][:51]]
#_ = [newstimuli.append(str(sti)) for sti in data['stimuli'][55:]]
#np.savez(dataPath+'p23conf1.908epochs.npz', data=newdata,stimuli=newstimuli)
#data.close()

## Noise Simulation
#from scipy.interpolate import interp1d
#lenMin = 50
#lenMax = 350
#interpSigma = 100
#
#lenSample = lenMin+np.random.randint(1)*(lenMax-lenMin)
#interpEqu = interp1d([0,lenSample/2,lenSample],\
#                     np.random.randn(3)*interpSigma,\
#                     kind='quadratic')
#interpSample = interpEqu(np.linspace(1,lenSample,lenSample))
