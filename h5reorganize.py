# -*- coding: utf-8 -*-
"""
Created on Sat Nov  3 15:07:09 2018

@author: user
"""

from h5py import File
from os import listdir
from numpy import asarray, savez
from scipy.signal import cheby2, cheb2ord, filtfilt


dataPath = './Data/'
h5Files = listdir(dataPath)
fs = 100
N, Wn = cheb2ord([8*2/fs, 40*2/fs], [7*2/fs, 45*2/fs], 3, 20)
b, a = cheby2(N, 20, Wn, 'bandpass')
for h5File in h5Files:
    if h5File.endswith('.h5'):
        h5 = File(dataPath+h5File, 'r')
        h5data = h5['data/value']
        data = asarray(h5data, dtype='float32')
        epochs = data.shape[0]
        stimuli = []
        for i in range(epochs):
            for j in range(data.shape[2]):
                data[i,:,j] = filtfilt(b, a, data[i,:,j])
            tmp = ''
            if epochs<100:
                tmpstr = 'stimuli/value/_%02d/value'%i
            elif epochs<1000:
                tmpstr = 'stimuli/value/_%03d/value'%i
            else:
                tmpstr = 'stimuli/value/_%04d/value'%i
            for char in h5[tmpstr]:
                tmp += chr(char)
            stimuli.append(tmp[1:])
        h5.close()
        savez(dataPath+h5File[:-3].lower(), data=data, stimuli=stimuli)
