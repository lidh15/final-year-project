pos = 'F:/';
newFolder = [pos, 'Data/'];
% Fz F3 C3 Pz P3 P4 Cz C4 F4 
channels = [10, 8, 26, 46, 44, 48, 28, 30, 12];
fs = 500;
newType = 'h5';
dataFolders = dir(pos);
channelNum = length(channels);
for i = 1:length(dataFolders)
    folder = dataFolders(i).name;
    if length(folder)>14 && strcmp(folder(1:4), 'OCD ')
        id = [pos, folder, '/ID.xlsx'];
        %%%%%%% Octave
        pkg load io;
        pid = xlsread(id, 'Sheet1');
        nid = xlsread(id, 'Sheet2');
        dataPath = [pos, folder, '/Data/'];
        dataFiles = dir(dataPath);
        for j = 1:length(dataFiles)
            dataFile = dataFiles(j).name;
            if length(dataFile)>6 && strcmp(dataFile(end-3:end), '.mat')
                id = str2double(dataFile(1:3));
                if isempty(find(nid==id))
                    newId = ['P', sprintf('%02d', find(pid==id))];
                else
                    newId = ['N', sprintf('%02d', find(nid==id))];
                end
                rawData = load([dataPath, dataFile]).EEG;
                epochLen = size(rawData.data,2);
                epochs = size(rawData.data,3);
                stimuli = cell(epochs, 1);
                for k = 1:length(rawData.epoch)
                    stimuli{k, 1} = ['S', num2str(rawData.epoch(k).STIM)];
                end
                data = zeros(channelNum, epochLen, epochs, "single");
                data = rawData.data(channels, :, :);
                newFile = [newFolder, 'OCD_', newId, '.', 'Rein', ...
                    '1', sprintf('.%3d', epochs), 'epochs.', newType];
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