function [trainpaa, testpaa] = paa(train, test, options)
%TRANSFORM.PAA   Piecewise Aggregate Approximation of time series data set.
%   DSP = PAA(DS) returns the Piecewise Aggregate Approximation of the time
%   series in DS.
%
%   The PAA transform of a time series is the averages of subsequences of
%   the original time series. The nubmer of subsequences (or segments) to
%   be used by this transformation is specified by the option
%   "paa::num segments" (or, implicitly, by "paa::segment size").
%
%   This transformation attempts to segment the series into subsequences of
%   equal length. If this is not possible, then some subsequences will be
%   larger than others. For instance, if a series of length 150 is used
%   with this function and a total of 4 segments is requested, then its PAA
%   will be calculated on the subsequences (1-38), (39-75), (76-113), and
%   (115,150), which have 38, 37, 38, and 37 observations respectivelly.
%
%   DSP = PAA(DS,OPTS) takes options from OPTS instead of using default
%   values.
%
%   [TRAINP,TESTP] = PAA(TRAIN,TEST,...) returns the PAA representation of
%   both the training and the test data sets.
%
%   Options:
%       paa::num segments       (default: 10)
%       paa::segment size       *see note below
%
%   The options "paa::segment size" and "paa::num segments" must not be
%   used simultaneously.
%
%   *If the segment size specified by "paa::segment size" cannot divide the
%   series into segments of approximately equal length, then it will be
%   reduced to a size that can be used to retrieve more similar segments.
%   For instance, attempting to segment a series of length 150 with
%   subsequences of 80 observations will actually segment the series with
%   subsequences of 75 observations.
if ~exist('options', 'var')
    if exist('test', 'var') && opts.isa(test)
        options = test;
        clear test;
    else
        options = opts.empty;
    end
end
assert(~(opts.has(options, 'paa::num segments') && opts.has(options, 'paa::segment size')), ['The options ' ...
    '"paa::num segments" and "paa::segment size" may not be used simultaneously.']);
numseg = opts.get(options, 'paa::num segments', 10);
segsize = opts.get(options, 'paa::segment size', []);
if ~isempty(segsize)
    tb.assert(segsize > 0 && round(segsize) == segsize, 'Segment size must be strictly positive integer');
    numseg = ceil((size(train, 2) - 1) / segsize);
end

len = size(train, 2) - 1;
tb.assert(len >= numseg, 'Series of length %d is too short for %d PAA segments', len, numseg);
tb.assert(numseg > 0 && round(numseg) == numseg, 'Number of segments must be strictly positive integer');

trainpaa = paapart(train, numseg, len);
if exist('test', 'var')
    testpaa = paapart(test, numseg, len);
end
end


function out = paapart(in, num_seg, serieslength)
% Create a matrix with the original classes and no observations
out = zeros(size(in, 1), 1 + num_seg);
out(:, 1) = in(:, 1);

% PAA it
for i = 1:num_seg
    j0 = 1 + ceil(1 + (i - 1) * (serieslength / num_seg));
    j1 = 1 + ceil(i * serieslength / num_seg);
    out(:, i+1) = mean(in(:, j0:j1), 2);
end
end