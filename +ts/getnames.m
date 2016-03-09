function dsnames = getnames
%TS.GETNAMES    Get a cell with the names of the data sets available in
%the TimeBox local repository. Please refer to TS.SAVE to save data sets
%into the TimeBox local repository.
%   Names are sorted case-insensitively. If two data sets have names that
%   differ only by their cases (e.g., 'Dataset' and 'DataSet'), then the
%   output order between them is unspecified.
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

% Sort names case-insensitively
[~, sortedindex] = sort(lower(dsnames));
dsnames = dsnames(sortedindex);
end