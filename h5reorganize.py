# -*- coding: utf-8 -*-
"""
Created on Sat Nov  3 15:07:09 2018

@author: user
"""

from h5py import File
from os import listdir
import numpy as np
import scipy.signal as ss


dataPath = './Data/'
newPath = './Data.npz/'
h5Files = listdir(dataPath)
fs = 500
fl = 4
fh = 36
ext = .9
N, Wn = ss.cheb2ord([fl*2/fs, fh*2/fs], [fl*ext*2/fs, fh/ext*2/fs], 3, 20)
b, a = ss.cheby2(N, 40, Wn, 'bandpass')
downSample = 5
fsamples = 9
W = 9
padded = fs+4
c = np.log(np.linspace(fl+1, fh, fh-fl)/np.linspace(fl, fh-1, fh-fl)) \
    /np.log(fh/fl)*fsamples
w = np.zeros((fsamples, fh-fl))
w[0, 0] = c[0]
row = 0
for i in range(1, len(c)-1):
    if np.sum(c[:i+1]) > row+1:
        row += 1
        w[row-1, i] = row-np.sum(c[:i])
        w[row, i] = np.sum(c[:i+1])-row
    else:
        w[row, i] = c[i]
w[-1, -1] = c[-1]
for h5File in h5Files:
    if h5File.endswith('.h5'):
        try:
            h5 = File(dataPath+h5File, 'r')
            if 'Schi' in h5File or 'Depr' in h5File or 'Rest' in h5File:
                trigger = 0
            elif 'OCD_' in h5File or 'Oddb' in h5File:
                trigger = 1000
            elif 'Conf' in h5File:
                trigger = 750
            else:
                trigger = 3000
            h5data = h5['data/value']
            rawData = np.asarray(h5data, dtype='float32')
            chans = rawData.shape[2]
            epochs = rawData.shape[0]
            data = np.zeros((epochs, chans, int(fs/downSample)), \
                    dtype='float32')
            spec = np.zeros((epochs, chans, W, fsamples), \
                    dtype='float32')
            stim = []
            pad = np.zeros(padded)
            for i in range(epochs):
                for j in range(chans):
                    rmmean = rawData[i, :, j]-np.mean(rawData[i, :, j])
                    filted = ss.filtfilt(b, a, rmmean)[trigger:trigger+fs]
                    data[i, j] = ss.decimate(filted, downSample)           
                    pad[2:-2] = filted
                    for k in range(W):
                        spec[i, j, k] = np.dot(w, \
                            np.abs(np.fft.fft(pad[k*54:k*54+72]))[fl:fh])
                tmp = ''
                if epochs < 100:
                    tmpstr = 'stimuli/value/_%02d/value'%i
#                elif epochs > 1000:
#                    tmpstr = 'stimuli/value/_%04d/value'%i
                else:
                    tmpstr = 'stimuli/value/_%03d/value'%i
                for char in h5[tmpstr]:
                    tmp += chr(char)
                stim.append(tmp[1:])
            np.savez(newPath+h5File[:-3].lower(), data=data, spec=spec, stim=stim)
            print(h5File[:-3].lower())
            # break
        except:
            print(h5File[:-3].lower()+' Failed!')
            continue
        finally:
            h5.close()
