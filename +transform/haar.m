function [trainwavelets, testwavelets] = haar(train, test, options)
%TRANSFORM.HAAR Get the Haar wavelets for time series data sets.
%   DSH = HAAR(DS) returns the Haar wavelets for the time series of the
%   data set DS. Haar wavelets are the same as Db1 wavelets. The time
%   series are expected to have length 2^n. If the length is not a power of
%   two, the series are interpolated to the next larger power of two with
%   TS.INTERP. This is the default behavior, but it may be changed with the
%   option "haar::extend".
%
%   DSH = HAAR(DS,OPTS) does the same, but takes options from the OPTS
%   object instead of using default values.
%
%   [TRAINH,TESTH] = HAAR(TRAIN,TEST,...) returns the Haar coefficients for
%   both training and test data sets.
%
%   This function takes the following options:
%       haar::level         default 'full'
%       haar::approximated  default 0
%       haar::normalize     default 0
%       haar::extend        default 1

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1

if ~exist('options', 'var')
    if exist('test', 'var') && opts.isa(test)
        options = test;
        clear test;
    else
        options = opts.empty();
    end
end

level = opts.get(options, 'haar::level', 'full');
approximate = opts.get(options, 'haar::approximate', 0);
normalize = opts.get(options, 'haar::normalize', 0);
extend = opts.get(options, 'haar::extend', 1);

trainwavelets = haar_part(train, level, approximate, normalize, extend);
if exist('test', 'var')
    testwavelets = haar_part(test, level, approximate, normalize, extend);
end;
end

function out = haar_part(in, level, approximate, normalize, extend)
len = size(in, 2) - 1;
if extend
    len2 = 2^ceil(log2(len));
else
    len2 = 2^floor(log2(len));
end

if ischar(level) && isequal(level, 'full')
    level = log2(len2);
end

if approximate
    outlen = len2 / 2;
else
    outlen = len2;
end

if normalize
    s = 1;
else
    s = sqrt(2);
end

if len ~= len2
    in = ts.interp(in, len2);
end

out = zeros(size(in, 1), outlen + 1);
out(:, 1) = in(:, 1);

if level == 1
    part = dwt1(in(:, 2:end), s);
elseif normalize
    part = dwtm(in(:, 2:end), level);
else
    part = dwti(in(:, 2:end), level, s);
end

if approximate
    out(:, 2:end) = part(:, 1:end/2);
else
    out(:, 2:end) = part;
end
end


function out = dwt1(in, s)
out = zeros(size(in));
for i = 1:size(in, 1)
    [c, d] = dwt(in(i, :), 'haar');
    out(i, :) = [c/s d/s];
end
end


function out = dwtm(in, level)
out = zeros(size(in));
for i = 1:size(in, 1)
    out(i, :) = wavedec(in(i, :), level, 'haar');
end
end


function out = dwti(in, level, s)
out = zeros(size(in));

for i = 1:size(in, 1)
    x = in(i, :);
    rindex = numel(x);
    for l = 1:level
        [c, d] = dwt(x, 'haar');
        x = c / s;
        lindex = rindex - numel(d) + 1;
        out(i, lindex:rindex) = d / s;
        rindex = lindex - 1;
    end
    out(i, 1:rindex) = x;
end
end