function is = iscached(dsname, varargin)
%DISTS.ISCACHED Verifies if distance matrices have been cached for a
%combination of data set/distance/representation.
%   ISCACHED(DSNAME) verififies if Euclidean distance is cached for the
%   data set named DSNAME. The name must be a char compatible with TS.LOAD.
%
%   ISCACHED(DSNAME,DIST) verifies if cache has been provided for the data
%   set with respect to the distance function named DIST. The distance name
%   must be compatible with DISTS.CACHED.
%
%   ISCACHED(DSNAME,[],REPNAME) does the same as ISCACHED(DSNAME), but with
%   respect to the decision space specified by REPNAME instead of the time
%   domain.
%
%   ISCACHED(DSNAME,DIST,REPNAME) checks if the distance has been cached on
%   the decision domains REPNAME for the distance DIST
cachepath = dists.cachepath(dsname, varargin{:});
is = exist(cachepath, 'file') ~= 0;
end