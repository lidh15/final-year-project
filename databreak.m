datapath = 'D:\Data\';
targetpath = 'F:\Databreak\';
% Ppath = [targetpath,]
flist = dir(datapath);
saved = zeros(9,2000);
for i = 1:length(flist)
    fname = flist(i).name;
    if endsWith(fname,'.mat')
        load([datapath,fname]);
        for j = 1:length(stimuli)            
            saved(:,:) = data(:,:,j); 
            newFile = [targetpath, fname(1:3),'_ses',fname(8),'_', stimuli{j},'_E',num2str(j),'.mat'];
            save(newFile,'saved');
        end
    end
end