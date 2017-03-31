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
%   By default, the series will be segmented into pieces of equal size. If
%   the required length does not match an integer number of observations,
%   then some observations will be "split" into two and partially count for
%   each segment. For instance, in order to segment a series of three
%   observations into two pieces, the first piece will take into
%   consideration half the value of the second observation (and the
%   "remaining" half will be accounted by the second piece).
%
%   If the option 'paa::constant' is set to 0 or false, then PAA will no
%   longer  be restricted to pieces of equal length. In this case, it will
%   find a segment length that is closest to matching an integer number of
%   observation and retrieve as many segments of that length as possible.
%   The remaining segments will have different numbers of observations. For
%   instance, if a series of length 150 is used with this function and a
%   total of 4 segments is requested with no constant segment length, then
%   its PAA will be calculated on the subsequences (1:38), (39:75),
%   (76:113), and (115:150), which have 38, 37, 38, and 37 observations
%   respectivelly.
%
%   DSP = PAA(DS,OPTS) takes options from OPTS instead of using default
%   values.
%
%   [TRAINP,TESTP] = PAA(TRAIN,TEST,...) returns the PAA representation of
%   both the training and the test data sets.
%
%   Options:
%       paa::num segments       (default: 10)
%       paa::constant           (default: 1)
%       paa::segment size       *see note below
%
%   If the option 'paa::segment size' is supplied, then 'paa::num segments'
%   must not be specified and 'paa::constant' is forced to 0.
%
%   *If the segment size specified by 'paa::segment size' cannot divide the
%   series into segments of approximately equal length, then it will be
%   reduced to a size that can be used to retrieve more similar segments.
%   For instance, attempting to segment a series of length 150 with
%   subsequences of 80 observations will actually segment the series with
%   subsequences of 75 observations.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 2.0.0
if ~exist('options', 'var')
    if exist('test', 'var') && opts.isa(test)
        options = test;
        clear test;
    else
        options = opts.empty;
    end
end

% Can't specify length and number of segments simultaneously
assert(~(opts.has(options, 'paa::num segments') && opts.has(options, 'paa::segment size')), ['The options ' ...
    '"paa::num segments" and "paa::segment size" may not be used simultaneously.']);

% Retrieve options with default values. "constant" must be zero if
% "segsize" is specified; defaults to 1 otherwise
numseg = opts.get(options, 'paa::num segments', 10);
segsize = opts.get(options, 'paa::segment size', []);
if ~isempty(segsize)
    constant = 0;
    tb.assert(segsize > 0 && round(segsize) == segsize, 'Segment size must be strictly positive integer');
    numseg = ceil((size(train, 2) - 1) / segsize);
else
    constant = opts.get(options, 'paa::constant', 1);
end

len = size(train, 2) - 1;
tb.assert(len >= numseg, 'Series of length %d is too short for %d PAA segments', len, numseg);
tb.assert(numseg > 0 && round(numseg) == numseg, 'Number of segments must be strictly positive integer');

if constant
    trainpaa = paaconst(train, numseg, len);
    if exist('test', 'var')
        testpaa = paaconst(test, numseg, len);
    end
else
    trainpaa = paaflex(train, numseg, len);
    if exist('test', 'var')
        testpaa = paaflex(test, numseg, len);
    end
end
end


function out = paaconst(in, numsegs, len)
% Retrieve the PAA forcing every segment to be of equal length. Some
% observations will be broken down into smaller pieces.

% This algorithm was retrieved from
% https://jmotif.github.io/sax-vsm_site/morea/algorithm/PAA.html
out = zeros(size(in, 1), 1 + numsegs);
out(:, 1) = in(:, 1);

for i = 0:len*numsegs - 1
    idx = floor(i / len) + 2;
    pos = floor(i / numsegs) + 2;
    out(:, idx) = out(:, idx) + in(:, pos);
end
out(:, 2:end) = out(:, 2:end) / len;
end


function out = paaflex(in, num_seg, serieslength)
% Retrieve the PAA transformation without breaking down observations; some
% segments will be calculated from more observations than others
out = zeros(size(in, 1), 1 + num_seg);
out(:, 1) = in(:, 1);

for i = 1:num_seg
    j0 = 1 + ceil(1 + (i - 1) * (serieslength / num_seg));
    j1 = 1 + ceil(i * serieslength / num_seg);
    out(:, i+1) = mean(in(:, j0:j1), 2);
end
end
