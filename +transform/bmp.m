function [trainbmp, testbmp] = bmp(train, test, options)
%TRANSFORM.BITMAP Transform a data set into bit map representation.
%   The time series Bitmap representation was proposed by Kumar et al
%   ("Time-series bitmaps: a practical visualization tool for working with
%   large time series databases", puslibhsed in "SIAM Data Mining
%   Conference", 2005).
%
%   DSBMP = BMP(DS) will transform the data set DS into time series
%   bitmaps. The size of the resulting series will be determined by the
%   bitmap level. For a bitmap of dimension n-by-n, the series weill be of
%   length 1-by-n^2, with each row of the bitmap concatenated in a single
%   sequence.
%
%   DSBMP = BMP(DS,OPTS) does the same, but uses OPTS as an options object
%   instead of default options.
%
%   [TRAINBMP,TESTBMP] = BMP(TRAIN,TEST,...) simultaneously returns the
%   time series bitmaps for both the training and test data set.
%
%   Options:
%       bmp::window width       (default: ceil(serieslength / 10))
%       bmp::level              (default: 3)
%       bmp::use paa            (default: 1)
%       bmp::real bmp           (default: 0)
%
%   In addition, this function is aware of the related following options:
%       sax::alphabet size      (default: 4)
%       paa::num segments*      (default: 10)
%       paa::segment size*      (no default value)
%
%   *"paa::num segments" defaults to 10 only if neither "paa::num segments"
%   nor "paa::segment size" have been specified by the user.

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 0.1
if ~exist('options', 'var')
    if exist('test', 'var') && opts.isa(test)
        options = test;
        clear test;
    else
        options = opts.empty();
    end
end

% Get options from arg or use their default values
serieslength = size(train, 2) - 1;
windowwidth = opts.get(options, 'bmp::window width', ceil(serieslength / 10));
level = opts.get(options, 'bmp::level', 3);
usepaa = opts.get(options, 'bmp::use paa', 1);
isbmp = opts.get(options, 'bmp::real bmp', 0);

% No matter what the SAX configuration is, we have our own default values
% for the bitmap representation
if ~opts.has(options, 'sax::alphabet size')
    options = opts.set(options, 'sax::alphabet size', 4);
end
if usepaa && ~opts.has(options, 'paa::num segments') && ~opts.has(options, 'paa::segment size')
    options = opts.set(options, 'paa::num segments', 10);
end

% Prepare the bitmaps
trainbmpdata = zeros(size(train, 1), 4^level);
if exist('test', 'var')
    testbmpdata = zeros(size(test, 1), 4^level);
end

% Add bitmap count according to every window. We begin with the window
% "off-range" and move it to the desired position at the beginning of each
% iteration. The window includes a spurious observation to the left that
% contains the class label in the first iteration and a spurious
% observation for uniformity in further iterations. The bitmaps matrices
% are generated without class labels; they are added in by finalbmp
windowleft = 0;
windowright = windowwidth;
if exist('test', 'var')
    while windowright <= serieslength
        windowleft = windowleft + 1;
        windowright = windowright + 1;
        
        % The spurious observations at train(:, windowleft) and
        % test(:, windowleft) will be considered to be the class labels by
        % SAX and will be ignored
        [trainsax, testsax] = transform.sax(train(:, windowleft:windowright), test(:, windowleft:windowright), options);
        trainbmpdata = bmppart(trainbmpdata, trainsax, level);
        testbmpdata = bmppart(testbmpdata, testsax, level);
    end
    
    trainbmp = finalbmp(train, trainbmpdata, isbmp, level);
    testbmp = finalbmp(test, testbmpdata, isbmp, level);
else
        
    while windowright <= serieslength
        windowleft = windowleft + 1;
        windowright = windowright + 1;
        
%         fprintf('\n\n\n\n------------------------\n\nIteration begins...\n\n');
        
%         train
        
%         windowleft
%         windowright
        
        % The spurious observations at train(:, windowleft) will be
        % considered to be the class labels by SAX and will be ignored
        trainsax = transform.sax(train(:, windowleft:windowright), options);
        
%         trainunderwindow = train(:, windowleft:windowright)
%         trainsax
        
        trainbmpdata = bmppart(trainbmpdata, trainsax, level);
    end
    
%     trainbmpdata
    
    trainbmp = finalbmp(train, trainbmpdata, isbmp, level);
end
end


function out = finalbmp(in, inbmp, isbmp, level)
% FINALBMP Normalize the observations in each bitmap and add classes

norm = bsxfun(@rdivide, inbmp, max(inbmp, [], 2));


if isbmp
    numseries = size(inbmp, 1);
    out = repmat(struct('class', 1, 'bmp', zeros(2^level)), numseries, 1);
    
    for i = 1:numseries
        out(i).class = in(i, 1);
        out(i).bmp = makebmp(inbmp(i, :), level);
    end
else
    out = ts.addclasses(in(:,1), norm);
end
end


function bmp = makebmp(in, level)
end



function out = bmppart(in, sax, level)
% BMPPART Part of the TRANSFORM.BMP transformation
%   This function will take a partially assembled bitmap time series, a new
%   subsequence of SAX symbols, its current level and will add the SAX
%   sustrings to the partially assembled bitmap time series. The first SAX
%   observation is assumed to contain the class label and is ignored.
%
%   Remember sax is a matrix where each row is the sax representation of a
%   window of a different time series
%
%         <SPURIOUS>   1   1   2   3 ...
%         <SPURIOUS>   1   2   1   4 ...
%         <SPURIOUS>   2   1   1   2 ...
%         <SPURIOUS>   3   4   2   1 ...

out = in;

% Indices to the iteration loop
rightmost = size(sax, 2) - level + 1;
windowrightshift = level - 1;

% Number of time series
numts = size(in, 1);

% Slide the window, getting indices for all subsequences in all time series
% SAX representations
for left = 2:rightmost
    % This will return a list of indices; each index is found in a given
    % time series
%     saxsubstrings = sax(:, left:left + windowrightshift) 
    indices = getindices(sax(:, left:left + windowrightshift));
    
    % For each index of each time series we need to increment their counter
    % individually
    for i = 1:numts
        idx = indices(i);
        out(i, idx) = out(i, idx) + 1;
    end
    
%     out
end
end



function idx = getindices(seq)
% GETINDEX Return the index of a sequence in a bitmap time series
%   Find the indices [row, columnn] of a sequence in a bitmap time series
%   of appropriate level. For level 1, this bitmap would be
%
%     1 2
%     3 4
%
%   For level 2, this map would be
%
%     11  12   21  22
%     13  14   23  24
%
%     31  32   41  42
%     33  34   43  44
%
%   This matrix, in the for of a vector, would be as follows
%
%     11 12 21 22 13 14 23 24 31 32 41 42 33 34 43 44    (values)
%      1  2  3  4  5  6  7  8  9  0  1  2  3  4  5  6    (indices)
%
%  So, for instance, the index of 23 would be 7, and the index of 34 would
%  be 14.

% Guess level from number of symbols in the sequence
level = size(seq, 2);

% Initial row/column values
row = ones(size(seq, 1), 1);
col = ones(size(seq, 1), 1);

% Move row/column to correct position according to the appropriate level
for l = 1:level
    % Get the top-level row/column indices (up-left, up-right, bottom-left,
    % or bottom-right)
    rrow = ceil(seq(:,l) / 2) - 1;
    rcol = 1 - mod(seq(:,l), 2);
    
    % Shift the row/column indices according to the current level. The
    % higher our current level is, the more elements we have to shift in
    % order to reach our true position in the matrix
    row = row + rrow * 2^(level - l);
    col = col + rcol * 2^(level - l);
end

% Get the linear index, which is (row - 1) x width + column. The width of
% the matrix is 2^level
idx = (row - 1) * (2^level) + col;
end