function [outtrain, outtest] = znorm(intrain, intest)
%TS.ZNORM Normalize time series dataset. 
%  N = ZNORM(D) normalize the dataset of time series D and return to N.
%
%  [NTRAIN,NTEST] = ZNORM(TRAIN,TEST) normalize both the training and test
%  data sets.

% Get the data without classes
outtrain = znormpart(intrain);
if exist('intest', 'var')
    outtest = znormpart(intest);
end
end


function out = znormpart(in)
data = in(:, 2:end);

% Shift to zero
zero = bsxfun(@minus, data, mean(data, 2));

% Get the standard deviation of the time series
dev = std(data, 0, 2);

% Attempt to move the data so that the standard deviation is one
stand = bsxfun(@rdivide, zero, dev);

% Some time series may have standard deviation zero. In that case, we get a
% division of zero by zero and there will be NaN all over them. If the
% first observation of any z-normalized time series is a NaN, replace the
% normalized time series with a bunch of zeros (which are actually what you
% get if you zero-mean them)
nans = isnan(stand(:, 1));
stand(nans, :) = 0;

% Merge class and data back
out = zeros(size(in));
out(:, 1) = in(:, 1);
out(:, 2:end) = stand;
end