function [traintrain, testtrain] = cached(dsname, distname, repname)
% DISTS.CACHED Return previously cached distance matrices
if exist('repname', 'var') && ~isequal(repname, 'time')
    path = ['~/timeseries/' dsname '/transforms/distances/' dsname '-' repname '-' distname '.mat'];
else
    path = ['~/timeseries/' dsname '/distances/' dsname '-' distname '.mat'];
end

if ~exist(path, 'file')
    err = MException('dists.cached:FileNotFound', 'File not found at %s', path);
    throw(err);
end

data = load(path);
traintrain = data.traintrain;
testtrain = data.testtrain;
end