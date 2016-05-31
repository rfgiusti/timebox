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
%   Revision 1.0.0
trainacf = acfpart(train);
if exist('test', 'var')
    testacf = acfpart(test);
end
end

function out = acfpart(in)
len = size(in, 2) - 1;
nseries = size(in, 1);

out = zeros(nseries, len + 1); 

% Copy classes
out(:, 1) = in(:, 1);

for i = 1:nseries
    % Copy this series
    series = in(i, 2:end);
    
    % Get statistics of this particular series
    cmean = mean(series);
    cvar = var(series);
    
    % Get a zero array with the number of coefficients
    acf = zeros(1, len);

    % Add the components as required
    % For a time series t = <x1, x2, .., xm> with mean x, this means
    % acf = <p1, p2, .., p[m-1]> where
    % p1 = (x1-x)*(x2-x) + (x2-x)*(x3-x) + ... + (x[m-1]-x)*(xm-x)
    % p2 = (x1-x)*(x2-x) + (x2-x)*(x3-x) + ... + (x[m-2]-x)*(x[m-1]-x)
    % ...
    % p[m-1] = (x1-x)*(x2-x)
    for lag = 0:(len - 1)
        synced = series(1:(end - lag)) - cmean;
        lagged = series((1 + lag):end) - cmean;
        acf(lag + 1) = sum(synced .* lagged);
    end 

    % Divide by the required factor
    acf = acf / (cvar * (len - 1));

    % Put the factors in the output dataset
    out(i, 2:end) = acf;
end
end
