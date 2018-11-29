pos = 'F:/';
newFolder = [pos, 'Data/'];
% Fz F3 C3 Pz P3 P4 Cz C4 F4 
channels = [2, 3, 8, 13, 14, 19, 24, 25, 30];
fs = 500;
newType = 'h5';
dataFolders = dir(pos);
channelNum = length(channels);
for i = 1:length(dataFolders)
    folder = dataFolders(i).name;
    if length(folder)>14 && strcmp(folder(1:13), 'Schizophrenia')
        dataPath = [pos, folder, '/Data/'];
        dataFiles = dir(dataPath);
        for l = 1:length(dataFiles)
            dataFile = dataFiles(l).name;
            if length(dataFile)>14 && strcmp(dataFile(end-3:end), '.mat')
                rawData = load([dataPath, dataFile]).EEG;
                ind = zeros(3,2);
                ind(1,1) = 2;
                indind = 1;
                for j = 2:length(rawData.event)-1
                    m = rawData.event(j+1).type;
                    if strcmp(rawData.event(j).type,'boundary') && strcmp(m,'boundary')
                        ind(indind,2) = j-1;
                        indind = indind + 1;
                        ind(indind,1) = j+2;
                    end
                    if indind == 3
                        break;
                    end
                end
                ind(indind,2) = length(rawData.event);
                if dataFile(end-4)=='P'
                    newId = ['P', dataFile(end-7:end-6)];
                else
                    newId = ['N', sprintf('%02d', str2double(dataFile(end-7:end-6))-48)];
                end
                for j = 1:2
                    epochs = ind(j,2)-ind(j,1)+1;
                    data = zeros(channelNum, fs, epochs, "single");
                    stimuli = cell(epochs, 1);
                    epoch = 1;
                    for k = ind(j,1):ind(j,2)
                        begin = rawData.event(k).latency;
                        data(:, :, epoch) = rawData.data(channels, begin:begin+fs-1);
                        stimuli{epoch, 1} = sprintf('S%3d', rawData.event(k).type);
                        epoch = epoch + 1;
                    end
                    newFile = [newFolder, 'Schi', newId, '.', 'Conf', ...
                        num2str(j), sprintf('.%03d', epochs), 'epochs.', newType];
                    disp(newFile);
                    if strcmp(newType, 'h5')
                        save('-float-hdf5', newFile, 'data', 'stimuli');
                    end
                    if strcmp(newType, 'mat')
                        save(newFile, 'data', 'stimuli');
                    end
                    clear('data', 'stimuli');
                end
                if indind == 3
                    epochs = ind(3,2)-ind(3,1)+1;
                    data = zeros(channelNum, fs, epochs, "single");
                    stimuli = cell(epochs, 1);
                    epoch = 1;
                    for k = ind(3,1):ind(3,2)
                        begin = rawData.event(k).latency;
                        data(:, :, epoch) = rawData.data(channels, begin:begin+fs-1);
                        stimuli{epoch, 1} = 'S  1';
                        epoch = epoch + 1;
                    end
                    newFile = [newFolder, 'Schi', newId, '.', 'Rest', ...
                        '1', sprintf('.%03d', epochs), 'epochs.', newType];
                    disp(newFile);
                    if strcmp(newType, 'h5')
                        save('-float-hdf5', newFile, 'data', 'stimuli');
                    end
                    if strcmp(newType, 'mat')
                        save(newFile, 'data', 'stimuli');
                    end
                    clear('rawData', 'data', 'stimuli');
                else
                    clear('rawData');
                end
            end
        end
    end
end