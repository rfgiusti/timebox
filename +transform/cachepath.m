function path = cachepath(dsname, repname)
%TRANSFORM.CACHEPATH    Path for cached data of transformed data set.
%   CACHEPATH(DS,REPNAME) returns the default path for the cached data
%   set named DS in the representation named REPNAME. If ommitted,
%   REPNAME defaults to 'time' and the path points to the original data
%   set.
dspath = tb.getdspath;
if ~exist('repname', 'var') || isequal(lower(repname), 'time')
    path = [dspath dsname '/' dsname '.mat'];
else
    path = [dspath dsname '/transforms/' dsname '-' repname '.mat'];
end
end