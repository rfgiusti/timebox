function filepath = getpath(dsname, representation)
%TS.GETPATH     Return the expected path of a data set in the local
%repository.
%   GETPATH(ds) returns the path where the data set "ds" should be
%   stored. This function does not check if the data set exists.
%
%   GETPATH(ds, rep) returns the path where the representation "rep" of
%   the data set "ds" should be stored. This function does not check if
%   the data set exists or if it has been cached for this specific
%   representation.
%
%   Example:
%       >> ts.getpath('Coffee', 'time')
%       >> ts.getpath('Coffee', 'ps')
if exist('representation', 'var') && ~isequal(representation, lower('time'))
    filepath = [tb.getdspath dsname '/transforms/' dsname '-' representation '.mat'];
else
    filepath = [tb.getdspath dsname '/' dsname '.mat'];
end
end