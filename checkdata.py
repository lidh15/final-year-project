# -*- coding: utf-8 -*-
"""
Created on Sat Nov  3 21:52:26 2018

@author: user
"""

import os
import numpy as np

dataPath = './Data.npz/'
dataFiles = os.listdir(dataPath)
channels = 9
# I think this is fine but I'm not sure if this is a best threshold.
threshold = 1e3 
total_pieces = 0
outliers = []
epoch_outliers = []
#Vars = []
for dataFile in dataFiles:
    if dataFile.endswith('.npz'):
        npzFile = np.load(dataPath+dataFile)
        data = npzFile['data']
        stim = npzFile['stim']
        for i in range(data.shape[0]):
            if ('rein' in dataFile and 'depr' in dataFile and \
                ((not 9 < int(stim[i]) < 230)) or int(stim[i]) == 110) or \
                ('conf' in dataFile and 'schi' in dataFile and \
                (0 < int(stim[i]) < 6 or 100 < int(stim[i]) < 106)):
                    for j in range(channels):
                        # print(dataFile, i, j)
                        epoch_outliers.append(dataFile+' '+str(i)+'-'+str(j))
            else:
                for j in range(channels):
                    total_pieces += 1
                    sampleVar = np.var(data[i, j])
                    if sampleVar > threshold:
                        # print(dataFile, i, j)
                        epoch_outliers.append(dataFile+' '+str(i)+'-'+str(j))
        npzFile.close()

outliers = list(set([epoch.split('-')[0]+'\n' for epoch in epoch_outliers]))
outliers.sort()
with open('outliers.txt', 'w') as f:
    f.writelines(outliers)
outliersFiles = {}
for dataFile in set([outlier.split(' ')[0] for outlier in outliers]):
    outliersFiles[dataFile] = []
for outlier in outliers:
    outliersplit = outlier.split(' ')
    outliersFiles[outliersplit[0]].append(int(outliersplit[1]))
    
for dataFile in outliersFiles:
    npzFile = np.load(dataPath+dataFile)
    all_epochs = set(range(int(dataFile.split('.')[2][:3])))
    corrupted = set(outliersFiles[dataFile])
    used_epochs = list(all_epochs-corrupted)
    used_epochs.sort()
    data = npzFile['data'][used_epochs]
    spec = npzFile['spec'][used_epochs]
    stim = npzFile['stim'][used_epochs]
    npzFile.close()
    np.savez(dataPath+dataFile, data=data, spec=spec, stim=stim)
    if used_epochs:
        newFile = dataFile[:14]+('%03d'%len(used_epochs))+dataFile[-10:]
        os.rename(dataPath+dataFile, dataPath+newFile)
    else:
        os.remove(dataPath+dataFile)

stims = {}
for dataFile in os.listdir(dataPath):
    npzFile = np.load(dataPath+dataFile)
    stims[dataFile] = list(set([str(s) for s in npzFile['stim']]))
    npzFile.close()

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
