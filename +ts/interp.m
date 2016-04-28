function [out, querypoints] = interp(ds, newlen, ~)
%TS.INTERP Interpolate the data set to a new number of observations to grow
%or shrink time series.
%   DS = INTERP(DS,LEN) interpolates the observations of the original time
%   series and returns a new data set where each time series is of length
%   LEN. Linear interpolation is used to find the new observations.
%
%   [DS,QP] = INTERP(DS,LEN) does the same, but returns in QP the "time
%   stamps" of the new observations in the data set. Original time stamps
%   are assumed to range in the interval 1,2,..N and the new time stamps
%   will range in the interval [1,LEN], with step depending on the factor
%   by which the series should be grown or shrinked.
%
%   This function takes no options.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
nseries = size(ds, 1);
len = size(ds, 2) - 1;

% Get the querypoints for a series that start in observation 2 and ends at observation newlen + 1
ratio = (len - 1) / (newlen - 1);
querypoints = 2 + (0:newlen - 1) * ratio;
querypoints(end) = len + 1;

% Make room for the new dataset
out = zeros(nseries, newlen + 1);

% Copy classes
out(:, 1) = ds(:, 1);

% Stretch each series individually
for i = 1:nseries
    out(i, 2:end) = interp1(ds(i,:), querypoints);
end
end