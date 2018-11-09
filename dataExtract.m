pos = 'F:/';
newFolder = [pos, 'Data/'];
% Fz F3 C3 Pz P3 P4 Cz C4 F4 
channels = [2, 3, 7, 11, 12, 17, 21, 22, 26];
downSample = 5;
newType = 'h5';
dataFolders = dir(pos);
newFiles = dir(newFolder);
channelNum = length(channels);
load('ONOFF.mat');
% [b, a] = cheby2(5, 20, [8 40]/250);
for i = 1:length(dataFolders)
    folder = dataFolders(i).name;
    if length(folder)>14 && strcmp(folder(1:9), 'Parkinson')
        Marker = 0;
        sessionPos = 0;
        newName = folder(11:14);
        if strcmp(newName, 'Conf')
            Marker = 751;
            sessionPos = 13;
        end
        if strcmp(newName, 'Oddb')
            Marker = 1001;
            sessionPos = 5;
        end
        if strcmp(newName, 'Rein')
            Marker = 3001;
            sessionPos = 13;
        end
        dataPath = [pos, folder, '/Data/'];
        dataFiles = dir(dataPath);
        for j = 1:length(dataFiles)
            dataFile = dataFiles(j).name;
            if length(dataFile)>14 && strcmp(dataFile(end-3:end), '.mat')
                id = str2double(dataFile(1:3));
                newId = '';
                Session = '';
                if id>889
                    newId = ['N', sprintf('%02d', id-889)];
                    Session = dataFile(sessionPos);
                else
                    if id>812
                        id = id - 1;
                    end
                    onoff = (id-801)*2+str2double(dataFile(sessionPos));
                    Session = num2str(ONOFF(onoff,3));
                    newId = ['P', sprintf('%02d', id-800)];
                end
                rawData = load([dataPath, dataFile]).EEG;
                epochLen = size(rawData.data,2);
                epochs = size(rawData.data,3);
                stimuli = cell(epochs, 1);
                epoch = 1;
                for k = 1:length(rawData.event)
                    if mod(rawData.event(k).latency, epochLen) == Marker
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
                newFile = [newFolder, newId, newName, ...
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
