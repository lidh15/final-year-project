pos = 'F:/';
newFolder = [pos, 'Data/'];
% Fz F3 C3 Pz P3 P4 Cz C4 F4 
channels = [10, 8, 26, 48, 46, 50, 28, 30, 12];
fs = 500;
newType = 'h5';
dataFolders = dir(pos);
channelNum = length(channels);
for i = 1:length(dataFolders)
    folder = dataFolders(i).name;
    if length(folder)>14 && strcmp(folder(1:11), 'Depression ')
        idFile = [pos, folder, '/ID.xlsx'];
        %%%%%%% Octave
        pkg load io;
        pid = xlsread(idFile, 'Sheet1');
        nid = xlsread(idFile, 'Sheet2');
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
                epochs = 0;
                for k = 2:length(rawData.event)
                    m = rawData.event(k).type;
                    if length(m) < 4
                        epochs = epochs + 1;
                    end
                end
                data = zeros(channelNum, fs, epochs, "single");
                stimuli = cell(epochs, 1);
                tmp = 'S   ';
                % hiconf_pos = [202 203 206 207 220 221];
                % hiconf_neg = [212 213 216 217 226 227];
                % loconf_pos = [204 205 208 209];
                % loconf_neg = [210 211 214 215];
                epoch = 1;
                for k = 2:length(rawData.event)
                    m = rawData.event(k).type;
                    if length(m) < 4
                        begin = rawData.event(k).latency;
                        data(:, :, epoch) = rawData.data(channels, begin:begin+fs-1);
                        stimuli{epoch, 1} = [tmp(1:4-length(m)), m];
                        epoch = epoch + 1;
                    end
                end
                newFile = [newFolder, 'Depr', newId, '.', 'Rein', ...
                    '1', sprintf('.%03d', epochs), 'epochs.', newType];
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