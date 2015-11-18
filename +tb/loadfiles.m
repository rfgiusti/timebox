function data = loadfiles(files, mask)
%TB.LOADFILES   Load several files at once and returns the data in a
%cell array
%   data = LOADFILES(files), where `files' is a cell array of file
%   names, returns in data{i} the contents of the i-th file. If files{i}
%   is not found, then data{i} contains the empty matrix []
%
%   data = LOADFILES(files,masK) does the same, but each `file{i}' is
%   used as argument to replace a '%s' in `mask'.
%
%       Example:
%
%           % This example assumes there is one file in ~/results for
%           each data set, each file named after the data set (i.e.,
%           Coffee.txt, GunPoint.txt, etc)
%           dsnames = ts.getnames;
%           data = loadfiles(dsnames, '~/results/%s.txt');
if ~exist('mask', 'var')
    mask = '%s';
end

data = cell(numel(files), 1);
for i = 1:numel(files)
    path = sprintf(mask, files{i});
    if exist(path, 'file')
        data{i} = load(path);
    else
        data{i} = [];
    end
end
end