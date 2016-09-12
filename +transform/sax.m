function [trainsax, testsax] = sax(train, test, options)
%TRANSFORM.SAX   Get the SAX representation for time series data sets.
%   DSX = SAX(DS) returns the SAX representation for the time series in the
%   data set DS, using integers 1, 2, 3, ... to index the symbols 'a', 'b',
%   'c', .... 
%
%   DSX = SAX(DS,OPTS) does the same, but takes options from OPTS.
%
%   [TRAINX,TESTX] = SAX(TRAIN,TEST,...) transforms both the training and
%   the test data set.
%
%   Options:
%       sax::alphabet size          (default: 4)
%       sax::segmenting function    (default: @transform.paa)
%
%   This function assumes the time series to be Z-normalized (approximately
%   standard normal).
%
%   This implements the Time Series representation proposed in the
%   paper: Jessica Lin, Eamonn Keogh,  Li Wei, and Stefano Leonardi.
%   "Experiencing SAX: a novel symbolic representation of time series". In:
%   Data Mining and Knowledge Discovery, Springer US, 2007, 15, 107-144.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0
if ~exist('options', 'var')
    if exist('test', 'var') && opts.isa(test)
        options = test;
        clear test;
    else
        options = opts.empty();
    end
end

segfun = opts.get(options, 'sax::segmenting function', @transform.paa);
alphabetsize = opts.get(options, 'sax::alphabet size', 4);
breakpoints = getbreakpoints(alphabetsize);

if exist('test', 'var')
    [trains, tests] = segfun(train, test, options);
    testsax = saxpart(tests, breakpoints);
else
    trains = segfun(train, options);
end
trainsax = saxpart(trains, breakpoints);
end


function sax = saxpart(ds, cutp)
% Apply SAX transformation on a single dataset
sax = ones(size(ds));
for i = 1:numel(cutp)
    sax = sax + (ds >= cutp(i));
end

% Copy the classes back into the first column
sax(:, 1) = ds(:, 1);
end


function breakpoints = getbreakpoints(alphabetsize)
%Return breakpoints attempting to produce equiprobable SAX words for a
%Z-normalized time series
switch alphabetsize
        case 2, breakpoints  = 0;
        case 3, breakpoints  = [-0.43 0.43];
        case 4, breakpoints  = [-0.67 0 0.67];
        case 5, breakpoints  = [-0.84 -0.25 0.25 0.84];
        case 6, breakpoints  = [-0.97 -0.43 0 0.43 0.97];
        case 7, breakpoints  = [-1.07 -0.57 -0.18 0.18 0.57 1.07];
        case 8, breakpoints  = [-1.15 -0.67 -0.32 0 0.32 0.67 1.15];
        case 9, breakpoints  = [-1.22 -0.76 -0.43 -0.14 0.14 0.43 0.76 1.22];
        case 10, breakpoints = [-1.28 -0.84 -0.52 -0.25 0. 0.25 0.52 0.84 1.28];
        case 11, breakpoints = [-1.34 -0.91 -0.6 -0.35 -0.11 0.11 0.35 0.6 0.91 1.34];
        case 12, breakpoints = [-1.38 -0.97 -0.67 -0.43 -0.21 0 0.21 0.43 0.67 0.97 1.38];
    otherwise
        error('transform:sax', 'Alphabet size must be integer in [2, 12]');
end
end
