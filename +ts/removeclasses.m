function [cls, obs] = removeclasses(ds)
%TS.REMOVECLASSES Remove classes from the first column of data set.
%   CLS = REMOVECLASSES(DS) returns classes only.
%
%   [CLS, OBS] = REMOVECLASSES(DS) returns classes in CLS and observations
%   in OBS.
%
%   [~, OBS] = REMOVE_CLASSES(DS) returns observations only.
cls = ds(:, 1);
obs = ds(:, 2:end);
end