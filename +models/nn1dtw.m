function [neighbor, distance, label, hit] = nn1dtw(stack, needle, windowlength_or_optsobj)
%MODELS.NN1DTW    Run the 1-Nearest Neighbor classification model for a
%single instance on a data set using the UCR Suite for 1-NNDTW. Has similar
%behavior to MODELS.NN with @DISTS.DTW_Cpp, but much faster. 
%   NN1DTW(DS,S), where DS is an n-by-m matrix of double representing a
%   data set (in format according to TS.LOAD and TS.SAVE) and S is a 1-by-m
%   column vector of double representing a single instance, returns the
%   index of the nearest neighbor of S in DS. A Sakoe-Chiba window with
%   width ajusted to 10% of the series length will be used.
%
%   Because of the way LB_Kim is used to prune unpromising neighbor
%   candidates, this classifier requires that the length of the series be
%   at least 6 observations long. For smaller series, please use MODELS.NN
%   with DISTS.DTW_Cpp.
%
%   NN1DTW(DS,S,w), where "w" is a double scalar, does the same as
%   explained above, however a Sakoe-Chiba window with widh "w" will be
%   used instead.
%   
%   NN1DTW(DS,S,options), where "options" is an OPTS object, does the same
%   as the previous calls, however options are taken from the OPTS object
%   "option".
%
%   [N,P] = NN1DTW(DS,S,...) returns the index of the nearest neighbor and
%   the distance from the test sample to the nearest neighbor.
%
%   [N,P,C] = NN1DTWDS,S,...) returns the same as above, and also a label
%   for the class of the nearest neighbor.
%
%   [N,P,C,H] = NN1DTW(DS,S, ...) returns the same as above, and also a
%   flag indicating if the nearest neighbor belongs to the same class as
%   the test sample (1 or 0).
%
%   Disclaimer: the UCR Suite is copyrighted by its authors. The usage
%   terms for the UCR Suite are transcribed into the MODELS.NN1DTW source
%   code. Please review those terms before using this function.

%%%%%%%%%%%%%%%%
% Copyright notice:
% This file is part of TimeBox
% TimeBox is copyrighted 2016 by Rafael Giusti (rfgiusti@gmail.com)
%%%%%%%%%%%%%%%%
% This function uses the UCR Suite
% The UCR Suite is copyrighted 2012 by Thanawin Rakthanmanon, Bilson
% Campana, Abdullah Mueen, Gustavo Batista, and Eamonn Keogh
%
% If you use this function or the UCR Suite, you are asked to reference
% this paper in your paper: Thanawin Rakthanmanon, Bilson Campana, Abdullah
% Mueen, Gustavo Batista, Brandon Westover, Qiang Zhu, Jesin Zakaria,
% Eamonn Keogh (2012). Searching and Mining Trillions of Time Series
% Subsequences under Dynamic Time Warping; SIGKDD 2012.
%
% Please visit http://www.cs.ucr.edu/~eamonn/UCRsuite.html for more
% information
%%%%%%%%%%%%%%%%

%   This file is part of TimeBox. Copyright 2015-16 Rafael Giusti
%   Revision 1.0

serieslen = size(stack, 2) - 1;
tb.assert(serieslen >= 5, ['Series of length 5 or longer are required for MODELS.NN1DTW. For short series, please' ...
    'use MODELS.NN with DISTS.DTW_Cpp']);

window = [];
if exist('windowlength_or_optsobj', 'var')
    if opts.isa(windowlength_or_optsobj)
        options = windowlength_or_optsobj;
        window = opts.get(options, 'dists::arg', []);
    else
        window = windowlength_or_optsobj;
        options = opts.empty;
        tb.assert(numel(window) == 1 && isnumeric(window), ['If supplied, third argument must be either an OPTS ' ...
            'object or a numeric value']);
    end
else
    options = opts.empty;
end
if isempty(window)
    window = round(0.10 * serieslen);
end

epsilon = opts.get(options, 'epsilon', 1e-10);

if numel(needle) == 1
    skipindex = needle;
    needle = stack(needle, :);
else
    skipindex = -1;
end

[neighbor, distance] = models.nn1dtw_mex(stack(:, 2:end)', needle(2:end), skipindex, window);
label = stack(neighbor, 1);
hit = abs(label - needle(1)) < epsilon;
end
