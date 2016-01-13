function meta = loadmeta(dsname, representation)
%TS.LOADMETA    Load only the meta-information of a data set
%   LOADMETA(ds) loads the meta-information of the data set "ds". The
%   meta-information is a STRUCT. If the file does not contain
%   meta-information, an 1x1 STRUCT ARRAY with no fields is returned. If
%   the file does not exist, and exception is thrown.
%
%   LOADMETA(ds, rep) does the same, but for the transformed data set.
if ~exist('representation', 'var')
    representation = 'time';
end
dspath = ts.getpath(dsname, representation);
tb.assert(exist(dspath, 'file'), ['The data set ' dsname ' with ' representation ' representation is not ' ...
        'stored in the TimeBox repository']);

if isempty(who('-file', dspath, 'meta'))
    meta = struct;
else
    filedata = load(dspath, 'meta');
    meta = filedata.meta;
end