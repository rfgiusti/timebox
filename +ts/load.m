function [train, test] = load(dsname, repname)
%DATASETS.LOAD Load a training and a test data set
%  TRAIN = LOAD(DS) load the training partition of the DS data set.
%
%  TRAIN = LOAD(DS,REP) attempts to load the data set in the representation
%  domain specified by REP. The data set must have been previously cached
%  in the intended representation. If the name of the representation is
%  "time" (case-insensitive), then the original data set is loaded.
%
%  [TRAIN,TEST] = LOAD(DS,...) load the training and the test partition of
%  the DS data set.
if exist('repname', 'var') && ~isequal(lower(repname), 'time')
    path = [tb.getdspath dsname '/transforms/' dsname '-' repname '.mat'];
else
    path = [tb.getdspath dsname '/' dsname '.mat'];
end
tb.assert(exist(path, 'file'), ['Data base not found in "' path '"']);
filedata = load(path, '-mat');
train = filedata.train;
test = filedata.test;
end