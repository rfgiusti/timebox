function [traind, testd] = dct(train, test, ~)
%TRANSFORM.DCT Discrete Cosine Transform of data sets.
%   DCT(DS) returns the Discrete Cosine Transform of the data set DS. The
%   transform is calculated from the Matlab function DCT.
%
%   [TRAIND,TESTD] = DCT(TRAIN,TEST) returns the DCT transform of both the
%   training and the test data sets.
traind = dctpart(train);
if exist('test', 'var')
    testd = dctpart(test);
end
end


function out = dctpart(in)
out = zeros(size(in));
out(:, 1) = in(:, 1);
out(:, 2:end) = dct(in(:, 2:end)')';
end