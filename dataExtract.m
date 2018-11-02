pos = 'F:/';
% Fz FC1 Cz FC2 FCz C1 C2
channels = [2, 7, 24, 29, 40, 41, 57];
downSample = 5;
dataFolders = dir(pos);
newFolder = [pos, 'Data/'];
newFiles = dir(newFolder);
for i = 1:length(dataFolders)
    folder = dataFolders(i).name;
    if length(folder)>14 && strcmp(folder(1:9), 'Parkinson')
        Marker = 0;
        Session = 0;
        newName = folder(11:14);
        if strcmp(newName, 'Conf')
            Marker = 751;
            Session = 13;
        end
        if strcmp(newName, 'Oddb')
            Marker = 1001;
            Session = 5;
        end
        if strcmp(newName, 'Rein')
            Marker = 3001;
            Session = 13;
        end
        dataPath = [pos, folder, '/Data/'];
        dataFiles = dir(dataPath);
        for j = 1:length(dataFiles)
            dataFile = dataFiles(j).name;
            if length(dataFile)>14 && strcmp(dataFile(end-3:end), '.mat')
                id = str2double(dataFile(1:3));
                newId = '';
                if strcmp(newName, 'Conf') && id < 903
                    continue
                end
                if id>889
                    newId = ['N', sprintf('%02d', id-889)];
                elseif id>812
                    newId = ['P', sprintf('%02d', id-801)];
                else
                    newId = ['P', sprintf('%02d', id-800)];
                end
                rawData = load([dataPath, dataFile]).EEG;
                data = rawData.data;
                epochLen = size(data,2);
                epochs = size(data,3);
                stimuli = cell(epochs, 1);
                epoch = 1;
                for k = 1:length(rawData.event)
                    if mod(rawData.event(k).latency, epochLen) == Marker
                        stimuli{epoch, 1} = rawData.event(k).type;
                        epoch = epoch + 1;
                    end
                end
                data = data(channels, 1:downSample ...
                    :epochLen-downSample+mod(epochLen, downSample)+1,:);
                newFile = [newFolder, newId, newName, ...
                    dataFile(Session), sprintf('.%3d', epochs), 'epochs.h5'];
                disp(newFile);
                save('-float-hdf5', newFile, 'data', 'stimuli');
                clear('rawData', 'data', 'stimuli');
            end
        end
    end
end
