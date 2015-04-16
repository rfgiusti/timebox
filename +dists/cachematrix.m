function cachematrix(traintrain, testtrain, dsname, varargin) %#ok<INUSL>
%DISTS.CACHEMATRIX Save distance matrix to a cache so it may be retrieved
%later.
%   CACHEMATRIX(TRAINTRAIN,TESTTRAIN,DSNAME) caches the distance matrices
%   of the data set named DSNAME. If the distance matrix has been already
%   cached, it is replaced.
%
%   CACHEMATRIX(TRAINTRAIN,TESTTRAIN,DSNAME,DIST) caches distance matrices
%   for the distance named DIST instead of the Euclidean distance.
%
%   CACHEMATRIX(TRAINTRAIN,TESTTRAIN,DSNAME,[],REPNAME) does the same as
%   CACHEMATRIX(TRAINTRAIN,TESTTRAIN,DSNAME), but with respect to the
%   decision space specified by REPNAME instead of the time domain.
%
%   CACHEMATRIX(TRAINTRAIN,TESTTRAIN,DSNAME,DIST,REPNAME) uses the distance
%   specified by DIST instead of the Euclidean distance and the decision
%   space specified by REPNAME instead of the time domain.
cachepath = dists.cachepath(dsname, varargin{:});
fprintf('Would save distance matrix: %s\n', cachepath);
% save(cachepath, 'traintrain', 'testtrain', '-mat');
end
