function dsnames = getnames
%DATASETS.GETNAMES Get a cell with the names of the data sets available in
%the TimeBox local repository. Please refer to TS.SAVE to save data sets
%into the TimeBox local repository.


% TEMPORARY:
% Work with only the RP data sets
dsnames = {'ArrowHead', 'BeetleFly', 'BirdChicken', 'Car', 'Computers', 'DistalPhalanxOutlineAgeGroup', 'DistalPhalanxTW', 'Herring', 'Meat', 'Plane', 'ToeSegmentation1', 'ToeSegmentation2', 'Wine', 'Worms', 'WormsTwoClass'};


path = tb.getdspath;
files = dir(path);

nds = 0;
dsnames = {};

for i = 1:size(files, 1)
    f = files(i).name;
    
    if isequal(f, '.') || isequal(f, '..')
        continue
    end
    
    if ~exist([path f], 'dir')
        continue
    end
    
    if exist([path f '/' f '.mat'], 'file') && ~exist([path f '/nolist'], 'file')
        nds = nds + 1;
        dsnames{nds} = f; %#ok<AGROW>
    end
end
end