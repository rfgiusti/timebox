function dsnames = getnames
%DATASETS.GETNAMES Get a cell with the names of the available data sets.
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