function out = shuffleds(ds, options)
%TS.SHUFFLE_DS Shuffle the time series in a dataset.
%   SHUFFLEDS(DS) returns a shuffled version of the data set DS.
%
%   SHUFFLEDS(DS,OPTS) does the same, but takes options from OPTS instead
%   of using default values.
%
%   Options:
%       shuffleds::indices      (default: 0)
numseries = size(ds, 1);
indices = randsample(numseries, numseries);
if exist('options', 'var') && opts.get(options, 'shuffleds::indices', 0)
    out = indices;
else
    out = ds(indices, :);
end
end

