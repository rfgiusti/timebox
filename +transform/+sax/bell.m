function [train, test] = bell(~, arg2, arg3)
%TRANSFORM.SAX.BELL Get SAX cut points according to a bell N(0,1)
%distribution. DEPRECATED since TimeBox 0.11.9
%   CP = BELL(DS) returns the cut points for the data set DS with default
%   options (alphabet size = 4). The data set is assumed to have been
%   normalized to a mean of zero and a standard deviation of one. Data sets
%   can be normalized with TS.ZNORM.
%
%   CP = BELL(DS,OPTS) does the same, but takes options from OPTS instead
%   of using default values.
%
%   [TRAINCP,TESTCP] = BELL(TRAIN,TEST,...) returns cut points for both the
%   training and the test data set. This is pure syntax sugar, as the cut
%   points for the test data set are the same as the cut points for the
%   training data set.
%
%   Options:
%       sax::alphabet size      (default: 4)
warnobsolete('transform:sax:bell');
if exist('arg3', 'var')
    option = arg3;
elseif exist('arg2', 'var') && opts.isa(arg2)
    option = arg2;
    clear arg2;
else
    option = opts.empty();
end
has_test = exist('arg2', 'var');


alpha_size = opts.get(option, 'sax::alphabet size', 4);

switch alpha_size
        case 2, cutp  = [-inf 0];
        case 3, cutp  = [-inf -0.43 0.43];
        case 4, cutp  = [-inf -0.67 0 0.67];
        case 5, cutp  = [-inf -0.84 -0.25 0.25 0.84];
        case 6, cutp  = [-inf -0.97 -0.43 0 0.43 0.97];
        case 7, cutp  = [-inf -1.07 -0.57 -0.18 0.18 0.57 1.07];
        case 8, cutp  = [-inf -1.15 -0.67 -0.32 0 0.32 0.67 1.15];
        case 9, cutp  = [-inf -1.22 -0.76 -0.43 -0.14 0.14 0.43 0.76 1.22];
        case 10, cutp = [-inf -1.28 -0.84 -0.52 -0.25 0. 0.25 0.52 0.84 1.28];
        case 11, cutp = [-inf -1.34 -0.91 -0.6 -0.35 -0.11 0.11 0.35 0.6 0.91 1.34];
        case 12, cutp = [-inf -1.38 -0.97 -0.67 -0.43 -0.21 0 0.21 0.43 0.67 0.97 1.38];
end

train = cutp;
if has_test
    test = cutp;
end
end

