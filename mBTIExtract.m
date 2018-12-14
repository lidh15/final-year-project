pos = 'F:/';
newFolder = [pos, 'Data/'];
% Fz F3 C3 Pz P3 P4 Cz C4 F4 
channels = [2, 3, 7, 11, 12, 17, 21, 22, 26];
% downSample = 5;
newType = 'h5';
dataFolders = dir(pos);
channelNum = length(channels);
for i = 1:length(dataFolders)
    folder = dataFolders(i).name;
    if length(folder)>14 && strcmp(folder(1:4), 'mBTI')
        dataPath = [pos, folder, '/Data/'];
        dataFiles = dir(dataPath);
        cBTICount = 0;
        Marker = 1001;
        for j = 1:length(dataFiles)
            dataFile = dataFiles(j).name;
            if length(dataFile)>14 && strcmp(dataFile(end-3:end), '.mat')
                if strcmp(dataFile(end-13:end-9), 'QUINN')
                    group = 2;
                    tmp = 'c';
                    Session = '1';
                    cBTICount = cBTICount+1;
                    newId = ['P', sprintf('%02d', cBTICount)];
                else
                    id = str2double(dataFile(3:4));
                    group = 1-mod(id,2);
                    tmp = 'm';
                    Session = dataFile(6);
                    str2double(dataFile(3:4));
                    if group
                        newId = ['P', sprintf('%02d', id/2)];
                    else
                        newId = ['N', sprintf('%02d', (id+1)/2)];
                    end
                end
                rawData = load([dataPath, dataFile]).EEG;
                epochLen = size(rawData.data,2);
                epochs = size(rawData.data,3);
                stimuli = cell(epochs, 1);
                epoch = 1;
                for k = 1:length(rawData.event)
                    if mod(rawData.event(k).latency, epochLen) == Marker && ...
                        rawData.event(k).type(1) == 'S'
                        stimuli{epoch, 1} = rawData.event(k).type;
                        epoch = epoch + 1;
                    end
                end
                data = zeros(channelNum, epochLen, epochs, "single");
                data = rawData.data(channels, :, :);
                %%Do this later with Python
                % for k = 1:channelNum
                %     for l = 1:epochs
                %         data(k,:,l) = filter(b, a, data(k,:,l));
                %     end
                % end
                % data = data(:, 1:downSample ...
                %     :epochLen-downSample+mod(epochLen, downSample)+1, :);
                newFile = [newFolder, tmp, 'BTI', newId, '.', 'Oddb', ...
                    Session, sprintf('.%03d', epochs), 'epochs.', newType];
                disp(newFile);
                if strcmp(newType, 'h5')
                    save('-float-hdf5', newFile, 'data', 'stimuli');
                end
                if strcmp(newType, 'mat')
                    save(newFile, 'data', 'stimuli');
                end
                clear('rawData', 'data', 'stimuli');
            end
        end
    end
end
