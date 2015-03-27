function [trainsax, testsax] = sax(train, test, options)
%TRANSFORM.SAX Get the SAX representation for time series data sets.
%   DSX = SAX(DS) returns the SAX representation for the time series in the
%   data set DS, using integers 1, 2, 3, ... to index the symbols 'a', 'b',
%   'c', .... 
%
%   DSX = SAX(DS,OPTS) does the same, but takes options from OPTS instead
%   of using default values.
%
%   [TRAINX,TESTX] = SAX(TRAIN,TEST,...) transforms both the training and
%   the test data set.
%
%   Options:
%       sax::alphabet size          (default: 4)
%       sax::segmenting function    (default: @transform.paa)
%       sax::cut function           (default: @transform.sax.bell)
%
%   This function invokes the segmenting function and the cut function
%   without specifying any options. Unless options are specified by the
%   caller, those functions will use default values.

if ~exist('options', 'var')
    if exist('test', 'var') && opts.isa(test)
        options = test;
        clear test;
    else
        options = opts.empty();
    end
end

segfun = opts.get(options, 'sax::segmenting function', @transform.paa);
cutter = opts.get(options, 'sax::cut function', @transform.sax.bell);

% Do we have a test dataset?
testds = exist('test', 'var');

% Z-norm it
trainz = ts.znorm(train);
if testds
    testz = ts.znorm(test);
end

% Get it segmented
if testds
    [trains, tests] = segfun(trainz, testz, options);
else
    trains = segfun(trainz, options);
end

% Get the cutpoints
if testds
    [trainc, testc] = cutter(trains, tests, options);
else
    trainc = cutter(trains, options);
end

% Do it
trainsax = saxpart(trains, trainc);
if testds
    testsax = saxpart(tests, testc);
end
end



function out = saxpart(in, cutp)
% Apply SAX transformation on a single dataset

% Separate data points and observations
[classes, data] = ts.removeclasses(in);

% Make SAX according to cut points
sax = arrayfun(@(x)(sum(x >= cutp)), data);

% Add classes back to SAX info
out = ts.addclasses(classes, sax);
end