function [train, test] = norm1(train, test)
%TS.NORM1   Normalize time series to the interval [0,1]
%   NORM1(X) normalizes the time series in the data set such that all
%   observations fall into the interval [0,1].
%
%   [X,Y]=NORM1(X,Y) behaves the same as two repeated calls.
%
%   In either case, X and Y must be compatible with the data loaded by
%   TS.LOAD.

%   This file is part of TimeBox. Copyright 2015-17 Rafael Giusti
%   Revision 0.1.0
train(:, 2:end) = norm1part(train(:, 2:end));
if nargin == 2
    test(:, 2:end) = norm1part(test(:, 2:end));
end
end

function part = norm1part(part)
% Subtract each line to zero
part = bsxfun(@minus, part, min(part, [], 2));

% Divide each line by the maximum value
part = bsxfun(@rdivide, part, max(part, [], 2));

% Some time series may have min(S) == max(S), in which case we get a
% division of zero by zero. If the first observation of any normalized time
% series is a NaN, replace all observations with 0.5 and center the series
% at the mean
nans = isnan(part(:, 1));
part(nans, :) = 0.5;
end
