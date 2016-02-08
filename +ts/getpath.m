function [filepath, filedir] = getpath(dsname, representation)
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
%
%   [f,d] = GETPATH(ds)
%   [f,d] = GETPATH(ds, rep) returns the path to the data set file in
%   "f" and the directory where "f" is stored in "d". The last character
%   of "d" is a slash ('/').
if exist('representation', 'var') && ~isequal(representation, lower('time'))
    filepath = [tb.getdspath dsname '/transforms/' dsname '-' representation '.mat'];
    filedir = [tb.getdspath dsname '/transforms/'];
else
    filepath = [tb.getdspath dsname '/' dsname '.mat'];
    filedir = [tb.getdspath dsname '/'];
end
end