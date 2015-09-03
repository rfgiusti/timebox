function [savepath, dirpath] = cachepath(dsname, repname)
%TRANSFORM.CACHEPATH    Path for cached data of transformed data set.
%   CACHEPATH(DS,REPNAME) returns the default path for the cached data
%   set named DS in the representation named REPNAME. If ommitted,
%   REPNAME defaults to 'time' and the path points to the original data
%   set.
%
%   [P,D] = CACHEPATH(DS,REPNAME) returns the full path to the cache in
%   P and the directory in D.
dspath = tb.getdspath;
if ~exist('repname', 'var') || isequal(lower(repname), 'time')
    dirpath = [dspath dsname '/'];
    savepath = [dirpath dsname '.mat'];
else
    dirpath = [dspath dsname '/transforms/'];
    savepath = [dirpath dsname '-' repname '.mat'];
end
end