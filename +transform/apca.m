function [train_t, test_t] = apca(train, test, options)
%TRANSFORM.APCA   Adaptive Piecewise Constant Approximation of time
%series.
%   APCA(DS) returns the Adaptive Piecewise Constant Approximation of
%   the time series in DS with M=10 constant segments.
%
%   The APCA transform of a time series is a sequence of M segments
%   [v(1),r(1)], [v(2),r(2)], ..., [v(M),r(M)] where each v(i) is the
%   mean of the observations between the indices r(i-1)+1 and r(i).
%   Consider r(0)=0.
%
%   Currently this function only returns the values of the segments.
%
%   The APCA transform is found by initially segmenting the series into
%   a set of floor(N/2) segments, where N is the length of the time
%   series. These segments are iteratively merged by attempting to
%   reduce the MSE until M segments remain. This process returns an
%   approximately optimal segmentation of the series.
%
%   The number of segments M may be chosen by setting the option
%   "apca::num segments" to the desired value.
%
%   APCA(DS,o) where o is an OPTS object takes options from o.
%
%   [T,t]=APCA(DS,DSt,...) returns the transformed training set in T and
%   the test set in t.
%
%   Options:
%       apca::num segments      (default: 10)
%
%   For further reference on the APCA transformation, please refer to
%   the following paper: Eamonn Keogh, Kaushik Chakrabarti, Michael
%   Pazzani, and Sharad Mehrotra. "Dimensionality Reduction for Fast
%   Similarity Search in Large Time Series Databases". Published in
%   Knowledge and Information Systems (2001).

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1.0

%   Thanks to professor Keogh for sharing his APCA implementation which
%   helped in implementing and testing this function.
if ~exist('options', 'var')
    if exist('test', 'var') && opts.isa(test)
        options = test;
        clear test;
    else
        options = opts.empty;
    end
end

len = size(train, 2) - 1;
M = opts.get(options, 'apca::num segments', min(floor(len / 2), 10));
tb.assert(M <= floor(len / 2), 'TRANSFORM.APCA: cannot segment series of length %d into %d pieces', len, M);

train_t = dods(train, M);
if exist('test', 'var')
    test_t = dods(test, M);
end
end


function out = dods(in, M)
if M == 1
    out = [in(:,1), mean(in(:, 2:end), 2)];
else
    numseries = size(in, 1);
    out = [in(:,1), zeros(numseries, M)];
    for i = 1:numseries
        out(i,2:end) = doseries(in(i,2:end), M);
    end
end
end


function out = doseries(in, M)
len = numel(in);

% Make segments of size 2 (with exception of the last segment)
segstart = 1:2:len - 1;
segend = segstart + 1;
segend(end) = len;
N = numel(segstart);

% Find the mean of each segment
meanfun = @(x) mean(in(segstart(x):segend(x)));
segmean = arrayfun(meanfun, 1:numel(segstart));

% Find the cost of merging segments (i,i+1). Add a sentinel to the segment
% cost to facilitate indexing
costfun = @(x) sum(abs(in(segstart(x):segend(x+1)) - mean(in(segstart(x):segend(x+1)))));
segcost = [arrayfun(costfun, 1:numel(segstart) - 1), inf];

% Merge until we have the desired number of segments
while N > M
    % Find the segment pair with lowest cost
    [~, idx] = min(segcost(1:N));

    % Merge the segments
    segend(idx) = segend(idx+1);
    segmean(idx) = mean(in(segstart(idx):segend(idx)));

    % If this is an in-between segment, shift the lists and find the cost
    % of merging the new segment with the next one
    if idx + 1 < N
        tomerge = in(segstart(idx):segend(idx+2));
        segcost(idx) = sum(abs(tomerge - mean(tomerge)));

        segstart(idx+1:N-1) = segstart(idx+2:N);
        segend(idx+1:N-1) = segend(idx+2:N);
        segmean(idx+1:N-1) = segmean(idx+2:N);
        segcost(idx+1:N-1) = segcost(idx+2:N);
    end

    % If this is not the first, fix the cost of the previous
    if idx > 1
        tomerge = in(segstart(idx-1):segend(idx));
        segcost(idx-1) = sum(abs(tomerge - mean(tomerge)));
    end

    N = N - 1;
end

out = segmean(1:N);
end
