# -*- coding: utf-8 -*-
"""
Created on Sat Nov  3 15:07:09 2018

@author: user
"""

from h5py import File
from os import listdir
from numpy import asarray, savez, zeros
from scipy.signal import cheby2, cheb2ord, filtfilt, decimate


dataPath = './Data/'
h5Files = listdir(dataPath)
fs = 500
N, Wn = cheb2ord([4*2/fs, 35*2/fs], [3.5*2/fs, 45*2/fs], 3, 20)
b, a = cheby2(N, 20, Wn, 'bandpass')
downSample = 5
for h5File in h5Files:
    if h5File.endswith('.h5'):
        h5 = File(dataPath+h5File, 'r')
        h5data = h5['data/value']
        rawData = asarray(h5data, dtype='float32')
        chans = rawData.shape[2]
        epochs = rawData.shape[0]
        data = zeros((epochs, chans, int(rawData.shape[1]/downSample)), \
                dtype='float32')
        stimuli = []
        for i in range(epochs):
            for j in range(chans):
                data[i, j] = decimate(filtfilt(b, a, rawData[i, :, j]), downSample)
            tmp = ''
            if epochs < 100:
                tmpstr = 'stimuli/value/_%02d/value'%i
            elif epochs < 1000:
                tmpstr = 'stimuli/value/_%03d/value'%i
            else:
                tmpstr = 'stimuli/value/_%04d/value'%i
            for char in h5[tmpstr]:
                tmp += chr(char)
            stimuli.append(tmp[1:])
        h5.close()
        savez(dataPath+h5File[:-3].lower(), data=data, stimuli=stimuli)
        # break