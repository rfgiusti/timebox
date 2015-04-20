function path = cachepath(dsname, varargin)
%DISTS.CACHEPATH Returns a path to be used as cache for a particular
%combination of data set, distance function, and decision space. This is an
%internal function for DISTS.ISCACHED, DISTS.CACHEMATRIX, and DISTS.CACHED.
%   The possible combination of arguments are:
%
%   CACHEPATH(DSNAME) distance defaults to 'Euclidean' and representation
%   defaults to 'time'
%
%   CACHEPATH(DSNAME,DIST) distance is specified by DIST and representation
%   defaults to 'time'
%
%   CACHEPATH(DSNAME,[],REPNAME) distance defaults to 'euclidean' and
%   representation is specified by REPNAME
%
%   CACHEPATH(DSNAME,DIST,REPNAME) both distance and representation are
%   taken from the argument list
tb.assert(nargin >= 1 && nargin <= 3, 'Function called with wrong number of arguments (should be 1, 2, or 3)');
if nargin == 1
    % Called as CACHEPATH(DSNAME)
    distname = 'euclidean';
    timedomain = 1;
elseif nargin == 2
    % Called as CACHEPATH(DSNAME,DIST)
    distname = varargin{1};
    tb.assert(~isempty(distname));
    timedomain = 1;
elseif nargin == 3
    % Called as CACHEPATH(DSNAME,[],REPNAME) or
    % Called as CACHEPATH(DSNAME,DIST,REPNAME)
    distname = varargin{1};
    if isempty(distname)
        distname = 'euclidean';
    end
    repname = varargin{2};
    if isequal(lower(repname), 'time')
        timedomain = 1;
    else
        timedomain = 0;
    end
end
dspath = tb.getdspath;
if ~timedomain
    path = [dspath dsname '/transforms/distances/' dsname '-' repname '-' distname '.mat'];
else
    path = [dspath dsname '/distances/' dsname '-' distname '.mat'];    
end
end
