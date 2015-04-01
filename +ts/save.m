function save(train, test, dsname) %#ok<INUSL>
%TS.SAVE    Save a data set into TimeBox repository.
%   For a partitioned data set, SAVE(TRAIN,TEST,DSNAME) saves the time
%   series data into a .mat file in TimeBox repository. Once saved in the
%   repository, the data set may be loaded by TimeBox functions that will
%   refer to the data set by its name.
%
%   The data set name restrictions are the same as the file system. It is
%   best advisable that data set names are ASCII characters without special
%   symbols nor space. It also best to assume the names are case-sensitive.
%
%   The input data must be in a format compatible with TS.LOAD. For a
%   training set containing n time series of length m, TRAIN must be an
%   n-by-(m+1) matrix of type double where each row is a time series,
%   the first column is the class labels of the series, and the remaining
%   columns are the series observations. For a test containing p time
%   series of length m, TEST must be a p-by-(m+1) matrix of type double.
%
%   If the particular data set does not contain test instances, the test
%   set must be specified as an empty array, [].
dspath = tb.getdspath;
savedir = [dspath dsname];
savefile = [savedir '/' dsname '.mat'];
if ~exist('savedir', 'file')
    mkdir(savedir);
end
save(savefile, 'train', 'test', '-mat');
end