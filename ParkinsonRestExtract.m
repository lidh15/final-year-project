pos = 'F:/';
newFolder = [pos, 'Data/'];
% Fz F3 C3 Pz P3 P4 Cz C4 F4 
channels = [2, 3, 8, 13, 14, 19, 24, 25, 30];
fs = 500;
newType = 'h5';
dataFolders = dir(pos);
newFiles = dir(newFolder);
channelNum = length(channels);
for i = 1:length(dataFolders)
    folder = dataFolders(i).name;
    if length(folder)>14 && strcmp(folder(1:11), 'Parkinson O')
        load([pos, folder, '/ONOFF.mat']);
        dataPath = [pos, folder, '/Rest/'];
        dataFiles = dir(dataPath);
        for j = 1:length(dataFiles)
            dataFile = dataFiles(j).name;
            if length(dataFile)>14 && strcmp(dataFile(end-3:end), '.mat')
                id = str2double(dataFile(1:3));
                newId = '';
                Session = '';
                if id>889
                    newId = ['N', sprintf('%02d', id-889)];
                    Session = dataFile(5);
                else
                    if id>812
                        id = id - 1;
                    end
                    onoff = (id-801)*2+str2double(dataFile(5));
                    Session = num2str(ONOFF(onoff,3));
                    newId = ['P', sprintf('%02d', id-800)];
                end
                rawData = load([dataPath, dataFile]).EEG;
                epoch = 1;
                epochs = length(rawData.event)-1;
                epoch0 = 1;
                if id == 896
                    epochs = epochs-3;
                    epoch0 = 4;
                % else
                %     continue
                end
                stimuli = cell(epochs, 1);
                data = zeros(channelNum, fs, epochs, "single");
                for epoch = 1:epochs
                    begin = rawData.event(epoch+epoch0).latency;
                    stimuli{epoch, 1} = rawData.event(epoch+epoch0).type;
                    data(:, :, epoch) = rawData.data(channels, begin:begin+fs-1);
                end
                newFile = [newFolder, 'Park', newId, '.', 'Rest', ...
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
