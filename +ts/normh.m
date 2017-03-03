function [train, test] = normh(train, test)
%TS.NORMH   Normalize time series as if they were histograms
%   NORMH(X) normalizes the time series in the data set such that all
%   observations fall into the interval [0,1] and the sum of the
%   observations equals one.
%
%   This kind of normalization is required for some distance functions that
%   rely on the Gibb's inequality or the Bhattacharrya similarity
%   coefficient.
%
%   [X,Y]=NORMH(X,Y) behaves the same as two repeated calls.
%
%   In either case, X and Y must be compatible with the data loaded by
%   TS.LOAD.
train(:, 2:end) = normhpart(train(:, 2:end));
if nargin == 2
    test(:, 2:end) = normhpart(test(:, 2:end));
end
end

function part = normhpart(part)
% Subtract each line to zero
part = bsxfun(@minus, part, min(part, [], 2));

% Divide each line by the sum of all values
part = bsxfun(@rdivide, part, sum(part, 2));

% If for a given series it happens that min(x)==max(x), then we'll get 0/0
% and the first observation will be NaN. When that happens, we replace the
% observations with 1/len(x) so that it remains a constant series and its
% observations add up to one
nans = isnan(part(:, 1));
part(nans, :) = 1 / size(part, 2);
end
