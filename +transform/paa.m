function [trainpaa, testpaa] = paa(train, test, options)
%TRANSFORM.PAA Piecewise Aggregate Approximation of time series data set.
%   DSP = PAA(DS) returns the Piecewise Aggregate Approximation of the time
%   series in DS.
%
%   DSP = PAA(DS,OPTS) takes options from OPTS instead of using default
%   values.
%
%   [TRAINP,TESTP] = PAA(TRAIN,TEST,...) returns the PAA representation of
%   both the training and the test data sets.
%
%   Options:
%       paa::num segments       (default: 10)
%       paa::segment size       (default: 0)
%
%   The option "paa::segment size" takes precedence on "paa::num segments".
%   If "paa::segment size" is different than zero, then the number of
%   segments will be calculated with from the specified segment size,
%   overriding assignments to "paa::num segments".

if ~exist('options', 'var')
    if exist('test', 'var') && opts.isa(test)
        options = test;
        clear test;
    else
        options = opts.empty;
    end
end
numseg = opts.get(options, 'paa::num segments', 10);
segsize = opts.get(options, 'paa::segment size', 0);
if segsize
    numseg = ceil((size(train, 2) - 1) / segsize);
end

trainpaa = paapart(train, numseg);
if exist('test', 'var')
    testpaa = paapart(test, numseg);
end
end

function out = paapart(in, num_seg)
numseries = size(in, 1);
serieslength = size(in, 2) - 1;

% Create a matrix with the original classes and no observations
out = zeros(numseries, 1 + num_seg);
out(:, 1) = in(:, 1);

% PAA it
for i = 1:num_seg
    j0 = 1 + ceil(1 + (i - 1) * (serieslength / num_seg));
    j1 = 1 + ceil(i * serieslength / num_seg);
    out(:, i+1) = mean(in(:, j0:j1), 2);
end
end