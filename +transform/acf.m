function [trainacf, testacf] = acf(train, test, ~)
%TRANSFORM.ACF   Time series transform to sample autocorrelation
%coefficients.
%   DSA = ACF(DS) transforms the time series data set DS into sample
%   correlation coefficients.
%
%   [TRAINA,TESTA] = ACF(TRAIN,TEST) converts both a training and a test
%   data sets into sample correlation coefficients.
%
%   For each output series, the first "observation" is the sample
%   autocorrelation at lag 0 and is always 1, the second observation is the
%   sample autocorrelation at lag 1, and so forth.
%
%   This function does not take any options.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 2.0.0
trainacf = acfpart(train);
if exist('test', 'var')
    testacf = acfpart(test);
end
end

function ds = acfpart(ds)
numMA = size(ds, 2) - 2;
for i = 1:size(ds, 1)
    ds(i, 2:end) = autocorr(ds(i, 2:end), numMA);
end
end
