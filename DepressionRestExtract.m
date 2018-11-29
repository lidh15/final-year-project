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
        dataPath = [pos, folder, '/Rest/'];
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
                ind = zeros(6,3);
                flag = 0;
                for k = 1:100
                    n = num2str(rawData.event(k).type);
                    if strcmp(n, '17')
                        flag = 1;
                    end
                end
                flag = 1-flag;
                for k = 1:length(rawData.event)
                    n = num2str(rawData.event(k).type);
                    if strcmp(n, '17')
                        flag = 1;
                    end
                    if flag && length(n) < 3
                        m = str2double(n(end));
                        if m < 7 && m > 0
                            if ind(m, 1) == 0
                                ind(m, 1) = rawData.event(k).latency;
                                ind(:, 3) = double(ind(:, 2)==0);
                            else 
                                if ind(m, 3)
                                    ind(m, 2) = rawData.event(k).latency;
                                end
                            end
                        end
                    end
                end
                for k = 1:6
                    ind(k, 3) = floor((ind(k, 2)-ind(k, 1))/fs);
                end
                epochs = ind(1, 3)+ind(3, 3)+ind(5, 3);
                data = zeros(channelNum, fs, epochs, "single");
                stimuli = cell(epochs, 1);
                tmp = 'S  3';
                epoch = 1;
                for k = 1:2:5
                    if ind(k, 3) > 0
                        for l = 0:ind(k, 3)-1
                            begin = ind(k, 1)+l*fs;
                            data(:, :, epoch) = rawData.data(channels, begin:begin+fs-1);
                            stimuli{epoch, 1} = tmp;
                            epoch = epoch + 1;
                        end
                    end
                end
                newFile = [newFolder, 'Depr', newId, '.', 'Rest', ...
                    '1', sprintf('.%03d', epochs), 'epochs.', newType];
                disp(newFile);
                if strcmp(newType, 'h5')
                    save('-float-hdf5', newFile, 'data', 'stimuli');
                end
                if strcmp(newType, 'mat')
                    save(newFile, 'data', 'stimuli');
                end
                clear('data', 'stimuli');
                epochs = ind(2, 3)+ind(4, 3)+ind(6, 3);
                data = zeros(channelNum, fs, epochs, "single");
                stimuli = cell(epochs, 1);
                tmp = 'S  1';
                epoch = 1;
                for k = 2:2:6
                    if ind(k, 3) > 0
                        for l = 0:ind(k, 3)-1
                            begin = ind(k, 1)+l*fs;
                            data(:, :, epoch) = rawData.data(channels, begin:begin+fs-1);
                            stimuli{epoch, 1} = tmp;
                            epoch = epoch + 1;
                        end
                    end
                end
                newFile = [newFolder, 'Depr', newId, '.', 'Rest', ...
                    '0', sprintf('.%03d', epochs), 'epochs.', newType];
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