function [trainclasses, testclasses] = loadclasses(dsname)
%TS.LOADCLASSES     Get classes of train/test data sets
%   LOADCLASSES(DS) returns an n-by-1 column vector of double for the
%   classes of the training instances of the data set named DS.
%
%   [X,Y] = LOADCLASSES(DS) also returns an m-by-1 column vector of double
%   for the classes of the test instances.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
cachepath = [tb.getdspath dsname '/' dsname '.mat'];
if numel(who('-file', cachepath, 'trainclasses', 'testclasses')) ~= 2
    filedata = load(cachepath, '-mat');
    trainclasses = filedata.train(:, 1);
    testclasses = filedata.test(:, 1);
else
    filedata = load(cachepath, 'trainclasses', 'testclasses', '-mat');
    trainclasses = filedata.trainclasses;
    testclasses = filedata.testclasses;
end