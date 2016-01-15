function [dim, len] = getdim(dsname, representation)
%TS.GETDIM  Return the dimensions of a data set without actually loading
%the data.
%   GETDIM(ds) returns a 1-by-2 matrix of double for the number of
%   instances in the training and in the test data set. The training 
%   data set is mandatory. If there is no test data, then the second
%   dimension is zero. If there is no training data or if the data set
%   is not present in the TimeBox repository, an exception is thrown.
%
%   [D,l] = GETDIM(ds) returns the number of instances in D and the
%   length of the instances in l.
%
%   [D,l] = GETDIM(ds,rep) does the same, but for the data set
%   transformed with the representation "rep". For this to work, the
%   data set must have been previously cached into the TimeBox
%   repository. This function does not serve as an estimate of the
%   resulting number of features that a data set will have after it has
%   been transformed. The number of instances should be the constant for
%   any data set regardless of the representation.
%
%   Note: TimeBox is designed to work with time series of equal length.
%         The length of the series is calculated from the training data.
if ~exist('representation', 'var')
    representation = 'time';
end

dspath = ts.getpath(dsname, representation);
tb.assert(exist(dspath, 'file'), ['The data set ' dsname ' with ' representation ' representation is not ' ...
        'stored in the TimeBox repository']);

train = whos('-file', dspath, 'train');
test = whos('-file', dspath, 'test');
tb.assert(~isempty(train), ['The data set ' dsname ' with ' representation ' representation does not ' ...
        'contain training data']);
if isempty(test)
    dim = [train.size(1), 0];
else
    dim = [train.size(1), test.size(1)];
end
len = train.size(2) - 1;