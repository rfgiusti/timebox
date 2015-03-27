function [trainacf, testacf] = acf(train, test, ~)
%TRANSFORM.ACF Time series transform to autocorrelation coefficients.
%   DSA = ACF(DS) transform the time series data set DS into correlation
%   coefficients.
%
%   [TRAINA,TESTA] = ACF(TRAIN,TEST) converts both a training and a a test
%   data set to correlation coefficients.
%
%   For each series, the first coefficient p(0) is the autocorrelation
%   between each original observation and itself. The second coefficient
%   p(1) is the autocorrelation between immediate pairs of observations,
%   and so forth.
%
%   For an original series S and the resulting series Z, it holds that
%   LEN(Z) == LEN(S) - 1
%
%   For zero-mean series, the first autocorrelation coefficient is always
%   zero.
%
%   This function does not take any options.
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
    cstd = std(series);
    
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
    acf = acf / (cstd * (len - 1));

    % Put the factors in the output dataset
    out(i, 2:end) = acf;
end
end
