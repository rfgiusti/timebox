function [train, test] = dwt(train, test, options)
%TRANSFORM.DWT   Discrete Wavelet Transform of time series data set.
%   DWT(DS) transforms the time series in DS using the Haar wavelet (db1)
%   at the maximum decomposition level.
%
%   DWT(DS,o), where "o" is an OPTS object, makes it possible to pass
%   options to the transform function. In particular, the option
%   "dw::wavelet" specifies which wavelet should be used. This function
%   wraps around Matlab's WAVEDEC function, so every wavelet supported by
%   Matlab is also supported by TRANSFORM.DWT.
%
%   [TRAIN,TEST]=DWT(TRAIN,TEST,...) does the same for both a training and
%   a test data sets.
%
%   This function takes the following options:
%       dwt::wavelet        (default: 'db1')
%       dwt::level          *see note below
%
%   By default, this function applies the highest level of decomposition
%   possible, according to WMAXLEV. If "dwt::level" is specified, that
%   level will be used even if it is greatear than specified by WMAXLEV.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1.0
if ~exist('options', 'var')
    if exist('test', 'var') && opts.isa(test)
        options = test;
        clear test;
    else
        options = opts.empty;
    end
end

wavelet = opts.get(options, 'dwt::wavelet', 'db1');
level = opts.get(options, 'dwt::level', []);
if isempty(level)
    len = size(train, 2) - 1;
    level = wmaxlev(len, wavelet);
end

train = do1(train, wavelet, level);
if exist('test', 'var')
    test = do1(test, wavelet, level);
end
end


function out = do1(in, wavelet, level)
% Find the size of the transformed wavelets
first = wavedec(in(1, 2:end), level, wavelet);

% Make room for the transformed data set
numseries = size(in, 1);
out = zeros(numseries, numel(first) + 1);

out(1, 2:end) = first;
for i = 2:numseries
    out(i, 2:end) = wavedec(in(i, 2:end), level, wavelet);
end

out(:, 1) = in(:, 1);
end
