function [traintrain, testtrain] = cached(dsname, varargin)
%DISTS.CACHED Return previously cached distance matrices.
%   CACHED(DSNAME) returs the previously cached n-by-n matrix for the
%   training series of the data set named DSNAME. If the distance matrix
%   has not yet been cached for this data set, an exception is raised.
%
%   CACHED(DSNAME,DIST) uses the distance specified by DIST instead of the
%   Euclidean distance.
%
%   CACHED(DSNAME,[],REPNAME) does the same as CACHED(DSNAME), but with
%   respect to the decision space specified by REPNAME instead of the time
%   domain.
%
%   CACHED(DSNAME,DIST,REPNAME) uses the distance specified by DIST instead
%   of the Euclidean distance and searches in the decision space specified
%   by REPNAME instead of the time domain.
%
%   [D1,D2] = CACHED(...) returns both the n-by-n matrix for the distances
%   between the pairs of the time series in the training data set as well
%   the the m-by-n matrix for the distance between each test time series
%   and training time series.
cachepath = dists.cachepath(dsname, varargin{:});
tb.assert(exist(cachepath, 'file'), 'Cache %s does not exist', cachepath);
data = load(cachepath);
traintrain = data.traintrain;
testtrain = data.testtrain;
end